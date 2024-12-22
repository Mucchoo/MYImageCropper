//
//  ImageCropViewModelTests.swift
//  MYImageCropper
//
//  Created by Musa Yazici on 12/23/24.
//

import XCTest
@testable import MYImageCropper

@MainActor
class ImageCropViewModelTests: XCTestCase {
    var sut: ImageCropViewModel!
    var type: ImageAspectRatioType!
    var image: UIImage!
    var dismissCalled: Bool!
    var savedImage: UIImage?

    @MainActor
    override func setUp() async throws {
        let size = CGSize(width: 800, height: 800)
        image = createImage(size: size)
        dismissCalled = false
        savedImage = nil
        
        sut = .init(
            image: image,
            type: .square,
            onDismiss: { [weak self] in
                self?.dismissCalled = true
            },
            onSave: { [weak self] image in
                self?.savedImage = image
            },
            screenWidth: 400
        )
    }

    func test_whenInitializedWithSquareType_cropAreaShouldBeSquare() throws {
        // Act
        sut = .init(
            image: createImage(size: CGSize(width: 200, height: 150)),
            type: .square,
            onDismiss: { },
            onSave: { _ in },
            screenWidth: 400
        )
        
        // Assert
        XCTAssertEqual(sut.maskSize.width, sut.maskSize.height)
    }

    func test_whenInitializedWith3to4RatioAndWideImage_cropAreaShouldMatchHeight() throws {
        // Act
        sut = ImageCropViewModel(
            image: createImage(size: CGSize(width: 420, height: 100)),
            type: .custom(width: 3, height: 4),
            onDismiss: { },
            onSave: { _ in },
            screenWidth: 400
        )
        
        // Assert
        XCTAssertEqual(sut.maskSize.width / sut.maskSize.height, 3.0/4.0)
    }

    func test_whenInitializedWith3to4RatioAndTallImage_cropAreaShouldMatchWidth() throws {
        // Act
        sut = ImageCropViewModel(
            image: createImage(size: CGSize(width: 300, height: 200)),
            type: .custom(width: 3, height: 4),
            onDismiss: { },
            onSave: { _ in },
            screenWidth: 400
        )
        
        // Assert
        XCTAssertEqual(sut.maskSize.width / sut.maskSize.height, 3.0/4.0)
    }

    func test_whenZoomingIn_shouldNotExceedMaximumZoom() throws {
        // Act
        sut.magnify(5.0)
        
        // Assert
        XCTAssertEqual(sut.scale, 4.0)
    }

    func test_whenZoomingOut_shouldNotGoBelowMinimumZoom() throws {
        // Act
        sut.magnify(0.1)
        
        // Assert
        XCTAssertEqual(sut.scale, 1)
    }

    func test_whenDraggingRight_shouldNotExceedImageBoundary() throws {
        // Arrange
        sut = ImageCropViewModel(
            image: createImage(size: CGSize(width: 800, height: 400)),
            type: .square,
            onDismiss: { },
            onSave: { _ in },
            screenWidth: 400
        )
        
        // Act
        sut.drag(CGSize(width: 1000, height: 0))
        
        // Assert
        XCTAssertEqual(sut.offset.width, 100.0)
    }

    func test_whenDraggingLeft_shouldNotExceedImageBoundary() throws {
        // Arrange
        sut = ImageCropViewModel(
            image: createImage(size: CGSize(width: 800, height: 400)),
            type: .square,
            onDismiss: { },
            onSave: { _ in },
            screenWidth: 400
        )
        
        // Act
        sut.drag(CGSize(width: -1000, height: 0))
        
        // Assert
        XCTAssertEqual(sut.offset.width, -100.0)
    }

    func test_whenDraggingUp_shouldNotExceedImageBoundary() throws {
        // Arrange
        sut = ImageCropViewModel(
            image: createImage(size: CGSize(width: 400, height: 800)),
            type: .square,
            onDismiss: { },
            onSave: { _ in },
            screenWidth: 400
        )
        
        // Act
        sut.drag(CGSize(width: 0, height: 1000))
        
        // Assert
        XCTAssertEqual(sut.offset.height, 200.0)
    }

    func test_whenDraggingDown_shouldNotExceedImageBoundary() throws {
        // Arrange
        sut = ImageCropViewModel(
            image: createImage(size: CGSize(width: 400, height: 800)),
            type: .square,
            onDismiss: { },
            onSave: { _ in },
            screenWidth: 400
        )
        
        // Act
        sut.drag(CGSize(width: 0, height: -1000))
        
        // Assert
        XCTAssertEqual(sut.offset.height, -200.0)
    }
    
