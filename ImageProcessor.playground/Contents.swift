//: Playground - noun: a place where people can play

import UIKit

let image = UIImage(named: "sample")!

// Process the image!

var rgbaImage = RGBAImage(image: image)!

func greyScaleFilter(_ pixel: Pixel) -> Pixel {
    // Calculate grey scale based on luminance
    let grey = UInt8(0.3 * Double(pixel.red) + 0.59 * Double(pixel.green) + 0.11 * Double(pixel.blue))
    var newPixel = Pixel()
    newPixel.red = grey
    newPixel.green = grey
    newPixel.blue = grey
    newPixel.alpha = pixel.alpha
    return newPixel
}

func processImage(_ rgbaImage: inout RGBAImage, filter: (_ pixel: Pixel) -> Pixel) {
    for i in 0..<(rgbaImage.width * rgbaImage.height) {
        rgbaImage.pixels[i] = filter(rgbaImage.pixels[i])
    }
}

processImage(&rgbaImage, filter: greyScaleFilter)

let result = rgbaImage.toUIImage()
