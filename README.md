# GitGraph

A beautiful Android home screen widget that displays your GitHub contribution graph, just like on your GitHub profile.

![Widget Preview](screenshots/widget_on_home_screen.jpeg)

## Features

### Widget Features
- 📊 **Real GitHub Data** - Fetches your actual contribution data from GitHub
- 🎨 **GitHub Dark Theme** - Matches GitHub's dark mode color scheme
- 📱 **Resizable Widget** - Adjust the widget size to show more or fewer weeks
- 🔄 **Auto Updates** - Widget updates hourly to show latest contributions
- 🔒 **Secure** - Your token is stored locally on your device only

### App Features
- 🔥 **Current Streak Counter** - Track your consecutive days of contributions
- 🏆 **Longest Streak Display** - See your best streak record
- 👆 **Tap for Details** - Tap any cell to see contribution count and date
- ↓ **Pull to Refresh** - Swipe down to refresh your contribution data
- 🎨 **Color Themes** - Choose from Green, Blue, or Yellow color schemes
- 🌈 **Theme-Aware Colors** - Streak icons and text match your selected theme

## Screenshots

| App Setup | Widget on Home Screen | Adding Widget |
|-----------|----------------------|---------------|
| ![Setup](screenshots/app_setup.jpeg) | ![Widget](screenshots/widget_on_home_screen.jpeg) | ![Adding Widget](screenshots/gitgraph-widget-drag.jpeg) |

## Color Themes

Personalize your contribution graph with three beautiful color themes:

| Theme | Graph Colors | Current Streak | Longest Streak |
|-------|-------------|----------------|----------------|
| 🟢 **Green** | GitHub default green | Orange 🔥 | Gold 🏆 |
| 🔵 **Blue** | Slate/steel blue | Dark Blue 🔥 | Light Blue 🏆 |
| 🟡 **Yellow** | Warm amber/gold | Dark Amber 🔥 | Bright Yellow 🏆 |

## Installation

### Option 1: Download APK (Recommended)

1. Go to the [Releases](../../releases) page
2. Download the latest `gitgraph-v1.2.1.apk`
3. On your Android phone:
   - Enable "Install from unknown sources" in Settings
   - Open the downloaded APK file
   - Tap "Install"

### Option 2: Build from Source

```bash
# Clone the repository
git clone https://github.com/gitgraph-app/git-graph.git
cd git-graph

# Install Flutter dependencies
flutter pub get

# Build the APK
flutter build apk --release

# The APK will be at: build/app/outputs/flutter-apk/app-release.apk
```

## Setup

### 1. Create a GitHub Personal Access Token

1. Go to [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens/new)
2. Click "Generate new token (classic)"
3. Give it a name (e.g., "Contributions Widget")
4. Select the `read:user` scope
5. Click "Generate token"
6. **Copy the token** (you won't be able to see it again!)

### 2. Configure the App

1. Open the GitGraph app
2. Enter your GitHub username
3. Paste your Personal Access Token
4. Tap "Save & Fetch Contributions"

### 3. Add the Widget

1. Long press on your home screen
2. Tap "Widgets"
3. Find "GitGraph"
4. Drag the widget to your home screen
5. Resize as needed

## App Usage

### Viewing Contribution Details
- **Tap any cell** in the contribution graph to see the exact contribution count and date

### Refreshing Data
- **Pull down** on the main screen to refresh your contribution data
- Or tap the **refresh icon** in the app bar

### Changing Color Theme
1. Scroll to the contribution graph
2. Below the graph, tap on any colored circle (🟢 🔵 🟡)
3. The graph and streak colors will update immediately
4. Your preference is saved automatically

## Widget Customization

The widget automatically adjusts to show more weeks when you make it wider. Try different sizes to find what works best for your home screen layout.

## Privacy & Security

- Your GitHub token is stored **only on your device**
- The app communicates directly with GitHub's API
- No data is sent to any third-party servers
- You can logout anytime to clear your credentials

## Requirements

- Android 5.0 (API 21) or higher
- GitHub account
- GitHub Personal Access Token with `read:user` scope

## Tech Stack

- **Flutter** - Cross-platform UI framework
- **Kotlin** - Native Android widget implementation
- **GitHub GraphQL API** - Fetching contribution data

## Version History

| Version | Features |
|---------|----------|
| v1.2.1 | Theme-aware streak colors |
| v1.2.0 | Color theme options (Green, Blue, Yellow) |
| v1.1.7 | Pull to refresh |
| v1.1.6 | Longest streak display |
| v1.1.5 | Current streak counter |
| v1.1.4 | Tap cells for contribution details |
| v1.1.0 | Initial release with widget support |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by GitHub's contribution graph
- Built with Flutter and ❤️

## Support

If you encounter any issues or have questions:
- Open an [Issue](../../issues)
- Check existing issues for solutions

---

**Note:** This app is not affiliated with GitHub. GitHub and the GitHub logo are trademarks of GitHub, Inc.