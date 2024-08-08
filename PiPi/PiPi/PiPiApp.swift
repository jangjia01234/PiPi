//
//  PiPiApp.swift
//  PiPi
//
//  Created by 정상윤 on 7/29/24.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
}

@main
struct PiPiApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("userID") var userID: String = ""
    
    var body: some Scene {
        WindowGroup {
            if userID.isEmpty {
                OnboardingTabView()
            } else {
                ContentView()
            }
        }
    }
    
}
