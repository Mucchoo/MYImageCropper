//
//  ImageAspectRatioType.swift
//  MYImageCropper
//
//  Created by Musa Yazici on 12/22/24.
//

import Foundation

public enum ImageAspectRatioType {
    case square
    case custom(height: CGFloat, width: CGFloat)

    var aspectRatio: CGFloat {
        switch self {
        case .square: 1.0
        case .custom(let height, let width):
            height / width
        }
    }
}
