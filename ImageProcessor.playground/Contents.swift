//: Playground - noun: a place where people can play

import UIKit

let image = UIImage(named: "sample")!

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

// Image processor
public class ImageProcessor {
    var filters = [String: Filter]()
    
    public func addFilter(_ name: String, filter: Filter) {
        filters.updateValue(filter, forKey: name)
    }

    public func applyFilters(_ image: UIImage) -> UIImage! {
        var rgbaImage = RGBAImage(image: image)!
        for (_, filter) in filters {
            filter.applyToImage(&rgbaImage)
        }
        return rgbaImage.toUIImage()
    }
}

// Process the image!

var imageProcessor = ImageProcessor()
imageProcessor.addFilter("Grey Scale", filter: GreyScaleFilter())

let result = imageProcessor.applyFilters(image)
