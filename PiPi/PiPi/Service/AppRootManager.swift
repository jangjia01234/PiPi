//
//  AppRootManager.swift
//  PiPi
//
//  Created by 정상윤 on 9/8/24.
//

import Foundation

final class AppRootManager: ObservableObject {
    
    @Published var currentRoot: AppRoot = (FirebaseAuthManager.shared.currentUser != nil) ? .content : .onboarding
    
    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleAuthStateDidChange(notification:)),
            name: .AuthStateDidChange,
            object: nil
        )
    }
    
    @objc
    private func handleAuthStateDidChange(notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let userInfo = notification.userInfo,
                  let userExists = userInfo["userExists"] as? Bool else { return }
            
            self?.currentRoot = userExists ? .content : .onboarding
        }
    }
    
    enum AppRoot {
        
        case onboarding
        case content
        case signUp
        
    }
    
}
