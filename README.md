# PotentialMusicStartUpApplication
SpotifyAPI Fun


######Latest Songs

##Tools/Install

1. Xcode 8.3.3 (simulator - iPhone 7)
2. Alamofire (Network Calling Framework)
3. Snapkit (Autolayout Wrapper Framework)

After downloading the app from github, navigate to the folder in terminal and enter the command `pod install` to add all the dependencies and run the project from the .xcworkspace. Animations are a little choppy on the simulator, but run fine on a device - specifically the search bar animation. 

##Code Design Decisions##

#Networking#

My main concern with networking was OAuth. Although I didn't build it out all the way - refresh token needs to be handled and addressed, there should be a check/error handling when a token comes back expired to call refresh, basic framework was laid out, but not implemented - I decided that having a AuthTokenModel to handle make and store tokens, which get accessed by a RequestManager that will then pass the information to my SongViewModel. The song ViewModel take the requests and goes to the API to fetch the data, parses it, and creates the local data models for the View Controller to interact with.

#View Controller Task Distribution#

As one can tell, View Controllers get a little bit unwieldy. UI elements can take up a ton of code and things can easily get lost in the sauce. It was for this reason that I decided to put all of the data logic into the ViewModel, all the VC does is listen using NotificationCenter (my main alternative to this is using RxSwift, although a bit of lack of familiarity with the framework and the nature of this project lead me to using Notifications) to listen to changes to the data. I chose that instead of using a delegate relationship to prevent any unnecessary retain cycles if the app got built out farther. 

#UI/UX#

- Color: I like grey as a colour scheme, it doesn't take away from any of the album art, white makes the song titles and menu items pop. 

- tableView v collectionView: In the Tidal app the manage albums using collection views and it drives me absolutely insane. I understand that a lot of users prefer seeing things visually and a whole album art is pretty nice, I just don't that it makes my eye switch from left to right, if i want to navigate by art in a table view I have to look at the left side, if I navigate by title, I just have to look at the right side. Just a pet pieve of mine.

#Closing#

Futher explanations can be found commented in the code, and I'm more than happy to discuss anything else in more detail.
