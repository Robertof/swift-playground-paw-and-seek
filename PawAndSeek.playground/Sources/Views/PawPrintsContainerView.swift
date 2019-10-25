import UIKit

class PawPrintsContainerView: UIView {
    /// The image used to represent a paw.
    private lazy var pawPrintImage = UIImage(named: "paw-fixed.png")
    /// The user-specified size for the paw prints.
    private let pawPrintSize: CGFloat
    /// The last generated animator.
    private var lastAnimator: UIViewPropertyAnimator? = nil
    /// The number of paw prints.
    /// - `real` corresponds to the real (effective) number of paw prints currently held.
    /// - `theoretical` corresponds to the number of paw prints which fit in the screen.
    /// In reality, `real` should be greater than or equal than `theoretical` - however,
    /// this can change if the screen becomes larger -- in that case, `layoutSubviews` takes care
    /// of that.
    private var numberOfPawPrints: (theoretical: Int, real: Int) {
        return (
            theoretical: Int (ceil (UIScreen.main.bounds.size.width / self.pawPrintSize)),
            real: self.subviews.count
        )
    }
    
    init (withPawPrintSize size: CGFloat) {
        self.pawPrintSize = size
        super.init (frame: .zero)
        // Disable auto-constraint creation.
        self.translatesAutoresizingMaskIntoConstraints = false
        // Start generating the single paw prints and retrieve the effective paw print height.
        let scaledHeight = self.generatePawPrints (until: self.numberOfPawPrints.theoretical)
        // The last constraint, applied on the root view, ensures that the height is exactly
        // scaledHeight * 2, to allow enough space for both paw prints to fit.
        self.heightAnchor
            .constraint (equalToConstant: scaledHeight * 2)
            .isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult private func generatePawPrints (
        startingFrom start: Int = 1,
        until end: Int,
        visible: Bool = false
    ) -> CGFloat {
        // Extract useful information about the paw print image.
        guard let pawPrintImage = self.pawPrintImage else {
            fatalError("Unable to retrieve the image associated to the paw print!")
        }
        let aspectRatio = pawPrintImage.size.height / pawPrintImage.size.width
        let scaledHeight = self.pawPrintSize * aspectRatio
        // Generate the individual subviews and constraint them.
        var previousPaw = self.subviews.last // The last added paw for relative positioning.
        for pawIndex in start...end {
            // A Paw View is simply an ImageView with the appropriate image set.
            let pawView = UIImageView (image: self.pawPrintImage)
            // Immediately add the new Paw View to the root.
            self.addSubview (pawView)
            // Apply a 90° rotation to the image (temporary - will do this on the asset itself).
            pawView.transform = .init(rotationAngle: .pi / 2)
            // Again, ensure no constraints are created based on the autoresizing mask.
            pawView.translatesAutoresizingMaskIntoConstraints = false
            if !visible {
                // In normal conditions, paws start with the alpha set to 0 -- it is then animated
                // once the master ViewController is ready.
                pawView.alpha = 0
            }
            // Add the constraints.
            // A. Ensure the requested width and height are respected.
            pawView.widthAnchor
                .constraint (equalToConstant: self.pawPrintSize)
                .isActive = true
            pawView.heightAnchor
                .constraint (equalTo: pawView.widthAnchor, multiplier: aspectRatio)
                .isActive = true
            // B. Horizontal positioning
            // This is more complex than it looks, because the paw prints need to follow an
            // "alternate" viewing style, like this:
            // 🐾   🐾   🐾
            //    🐾   🐾   🐾
            // To do so, the leading constraint of this paw print is attached to the trailing of
            // the previous one. The only exception is if no paw prints have been added yet - in
            // that case, the leading constraint of the root view is used.
            pawView.leadingAnchor
                .constraint (equalTo: previousPaw?.trailingAnchor ?? self.leadingAnchor)
                .isActive = true
            // C. Vertical positioning
            // This is tricky as well, because the paw prints need to be offset one by one.
            // To do this, `pawIndex` is checked -- if it is odd, then no spacing is necessary,
            // otherwise, this paw print is pushed down.
            pawView.topAnchor
                .constraint (equalTo: self.topAnchor,
                             constant: pawIndex % 2 == 0 ? scaledHeight : 0)
                .isActive = true
            // The final step is to update the last added paw.
            previousPaw = pawView
        }
        return scaledHeight
    }
    
    /// Generates an `UIViewPropertyAnimator` which displays the paw prints with a specified
    /// interval between each animation.
    ///
    /// - Parameter delay: The delay between each single paw print animation.
    /// - Returns: A suspended `UIViewPropertyAnimator` usable to start the animation.
    func animator (withProgressiveDelay delay: Double = 0.15) -> UIViewPropertyAnimator {
        // Retrieve the number of paw prints according to the number of subviews.
        let numberOfPawPrints = Double (self.subviews.count)
        // The total duration of the animation is given by the longest progressive delay
        // (obtained with numberOfPawPrints * delay) plus the duration of one animation (1s).
        let totalDuration = delay * numberOfPawPrints
        // Here's the trick: to give a proper "progressive" paw print animation, we employ the
        // relatively new UIViewPropertyAnimator plus keyframes. Thanks to UIViewPropertyAnimator,
        // the animation can be started when needed (e.g. when the container view initializes), and
        // thanks to the magic of keyframes no "callback hell" code is required to to start the
        // animations with the correct delay and duration.
        // Thanks to WWDC17 session 230 "Advanced Animations with UIKit" for inspiration!
        let animator = UIViewPropertyAnimator (duration: totalDuration, curve: .linear) {
            // NOTE: the linear curve is required because otherwise any other easing is applied
            // to each key frame sub-animation.
            UIView.animateKeyframes (withDuration: totalDuration, delay: 0.0, options: [], animations: {
                // The total delay, accumulated throughout each iteration.
                var accumulatedDelay = 0.0
                // Iterate for each paw print subview.
                for pawPrint in self.subviews {
                    UIView.addKeyframe (
                        // Here's the trick: keyframe values are relative, so we just provide
                        // relative values using `totalDuration` as a reference.
                        withRelativeStartTime: accumulatedDelay / totalDuration,
                        // Just one second per paw print.
                        relativeDuration: 1.0 / totalDuration,
                        animations: {
                            // That's it!
                            pawPrint.alpha = 1
                        }
                    )
                    // Increase the accumulator with each iteration.
                    accumulatedDelay += delay
                }
            })
        }
        animator.pausesOnCompletion = true
        self.lastAnimator = animator
        return animator
    }
    
    override func layoutSubviews() {
        // Ensure that if more paw prints fit the screen than the current number, more are
        // generated.
        if self.numberOfPawPrints.real < self.numberOfPawPrints.theoretical {
            // More paw prints have to be generated -- however, how this is done depends on the
            // animation status.
            // - if no animation has been started yet (or there are no animators), then new paw
            //   prints are added with the default visibility.
            // - if an animation is in progress, ouch - this is an issue! No changes can be done
            //   to the running animator, so the new paw prints will be visible.
            // - if if the animation is completed, just make them visible straight away.
            let willBeVisible = self.lastAnimator == nil ||
                self.lastAnimator?.state != UIViewAnimatingState.inactive
            self.generatePawPrints (startingFrom: self.numberOfPawPrints.real + 1,
                                    until: self.numberOfPawPrints.theoretical,
                                    visible: willBeVisible)
        }
    }
}
