//: Playground - noun: a place where people can play

import UIKit

let image = UIImage(named: "sample")!

// Process the image!

var rgbaImage = RGBAImage(image: image)!

// Base filter class
public class Filter {
    public func applyToImage(_ image: inout RGBAImage) {
        for i in 0..<(image.width * image.height) {
            applyToPixel(&image.pixels[i])
        }
    }

    func applyToPixel(_ pixel: inout Pixel) {
        // ...
    }
}

// Grey scale filter
public class GreyScaleFilter: Filter {
    // Calculate grey scale based on luminance
    override func applyToPixel(_ pixel: inout Pixel) {
        let grey = UInt8(0.3 * Double(pixel.red) + 0.59 * Double(pixel.green) + 0.11 * Double(pixel.blue))
        pixel.red = grey
        pixel.green = grey
        pixel.blue = grey
    }
}

func processImage(_ rgbaImage: inout RGBAImage, filter: Filter) {
    filter.applyToImage(&rgbaImage)
}

let greyScaleFilter = GreyScaleFilter()

processImage(&rgbaImage, filter: greyScaleFilter)

let result = rgbaImage.toUIImage()
