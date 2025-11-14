import Foundation
import AVFoundation
import Vision

final class SleepDetectionManager: NSObject, ObservableObject {
    static let shared = SleepDetectionManager()

    @Published var isCameraModeEnabled: Bool = false
    @Published var isCameraAuthorized: Bool = false
    @Published var isSessionRunning: Bool = false
    @Published var isUserAsleep: Bool = false
    @Published var statusMessage: String = "Camera tracking is off."

    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "SleepDetectionManager.SessionQueue")
    private var isSessionConfigured = false

    private let videoOutput = AVCaptureVideoDataOutput()
    private let videoOutputQueue = DispatchQueue(label: "SleepDetectionManager.VideoOutput", qos: .userInitiated)

    private let sequenceHandler = VNSequenceRequestHandler()

    // Sliding window parameters
    private let windowSize = 50 // Number of frames to consider (~5 seconds at 10 fps)
    private let sleepThresholdPercent = 0.8 // 80% of frames must be closed
    private let wakeThresholdPercent = 0.3 // 30% or less closed frames means awake

    // EAR thresholds with hysteresis to prevent flicker
    private let earClosedThreshold = 0.21 // Below this = eyes closing
    private let earOpenThreshold = 0.25   // Above this = eyes opening

    // Frame smoothing to reduce flicker
    private let maxMissedFrames = 10 // ~1 second tolerance for face detection loss
    private var missedFramesCount = 0

    // Sliding window buffer: true = eyes closed, false = eyes open
    private var eyeStateWindow: [Bool] = []

    // Current eye state for hysteresis
    private var currentEyeState: Bool = false // false = open, true = closed

    private override init() {
        super.init()
    }

    func setCameraModeEnabled(_ enabled: Bool) {
        self.isCameraModeEnabled = enabled

        if enabled {
            requestAuthorizationAndStart()
        } else {
            stopSession()
            resetDetectionState()
            DispatchQueue.main.async {
                self.statusMessage = "Camera tracking is off."
            }
        }
    }

    private func requestAuthorizationAndStart() {
        let currentStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch currentStatus {
        case .authorized:
            DispatchQueue.main.async {
                self.isCameraAuthorized = true
            }
            startSessionIfNeeded()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    self.isCameraAuthorized = granted
                }
                if granted {
                    self.startSessionIfNeeded()
                } else {
                    DispatchQueue.main.async {
                        self.statusMessage = "Camera access was denied."
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.isCameraAuthorized = false
                self.statusMessage = "Camera access is not authorized. Please enable it in System Settings."
            }
        @unknown default:
            DispatchQueue.main.async {
                self.isCameraAuthorized = false
                self.statusMessage = "Camera access is not available."
            }
        }
    }

    private func startSessionIfNeeded() {
        sessionQueue.async {
            if self.session.isRunning {
                return
            }

            self.configureSessionIfNeeded()

            guard self.isSessionConfigured else {
                DispatchQueue.main.async {
                    self.statusMessage = "Failed to configure camera session."
                }
                return
            }

            self.session.startRunning()

            DispatchQueue.main.async {
                self.isSessionRunning = true
                self.statusMessage = "Looking for your face..."
            }
        }
    }

    private func configureSessionIfNeeded() {
        if isSessionConfigured {
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .low

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            ?? AVCaptureDevice.default(for: .video) else {
            session.commitConfiguration()
            return
        }

        // Configure device for better performance
        do {
            try device.lockForConfiguration()

            // Set frame rate to 10 fps for efficiency (matches our window size calculation)
            if let range = device.activeFormat.videoSupportedFrameRateRanges.first {
                let targetFrameRate = CMTime(value: 1, timescale: 10) // 10 fps
                if range.minFrameDuration <= targetFrameRate && targetFrameRate <= range.maxFrameDuration {
                    device.activeVideoMinFrameDuration = targetFrameRate
                    device.activeVideoMaxFrameDuration = targetFrameRate
                }
            }

            device.unlockForConfiguration()
        } catch {
            // Continue with default settings if configuration fails
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            session.commitConfiguration()
            return
        }

        videoOutput.setSampleBufferDelegate(self, queue: videoOutputQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true

        // Set video settings for better performance
        videoOutput.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        ]

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }

        isSessionConfigured = true
        session.commitConfiguration()
    }

    private func stopSession() {
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }

            DispatchQueue.main.async {
                self.isSessionRunning = false
            }
        }
    }

    private func resetDetectionState() {
        eyeStateWindow.removeAll()
        missedFramesCount = 0
        currentEyeState = false
        DispatchQueue.main.async {
            self.isUserAsleep = false
        }
    }

    private func handleEyeState(closed: Bool) {
        // Add current frame state to sliding window
        eyeStateWindow.append(closed)

        // Keep window size limited
        if eyeStateWindow.count > windowSize {
            eyeStateWindow.removeFirst()
        }

        // Need enough frames before making decisions
        guard eyeStateWindow.count >= windowSize else {
            return
        }

        // Calculate percentage of closed frames in the window
        let closedFramesCount = eyeStateWindow.filter { $0 }.count
        let closedPercentage = Double(closedFramesCount) / Double(eyeStateWindow.count)

            // Check for sleep condition (high percentage of closed frames)
            if !isUserAsleep && closedPercentage >= sleepThresholdPercent {
                DispatchQueue.main.async {
                    self.isUserAsleep = true
                    self.statusMessage = "Eyes appear closed. Starting 30-minute sleep timer."
                    if !TimerManager.shared.isTimerActive {
                        TimerManager.shared.startTimer(hours: 0.5)
                    }
                    // Notify status bar to update icon
                    NotificationCenter.default.post(name: NSNotification.Name("CameraModeChanged"), object: nil)
                }
            }

            // Check for wake condition (low percentage of closed frames)
            if isUserAsleep && closedPercentage <= wakeThresholdPercent {
                DispatchQueue.main.async {
                    self.isUserAsleep = false
                    self.statusMessage = "Eyes appear open. Cancelling sleep timer and resuming tracking."
                    if TimerManager.shared.isTimerActive {
                        TimerManager.shared.stopTimer()
                    }
                    // Notify status bar to update icon
                    NotificationCenter.default.post(name: NSNotification.Name("CameraModeChanged"), object: nil)
                }
            }
    }

    private func process(sampleBuffer: CMSampleBuffer) {
        guard isCameraModeEnabled else {
            return
        }

        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }

        // Create request with optimized settings
        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let self else { return }

            if error != nil {
                DispatchQueue.main.async {
                    self.statusMessage = "Can't analyze video right now."
                }
                return
            }

            guard let observations = request.results as? [VNFaceObservation],
                let face = observations.first,
                let leftEye = face.landmarks?.leftEye,
                let rightEye = face.landmarks?.rightEye else {
                // No face or eyes detected; increment missed frames counter
                self.missedFramesCount += 1

                // Only reset window if we've missed enough consecutive frames
                if self.missedFramesCount >= self.maxMissedFrames {
                    self.eyeStateWindow.removeAll()
                    self.currentEyeState = false
                    DispatchQueue.main.async {
                        if self.isSessionRunning {
                            self.statusMessage = "Looking for your face..."
                        }
                    }
                }
                return
            }

            // Face and eyes found; reset missed frames counter
            self.missedFramesCount = 0

            let leftRatio = Self.eyeAspectRatio(for: leftEye)
            let rightRatio = Self.eyeAspectRatio(for: rightEye)

            let averageRatio = (leftRatio + rightRatio) / 2.0

            // Apply hysteresis to prevent flicker
            // If currently open, need to drop below closed threshold to change state
            // If currently closed, need to rise above open threshold to change state
            let isClosed: Bool
            if self.currentEyeState {
                // Currently closed: only open if EAR rises above open threshold
                isClosed = averageRatio < self.earOpenThreshold
            } else {
                // Currently open: only close if EAR drops below closed threshold
                isClosed = averageRatio < self.earClosedThreshold
            }

            self.currentEyeState = isClosed
            self.handleEyeState(closed: isClosed)

            // Update status message with eye state and window stats
            DispatchQueue.main.async {
                let eyeStatus = isClosed ? "Eyes closed" : "Eyes open"

                // Calculate percentage if we have enough frames
                if !self.eyeStateWindow.isEmpty {
                    let closedCount = self.eyeStateWindow.filter { $0 }.count
                    let percentage = Int((Double(closedCount) / Double(self.eyeStateWindow.count)) * 100)

                    // Estimate time window (assuming ~10 fps)
                    let timeWindow = self.eyeStateWindow.count / 10
                    self.statusMessage = "\(eyeStatus) (\(percentage)% closed, last \(timeWindow) sec)"
                } else {
                    self.statusMessage = eyeStatus
                }
            }
        }

        // Use revision 3 for best accuracy (available since macOS 14)
        if #available(macOS 14.0, *) {
            request.revision = VNDetectFaceLandmarksRequestRevision3
        }
        
        do {
            // Perform with orientation for better accuracy
            let orientation = CGImagePropertyOrientation.up
            try sequenceHandler.perform([request], on: pixelBuffer, orientation: orientation)
        } catch {
            DispatchQueue.main.async {
                self.statusMessage = "Can't analyze video right now."
            }
        }
    }

    private static func eyeAspectRatio(for region: VNFaceLandmarkRegion2D) -> Double {
        let points = region.normalizedPoints

        // Need at least 6 points for proper EAR calculation
        guard points.count >= 6 else {
            return 0.0
        }

        // Classic EAR formula uses 6 key points on the eye contour:
        // EAR = (||p2 - p6|| + ||p3 - p5||) / (2 * ||p1 - p4||)
        //
        // For Vision's eye landmarks, we approximate by finding:
        // - Horizontal extremes (leftmost and rightmost)
        // - Vertical points along the top and bottom of the eye

        // Helper function to calculate Euclidean distance
        func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
            let dx = a.x - b.x
            let dy = a.y - b.y
            return sqrt(dx * dx + dy * dy)
        }

        // Find horizontal extremes (corners of the eye)
        let leftmost = points.min(by: { $0.x < $1.x }) ?? points[0]
        let rightmost = points.max(by: { $0.x < $1.x }) ?? points[0]

        // Sort points by Y coordinate to find top and bottom
        let sortedByY = points.sorted(by: { $0.y < $1.y })

        // Select points for vertical measurements
        // Bottom points (lower Y values in Vision's coordinate system)
        let bottomThird = sortedByY.prefix(sortedByY.count / 3)
        let p2 = bottomThird.dropFirst(bottomThird.count / 3).first ?? sortedByY[0]
        let p6 = bottomThird.dropFirst(2 * bottomThird.count / 3).first ?? sortedByY[0]

        // Top points (higher Y values)
        let topThird = sortedByY.suffix(sortedByY.count / 3)
        let p3 = topThird.dropFirst(topThird.count / 3).first ?? sortedByY[sortedByY.count - 1]
        let p5 = topThird.dropFirst(2 * topThird.count / 3).first ?? sortedByY[sortedByY.count - 1]

        // Calculate distances
        let verticalDist1 = distance(p2, p6)
        let verticalDist2 = distance(p3, p5)
        let horizontalDist = distance(leftmost, rightmost)

        guard horizontalDist > 0 else {
            return 0.0
        }

        // Classic EAR formula
        let ear = (verticalDist1 + verticalDist2) / (2.0 * horizontalDist)

        return Double(ear)
    }
}

extension SleepDetectionManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        process(sampleBuffer: sampleBuffer)
    }
}
