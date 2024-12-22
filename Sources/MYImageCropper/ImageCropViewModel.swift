//
//  ImageCropViewModel.swift
//  MYImageCropper
//
//  Created by Musa Yazici on 12/22/24.
//

import UIKit
import CoreGraphics

@MainActor
public class ImageCropViewModel: ObservableObject {
    let image: UIImage
    private let type: ImageAspectRatioType
    private let imageSize: CGSize
    private let onDismiss: () -> Void
    private let onSave: (UIImage?) -> Void

    @Published private(set) public var maskSize: CGSize = .zero
    @Published private(set) public var scale: CGFloat = 1.0
    @Published private(set) public var lastScale: CGFloat = 1.0
    @Published private(set) public var offset: CGSize = .zero
    @Published private(set) public var lastOffset: CGSize = .zero
    
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
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let screenWidth = UIScreen.main.bounds.width
        let displayHeight = (screenWidth * imageHeight) / imageWidth
        self.imageSize = CGSize(width: screenWidth, height: displayHeight)

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

    private func maxX() -> CGFloat { (imageSize.width * scale - maskSize.width) * 0.5 }
    private func minX() -> CGFloat { (imageSize.width * scale - maskSize.width) * -0.5 }
    private func maxY() -> CGFloat { (imageSize.height * scale - maskSize.height) * 0.5 }
    private func minY() -> CGFloat { (imageSize.height * scale - maskSize.height) * -0.5 }

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

    public func drag(_ translation: CGSize) {
        let newX = translation.width + lastOffset.width
        let newY = translation.height + lastOffset.height
        offset = constrainPositionToAllowedArea(x: newX, y: newY)
    }

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

    public func updateLastValues() {
        lastScale = scale
        lastOffset = offset
    }

    public func onCancelButton() {
        onDismiss()
    }
    
    public func onSaveButton() {
        let croppedImage = crop(image)
        onSave(croppedImage)
    }

    private func crop(_ image: UIImage) -> UIImage? {
        guard let upwardImage = image.upwardOriented else { return nil }

        let resolutionFactor = upwardImage.size.width / imageSize.width
        let center = CGPoint(x: upwardImage.size.width / 2, y: upwardImage.size.height / 2)
        let cropSize = CGSize(
            width: (maskSize.width * resolutionFactor) / scale,
            height: (maskSize.height * resolutionFactor) / scale
        )

        let offsetX = offset.width * resolutionFactor / scale
        let offsetY = offset.height * resolutionFactor / scale
        let cropRectX = (center.x - cropSize.width / 2) - offsetX
        let cropRectY = (center.y - cropSize.height / 2) - offsetY

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

private extension UIImage {
    var upwardOriented: UIImage? {
        if imageOrientation == .up { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return normalizedImage
    }
}
