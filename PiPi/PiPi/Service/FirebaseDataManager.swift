//
//  FirebaseDataManager.swift
//  PiPi
//
//  Created by 정상윤 on 8/1/24.
//

import Firebase
import FirebaseDatabase

final class FirebaseDataManager<T: FirebaseData> {
    
    private let ref = Database.database(url: "https://koatmilk-9a443-default-rtdb.firebaseio.com").reference()
    private let key: String
    
    init() {
        key = (T.self == Activity.self) ? "activities" : "users"
    }
    
    deinit {
        ref.removeAllObservers()
    }
    
    func addData(
        _ data: T,
        id: String
    ) throws {
        let data = try JSONEncoder().encode(data)
        let jsonString = try JSONSerialization.jsonObject(with: data)
        
        ref.child(key)
            .child(id)
            .setValue(jsonString)
    }
    
    func fetchData(
        dataID: String? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var databaseRef = ref.child(key)
        if let dataID {
            databaseRef = databaseRef.child(dataID)
        }
        
        databaseRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self else { return }
            
            completion(self.handleSnapshot(snapshot: snapshot, dataID: dataID))
        }
    }
    
    func observeData(
        eventType: DataEventType,
        dataID: String? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        var databaseRef = ref.child(key)
        if let dataID {
            databaseRef = databaseRef.child(dataID)
        }
        
        databaseRef.observe(eventType) { [weak self] snapshot in
            guard let self else { return }
            
            completion(self.handleSnapshot(snapshot: snapshot, dataID: dataID))
        }
    }
    
    func updateData(
        _ data: T,
        id: String
    ) throws {
        let data = try JSONEncoder().encode(data)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        
        if let json = jsonObject as? [String: Any] {
            ref.child(key)
                .child(id)
                .updateChildValues(json)
        } else {
            throw FirebaseError.jsonObjectConvertFailed
        }
    }
    
    func removeObserver(dataID: String? = nil) {
        var databaseRef = ref.child(key)
        if let dataID {
            databaseRef = databaseRef.child(dataID)
        }
        
        databaseRef.removeAllObservers()
    }
    
    private func handleSnapshot(
        snapshot: DataSnapshot,
        dataID: String?
    ) -> Result<T, Error> {
        if snapshot.exists() {
            do {
                let decodedData: T = try self.decode(id: dataID, value: snapshot.value)
                return .success(decodedData)
            } catch {
                return .failure(error)
            }
        } else {
            return .failure(FirebaseError.dataNotFound)
        }
    }
    
    private func decode(id: String?, value: Any?) throws -> T {
        guard let object = value as? [String: Any] else {
            throw FirebaseError.dataNotFound
        }
        
        let data = try JSONSerialization.data(withJSONObject: object)
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
}

extension FirebaseDataManager {
    
    enum FirebaseError: Error {
        case dataNotFound
        case jsonObjectConvertFailed
    }
    
}
