//: Playground - noun: a place where people can play

import UIKit

let image = UIImage(named: "sample")!

// MARK: - Filters

// Base filter class.
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

// Brightness filter.
//
// Increase or decrease the intensity of each pixel in the image by the given
// factor. A factor less than 1 will darken the image and a factor greater
// than 1 will make it brighter.
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

// Contrast filter.
//
// Adjust the contrast of the image by the given factor. The intensity of each
// pixel is adjusted by calculating the different between the pixel and the
// average brightness, multiplying this value by the given factor, then
// adding or subtracting this from the average brightness.
//
// For the sake of simplicity, the average grey scale is used as the average
// brightness.
public class ContrastFilter: Filter {
    private var factor: Double
    private var average: UInt8 = 0
    
    public init(_ factor: Double = 1.0) {
        self.factor = factor
    }

    override public func applyToImage(_ image: inout RGBAImage) {
        // Calculate average grey scale
        var total = 0
        for i in 0..<(image.width * image.height) {
            let pixel = image.pixels[i]
            total += Int(Double(pixel.red) * 0.3 + Double(pixel.green) * 0.59 + Double(pixel.blue) * 0.11)
        }
        average = UInt8(total / (image.width * image.height))
        // Process the image
        super.applyToImage( &image)
    }
    
    override func applyToPixel(_ pixel: inout Pixel) {
        if factor == 1 {
            return
        }
        pixel.red = calculateComponentValue(pixel.red)
        pixel.green = calculateComponentValue(pixel.green)
        pixel.blue = calculateComponentValue(pixel.blue)
    }
    
    private func calculateComponentValue(_ value: UInt8) -> UInt8 {
        // The component value is calculated as the average brightness +/-
        // the coefficient multiplied by the difference between the component
        // value and the average brightness
        return UInt8(max(0, min(255, Double(average) + factor * (Double(value) - Double(average)))))
    }
}

// Negative filter.
public class NegativeFilter: Filter {
    override func applyToPixel(_ pixel: inout Pixel) {
        pixel.red = 255 - pixel.red
        pixel.green = 255 - pixel.green
        pixel.blue = 255 - pixel.blue
    }
}

// Grey scale filter.
//
// Convert the image to grey scale. A luminance method is used to calculate the
// grey scale of each pixel which applies a weighting to each of the RGB
// components of the pixel.
//
// See:
// https://en.wikipedia.org/wiki/Grayscale
public class GreyScaleFilter: Filter {
    override func applyToPixel(_ pixel: inout Pixel) {
        let grey = calculateGreyScale(pixel)
        pixel.red = grey
        pixel.green = grey
        pixel.blue = grey
    }

    func calculateGreyScale(_ pixel: Pixel) -> UInt8 {
        // Calculate grey scale based on luminance
        return UInt8(0.3 * Double(pixel.red) + 0.59 * Double(pixel.green) + 0.11 * Double(pixel.blue))
    }
}

// Black and white filter.
//
// Convert the image to black and white. Each pixel is set to black (#00) or
// white (#FF), depending whether its grey scale value is less than or greater
// than the mid-point. The mid-point is 127 by default and adjusted by a given
// factor, to make the image more black or white as required.
public class BlackAndWhiteFilter: GreyScaleFilter {
    var mid: UInt8

    public init(_ factor: Double = 1.0) {
        // Adjust the mid-point by the given factor
        mid = UInt8(255 / 2 / factor)
    }

    override func calculateGreyScale(_ pixel: Pixel) -> UInt8 {
        // Calculate black or white based on whether the grey scale value of
        // the pixel falls above or below the mid-point.
        return super.calculateGreyScale(pixel) > mid ? 255 : 0
    }
}

// Opacity filter.
//
// Set the opacity of the image. An opacity less than 1 will make the image more
// transparent and an opacity of 1 will make the image opaque.
public class OpacityFilter: Filter {
    var opacity: Double  // transparent < > opaque

    public init(_ opacity: Double = 1.0) {
        self.opacity = max(0, min(1, opacity))
    }

    override func applyToPixel(_ pixel: inout Pixel) {
        pixel.alpha = UInt8(255 * opacity)
    }
}

// MARK: - Processor

// Image processor.
//
// Apply a list of filters to a give image. There are a number of predefined
// filters that can be applied or new filters can be added and applied. Filters
// are applied in the order specified when calling `applyFilters`.
public class ImageProcessor {
    var filters: [String: Filter] = [
        // Predefined filters
        "Grey Scale": GreyScaleFilter(),
        "50% Darker": BrightnessFilter(0.5),
        "50% Brighter": BrightnessFilter(1.5),
        "2x Contrast": ContrastFilter(2.0),
        "Negative": NegativeFilter(),
        "BlackAndWhite": BlackAndWhiteFilter(),
        "100% Opactity": OpacityFilter(1.0),
        "50% Opacity": OpacityFilter(0.5)
    ]

    public func addFilter(_ name: String, filter: Filter) {
        filters.updateValue(filter, forKey: name)
    }

    public func applyFilters(_ image: UIImage, filters: [String]) -> UIImage! {
        // Apply the list of filters (by name) to the given image
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

// MARK: - Process the image!

var imageProcessor = ImageProcessor()

//let result = imageProcessor.applyFilters(image, filters: ["Grey Scale", "50% Darker"])
//let result = imageProcessor.applyFilters(image, filters: ["2x Contrast", "50% Brighter"])
//let result = imageProcessor.applyFilters(image, filters: ["Negative"])
//let result = imageProcessor.applyFilters(image, filters: ["BlackAndWhite"])
let result = imageProcessor.applyFilters(image, filters: ["50% Opacity"])
