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
    
    @StateObject private var appRootManager = AppRootManager()
    @State var isShowingSheet: Bool = false
    
    var activity: Activity = Activity.sampleData
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch appRootManager.currentRoot {
                case .onboarding:
                    OnboardingTabView()
                case .content:
                    ContentView(isShowingSheet: $isShowingSheet, activity: activity)
                case .signUp:
                    SignUpView()
                }
            }
            .environmentObject(appRootManager)
        }
    }
    
}
