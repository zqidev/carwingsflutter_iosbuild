# My Leaf

![Build iOS IPA](https://github.com/zqidev/carwingsflutter_iosbuild/actions/workflows/build-ios.yml/badge.svg)

A NissanConnect app alternative written using Flutter.

My Leaf is a simple, striving to be great looking, and fast alternative to the official NissanConnect app(s) from Nissan.

You can ask your vehicle for the latest data, see current battery and charging statuses, see the current climate control state, start or stop climate control remotely, remotely start charging, scheduling climate control and charging, lastly retrieve the last known location of your vehicle.

My Leaf is free 🎉 and open source ✌️ It takes effort to continually maintain and improve! Therefore donations are more than welcome! 😎 You can do it directly in-app!

My Leaf uses [dartcarwings](https://gitlab.com/tobiaswkjeldsen/dartcarwings), [dartnissanconnectna](https://gitlab.com/tobiaswkjeldsen/dartnissanconnectna) and [dartnissanconnect](https://gitlab.com/tobiaswkjeldsen/dartnissanconnect) for communicating with Nissan's NissanConnect API's.

My Leaf is available on [Google Play](https://play.google.com/store/apps/details?id=dk.kjeldsen.carwingsflutter), [App Store](https://itunes.apple.com/us/app/my-leaf-for-nissan-ev/id1436701776) and [F-Droid](https://f-droid.org/en/packages/dk.kjeldsen.carwingsflutter/).

Join the testing and feedback community at the [My Leaf group on Google Groups](https://groups.google.com/forum/#!forum/my-leaf).

## Automated iOS Builds

This repository includes automated GitHub Actions workflows that build unsigned IPA files for iOS. Every push to main/master triggers an automatic build that includes all the latest fixes and enhancements.

**Features included in automated builds:**
- ✅ Enhanced authentication error logging for NA and EU regions
- ✅ Hardcoded User-Agent-Key (no external API dependencies)
- ✅ iOS entitlements for network and keychain access
- ✅ Improved debug logging UI
- ✅ Local path dependencies for faster builds

**To download a build:**
1. Go to the [Actions tab](https://github.com/zqidev/carwingsflutter_iosbuild/actions)
2. Select a successful workflow run
3. Download the IPA artifact from the Artifacts section

**Note:** The IPA is unsigned and must be signed with your own certificate before installation. See [GITHUB_ACTIONS.md](GITHUB_ACTIONS.md) for detailed instructions on signing and installation options.

For complete documentation on the build process, see [GITHUB_ACTIONS.md](GITHUB_ACTIONS.md).
For details on recent fixes and improvements, see [CHANGES.md](CHANGES.md).
