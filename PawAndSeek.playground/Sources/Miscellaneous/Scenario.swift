import UIKit

extension CGRect {
    /// Applies a given function to a rectangle using the specified size object. Returns the
    /// altered `CGRect`.
    func apply (_ fn: (CGFloat, CGFloat) -> CGFloat, _ size: CGSize) -> CGRect {
        return CGRect(x: fn (self.origin.x, size.width),
                      y: fn (self.origin.y, size.height),
                      width: fn (self.size.width, size.width),
                      height: fn (self.size.height, size.height))
    }
}

/// Game scenarios.
public enum Scenario {
    case farm, savanna, forest, snowyForest
    
    /// The image associated to the scenario.
    var image: UIImage {
        switch self {
        case .farm:
            return UIImage(named: "background-farm.jpg")!
        case .savanna:
            return UIImage(named: "background-savanna.jpg")!
        case .forest:
            return UIImage(named: "background-forest.jpg")!
        case .snowyForest:
            return UIImage(named: "background-snowy-forest.jpg")!
        }
    }
    
    /// The size of this scenario.
    var size: CGSize {
        switch self {
        case .farm:
            return CGSize (width: 1920, height: 1080)
        case .savanna:
            return CGSize (width: 1920, height: 1280)
        case .forest:
            return CGSize (width: 1920, height: 1017)
        case .snowyForest:
            return CGSize (width: 1920, height: 1807)
        }
    }
    
    /// The usable rectangle of this zone. Note that this is a relative rectangle and is calculated
    /// according to the dimensions of the background itself. This is to allow smooth and easy
    /// automatic resizing using AutoLayout.
    var usableZone: CGRect {
        switch self {
        case .farm:
            return CGRect (
                x: 0,
                y: 614,
                width: 1920,
                height: 1080 - 614
            ).apply (/, self.size)
        case .savanna:
            return CGRect (
                x: 0,
                y: 1280 - 272,
                width: 1920,
                height: 272
            ).apply (/, self.size)
        case .forest:
            return CGRect (
                x: 0,
                y: 1017 - 285,
                width: 1920,
                height: 285
            ).apply (/, self.size)
        case .snowyForest:
            return CGRect (
                x: 0,
                y: 1807 - 355,
                width: 1920,
                height: 355
            ).apply (/, self.size)
        }
    }
}
