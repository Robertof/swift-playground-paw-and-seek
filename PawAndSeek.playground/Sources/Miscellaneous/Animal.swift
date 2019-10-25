import UIKit

extension CGRect {
    /// Finds and returns a random point within a `CGRect`.
    ///
    /// - Returns: a randm point within the given `CGRect`.
    func randomPoint() -> CGPoint {
        return CGPoint(
            x: .random (in: 0...self.width)  + self.origin.x,
            y: .random (in: 0...self.height) + self.origin.y
        )
    }
    
    /// Calculates and returns the distance from a given point to this rectangle.
    ///
    /// - Parameter point: a point for which you'd like to know the distance.
    /// - Returns: The distance between `point` and this rectangle.
    func distance (fromPoint point: CGPoint) -> CGFloat {
        let distanceX = max (self.minX - point.x, point.x - self.maxX, 0)
        let distanceY = max (self.minY - point.y, point.y - self.maxY, 0)
        // The distance is either the hypotenuse of the triangle with `distanceX` and `distanceY`
        // as its sides or the value which is non-zero.
        return distanceX * distanceY == 0
            ? max (distanceX, distanceY)
            : hypot (distanceX, distanceY)
    }
}

/// Animals!
public enum Animal: String {
    case 🐮, 🐶, 🐱, 🐷, 🐰, 🐴, 🐵
    
    /// The font size of the emojis is calculated by dividing the smallest screen dimension by
    /// a shrink factor. This can be changed according to the game difficulty, and defaults to
    /// `8`.
    public static var shrinkFactor: CGFloat = 8
    
    /// The font size of the emoijs. See also `shrinkFactor`.
    static var fontSize: CGFloat {
        return min (
            UIScreen.main.bounds.size.width,
            UIScreen.main.bounds.size.height
        ) / Animal.shrinkFactor
    }
    
    /// The `UIFont` with the correct size used by the labels.
    static var font: UIFont {
        return UIFont.systemFont (ofSize: Animal.fontSize)
    }
    
    /// The emoji.
    var emoji: String {
        return self.rawValue
    }
    
    /// The animal name.
    var name: String {
        switch self {
        case .🐮:
            return "cow"
        case .🐵:
            return "monkey"
        case .🐶:
            return "dog"
        case .🐱:
            return "cat"
        case .🐷:
            return "pig"
        case .🐰:
            return "rabbit"
        case .🐴:
            return "horse"
        }
    }
    
    /// Facts and sources about all of the animals.
    var facts: (source: String, elements: [String]) {
        switch self {
        case .🐮:
            return (
                source: "Dairy Moos",
                elements: [
                    "Cows can hear lower and higher frequencies better than humans",
                    "The average cow chews at least 50 times per minute",
                    "Cows have a single stomach, but four different digestive compartments",
                    "The average cow drinks 30 to 50 gallons of water each day",
                    "Cows only have teeth on the bottom"
                ]
            )
        case .🐵:
            return (
                source: "LiveScience",
                elements: [
                    "If there is a lack of food, female monkeys will stop mating until there are better circumstances for getting pregnant",
                    "When a troop of howler monkeys yell, they can be heard for up to three miles",
                    "Monkeys express affection and make peace with others by grooming each other",
                    "Monkeys are omnivores, so they eat meat and plant-based foods",
                    "The world's smallest monkey is the pygmy marmoset, it weighs only around 4 ounces and is only around 5 inches tall"
                ]
            )
        case .🐶:
            return (
                source: "MSPCA",
                elements: [
                    "Dogs do not sweat by salivating, they sweat through the pads of their feet",
                    "Dogs have over 200 million scent receptors in their noses",
                    "An adult dog has 42 teeth",
                    "Dogs do see in color, just not as vivid as we see",
                    "When a puppy is born, he is blind, deaf, and toothless"
                ]
            )
        case .🐱:
            return (
                source: "Purina",
                elements: [
                    "Cats can see up to 6 times better than humans in low light thanks to a reflective layer in their eyes",
                    "More cats are left-pawed than right",
                    "Cats can travel at speeds of up to 18 mph",
                    "The collective nouns used for cats and kittens are a clowder of cats and a kindle of kittens",
                    "Cats have 32 muscles in their ears"
                ]
            )
        case .🐷:
            return (
                source: "National Geographic",
                elements: [
                    "Despite their reputation, pigs are not dirty animals",
                    "Pigs eat everything from leaves, roots, and fruit to rodents and small reptiles",
                    "Pigs are among the smartest of all domesticated animals and are even smarter than dogs",
                    "Fully grown, pigs can grow to between 300 and 700 pounds",
                    "Pigs have poor eyesight, but a great sense of smell"
                ]
            )
        case .🐰:
            return (
                source: "Blue Cross",
                elements: [
                    "Rabbits can turn their ears 180 degrees and can pinpoint the exact location of a sound",
                    "Baby rabbits are called kittens",
                    "Rabbits have almost 360 degree vision but they are born with their eyes shut",
                    "Rabbits are social creatures and are happiest in the company of their own species",
                    "Rabbits and guinea pigs don’t make good pals"
                ]
            )
        case .🐴:
            return (
                source: "Double Trailers",
                elements: [
                    "Horses have the largest eyes of any land mammal",
                    "A horse's teeth take up a larger amount of space in their head than their brain",
                    "Horses can sleep both lying down and standing up",
                    "The fastest recorded sprinting speed of a horse was 55 mph",
                    "Horses use their ears, eyes and nostrils to express their mood"
                ]
            )
        }
    }
    
