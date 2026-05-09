# NumerJumping – Setup & Deploy

## 1. Install Godot 4
Download Godot 4.2+ from https://godotengine.org/download
Place it in /Applications or add to PATH as `godot4`.

## 2. Open the project
Open Godot → Import → select `numerjumping/project.godot`

## 3. Run on desktop (quick test)
Press F5 (Play) in the editor. Use mouse clicks: left half = jump left, right half = jump right.

## 4. Export to iPhone via Xcode

### Prerequisites
- Xcode 15+ installed
- Apple Developer account
- Godot iOS export templates installed:
  Editor → Export → Manage Export Templates → Download

### Export steps
1. Editor → Project → Export → Add → iOS
2. Set your Bundle ID and signing team in the export dialog
3. Click "Export Project" → choose a folder → Godot generates an Xcode project
4. Open the `.xcodeproj` in Xcode
5. Select your device, hit Run

## Game controls
- Tap left half of screen → jump to left platform above
- Tap right half of screen → jump to right platform above

## Levels
Each level trains one multiplication table (×2 through ×10).
10 correct jumps = level complete. Wrong jump = try again from same platform.
