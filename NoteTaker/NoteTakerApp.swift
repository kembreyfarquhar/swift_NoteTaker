//
//  NoteTakerApp.swift
//  NoteTaker
//
//  Created by Katie on 11/24/20.
//

import SwiftUI
import Firebase

@main
struct NoteTakerApp: App {
    
    // Attaching App Delegate to SwiftUI
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


// Create App Delegate

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) ->
            Bool {
                // Initializing Firebase
                FirebaseApp.configure()
        return true
    }
}
