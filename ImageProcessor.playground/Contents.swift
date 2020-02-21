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

// Brightness filter
public class BrightnessFilter: Filter {
    var intensity: Double  // 0 <- darker <- 1 -> brighter

    public init(_ intensity: Double = 1.0) {
        self.intensity = intensity
    }

    override func applyToPixel(_ pixel: inout Pixel) {
        if intensity == 1 {
            return
        }
        pixel.red = UInt8(max(0, min(255, Double(pixel.red) * intensity)))
        pixel.green = UInt8(max(0, min(255, Double(pixel.green) * intensity)))
        pixel.blue = UInt8(max(0, min(255, Double(pixel.blue) * intensity)))
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
    var filters: [String: Filter] = [
        // Pre-determined filters
        "Grey Scale": GreyScaleFilter(),
        "50% Darker": BrightnessFilter(0.5),
        "50% Brighter": BrightnessFilter(1.5),
        "2x Contrast": ContrastFilter(2.0)
    ]
    
    public func addFilter(_ name: String, filter: Filter) {
        filters.updateValue(filter, forKey: name)
    }

    public func applyFilters(_ image: UIImage, filters: [String]) -> UIImage! {
        var rgbaImage = RGBAImage(image: image)!
        var count = 0
        print("Processing image (\(rgbaImage.width)x\(rgbaImage.height))")
        for name in filters {
            if let filter = self.filters[name] {
                print("Applying filter: \"\(name)\"")
                filter.applyToImage(&rgbaImage)
                count += 1
            } else {
                print("Filter \"\(name)\" not recognized")
            }
        }
        print("\(count) filter(s) applied")
        return rgbaImage.toUIImage()
    }
}

// Process the image!

var imageProcessor = ImageProcessor()

let result = imageProcessor.applyFilters(image, filters: ["Grey Scale", "50% Darker"])
