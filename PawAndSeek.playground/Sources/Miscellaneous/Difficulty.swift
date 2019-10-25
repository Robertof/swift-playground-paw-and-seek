import UIKit

/// Difficulty levels.
public enum Difficulty {
    case easy, medium, hard
    
    /// The possible number of animals that can be added to the scenario.
    var possibleNumberOfAnimals: ClosedRange<Int> {
        switch self {
        case .easy:
            return 2...3
        case .medium:
            return 4...6
        case .hard:
            return 7...9
        }
    }
    
    /// Provides a finite value for the number of animals randomly chosen from the possible
    /// values.
    var numberOfAnimals: Int {
        return Int.random (in: self.possibleNumberOfAnimals)
    }
    
    /// How much the animals will be shrank according to the difficulty.
    var shrinkFactor: CGFloat {
        switch self {
        case .easy:
            return 12
        case .medium:
            return 14
        case .hard:
            return 16
        }
    }
}
