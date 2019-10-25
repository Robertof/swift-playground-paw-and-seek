import UIKit

class AnimalView: UILabel {
    let animal: Animal
    var position: CGPoint
    var createPositionBasedConstraints = true
    var hasBeenFound: Bool = false {
        didSet {
            self.text = animal.rawValue
            self.sizeToFit()
        }
    }
    
    init (withAnimal animal: Animal, atPosition position: CGPoint) {
        // Save the specified parameters.
        self.animal = animal
        self.position = position
        // The frame will be properly sized later.
        super.init (frame: .zero)
        self.font = Animal.font
        // Randomly flip this animal to add more depth.
        self.transform = Bool.random() ? .init(scaleX: -1, y: 1) : .identity
        // Set the emoji!
        self.text = animal.emoji
        self.isUserInteractionEnabled = false
        self.translatesAutoresizingMaskIntoConstraints = false
        // Size the label appropriately.
        self.sizeToFit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        if let superview = self.superview, self.createPositionBasedConstraints {
            NSLayoutConstraint.activate([
                NSLayoutConstraint(item: self,
                                   attribute: .top,
                                   relatedBy: .equal,
                                   toItem: superview,
                                   attribute: .bottom,
                                   multiplier: max (min (self.position.y, 1), .leastNormalMagnitude),
                                   constant: position.y * -self.frame.size.height + 15),
                NSLayoutConstraint(item: self,
                                   attribute: .leading,
                                   relatedBy: .equal,
                                   toItem: superview,
                                   attribute: .trailing,
                                   multiplier: max (min (self.position.x, 1), .leastNormalMagnitude),
                                   constant: position.x * -self.frame.size.width)
            ])
        }
    }
}
