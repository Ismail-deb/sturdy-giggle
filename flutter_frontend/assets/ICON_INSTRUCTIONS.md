# App Icon Setup - GreenSense

## Icon Design Brief

**App Name:** GreenSense  
**Concept:** Smart Greenhouse Monitoring System

### Design Elements
Your logo design (green leaf with blue waveform) is perfect! It combines:
- 🌿 **Green Leaf** = Greenhouse/Plant growth
- 📊 **Blue Waveform** = Sensor data/Smart monitoring

### Icon Requirements

#### File Specifications:
- **Filename:** `app_icon.png`
- **Size:** 1024x1024 pixels
- **Format:** PNG with transparency
- **Color Space:** RGB
- **Resolution:** 72 DPI minimum (for digital display)

#### Design Guidelines:
1. **Keep it Simple:** Icon will display at small sizes (48x48 to 192x192 on phones)
2. **Bold Shapes:** Ensure the leaf and waveform are clearly visible when small
3. **High Contrast:** Green and blue should stand out against backgrounds
4. **No Text:** The leaf + waveform symbol should work alone
5. **Safe Zone:** Keep important elements at least 10% from edges

#### Recommended Colors:
- **Primary Green:** #4CAF50 (Material Design Green 500) - for the leaf
- **Accent Blue:** #2196F3 (Material Design Blue 500) - for the waveform
- **Background:** Transparent or white
- **Optional Gradient:** Subtle gradient from light to dark green on leaf

### Android Adaptive Icon (Optional but Recommended)

For modern Android devices, you can also create:

1. **Foreground Image** (`app_icon_foreground.png`):
   - 1024x1024 pixels
   - Just the leaf + waveform icon (centered)
   - Use 432x432px safe area in the middle
   - Transparent background

2. **Background Color** or Image:
   - Solid color: `#FFFFFF` (white) or `#E8F5E9` (light green)
   - OR background image: 1024x1024 pixels

## How to Apply Your Icon

### Step 1: Save Your Logo
1. Open your logo design in your graphics editor (Photoshop, GIMP, Figma, etc.)
2. Export/Save as `app_icon.png`
3. Dimensions: **1024x1024 pixels**
4. Save to: `flutter_frontend/assets/app_icon.png`

### Step 2: Generate Icons
Run this command in the terminal:
```bash
cd C:\Users\griff\Downloads\flutter_python_app\flutter_frontend
dart run flutter_launcher_icons
```

This will automatically generate:
- ✅ Android icons (all densities: mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- ✅ iOS icons (all required sizes)
- ✅ Web icons (favicon, manifest icons)
- ✅ Windows icons
- ✅ macOS icons

### Step 3: Rebuild the App
```bash
flutter run -d R58T40Z6E8M
```

### Step 4: Verify
Check your phone's app drawer - you should see "GreenSense" with your custom icon!

## Design Tools (Free Options)

If you need to create/edit your icon:

1. **Figma** (Web-based, free): https://figma.com
2. **GIMP** (Desktop, free): https://gimp.org
3. **Canva** (Web-based, free tier): https://canva.com
4. **Inkscape** (Vector graphics, free): https://inkscape.org
5. **Paint.NET** (Windows, free): https://getpaint.net

## Icon Templates

You can use online generators if needed:
- **App Icon Generator**: https://appicon.co
- **Icon Kitchen**: https://icon.kitchen
- **Make App Icon**: https://makeappicon.com

Just upload your 1024x1024 PNG and download all sizes!

## Current Status

- ✅ App renamed to "GreenSense"
- ✅ Icon configuration ready in `pubspec.yaml`
- ⏳ Waiting for `app_icon.png` file (1024x1024)
- ⏳ Then run `dart run flutter_launcher_icons`

---

**Need help?** Just ask! I can guide you through any graphics editing tool.
