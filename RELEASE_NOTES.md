# Release Notes

## v1.0.0 - Initial Release

### Features
- 📊 Display GitHub contribution graph on your Android home screen
- 🎨 Beautiful dark theme matching GitHub's design
- 📱 Resizable widget - adjust to show more or fewer weeks
- 🔄 Auto-updates hourly
- 🔒 Secure local storage of credentials

### Requirements
- Android 5.0 (API 21) or higher
- GitHub Personal Access Token with `read:user` scope

### Installation
1. Download `app-release.apk` from the assets below
2. Enable "Install from unknown sources" on your Android device
3. Install the APK
4. Open the app and enter your GitHub credentials
5. Add the widget to your home screen

### How to Create a GitHub Release

1. **Build the release APK:**
   ```bash
   flutter build apk --release
   ```

2. **Create a new release on GitHub:**
   - Go to your repository → Releases → "Create a new release"
   - Tag: `v1.0.0`
   - Title: `v1.0.0 - Initial Release`
   - Description: Copy the content above
   - Attach the APK file: `build/app/outputs/flutter-apk/app-release.apk`
   - Click "Publish release"

3. **Users can then:**
   - Go to the Releases page
   - Download the APK
   - Install on their Android device

---

## Future Releases

When releasing new versions:

1. Update version in `pubspec.yaml`:
   ```yaml
   version: 1.1.0+2
   ```

2. Build new APK:
   ```bash
   flutter build apk --release
   ```

3. Create new GitHub release with updated notes

4. Attach the new APK file