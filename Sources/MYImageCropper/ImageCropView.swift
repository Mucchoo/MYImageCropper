//
//  ImageCropView.swift
//  MYImageCropper
//
//  Created by Musa Yazici on 12/22/24.
//

import SwiftUI

/// A SwiftUI view that provides image cropping functionality.
///
/// This view displays an interface for cropping images with the following features:
/// - Pinch to zoom the image
/// - Drag to pan the image
/// - Maintains aspect ratio according to the specified configuration
/// - Preview of the crop area with a mask
/// - Cancel and Save actions
///
/// Example usage:
/// ```swift
/// ImageCropView(viewModel: ImageCropViewModel(
///     image: myImage,
///     type: .square,
///     ondismiss: { /* handle dismissal */ },
///     onSave: { croppedImage in /* handle saved image */ }
/// ))
/// ```
public struct ImageCropView: View {
    /// The view model that handles the cropping logic and state
    @StateObject private var viewModel: ImageCropViewModel

    /// Creates a new image cropping view
    /// - Parameter viewModel: The view model that will manage the cropping state and operations
    public init(viewModel: ImageCropViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        ZStack {
            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFit()
                .scaleEffect(viewModel.scale)
                .offset(viewModel.offset)
                .opacity(0.5)

            Image(uiImage: viewModel.image)
                .resizable()
                .scaledToFit()
                .scaleEffect(viewModel.scale)
                .offset(viewModel.offset)
                .mask(
                    Rectangle()
                        .frame(width: viewModel.maskSize.width, height: viewModel.maskSize.height)
                )

            VStack {
                Text("Select Crop Area")
                    .font(.system(size: 20, weight: .bold))
                    .padding(.top, 100)
                    .foregroundColor(.white)

                Spacer()

                HStack {
                    Button {
                        viewModel.onCancelButton()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button {
                        viewModel.onSaveButton()
                    } label: {
                        Text("Save")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding(40)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .contentShape(Rectangle())
        .simultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    viewModel.magnify(value.magnitude)
                }
                .onEnded { _ in
                    viewModel.updateLastValues()
                }
        )
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    viewModel.drag(value.translation)
                }
                .onEnded { _ in
                    viewModel.updateLastValues()
                }
        )
        .clipped()
    }
}
