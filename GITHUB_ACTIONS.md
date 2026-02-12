# GitHub Actions iOS Build Workflow

This repository includes an automated GitHub Actions workflow that builds an unsigned IPA file for iOS with all the fixes and enhancements.

## What the Workflow Does

The workflow (`.github/workflows/build-ios.yml`) automatically:

1. **Sets up the build environment**
   - Uses macOS runner (required for iOS builds)
   - Installs Flutter stable channel (version 3.24.5)
   - Caches Flutter SDK for faster subsequent builds

2. **Cleans and prepares**
   - Runs `flutter clean` to remove any stale build artifacts
   - This ensures a fresh build every time
   - Gets all Flutter dependencies including local path packages

3. **Verifies configuration**
   - Checks that local Dart dependencies exist (dartcarwings-master, dartnissanconnect-master, dartnissanconnectna-master)
   - Verifies the iOS entitlements file is present
   - Displays configuration for debugging

4. **Builds the iOS app**
   - Runs `flutter build ios --release --no-codesign`
   - Includes all fixes: enhanced error logging, hardcoded User-Agent-Key, null safety checks
   - Includes iOS entitlements for network and keychain access
   - Bundles with fixed bundle identifier: `com.zqidev.myleaf`

5. **Creates the IPA package**
   - Packages the built app into a standard IPA format
   - Creates `MyLeaf-unsigned.ipa`
   - Verifies the package was created successfully

6. **Uploads the artifact**
   - Saves the IPA as a GitHub Actions artifact
   - Artifact name: `MyLeaf-iOS-unsigned-{run_number}`
   - Retained for 30 days
   - Can be downloaded from the Actions tab

## When Does It Run?

The workflow triggers automatically on:
- **Push to master/main branch** - Every commit triggers a build
- **Pull requests to master/main** - PRs get built automatically
- **Manual trigger** - You can run it manually from the Actions tab

## How to Use

### Automatic Builds

Simply push to the main/master branch and the workflow will run automatically.

### Manual Trigger

1. Go to the **Actions** tab on GitHub
2. Select **Build iOS IPA** workflow
3. Click **Run workflow**
4. Select the branch you want to build
5. Click the green **Run workflow** button

### Downloading the IPA

1. Go to the **Actions** tab
2. Click on the workflow run you want
3. Scroll down to **Artifacts** section
4. Click on the artifact name to download (e.g., `MyLeaf-iOS-unsigned-123`)

## What's Included in the Build

✅ **All authentication fixes**
- Enhanced error logging for NA and EU regions
- Hardcoded User-Agent-Key (no external dependencies)
- Null safety checks to prevent crashes

✅ **iOS Configuration**
- Entitlements file for network and keychain access
- Fixed bundle identifier
- Proper Xcode project settings

✅ **Local Dependencies**
- Uses local copies of dartcarwings, dartnissanconnect, dartnissanconnectna
- No external git dependencies during build

✅ **UI Improvements**
- Improved debug logging with scrollable text field
- Easy copy/paste functionality

## Installing the IPA

The IPA produced by this workflow is **unsigned**. To install it on your device:

### Option 1: Xcode
1. Download the IPA
2. Open Xcode
3. Go to Window → Devices and Simulators
4. Select your device
5. Drag and drop the IPA (requires paid Apple Developer account)

### Option 2: iOS App Signer
1. Download the IPA
2. Use [iOS App Signer](https://dantheman827.github.io/ios-app-signer/)
3. Select your signing certificate
4. Sign the IPA
5. Install via Xcode or other tools

### Option 3: AltStore / Sideloadly
1. Download the IPA
2. Use [AltStore](https://altstore.io/) or [Sideloadly](https://sideloadly.io/)
3. Sign with your Apple ID (free account works)
4. Install directly to your device

### Option 4: fastlane
If you have fastlane configured:
```bash
fastlane sigh resign MyLeaf-unsigned.ipa --signing_identity "Your Identity" --provisioning_profile "Your Profile"
```

## Customizing the Bundle ID

If you need to change the bundle identifier for your signing certificate:

1. Edit `ios/Runner/Info.plist` - line 12
2. Edit `ios/Runner/Runner.entitlements` - line 12
3. Edit `ios/Runner.xcodeproj/project.pbxproj` - search for `PRODUCT_BUNDLE_IDENTIFIER`

Make sure all three locations match your provisioning profile's app ID.

## Troubleshooting

### Build fails with "Flutter version not found"
- The workflow uses Flutter 3.24.5 stable
- You can change this in `.github/workflows/build-ios.yml` line 22

### Build fails with "pub get failed"
- Check that local dependencies exist in the repository
- Ensure `dartcarwings-master`, `dartnissanconnect-master`, `dartnissanconnectna-master` folders are present

### IPA won't install on device
- The IPA is unsigned - you must sign it with your own certificate
- See "Installing the IPA" section above for signing options

### Entitlements not working
- The entitlements are embedded during build
- Check the workflow logs for "Checking entitlements file" step
- Verify `ios/Runner/Runner.entitlements` exists and is valid

## What Does `flutter clean` Do?

`flutter clean` removes all build artifacts and cached files:
- Deletes `build/` directory
- Clears Flutter's internal cache
- Forces a fresh rebuild from scratch

This ensures:
- No stale artifacts from previous builds
- Consistent builds across different environments
- Fixes issues caused by corrupted cache

It's especially important in CI/CD to ensure reproducible builds.

## Viewing Build Details

Each build generates a detailed summary showing:
- Bundle ID and version
- Build number
- Features included
- Installation instructions

To view:
1. Go to Actions tab
2. Click on a workflow run
3. The summary appears at the top of the page

## Advanced: Adding Signing to Workflow

If you want to add automatic signing to the workflow, you would need to:

1. Add secrets to your repository:
   - `IOS_CERTIFICATE_BASE64` - Your .p12 certificate
   - `IOS_CERTIFICATE_PASSWORD` - Password for the certificate
   - `IOS_PROVISIONING_PROFILE_BASE64` - Your provisioning profile

2. Add signing steps before creating IPA:
   ```yaml
   - name: Import signing certificate
     env:
       CERTIFICATE_BASE64: ${{ secrets.IOS_CERTIFICATE_BASE64 }}
       CERTIFICATE_PASSWORD: ${{ secrets.IOS_CERTIFICATE_PASSWORD }}
     run: |
       # Decode and import certificate
       echo $CERTIFICATE_BASE64 | base64 --decode > certificate.p12
       security create-keychain -p "" build.keychain
       security import certificate.p12 -k build.keychain -P $CERTIFICATE_PASSWORD
       # ... etc
   ```

However, this is not included by default since most users will sign locally with their own certificates.

## Support

For issues with:
- **The workflow itself**: Check this documentation and workflow logs
- **The app functionality**: See `CHANGES.md` for feature details
- **Authentication issues**: Enable debug logs in the app and check the debug log viewer

## Build Status

You can add a build status badge to your README:

```markdown
![Build iOS IPA](https://github.com/zqidev/carwingsflutter_iosbuild/actions/workflows/build-ios.yml/badge.svg)
```

This shows whether the latest build passed or failed.