    /// Sound effects for the animals.
    var soundPath: URL? {
        return URL (fileURLWithPath:
            Bundle.main.path (forResource: self.name, ofType: "mp3") ?? "")
    }
    
    /// The size occupied by this animal's emoji. This is calculated according to `Animal.font` and
    /// the emoji character used by this animal.
    var size: CGSize {
        return self.emoji.boundingRect (
            with: CGSize (width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            attributes: [.font: Animal.font],
            context: nil
        ).size
    }
    
    /// Returns a random fact about this animal.
    func randomFact() -> String {
        return self.facts.elements.randomElement()!.lowercased()
    }
    
    /// Adds this animal to the specified view in a random position between `zone`. Tries to avoid
    /// animals laying on top of each other, but it's not guaranteed.
    ///
    /// - Parameters:
    ///   - view: The view where the corresponding `AnimalView` will be inserted.
    ///   - zone: A relative `CGRect` specifying where the animal can lay.
    /// - Returns: The created `AnimalView`.
    @discardableResult func add (to view: UIView, randomlyIn zone: CGRect) -> AnimalView {
        // Get a random point from within the given zone.
        // The trick here is that `zone` is specified using relative coordinates -- that means that
        // it does not depend on the size of the screen and works everywhere. The downside is that
        // when doing collision calculation logic, it needs to be converted back to absolute
        // coordinates.
        var position = zone.randomPoint()
        // The anti-collision logic begins here.
        do {
            // This closure converts a relative `CGPoint` to an absolute `CGRect` with the correct
            // dimensions.
            let makePositionRect = { (position: CGPoint?) -> CGRect? in
                guard let position = position else {
                    return nil
                }
                var rect = CGRect (origin: position, size: self.size)
                // Transform from relative to absolute dimensions.
                rect.origin.x *= UIScreen.main.bounds.width
                rect.origin.y *= UIScreen.main.bounds.height
                return rect
            }
            // The initial, generated, position rectangle.
            var positionRect = makePositionRect (position)!
            // How many tries are left to generate a different, non-colliding position.
            var triesLeft = 5
            // Until there's another animal which intersects with this one (and there are enough
            // tries left), generate another position and try again.
            while triesLeft > 0, (view.subviews.contains {
                makePositionRect (($0 as? AnimalView)?.position)?.intersects(positionRect) ?? false
            }) {
                position = zone.randomPoint()
                positionRect = makePositionRect (position)!
                triesLeft -= 1
            }
        }
        // Finally, create the `AnimalView` at the generated position and place it.
        let animalView = AnimalView (withAnimal: self, atPosition: position)
        view.addSubview (animalView)
        return animalView
    }
}
