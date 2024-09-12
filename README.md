Tracker App
Overview
The Tracker App is an iOS application built using the MVVM (Model-View-ViewModel) pattern. The app allows users to track their location in real-time, save the path they have traveled, and view previously saved paths on a map. It uses Google Maps SDK to provide real-time map tracking and Core Data for offline data persistence.

Features
Real-time Location Tracking: Track the user’s location in real-time and display the path traveled on the map.
Save Paths Offline: Save the tracked paths to Core Data, allowing offline access to the user's history.
View Saved Paths: Display a list of saved paths and view any selected path in a pop-up Google Map.
MVVM Architecture: The app is built using the MVVM pattern for clean separation of logic and UI.
Technologies Used
Google Maps SDK for iOS: To display the map and handle path drawing.
Core Location: To track the user’s location in real-time.
Core Data: To store and persist the user's tracked paths.
MVVM Architecture: For better separation of concerns and easier maintainability.
Requirements
iOS 13.0+
Xcode 12.0+
Swift 5.0+
Google Maps API Key (you will need your own API key for Google Maps)
Setup Instructions
Clone the Repository:

bash
Copy code
git clone https://github.com/yourusername/tracker-app.git
cd tracker-app
Install CocoaPods (if you haven't already):

If your project uses CocoaPods to manage dependencies, run the following command:

bash
Copy code
sudo gem install cocoapods
Install Dependencies:

Run the following command to install the necessary dependencies (such as Google Maps SDK):

bash
Copy code
pod install
Open the Project:

Open the .xcworkspace file:

bash
Copy code
open TrackerApp.xcworkspace
Add Your Google Maps API Key:

To use Google Maps in your app, you'll need to add your API key in the AppDelegate.swift file:

swift
Copy code
import GoogleMaps

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
        return true
    }
}
Update the Info.plist File:

Make sure the following keys are added to your Info.plist file to allow location access:

xml
Copy code
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to show your path on the map.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>We need your location to show your path on the map.</string>
Run the App:

Open the project in Xcode.
Select your simulator or device.
Press Cmd + R to run the app.
Key Components
1. TrackerViewController (View)
This is the main view controller responsible for managing the map view, starting and stopping tracking, and displaying the list of saved paths.

2. MapViewModel (ViewModel)
The MapViewModel contains the business logic for:

Tracking the user's location.
Saving the path to Core Data.
Fetching and decoding saved paths. It handles all interactions between the model and the view controller.
3. PathEntity (Model)
The Core Data entity used to store the user's tracked paths. Each path contains:

Coordinates: A list of latitude and longitude points that define the path.
Date: The date when the path was saved.
Core Features
Start Tracking: Press the "Start" button to begin tracking your location. The app will draw your path on the map as you move.
Stop Tracking: Press the "Stop" button to save your current path to Core Data.
View Saved Paths: The list of saved paths is displayed under the map. Selecting a path will show it on a Google Map in a pop-up.
Known Issues
If the Google Maps location button or blue dot for user location doesn't appear, ensure that location services are enabled and permissions are correctly set.
Ensure that the Google Maps API key is valid and has the correct permissions enabled (such as Maps SDK for iOS).
