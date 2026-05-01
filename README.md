# 🚀 Shipa:



## ✨ Key Features

- **📍 Real-Time Courier Tracking**: High-fidelity live updates of courier locations on an interactive map.
- **⏱️ Dynamic ETA Estimation**: Intelligent calculation of remaining time based on current speed and traffic simulation.
- **🗺️ Interactive Map Controls**: 
  - **Auto-Following**: Smooth camera transitions that follow the courier's movement.
  - **Manual Exploration**: Intuitive panning and zooming with a quick 'Recenter' feature to resume tracking.
- **🛣️ Route Visualization**: Visual distinction between traveled segments and remaining paths for clear delivery progress.
- **🔔 Proximity Alerts**: Automated state transitions and notifications as the courier approaches the destination.
- **🎨 Premium Design System**: 
  - **Typography**: Utilizing the **Inter** font family for maximum legibility and modern feel.
  - **Aesthetics**: Glassmorphism-inspired UI elements, smooth micro-animations, and a curated color palette.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform excellence)
- **State Management**: [Riverpod 3.0](https://riverpod.dev/) (Robust and reactive state handling)
- **Maps**: [Google Maps SDK](https://pub.dev/packages/google_maps_flutter) (Industry-standard mapping solution)
- **Architecture**: **Clean Architecture** (Separation of concerns across Data, Domain, and Presentation layers)
- **Styling**: Custom Design System with Vanilla CSS-inspired Flutter constants.

---

## 🏗️ Project Structure

The project follows a modular Clean Architecture pattern:

```text
lib/
├── core/             # Shared constants, themes, and utilities
├── data/             # API/Database implementations (Models, DataSources, Repositories)
├── domain/           # Business logic (Entities, Usecases, Repository Interfaces)
├── presentation/     # UI Layer (Screens, ViewModels, Widgets, Providers)
└── main.dart         # Entry point
```

---
## Download apk
https://drive.google.com/file/d/185_yWHwTpK5tRI-cO3f5KFUxvoioVg0i/view?usp=sharing
## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- A Google Maps API Key

### Installation

1. **Clone the repository**:
   git clone https://github.com/HorlahTech/shipa.git


2. **Install dependencies**:
   flutter pub get


3. **Configure Maps API Key**:
   - **Android**: Add `MAPS_API_KEY=your_key_here` to `android/local.properties`.
   - **iOS**: Add `MAPS_API_KEY=your_key_here` to `ios/Flutter/Config.xcconfig`.

4. **Run the app**:
   flutter run


