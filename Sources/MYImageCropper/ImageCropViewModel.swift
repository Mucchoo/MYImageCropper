//
//  ImageCropViewModel.swift
//  MYImageCropper
//
//  Created by Musa Yazici on 12/22/24.
//

import UIKit
import CoreGraphics

/// A view model that manages the state and logic for image cropping functionality.
/// This class handles image scaling, positioning, and cropping operations while maintaining
/// the specified aspect ratio constraints.
///
/// Example usage:
/// ```swift
/// let viewModel = ImageCropViewModel(
///     image: myImage,
///     type: .square,
///     ondismiss: { /* handle dismissal */ },
///     onSave: { croppedImage in /* handle saved image */ }
/// )
/// ```
@MainActor
public class ImageCropViewModel: ObservableObject {
    /// The original image to be cropped
    let image: UIImage
    
    /// The aspect ratio configuration for cropping
    private let type: ImageAspectRatioType
    
    /// The size of the image as displayed in the view
    private let imageSize: CGSize
    
    /// Callback closure for when the cropping operation is cancelled
    private let onDismiss: () -> Void
    
    /// Callback closure for when the cropping operation is completed
    private let onSave: (UIImage?) -> Void

    /// The size of the cropping mask, calculated based on the aspect ratio and image size
    @Published private(set) public var maskSize: CGSize = .zero
    
    /// The current scale factor of the image
    @Published private(set) public var scale: CGFloat = 1.0
    
    /// The previous scale factor, used for gesture handling
    @Published private(set) public var lastScale: CGFloat = 1.0
    
    /// The current offset of the image from its center position
    @Published private(set) public var offset: CGSize = .zero
    
    /// The previous offset, used for gesture handling
    @Published private(set) public var lastOffset: CGSize = .zero
    
    /// Initializes a new image cropping view model
    /// - Parameters:
    ///   - image: The UIImage to be cropped
    ///   - type: The aspect ratio type for cropping (.square or .custom)
    ///   - ondismiss: A closure to be called when the cropping operation is cancelled
    ///   - onSave: A closure to be called with the cropped image when the operation is completed
    public init(
        image: UIImage,
        type: ImageAspectRatioType,
        ondismiss: @escaping () -> Void,
        onSave: @escaping (UIImage?) -> Void
    ) {
        self.image = image
        self.type = type
        self.onDismiss = ondismiss
        self.onSave = onSave
        
        // Calculate the display size while maintaining aspect ratio
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let screenWidth = UIScreen.main.bounds.width
        let displayHeight = (screenWidth * imageHeight) / imageWidth
        self.imageSize = CGSize(width: screenWidth, height: displayHeight)

        // Initialize the mask size based on the aspect ratio type
        if imageSize.width / imageSize.height > type.aspectRatio {
            let height = imageSize.height
            let width = height * type.aspectRatio
            maskSize = CGSize(width: width, height: height)
        } else {
            let width = imageSize.width
            let height = width / type.aspectRatio
            maskSize = CGSize(width: width, height: height)
        }
    }

    // MARK: - Private Helper Methods for Position Constraints
    
    /// Calculates the maximum allowed x-offset based on current scale and mask size
    private func maxX() -> CGFloat { (imageSize.width * scale - maskSize.width) * 0.5 }
    
    /// Calculates the minimum allowed x-offset based on current scale and mask size
    private func minX() -> CGFloat { (imageSize.width * scale - maskSize.width) * -0.5 }
    
    /// Calculates the maximum allowed y-offset based on current scale and mask size
    private func maxY() -> CGFloat { (imageSize.height * scale - maskSize.height) * 0.5 }
    
    /// Calculates the minimum allowed y-offset based on current scale and mask size
    private func minY() -> CGFloat { (imageSize.height * scale - maskSize.height) * -0.5 }

    // MARK: - Public Gesture Handling Methods

    /// Handles pinch gesture magnification
    /// - Parameter magnitude: The magnitude of the pinch gesture
    public func magnify(_ magnitude: CGFloat) {
        scale = min(max(
            magnitude * lastScale, max(
                maskSize.width / imageSize.width,
                maskSize.height / imageSize.height
            )
        ), 4.0)
        offset = constrainPositionToAllowedArea(x: offset.width, y: offset.height)
        lastOffset = offset
    }

    /// Handles drag gesture translation
    /// - Parameter translation: The translation amount from the drag gesture
    public func drag(_ translation: CGSize) {
        let newX = translation.width + lastOffset.width
        let newY = translation.height + lastOffset.height
        offset = constrainPositionToAllowedArea(x: newX, y: newY)
    }

    /// Constrains the position of the image to ensure it stays within the allowed area
    /// - Parameters:
    ///   - x: The proposed x coordinate
    ///   - y: The proposed y coordinate
    /// - Returns: A size representing the constrained position
    private func constrainPositionToAllowedArea(x: CGFloat, y: CGFloat) -> CGSize {
        var newX = x
        var newY = y

        if newX > maxX() {
            newX = maxX()
        } else if newX < minX() {
            newX = minX()
        }

        if newY > maxY() {
            newY = maxY()
        } else if newY < minY() {
            newY = minY()
        }

        return CGSize(width: newX, height: newY)
    }

    /// Updates the last known scale and offset values
    /// Called when gestures end to prepare for the next gesture
    public func updateLastValues() {
        lastScale = scale
        lastOffset = offset
    }

    /// Handles the cancel button tap by calling the dismiss closure
    public func onCancelButton() {
        onDismiss()
    }
    
    /// Handles the save button tap by performing the crop operation and calling the save closure
    public func onSaveButton() {
        let croppedImage = crop(image)
        onSave(croppedImage)
    }

    /// Performs the actual image cropping operation
    /// - Parameter image: The image to be cropped
    /// - Returns: The cropped image, or nil if cropping fails
    private func crop(_ image: UIImage) -> UIImage? {
        // Ensure image is correctly oriented
        guard let upwardImage = image.upwardOriented else { return nil }

        // Calculate resolution factor between file size and display size
        let resolutionFactor = upwardImage.size.width / imageSize.width
        
        // Calculate the center point of the image
        let center = CGPoint(x: upwardImage.size.width / 2, y: upwardImage.size.height / 2)
        
        // Calculate the actual crop size in image coordinates
        let cropSize = CGSize(
            width: (maskSize.width * resolutionFactor) / scale,
            height: (maskSize.height * resolutionFactor) / scale
        )

        // Calculate the starting point for cropping
        let offsetX = offset.width * resolutionFactor / scale
        let offsetY = offset.height * resolutionFactor / scale
        let cropRectX = (center.x - cropSize.width / 2) - offsetX
        let cropRectY = (center.y - cropSize.height / 2) - offsetY

        // Perform the actual image cropping
        guard let cgImage = upwardImage.cgImage,
              let result = cgImage.cropping(
                to: CGRect(
                    origin: CGPoint(x: cropRectX, y: cropRectY),
                    size: cropSize
                )
              ) else {
            return nil
        }

        return UIImage(cgImage: result)
    }
}

/// Private extension to handle image orientation
private extension UIImage {
    /// Ensures the image is in the upward orientation
    /// - Returns: A new image in the correct orientation, or nil if the operation fails
    var upwardOriented: UIImage? {
        if imageOrientation == .up { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}
