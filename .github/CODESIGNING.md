# macOS Code Signing and Notarization Setup

This document explains how to set up code signing and notarization for macOS builds in GitHub Actions.

## Overview

The GitHub Actions workflow automatically signs and notarizes the macOS build using Godot's built-in support for macOS code signing. This is configured through environment variables that override the export preset settings.

## Prerequisites

Before setting up GitHub secrets, you need:

1. **Apple Developer Account** - Enrolled in the Apple Developer Program ($99/year)
2. **Developer ID Application Certificate** - For distributing outside the Mac App Store
3. **App Store Connect API Key** - For automated notarization

## Step 1: Export Your Developer Certificate

### On macOS:

1. Open **Keychain Access**
2. Find your "Developer ID Application" certificate
3. Right-click the certificate and select "Export"
4. Save as `.p12` file with a strong password
5. Convert to PEM format (optional, but Godot can use .p12 directly):
   ```bash
   # Extract certificate
   openssl pkcs12 -in certificate.p12 -clcerts -nokeys -out certificate.pem

   # Extract private key
   openssl pkcs12 -in certificate.p12 -nocerts -nodes -out private_key.pem

   # Combine into single PEM file
   cat certificate.pem private_key.pem > combined.pem
   ```

## Step 2: Create App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to **Users and Access** → **Keys** → **App Store Connect API**
3. Click the **+** button to create a new key
4. Give it a name (e.g., "CI/CD Notarization")
5. Set role to **Developer** or **App Manager**
6. Download the `.p8` key file (you can only download it once!)
7. Note the **Key ID** and **Issuer ID** (UUID format)

## Step 3: Set Up GitHub Secrets

Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions**, then add these secrets:

### Required Secrets:

| Secret Name | Description | Value |
|-------------|-------------|-------|
| `MACOS_CERTIFICATE_FILE` | Your Developer ID certificate | Base64-encoded .p12 or PEM file |
| `MACOS_CERTIFICATE_PASSWORD` | Certificate password | The password you set when exporting |
| `MACOS_NOTARIZATION_API_UUID` | App Store Connect Issuer ID | UUID from App Store Connect |
| `MACOS_NOTARIZATION_API_KEY` | App Store Connect API Key | Base64-encoded .p8 key file |
| `MACOS_NOTARIZATION_API_KEY_ID` | App Store Connect Key ID | Key ID from App Store Connect |

### Optional (if not using provisioning profile):

| Secret Name | Description |
|-------------|-------------|
| `MACOS_PROVISIONING_PROFILE` | Provisioning profile (if needed) |

### Encoding Files as Base64:

Since certificate files (.p12, .cer) and API key files (.p8) are binary files, they must be base64-encoded before storing as GitHub Secrets. The workflow will automatically decode them back to binary files during the build.

```bash
# Encode certificate file (.p12 or .cer)
base64 -i certificate.p12 | pbcopy
# OR
base64 -i certificate.cer | pbcopy

# Encode API key file (.p8)
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy
```

The base64 string will be in your clipboard, ready to paste into GitHub secrets.

**Important:** Make sure to encode the entire file as-is, including any line breaks or formatting. The workflow step "Setup macOS certificate" will decode these base64 strings back into binary files and write them to temporary paths that Godot can use during export.

## Step 4: Update Export Preset (Already Configured)

The `export_presets.cfg` file is already configured with:
- `codesign/codesign=2` (Xcode codesign tool)
- `notarization/notarization=1` (Xcode notarytool)

These settings work with the environment variables set in the GitHub Actions workflow.

## Step 5: Configure Identity in Export Preset

You need to set the code signing identity in your `export_presets.cfg`:

1. Open Godot Editor
2. Go to **Project** → **Export**
3. Select the **macOS** preset
4. Under **Code Signing** → **Identity**, enter your certificate's Common Name:
   - Usually looks like: `Developer ID Application: Your Name (TEAM_ID)`
   - Or just the Team ID: `TEAM_ID`
5. Under **Code Signing** → **Apple Team ID**, enter your Team ID
6. Save the preset

## Alternative: Apple ID Authentication

Instead of using App Store Connect API keys, you can use Apple ID authentication:

1. Generate an app-specific password at [appleid.apple.com](https://appleid.apple.com/)
2. In GitHub secrets, use these instead:
   - `MACOS_NOTARIZATION_APPLE_ID_NAME` - Your Apple ID email
   - `MACOS_NOTARIZATION_APPLE_ID_PASSWORD` - App-specific password
3. Update the workflow to use these environment variables (commented out by default)

## How the Workflow Processes Certificates

The GitHub Actions workflow handles certificate files in these steps:

1. **Setup macOS certificate step** (lines 28-41 in build-game.yml):
   - Decodes base64-encoded certificate from `MACOS_CERTIFICATE_FILE` secret
   - Writes decoded binary certificate to `$RUNNER_TEMP/macos_certificate.p12`
   - Decodes base64-encoded API key from `MACOS_NOTARIZATION_API_KEY` secret
   - Writes decoded binary API key to `$RUNNER_TEMP/AuthKey.p8`
   - Sets environment variables `MACOS_CERTIFICATE_PATH` and `MACOS_API_KEY_PATH` with file paths

2. **Export game step** (lines 43-64 in build-game.yml):
   - Sets `GODOT_MACOS_CODESIGN_CERTIFICATE_FILE` to the certificate file path
   - Sets `GODOT_MACOS_NOTARIZATION_API_KEY` to the API key file path
   - Godot reads these environment variables and uses the file paths to access the certificates
   - Godot performs signing and notarization using these credentials

**Note:** The environment variables expect **file paths**, not file contents. This is why we write the decoded certificates to temporary files first.

## Testing the Workflow

1. Make sure all secrets are properly set
2. Push a commit or tag to trigger the workflow
3. Check the Actions tab to monitor the build
4. The macOS build will be signed and notarized automatically

## Troubleshooting

### Common Issues:

**"No identity found"**
- Make sure `codesign/identity` is set in export_presets.cfg
- Verify the certificate Common Name matches

**"Notarization failed"**
- Check that API Key has correct permissions
- Verify Team ID is set in export preset
- Ensure the app is properly signed first

**"Certificate password incorrect"**
- Verify the password in GitHub secrets matches
- Try re-exporting the certificate

**"API Key invalid"**
- Ensure the .p8 file is correctly base64-encoded
- Verify the Key ID and Issuer ID are correct
- Check that the API key hasn't been revoked

## Security Notes

- Never commit certificates or keys to your repository
- Use GitHub Secrets for all sensitive data
- Rotate API keys periodically
- Use App Store Connect API keys instead of Apple ID when possible
- Consider using separate keys for CI/CD vs. other purposes

## Additional Resources

- [Apple Code Signing Guide](https://developer.apple.com/support/code-signing/)
- [Godot macOS Export Documentation](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_macos.html)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Notarization Documentation](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
