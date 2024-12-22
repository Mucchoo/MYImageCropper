import SwiftUI

/// MYImageCropper is a Swift package that provides easy-to-use image cropping functionality
/// with customizable aspect ratios for iOS applications.
///
/// The main components of this library are:
/// - `ImageCropView`: The SwiftUI view that provides the cropping interface
/// - `ImageCropViewModel`: The view model that handles cropping logic
/// - `ImageAspectRatioType`: Configuration for different aspect ratios
///
/// For usage examples and detailed documentation, please refer to the README.md file.
public enum MYImageCropper {
    /// The current version of the library
    public static let version = "1.0.0"
    
    /// Convenience method to create an image cropper view with a square aspect ratio
    /// - Parameters:
    ///   - image: The image to be cropped
    ///   - onDismiss: Callback when cropping is cancelled
    ///   - onSave: Callback with the cropped image result
    /// - Returns: An ImageCropView instance
    @MainActor public static func squareCropper(
        image: UIImage,
        onDismiss: @escaping () -> Void,
        onSave: @escaping (UIImage?) -> Void
    ) -> ImageCropView {
        ImageCropView(viewModel: ImageCropViewModel(
            image: image,
            type: .square,
            ondismiss: onDismiss,
            onSave: onSave
        ))
    }
    
    /// Convenience method to create an image cropper view with a custom aspect ratio
    /// - Parameters:
    ///   - image: The image to be cropped
    ///   - height: The height for the custom aspect ratio
    ///   - width: The width for the custom aspect ratio
    ///   - onDismiss: Callback when cropping is cancelled
    ///   - onSave: Callback with the cropped image result
    /// - Returns: An ImageCropView instance
    @MainActor public static func customCropper(
        image: UIImage,
        height: CGFloat,
        width: CGFloat,
        onDismiss: @escaping () -> Void,
        onSave: @escaping (UIImage?) -> Void
    ) -> ImageCropView {
        ImageCropView(viewModel: ImageCropViewModel(
            image: image,
            type: .custom(height: height, width: width),
            ondismiss: onDismiss,
            onSave: onSave
        ))
    }
}
