# Instagram clone

The purpose of this document is to represent the capabilities of the app. 

## Architecture
The project was designed using MVVM architecture. It consists of different units which satisfy the architecture requirements. Each unit is responsible for a particular task and has its own behavior. Communication between view and view model is implemented using the observer pattern. 

<img width="250" alt="Project folders" src="https://user-images.githubusercontent.com/76248402/157687384-401c4fa8-c8d9-4b14-9166-e983ca3560e2.png">


## Log in
You may try the app out using following accounts:

***Logins***:

archer@gmail.ru
JamesBrown@gmail.com

***Password***:

111111


## Table of Contents
1. Log in & Sign in screens
2. Main screen
3. Explore screen
4. Photo upload screen
5. Notifications screen
6. Profile screen


## 1.Log in & Sign in
When the app launches for the first time, a user has to go through autenfication process.  

![LoginAndSignInScreen](https://user-images.githubusercontent.com/76248402/157698460-d3137e92-4829-4d8a-81c2-d7ab07a85309.gif)


## 2.Main screen
When a user completes authentication they are presented with feed, explore, notification, and profile screens. 
The feed screen is populated with photos having been published by the user's followers. 

![MainScreen](https://user-images.githubusercontent.com/76248402/157703740-a96c22fd-ccc8-4736-83c6-be13b6cedab6.gif)


## 3.Explore screen
Here you can find photos which have ever been shared by instagram users. 

![ExploreScreen](https://user-images.githubusercontent.com/76248402/157709914-f799ca29-06f4-463a-b879-9a20543d519e.gif)


## 4. Photo upload screen
This screen is implemented through the use of CocoaPod "YPImagePicker". User peeks photo, applies the filter (optional) and may insert a comment.

![PhotoUploadScreen](https://user-images.githubusercontent.com/76248402/157718962-a134c404-c426-4ee5-aeb0-67d41c24c505.gif)


## 5. Notifications screen
This screen displays new followers, photos being liked or commented. 

![NotificationsScreen](https://user-images.githubusercontent.com/76248402/157723077-13385cfc-0fac-4cfa-8502-453eba98c3ee.gif)


## 6. Profile screen
Here users can find information about their profile (number of posts, followers and users they follow). Users are also able to edit profiles.  

![ProfileScreen](https://user-images.githubusercontent.com/76248402/157726586-8264294a-fd0f-4786-a55d-8ab5f3cde4e3.gif)
