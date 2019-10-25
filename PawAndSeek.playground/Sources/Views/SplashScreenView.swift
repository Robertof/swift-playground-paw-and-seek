import UIKit

class SplashScreenView: UIView {
    private(set) var pawAnimator: UIViewPropertyAnimator!
    
    init() {
        super.init (frame: .zero)
        self.isUserInteractionEnabled = false
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        // Step 1: configure and add the "paw prints" container view.
        let pawPrintsHolder = PawPrintsContainerView (withPawPrintSize: 50)
        self.addSubview (pawPrintsHolder)
        NSLayoutConstraint.activate([
            pawPrintsHolder.centerYAnchor.constraint (equalTo: self.centerYAnchor),
            pawPrintsHolder.leadingAnchor.constraint (equalTo: self.leadingAnchor, constant: -15),
            pawPrintsHolder.trailingAnchor.constraint (equalTo: self.trailingAnchor)
        ])
        self.pawAnimator = pawPrintsHolder.animator (withProgressiveDelay: 0.2)
        // Step 2: configure and add the "title" label.
        let titleLabel = UILabel()
        // Use a creative font with a lage size.
        titleLabel.font = UIFont(name: "Chalkduster", size: 90)
        // Ensure the title text auto-sizes.
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.baselineAdjustment = .alignCenters
        titleLabel.numberOfLines = 1
        titleLabel.minimumScaleFactor = 0.05
        // Add shadows and colors.
        titleLabel.shadowColor = .white
        titleLabel.textColor = .black
        titleLabel.shadowOffset = CGSize (width: 3, height: 3)
        // Text.
        titleLabel.text = "Paw 'n Seek"
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview (titleLabel)
        // Center vertically, horizontally and make it 90% of the container view's width.
        NSLayoutConstraint.activate ([
            titleLabel.centerXAnchor.constraint (equalTo: self.centerXAnchor),
            titleLabel.centerYAnchor.constraint (equalTo: self.centerYAnchor),
            titleLabel.widthAnchor.constraint   (equalTo: self.widthAnchor, multiplier: 0.8)
        ])
        // Step 3: add a label which reminds the user to increase the volume.
        let volumeLabel = UILabel()
        var volumeStates =  ["🔉", "🔊", "🔈"]
        volumeLabel.font = UIFont.systemFont(ofSize: 48)
        volumeLabel.text = volumeStates.last
        volumeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview (volumeLabel)
        NSLayoutConstraint.activate ([
            volumeLabel.centerXAnchor.constraint (equalTo: self.centerXAnchor, constant: 0),
            volumeLabel.bottomAnchor.constraint  (equalTo: self.bottomAnchor,  constant: -50)
        ])
        // Animate it.
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] timer in
            // If this view gets hidden or unloaded, immediately stop the timer and release every
            // resource.
            guard let self = self, !self.isHidden, self.alpha > 0 else {
                timer.invalidate()
                return
            }
            let nextState = volumeStates.removeFirst()
            volumeLabel.text = nextState
            volumeStates.append (nextState)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
