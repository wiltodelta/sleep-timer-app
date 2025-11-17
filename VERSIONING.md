# Version Management

## How to Release a New Version

The app version is **automatically derived from git tags**. No need to edit any files!

### Steps to Release:

1. **Commit your changes:**
   ```bash
   git add .
   git commit -m "Add new features"
   git push origin main
   ```

2. **Create a git tag:**
   ```bash
   git tag -a v1.2.0 -m "Release v1.2.0

   New features:
   - Feature 1
   - Feature 2
   
   Bug fixes:
   - Fix 1"
   ```

3. **Push the tag:**
   ```bash
   git push origin v1.2.0
   ```

4. **Build the app:**
   ```bash
   ./create-app.sh
   ```
   
   The script will automatically:
   - Extract version from git tag (`v1.2.0` → `1.2.0`)
   - Generate `Info.plist` with correct version
   - Build the app bundle

5. **Create GitHub Release:**
   - Go to: https://github.com/wiltodelta/sleep-timer-app/releases/new
   - Select tag: `v1.2.0`
   - Upload `Sleep Timer.app` (zipped)
   - Add release notes (can copy from tag message)

## How Auto-Update Works

- `create-app.sh` extracts version from latest git tag
- Injects version into `Info.plist` during build
- `UpdateChecker.swift` reads version from `Bundle.main.infoDictionary["CFBundleShortVersionString"]`
- Checks GitHub Releases API for latest version
- Compares using semantic versioning

## Benefits

✅ **Single source of truth**: Version is defined only by git tag  
✅ **No file changes**: No need to commit version updates  
✅ **Automatic**: Version is injected during build  
✅ **Git-flow compatible**: Follows standard git workflow

## Version Format

Use semantic versioning: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes
- **MINOR**: New features (backwards compatible)
- **PATCH**: Bug fixes

Examples:
- `1.1.2` → `1.1.3` (bug fix)
- `1.1.2` → `1.2.0` (new feature)
- `1.1.2` → `2.0.0` (breaking change)

