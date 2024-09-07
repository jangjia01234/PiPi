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
    
    func observeAllData(
        eventType: DataEventType,
        completion: @escaping (Result<[String: T], Error>) -> Void
    ) {
        ref.child(key)
            .observe(eventType) { [weak self] snapshot in
            guard let self else { return }
            
            completion(self.handleSnapshot(snapshot: snapshot))
        }
    }
    
    func observeSingleData(
        eventType: DataEventType,
        id: String,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        ref.child(key).child(id)
            .observe(eventType) { [weak self] snapshot in
                guard let self else { return }
                
                completion(self.handleSnapshot(snapshot: snapshot))
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
    
    private func handleSnapshot<SuccessType: Decodable>(
        snapshot: DataSnapshot
    ) -> Result<SuccessType, Error> {
        if snapshot.exists() {
            do {
                let decodedData: SuccessType = try self.decode(value: snapshot.value)
                return .success(decodedData)
            } catch {
                return .failure(error)
            }
        } else {
            return .failure(FirebaseError.dataNotFound)
        }
    }
    
    private func decode<DataType: Decodable>(value: Any?) throws -> DataType {
        guard let object = value as? [String: Any] else {
            throw FirebaseError.dataNotFound
        }
        
        let data = try JSONSerialization.data(withJSONObject: object)
        
        return try JSONDecoder().decode(DataType.self, from: data)
    }
    
}

extension FirebaseDataManager {
    
    enum FirebaseError: Error {
        case dataNotFound
        case jsonObjectConvertFailed
    }
    
}
