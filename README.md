# MYImageCropper [![](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

A SwiftUI-based image cropping library for iOS that provides an intuitive interface for cropping images with customizable aspect ratios.

<p align="center">
<img src="https://github.com/user-attachments/assets/d7211494-f9fc-4bec-974e-85359dca8e1f" width="300"/>
</p>

## Features

- 📱 Native SwiftUI implementation
- 🎯 Square and custom aspect ratio support
- 🔄 Pinch to zoom and drag to pan
- 🎨 Clean and intuitive user interface
- 💪 Strong type safety with Swift
- 📦 Easy integration with SPM

## Requirements

- iOS 14.0+

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/MYImageCropper.git", from: "1.0.0")
]
```

Or add it directly through Xcode:
1. Go to File > Add Package Dependencies
2. Enter the repository URL: `https://github.com/yourusername/MYImageCropper.git`
3. Click "Add Package"

## Usage

### Basic Implementation

```swift
import SwiftUI
import MYImageCropper

struct ContentView: View {
    @State private var selectedImage: UIImage?
    @State private var showCropper = false
    
    var body: some View {
        Button("Show Cropper") {
            showCropper = true
        }
        .fullScreenCover(isPresented: $showCropper) {
            if let image = selectedImage {
                // Using convenience method for square cropping
                ImageCropView(
                    image: image,
                    aspectRatio: .square,
                    onDismiss: {
                        showCropper = false
                    },
                    onSave: { croppedImage in
                        if let croppedImage {
                            // Handle cropped image
                            selectedImage = croppedImage
                        }
                        showCropper = false
                    }
                )
            }
        }
    }
}
```

### Custom Aspect Ratio

```swift
// Using custom aspect ratio (16:9)
ImageCropView(
    image: image,
    aspectRatio: .custom(width: 16, height: 9),
    onDismiss: {
        showCropper = false
    },
    onSave: { croppedImage in
        if let croppedImage {
            // Handle cropped image
            selectedImage = croppedImage
        }
        showCropper = false
    }
)
```

## Demo

Check out our [demo application](https://github.com/Mucchoo/MYImageCropperDemo) to see MYImageCropper in action:

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MYImageCropper is available under the MIT license. See the LICENSE file for more info.
