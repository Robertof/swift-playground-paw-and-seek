//#-hidden-code
import UIKit
import PlaygroundSupport
let pawAndSeek = PawAndSeekViewController()
//#-end-hidden-code

/*:
 ## Welcome to Paw 'n Seek!
 Welcome! This is a little game where you are tasked with the job of finding all of the
 sneaky animals which decided to play *hide and seek* in the scenario you chose. If you succeed,
 every animal that you find will give you an interesting fact about that species, and you will
 hopefully learn something!
 
 To get started, run this playground, tap to start the game and tap around to reveal little
 portions of the scenario. **Turn up your volume and listen closely**: the *farther* you are from
 the nearest animal, the *farther* will be the sound! In addition, if you hear the animal's sound
 coming from your left, guess what -- that means that it's indeed on your left!
 Try to find all of the animals!
 
 ### Make it yours
 Don't like the default selection of animals? Or maybe you prefer a colder climate? Make yourself
 at home! First, choose the scenario you prefer. Just tap on the scenario to see what's available!
 */

pawAndSeek.scenario = .forest
/*:
 But wait, there's more! You can choose **what animals to play with**. We have dogs, cats, cows,
 pigs, rabbits, horses, even monkeys! Try to experiment with the different choices.
 */
pawAndSeek.animals = [.🐵, .🐮, .🐰, .🐱]
/*:
 The game feels too easy for you? That's not a problem. Feel free to change the difficulty and
 observe how the game changes.
 */
pawAndSeek.difficulty = .medium
/*:
 ### Footnotes
 This playground was made by Roberto Frenna - thanks for your time!
 
 Please feel free to inspect the source code of the other files to learn how this works.
 
 Everything is documented and everything should be understandable even for a Swift beginner.
 */
//#-hidden-code
PlaygroundPage.current.liveView = pawAndSeek
//#-end-hidden-code
