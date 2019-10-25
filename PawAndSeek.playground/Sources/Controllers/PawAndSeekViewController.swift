import UIKit
import Swift
import AVKit

open class PawAndSeekViewController: UIViewController {
    /// The game's possible states.
    enum GameState {
        /// In this state the game is waiting for the user to dismiss the splash screen.
        case waitingForInput
        case animating
        case playing
        case found (animal: AnimalView)
        case foundAndAwaitingDismissal (with: (_ completion: (() -> ())?) -> ())
        case won
    }
    
    /// The scenario where your animals will sneakily hide from you!
    public var scenario: Scenario = .snowyForest
    
    /// What animals are allowed to roam in this scenario!
    public var animals: [Animal] = [ .🐶 ]
    
    /// The difficulty level.
    public var difficulty: Difficulty = .easy
    
    // The view responsible for the splash screen.
    private lazy var splashScreenView = SplashScreenView()
    
    /// Contains the scenario's image.
    private lazy var backgroundView: UIImageView = {
        let view = UIImageView()
        view.image = self.scenario.image
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    /// An overlay which is appropriately masked according to the user's finger position during
    /// the main game stage.
    private lazy var overlayView: OverlayView = {
        let view = OverlayView()
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// The view which contains the other `AnimalView`s.
    private lazy var animalsContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    /// Holds cached AVAudioPlayer instances for each animal.
    private lazy var cachedPlayers: [Animal: AVAudioPlayer] = [:]
    
    /// The game's current state. It evolves as follows:
    /// - it starts with `waitingForInput` during the splash screen intro.
    /// - once something is pressed, the state transitions to `animating` which disables all
    ///   input while the splash screen is fading out and the overlay view is fading in.
    /// - at that point, the game enters the main playing stage with the state `playing`.
    /// - the state is set once again to `animating` during the on-tap animation to prevent further
    ///   input.
    /// - finally, if an animal is found the state is set to `found(animal: view)`, handled here,
    ///   and once it is ready to be dismissed it transitions to `foundAndAwaitingDismissal`. When
    ///   dismissed, the game comes back to normal and transitions to `playing`.
    private var gameState: GameState = .waitingForInput {
        didSet {
            // "found" state, which means that the animal has been found by the user.
            if case .found (let animalView) = self.gameState {
                // Move the animal out of its superview.
                animalView.removeFromSuperview()
                // Create a StackView which holds all the relevant information after the animal
                // was found.
                let foundDialog = UIStackView()
                foundDialog.spacing = 12
                foundDialog.axis = .vertical
                foundDialog.alignment = .center
                foundDialog.translatesAutoresizingMaskIntoConstraints = false
                // Configure and add the animal view.
                animalView.createPositionBasedConstraints = false
                
                foundDialog.addArrangedSubview (animalView)
                // Use separate blocks to configure the different labels.
                do {
                    let foundLabel = UILabel()
                    foundLabel.text = "You found a \(animalView.animal.name)!"
                    foundLabel.font = .boldSystemFont (ofSize: Animal.fontSize / 2)
                    foundLabel.textColor = .white
                    foundDialog.addArrangedSubview (foundLabel)
                }
                do {
                    let didYouKnowLabel = UILabel()
                    didYouKnowLabel.numberOfLines = 0
                    didYouKnowLabel.text = "Did you know that \(animalView.animal.randomFact())?"
                    didYouKnowLabel.font = .italicSystemFont (ofSize: 16)
                    didYouKnowLabel.textColor = .white
                    didYouKnowLabel.textAlignment = .center
                    foundDialog.addArrangedSubview (didYouKnowLabel)
                }
                // Put the StackView in a container to allow background color drawing and
                // fine-tuning of the margins using constraints.
                let container = UIView()
                // Purple as recommended by the Apple Human Interface Guidelines.
                container.backgroundColor = UIColor(red: 0 / 255,
                                                    green: 139 / 255,
                                                    blue: 96 / 255,
                                                    alpha: 1)
                container.translatesAutoresizingMaskIntoConstraints = false
                // Set `alpha` to 0 to allow animations.
                container.alpha = 0
                // Round the corners.
                container.layer.cornerRadius = 10
                container.addSubview(foundDialog)
                do {
                    // This label, which holds the source of the shown fact along with a tip which
                    // specifies how to keep playing, sits outside of the stack view.
                    let tapToDismissLabel = UILabel()
                    tapToDismissLabel.numberOfLines = 0
                    tapToDismissLabel.translatesAutoresizingMaskIntoConstraints = false
                    tapToDismissLabel.textAlignment = .center
                    tapToDismissLabel.text = """
                        source: \(animalView.animal.facts.source)
                        tap anywhere to dismiss
                    
                        \(self.animalsContainerView.subviews.count) left
                    """
                    tapToDismissLabel.font = .italicSystemFont (ofSize: 12)
                    tapToDismissLabel.textColor = .white
                    container.addSubview (tapToDismissLabel)
                    // Align with proper spacing.
                    tapToDismissLabel.topAnchor
                        .constraint (equalTo: container.bottomAnchor, constant: 20)
                        .isActive = true
                    tapToDismissLabel.centerXAnchor
                        .constraint (equalTo: container.centerXAnchor)
                        .isActive = true
                }
                // Position the StackView relative to the container, using 10pt margins.
                NSLayoutConstraint.activate ([
                    foundDialog.topAnchor.constraint (equalTo: container.topAnchor,
                                                      constant: 10),
                    foundDialog.leadingAnchor.constraint (equalTo: container.leadingAnchor,
                                                          constant: 10),
                    foundDialog.trailingAnchor.constraint (equalTo: container.trailingAnchor,
                                                           constant: -10),
                    foundDialog.bottomAnchor.constraint (equalTo: container.bottomAnchor,
                                                         constant: -10)
                ])
                self.view.addSubview (container)
                // Position the container.
                NSLayoutConstraint.activate ([
                    container.widthAnchor.constraint (equalTo: self.view.widthAnchor,
                                                      multiplier: 0.9),
                    container.centerXAnchor.constraint (equalTo: self.view.centerXAnchor),
                    container.centerYAnchor.constraint (equalTo: self.view.centerYAnchor)
                ])
                // Here's a neat trick: to allow dismissal of this "dialog" with a fade-out
                // animation, we update the state machine providing a black-box closure which
                // basically just fades out the view and removes it from the controller.
                // This allows to avoid unnecessary additional variables or the passing of the
                // view itself.
                let dismiss = { (completion: (() -> ())?) in
                    // Fade out with a 0.5s duration.
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.5,
                        delay: 0,
                        animations: { container.alpha = 0 },
                        completion: { _ in
                            container.removeFromSuperview()
                            completion?()
                        }
                    )
                    return
                }
                // Fade in with a 1s duration.
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 1,
                    delay: 0,
                    animations: { container.alpha = 1 },
                    completion: { _ in
                        // Once shown, this view is ready for dismissal.
                        self.gameState = .foundAndAwaitingDismissal (with: dismiss)
                    }
                )
            } else if case .won = self.gameState {
                // The user won, hooray! Add a cheerful label.
                let wonMsgContainer = UIStackView()
                wonMsgContainer.spacing = 12
                wonMsgContainer.axis = .vertical
                wonMsgContainer.alignment = .center
                wonMsgContainer.translatesAutoresizingMaskIntoConstraints = false
                do {
                    let congratulationsLabel = UILabel()
                    congratulationsLabel.text = "Congratulations!\nYou found all of them! 🎉"
                    congratulationsLabel.font = .boldSystemFont (ofSize: 24)
                    congratulationsLabel.textColor = .white
                    congratulationsLabel.shadowColor = .black
                    congratulationsLabel.numberOfLines = 0
                    congratulationsLabel.textAlignment = .center
                    wonMsgContainer.addArrangedSubview (congratulationsLabel)
                }
                do {
                    let greetingsLabel = UILabel()
                    greetingsLabel.text = "Hope you enjoyed this playground.\nHave a good day!"
                    greetingsLabel.font = .italicSystemFont (ofSize: 18)
                    greetingsLabel.textColor = .white
                    greetingsLabel.shadowColor = .black
                    greetingsLabel.numberOfLines = 0
                    greetingsLabel.textAlignment = .center
                    wonMsgContainer.addArrangedSubview (greetingsLabel)
                }
                self.view.insertSubview (wonMsgContainer, belowSubview: self.overlayView)
                NSLayoutConstraint.activate ([
                    wonMsgContainer.widthAnchor.constraint (equalTo: self.view.widthAnchor,
                                                            multiplier: 0.9),
                    wonMsgContainer.centerXAnchor.constraint (equalTo: self.view.centerXAnchor),
                    wonMsgContainer.centerYAnchor.constraint (equalTo: self.view.centerYAnchor)
                ])
            }
        }
    }
    
