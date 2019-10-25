# Paw 'n Seek

This is the playground I created for WWDC 2019 for which I received a scholarship. I have only tested it on Xcode due to unavailability of an iPad, but it should work there too.

Making games is not what I'm better at, but it was a fun experience! I learned stuff about `AVKit` and played with `UIViewPropertyAnimator`s.

## Synopsis

Taken from the playground's main page:

> Welcome! This is a little game where you are tasked with the job of finding all of the sneaky animals which decided to play *hide and seek* in the scenario you chose. If you succeed, every animal that you find will give you an interesting fact about that species, and you will hopefully learn something!

> [...] Tap around to reveal little portions of the scenario. **Turn up your volume and listen closely**: the *farther* you are from the nearest animal, the *farther* will be the sound! In addition, if you hear the animal's sound coming from your left, guess what -- that means that it's indeed on your left!


## Points of interest

- With the idea of a playground being somewhat educational, documentation was a primary concern as it was for the [previous playground I made](https://github.com/Robertof/swift-playground-bubblypictures).
- The splash screen (which has little paws animating from one end of the screen to the other) is dynamically generated, aligned with constraints magic and animated using `UIViewPropertyAnimator` and UIKit animation keyframes. The latter was a pretty new technology and I attended a session at WWDC17 which was helpful!
- What makes the game interesting is the _sound aspect_. In fact, sound is positional: wherever the closest animal to your tap is, the sound will come from that direction and will become quieter as distance increases. The algorithm per se is not that complicated, but it was fun making everything work with `AVKit`.
- Every animal in the minigame is represented using emojis (even in the code, thanks UTF-8).
