//
//  FirebaseAuthManager.swift
//  PiPi
//
//  Created by 정상윤 on 9/7/24.
//

import FirebaseAuth

final class FirebaseAuthManager {
    
    typealias User = FirebaseAuth.User
    
    static let shared = FirebaseAuthManager()
    
    private let auth = Auth.auth()
    private let handle: AuthStateDidChangeListenerHandle
    
    var currentUser: User? {
        auth.currentUser
    }
    
    private init() {
        handle = Auth.auth().addStateDidChangeListener { auth, user in
            NotificationCenter.default.post(
                name: .AuthStateDidChange,
                object: nil,
                userInfo: ["userExists" : (user != nil)]
            )
        }
    }
    
    deinit {
        auth.removeStateDidChangeListener(handle)
    }
    
    func signUp(email: String, password: String) async -> Result<User, NSError> {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            return .success(result.user)
        } catch {
            return .failure(error as NSError)
        }
    }
    
    func signIn(email: String, password: String) async -> Result<User ,Error> {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return .success(result.user)
        } catch {
            return .failure(error)
        }
    }
    
    func signOut() async throws {
        try auth.signOut()
    }
    
    func sendPasswordResetEmail(email: String) {
        auth.sendPasswordReset(withEmail: email)
    }
    
}
