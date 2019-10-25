import UIKit

class OverlayView: UIView {
    lazy var maskLayer = CAShapeLayer()
    
    var lastAnimation: CABasicAnimation? = nil
    
    override func didMoveToSuperview() {
        self.backgroundColor = .black
        // Create the mask layer used to display the oval opening.
        self.maskLayer.frame = self.bounds
        self.maskLayer.fillColor = UIColor.black.cgColor
        self.maskLayer.fillRule = .evenOdd
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // When the view size changes, reset the mask layer.
        self.maskLayer.frame = self.bounds
        self.layer.mask = nil
    }
    
    /// Reveals a section positioned at a determined point displaying a circle of the specified
    /// radius.
    func revealSection (positionedAt point: CGPoint, radius: CGFloat, completion: (() -> Void)? = nil) {
        // This "reveals" a section and shows what is underneath it. This is accomplished
        // by masking the content of this view (a solid black color) with a CALayer.
        // First, create the path corresponding to the full circle.
        let fullCirclePath = UIBezierPath (rect: self.bounds)
        fullCirclePath.append (UIBezierPath (ovalIn: CGRect (x: point.x - radius,
                                                             y: point.y - radius,
                                                             width: 2 * radius,
                                                             height: 2 * radius)))
        // Then create the path corresponding to an empty circle in the same position to make the
        // animation possible.
        let emptyCirclePath = UIBezierPath (rect: self.bounds)
        emptyCirclePath.append (UIBezierPath (ovalIn: CGRect (x: point.x,
                                                              y: point.y,
                                                              width: 0,
                                                              height: 0)))
        // Animate!
        self.animatePath(from: emptyCirclePath.cgPath,
                         to: fullCirclePath.cgPath,
                         completion: completion)
        self.layer.mask = self.maskLayer
    }
    
    /// Hides the currently shown section.
    func hideCurrentlyShownSection (completion: (() -> Void)? = nil) {
        guard let lastAnimation = self.lastAnimation else {
            return
        }
        self.animatePath(from: lastAnimation.toValue   as! CGPath,
                         to:   lastAnimation.fromValue as! CGPath,
                         completion: completion)
    }
    
    /// Animates the removal of the mask layer and removes this view from the superview.
    func revealAllAndRemoveFromSuperview() {
        guard let lastAnimation = self.lastAnimation else {
            return
        }
        let filledPath = UIBezierPath (rect: self.bounds)
        filledPath.append (UIBezierPath (rect: self.bounds))
        self.animatePath(
            from: lastAnimation.toValue as! CGPath,
            to: filledPath.cgPath
        ) { self.removeFromSuperview() }
    }
    
    /// Animates a `CGPath`.
    private func animatePath (from: CGPath, to: CGPath, completion: (() -> Void)? = nil) {
        CATransaction.begin()
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.3
        animation.fromValue = from
        animation.toValue = to
        animation.timingFunction = CAMediaTimingFunction (name: .easeInEaseOut)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        CATransaction.setCompletionBlock(completion)
        self.maskLayer.add (animation, forKey: nil)
        CATransaction.commit()
        self.lastAnimation = animation
    }
}