    func generateAnimals() {
        // Set the shrink factor according to the selected difficulty.
        Animal.shrinkFactor = self.difficulty.shrinkFactor
        // Generate all of them!
        for _ in 1...self.difficulty.numberOfAnimals {
            self.animals.randomElement()?.add (to: self.animalsContainerView,
                                               randomlyIn: self.scenario.usableZone)
        }
    }
    
    open override func loadView() {
        let rootView = UIView()
        rootView.backgroundColor = .white
        // The container of the animals -- basically just a View which holds AnimalViews. Defaults
        // hidden.
        rootView.addSubview (self.animalsContainerView)
        // It's as large as the superview, however only a portion of it is used according to the
        // scenario's usable zone.
        NSLayoutConstraint.activate ([
            self.animalsContainerView.topAnchor.constraint (equalTo: rootView.topAnchor),
            self.animalsContainerView.leadingAnchor.constraint (equalTo: rootView.leadingAnchor),
            self.animalsContainerView.trailingAnchor.constraint (equalTo: rootView.trailingAnchor),
            self.animalsContainerView.bottomAnchor.constraint (equalTo: rootView.bottomAnchor)
        ])
        // Splash screen.
        rootView.addSubview (self.splashScreenView)
        NSLayoutConstraint.activate ([
            self.splashScreenView.heightAnchor.constraint (equalTo: rootView.heightAnchor),
            self.splashScreenView.widthAnchor.constraint (equalTo: rootView.widthAnchor)
        ])
        // Overlay view -- hides everything and shows the finger's position. Defaults hidden.
        rootView.addSubview (self.overlayView)
        NSLayoutConstraint.activate ([
            self.overlayView.leadingAnchor.constraint (equalTo: rootView.leadingAnchor),
            self.overlayView.topAnchor.constraint (equalTo: rootView.topAnchor),
            self.overlayView.widthAnchor.constraint (equalTo: rootView.widthAnchor),
            self.overlayView.heightAnchor.constraint (equalTo: rootView.heightAnchor)
        ])
        // Generate all the little animals!
        self.generateAnimals()
        // Background view.
        rootView.addSubview (self.backgroundView)
        NSLayoutConstraint.activate ([
            self.backgroundView.leadingAnchor.constraint (equalTo: rootView.leadingAnchor),
            self.backgroundView.topAnchor.constraint (equalTo: rootView.topAnchor),
            self.backgroundView.widthAnchor.constraint (equalTo: rootView.widthAnchor),
            self.backgroundView.heightAnchor.constraint (equalTo: rootView.heightAnchor)
        ])
        rootView.sendSubviewToBack (self.backgroundView)
        self.view = rootView
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Animate the paws!
        self.splashScreenView.pawAnimator.startAnimation (afterDelay: 0.5)
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch self.gameState {
        // State: waiting for input.
        // Happens when the splash screen is still shown.
        case .waitingForInput:
            self.gameState = .animating
            // Get rid of the splash screen and show the overlay view.
            UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.5, delay: 0, animations: {
                self.splashScreenView.alpha = 0
            }) { _ in
                self.splashScreenView.isHidden = true
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 1,
                    delay: 0,
                    animations: { self.overlayView.alpha = 1 },
                    completion: { _ in
                        // We're playing!
                        self.gameState = .playing
                        self.animalsContainerView.isHidden = false
                    }
                )
            }
        // State: playing.
        // Normal game state.
        case .playing:
            guard let touch = touches.first else {
                return
            }
            // Animate the "reveal" of the section underneath.
            self.gameState = .animating
            var intersectedView: AnimalView? = nil
            var closestView: (distance: CGFloat, view: AnimalView)?
            let touchLocation = touch.location(in: self.view)
            // Find intersections of the tapped zone within existing animals in the screen.
            for subview in self.animalsContainerView.subviews {
                guard let subview = subview as? AnimalView else {
                    continue
                }
                if subview.point (inside: touch.location (in: subview), with: event) {
                    intersectedView = subview
                    closestView = (distance: 0, view: subview)
                    break
                }
                let distanceFromTouch = subview.frame.distance (fromPoint: touchLocation)
                if closestView == nil || closestView!.distance > distanceFromTouch {
                    closestView = (distance: distanceFromTouch, view: subview)
                }
                
            }
            // Reveal the tapped section and warn the user that he won if he found the
            // intersection!
            self.overlayView.revealSection (
                // Position the reveal circle right where the user tapped.
                positionedAt: touch.location (in: self.view),
                // The radius is a little larger than the emoji container to make the game easier.
                radius: (intersectedView?.animal.size.width ?? Animal.🐮.size.width) / 1.5
            ) {
                // Handle sounds.
                if let closestView = closestView {
                    // If there is no cached player for this animal, initialize a new one.
                    if self.cachedPlayers[closestView.view.animal] == nil {
                        if let soundFile = closestView.view.animal.soundPath {
                            self.cachedPlayers[closestView.view.animal]
                                = try? AVAudioPlayer(contentsOf: soundFile)
                        }
                    }
                    // Retrieve the cached player.
                    if let player = self.cachedPlayers[closestView.view.animal] {
                        // Now this is interesting. To make the game interesting, the user should
                        // have the impression of sounds coming from the animal themselves.
                        if intersectedView != nil {
                            // First, if the user actually found the hidden animal, play the sound
                            // with the maximum intensity and with no specific position.
                            player.pan = 0
                            player.volume = 1
                        } else {
                            // Otherwise, calculate the horizontal distance between the tapped
                            // point and the closest view.
                            let dx = closestView.view.frame.minX - touchLocation.x
                            // Calculate the relative distance according to the view size.
                            let relativeDistance = dx /
                                (self.view.bounds.width - closestView.view.frame.width)
                            // Move the sound around using `pan` using -1 and 1 as limits.
                            // NOTE: `relativeDistance` is multiplied by 2 to _increase_ the
                            // effect of the panning.
                            player.pan = Float (max (-1, min (1, relativeDistance * 2)))
                            // Change the volume according to the distance of the animal.
                            player.volume = max (0.3, min (1, 1 - abs (player.pan)))
                        }
                        // Finally, add a little random element to the pitch of the animal sound.
                        player.enableRate = true
                        player.rate = Float.random(in: 0.8...1.4)
                        player.play()
                    }
                }
                // Wait more time if nothing has been touched, otherwise use a quick hide
                // animation.
                let waitTime = intersectedView != nil ? 0.3 : 1
                DispatchQueue.main.asyncAfter(deadline: .now() + waitTime) {
                    self.overlayView.hideCurrentlyShownSection {
                        // Update the game state accordingly.
                        if let view = intersectedView {
                            self.gameState = .found(animal: view)
                        } else {
                            self.gameState = .playing
                        }
                    }
                }
            }
        // State: found and awaiting dismissal.
        // The user has found an animal and has requested to dismiss the shown dialog.
        case .foundAndAwaitingDismissal (let dismissFn):
            self.gameState = .playing
            // The state machine provides a closure to easily dismiss the dialog considering it as
            // a black-box.
            dismissFn {
                if self.animalsContainerView.subviews.isEmpty {
                    self.gameState = .won
                    self.overlayView.revealAllAndRemoveFromSuperview()
                }
            }
        default:
            return
        }
    }
}