    func test_whenDraggingWithinBounds_shouldAllowMovement() throws {
        // Arrange
        sut.magnify(2)
        sut.updateLastValues()
        let validTranslation = CGSize(width: Int.random(in: -100...100), height: Int.random(in: -100...100))
        
        // Act
        sut.drag(validTranslation)
        
        // Assert
        XCTAssertEqual(sut.offset, validTranslation)
    }

    func test_whenDraggingEnds_shouldUpdatePositionForNextGesture() throws {
        // Arrange
        sut = ImageCropViewModel(
            image: createImage(size: CGSize(width: 400, height: 800)),
            type: .square,
            onDismiss: { },
            onSave: { _ in },
            screenWidth: 400
        )
        sut.drag(CGSize(width: 0, height: 20))
        
        // Act
        sut.updateLastValues()
        
        // Assert
        XCTAssertEqual(sut.lastOffset, CGSize(width: 0, height: 20))
    }

    func test_whenZoomEnds_shouldUpdateScaleForNextGesture() throws {
        // Arrange
        sut.magnify(2)
        
        // Act
        sut.updateLastValues()
        
        // Assert
        XCTAssertEqual(sut.lastScale, 2.0)
    }

    func test_whenCancelPressed_shouldCloseScreen() throws {
        // Act
        sut.onCancelButton()
        
        // Assert
        XCTAssertTrue(dismissCalled)
    }
}

// MARK: - Crop Tests
extension ImageCropViewModelTests {
    func test_whenSavePressed_shouldCropAndReturnImage() throws {
        // Act
        sut.onSaveButton()
        
        // Assert
        XCTAssertNotNil(savedImage)
    }

    func test_whenCroppingSquareImageWithoutZoom_shouldMaintainOriginalSize() throws {
        // Arrange
        let imageSize = CGSize(width: 200, height: 200)
        sut = ImageCropViewModel(
            image: createImage(size: imageSize),
            type: .square,
            onDismiss: { },
            onSave: { self.savedImage = $0 }
        )
        
        // Act
        sut.onSaveButton()
        
        // Assert
        XCTAssertNotNil(savedImage)
        XCTAssertEqual(savedImage?.size, imageSize)
    }

    func test_whenCroppingWithDoubleZoom_croppedImageShouldBeHalfSize() throws {
        // Arrange
        sut = ImageCropViewModel(
            image: createImage(size: CGSize(width: 200, height: 200)),
            type: .square,
            onDismiss: { },
            onSave: { self.savedImage = $0 }
        )
        sut.magnify(2)
        
        // Act
        sut.onSaveButton()
        
        // Assert
        XCTAssertNotNil(savedImage)
        XCTAssertEqual(savedImage?.size, CGSize(width: 100, height: 100))
    }

    func test_whenImageIsRotated_shouldCorrectOrientation() throws {
        // Arrange
        let rotatedImage = createImage(size: CGSize(width: 200, height: 200)).rotated(to: .right)
        sut = ImageCropViewModel(
            image: rotatedImage,
            type: .square,
            onDismiss: { },
            onSave: { self.savedImage = $0 }
        )
        
        // Act
        sut.onSaveButton()
        
        // Assert
        XCTAssertNotNil(savedImage)
        XCTAssertEqual(savedImage?.imageOrientation, .up)
    }

    func test_whenCropping3to4RatioImage_shouldMaintainAspectRatio() throws {
        // Arrange
        sut = ImageCropViewModel(
            image: createImage(size: CGSize(width: 400, height: 400)),
            type: .custom(width: 3, height: 4),
            onDismiss: { },
            onSave: { self.savedImage = $0 },
            screenWidth: 400
        )
        
        // Act
        sut.onSaveButton()
        
        // Assert
        XCTAssertNotNil(savedImage)
        let aspectRatio = savedImage!.size.width / savedImage!.size.height
        XCTAssertEqual(aspectRatio, 3.0/4.0)
    }

    private func createImage(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(UIColor.white.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

fileprivate extension UIImage {
    func rotated(to orientation: UIImage.Orientation) -> UIImage {
        return UIImage(cgImage: cgImage!, scale: scale, orientation: orientation)
    }
}
