# MYImageCropper

A SwiftUI-based image cropping library for iOS that provides an intuitive interface for cropping images with customizable aspect ratios.

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
                MYImageCropper.squareCropper(
                    image: image,
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
MYImageCropper.customCropper(
    image: image,
    width: 16,
    height: 9,
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

### Direct View Model Usage

For more control, you can create the view model directly:

```swift
ImageCropView(viewModel: ImageCropViewModel(
    image: image,
    type: .custom(width: 3, height: 4),
    ondismiss: { /* handle dismiss */ },
    onSave: { croppedImage in /* handle save */ }
))
```

## Advanced Configuration

The library provides two main aspect ratio types:
- `.square`: 1:1 aspect ratio
- `.custom(width:height:)`: Custom aspect ratio with specified dimensions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MYImageCropper is available under the MIT license. See the LICENSE file for more info.
