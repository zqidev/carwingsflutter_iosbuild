# Implementation Notes for Authentication Fixes

## Summary of Changes Made

### ✅ Completed in This Repository

1. **Debug Page UI Improvements** - Fixed all 3 debug pages (carwings, nissanconnect, nissanconnectna):
   - Fixed typo in `nissanconnect/debug_page.dart` (was using wrong session variable)
   - Replaced individual log bubble ListView with unified SelectableText view
   - Uses system default font for maximum compatibility
   - All logs now display in a single scrollable, copyable text block
   - Copy All button still works as before

2. **iOS Entitlements Configuration**:
   - Created `ios/Runner/Runner.entitlements` with required capabilities
   - App sandbox enabled for security
   - Network client access for API calls
   - App Groups (`group.com.zqidev.myleaf`) for data persistence
   - Keychain access (`$(AppIdentifierPrefix)com.zqidev.myleaf`) for secure storage
   - Updated Xcode project file to reference entitlements in both Debug and Release configurations
   - Settings should now persist between app restarts on iOS

3. **User-Agent-Key Already Hardcoded**:
   - The User-Agent-Key `5AFC98CCD7E2AF32FD7C59916AABD` is already hardcoded in `lib/session.dart` (line 13)
   - This value is passed to `nissanConnectNa.login()` calls
   - This prevents the need for dynamic fetching in the app layer

### ⚠️ External Dependencies That Need Manual Intervention

The following changes **cannot be automated** because they require modifying external GitLab repositories:

#### 1. dartnissanconnectna Library Fix

**Location:** `https://gitlab.com/tobiaswkjeldsen/dartnissanconnectna.git`  
**File:** `lib/src/nissanconnect_session.dart`  
**Method:** In the login or initialization method where userAgentKey is set

**Current Code:**
```dart
var userAgentKey = await http.get(Uri.parse(
    'https://gitlab.com/tobiaswkjeldsen/dartnissanconnectna/-/raw/master/user_agent_key'));
this.userAgentKey = userAgentKey.body;
```

**Should be changed to:**
```dart
// Hardcoded User-Agent-Key (public constant, not a secret)
// This is a server-side API identifier required by NissanConnect NA
// The value has been stable for 4+ years and is publicly available
// in the dartnissanconnectna repository and various open-source projects
this.userAgentKey = '5AFC98CCD7E2AF32FD7C59916AABD';
```

**Why:** The dynamic GitLab fetch can fail or timeout, causing authentication failures. The key is a public constant required by Nissan's server-side API for authentication, not a secret credential.

**Workaround Options:**
1. Fork the repository on GitLab, make the change, and update `pubspec.yaml` to point to your fork
2. Contact the library maintainer to submit a merge request with this fix
3. Vendor the entire library into this repository under a `dependencies/` folder and modify it directly

#### 2. JSON Decode Error Handling (Multiple Libraries)

**Affected Libraries:**
- `dartnissanconnectna/lib/src/nissanconnect_session.dart`
- `dartnissanconnect/lib/src/nissanconnect_session.dart`
- `dartcarwings/lib/src/carwings_session.dart`

**Required Changes:**  
Wrap all `json.decode()` calls with better error handling:

```dart
try {
  jsonData = json.decode(response.body);
  _print('Result: $jsonData');
} catch (e) {
  _print('JSON decoding failed!');
  _print('Raw response body: ${response.body}');
  _print('Status code: ${response.statusCode}');
  _print('Error: $e');
  rethrow; // Re-throw to maintain existing error handling
}
```

**Why:** When JSON decoding fails, developers need to see what the API actually returned (HTML error pages, empty responses, invalid JSON, etc.) for debugging.

#### 3. World Region Authentication Retry Logic

**Location:** `https://gitlab.com/tobiaswkjeldsen/dartnissanconnect.git`  
**File:** `lib/src/nissanconnect_session.dart`  
**Method:** In the world region authentication method with the retry loop

**Required Changes:**
- Reduce max retries from 10 to 3-5
- Add better logging to show retry attempts
- Ensure the retry loop doesn't exceed authId token lifetime
- Add clearer error messages for session timeout

**Example:**
```dart
const int MAX_RETRIES = 3; // Reduced from 10
int retryCount = 0;

while (retryCount < MAX_RETRIES) {
  _print('Authentication attempt ${retryCount + 1}/$MAX_RETRIES');
  // ... existing retry logic ...
  retryCount++;
  
  if (error) {
    if (retryCount >= MAX_RETRIES) {
      _print('Authentication failed after $MAX_RETRIES attempts');
      _print('Session may have timed out. Please try logging in again.');
      throw Exception('Session timeout after $MAX_RETRIES retries');
    }
  }
}
```

## How to Apply External Dependency Fixes

### Option 1: Fork and Modify (Recommended)

1. Fork each affected GitLab repository to your own GitLab account
2. Clone your forks locally
3. Apply the fixes described above
4. Commit and push to your forks
5. Update `pubspec.yaml` to point to your forks:

```yaml
dependencies:
  dartcarwings:
    git:
      url: https://gitlab.com/YOUR-USERNAME/dartcarwings.git
      ref: main
  dartnissanconnectna:
    git:
      url: https://gitlab.com/YOUR-USERNAME/dartnissanconnectna.git
      ref: main
  dartnissanconnect:
    git:
      url: https://gitlab.com/YOUR-USERNAME/dartnissanconnect.git
      ref: main
```

6. Run `flutter pub get` to fetch your modified dependencies

### Option 2: Vendor Dependencies Locally

1. Clone the dependencies into a local `dependencies/` folder
2. Apply the fixes directly
3. Update `pubspec.yaml` to use local paths:

```yaml
dependencies:
  dartcarwings:
    path: dependencies/dartcarwings
  dartnissanconnectna:
    path: dependencies/dartnissanconnectna
  dartnissanconnect:
    path: dependencies/dartnissanconnect
```

4. Add `dependencies/` to `.gitignore` if you don't want to commit them, or commit them for vendored approach

### Option 3: Submit Merge Requests

Contact the library maintainers and submit merge requests with these fixes. This is the best long-term solution but may take time.

## Testing After Applying Fixes

1. **Test NA region authentication** with a valid US/Canada account
2. **Test World region authentication** with a valid account
3. **Verify debug logs** show raw response bodies when JSON decode fails
4. **Test iOS settings persistence** by:
   - Setting a preference
   - Force-closing the app (swipe up in app switcher)
   - Reopening the app
   - Verifying the setting persisted
5. **Check authentication doesn't timeout** due to excessive retries

## Notes

- All network calls go through HTTPS for security
- iOS entitlements follow Apple's sandboxing requirements
- App Groups must match the Bundle Identifier pattern

## Questions or Issues?

If you encounter problems:
1. Check the debug logs (now in unified text view)
2. Look for "JSON decoding failed!" messages with raw response bodies
3. Verify iOS entitlements are properly signed
4. Ensure the Bundle Identifier matches in all configurations
5. Check that network permissions are granted on iOS
