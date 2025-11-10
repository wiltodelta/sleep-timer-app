# Code Signing Setup

## Creating a Self-Signed Certificate

To avoid the "damaged app" warning when opening the app, you can create a self-signed code signing certificate.

### Steps:

1. Open **Keychain Access** application (Applications → Utilities → Keychain Access)

2. From the menu bar: **Keychain Access → Certificate Assistant → Create a Certificate...**

3. Fill in the certificate details:
   - **Name:** Your name (e.g., "John Doe" or "My Company")
   - **Identity Type:** Self-Signed Root
   - **Certificate Type:** Code Signing

4. Check the box: **"Let me override defaults"**

5. Click **Continue** through the following screens:
   - Certificate Information → **Continue**
   - Serial Number (leave default) → **Continue**
   - Validity Period: Enter **3650** (10 years) → **Continue**

6. Continue with defaults until the end:
   - Email, Name → **Continue**
   - Key Pair Information → **Continue**
   - Key Usage Extension → **Continue**
   - Extended Key Usage Extension → **Continue**
   - Basic Constraints Extension → **Continue**
   - Subject Alternate Name Extension → **Continue**

7. **Important:** Make sure the certificate is saved to the **"login"** keychain

8. Click **Create** and then **Done**

### Using the Certificate

After creating the certificate, you can sign the app manually:

```bash
codesign --force --sign "Your Certificate Name" --deep "Sleep Timer.app"
```

Or update `create-app.sh` to use your certificate name:

```bash
# Change this line in create-app.sh:
CERT_NAME="Your Certificate Name"
```

### Note

Currently, `create-app.sh` automatically removes the quarantine attribute using `xattr -cr`, which works without a certificate. Code signing is optional but provides better security and trust.

### Alternative: Notarization

For production apps, consider:
1. Join the Apple Developer Program ($99/year)
2. Use a Developer ID certificate
3. Notarize the app with Apple
4. Users won't see any warnings

---

For development purposes, the current `xattr -cr` approach is sufficient.

