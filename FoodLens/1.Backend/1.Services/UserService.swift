//
//  UserService.swift
//  FoodLens
//
//  Created by Melanie & Muna on 12/1/25.
//

import FirebaseFirestore

struct UserService {
    private let db = Firestore.firestore()
    private let collection = "users"
    
    func createUserDocument(_ profile: UserProfile) throws {
        var data: [String: Any] = [
            "email": profile.email,
            "onboardingCompleted": false,
            "onboardingStep": 0
        ]
        
        if let name = profile.name {
            data["name"] = name
        }
        
        db.collection(collection)
            .document(profile.id)
            .setData(data)
    }
    
    // One-time fetch of the user doc (used for upsert on login)
    func getUserOnce(uid: String, completion: @escaping (_ data: [String: Any]?) -> Void) {
        db.collection(collection)
            .document(uid)
            .getDocument { snapshot, _ in
                completion(snapshot?.data())
            }
    }
    
    // Minimal upsert that ensures required profile fields exist
    func upsertMinimalUser(uid: String, email: String, completion: ((Error?) -> Void)? = nil) {
        let minimal: [String: Any] = [
            "email": email,
            "onboardingCompleted": false,
            "onboardingStep": 0
        ]
        db.collection(collection)
            .document(uid)
            .setData(minimal, merge: true, completion: completion)
    }
    
    // Return ListenerRegistration so callers can remove() it.
    @discardableResult
    func listenToUser(uid: String, completion: @escaping (UserProfile?) -> Void) -> ListenerRegistration {
        return db.collection(collection)
            .document(uid)
            .addSnapshotListener { snapshot, _ in
                guard
                    let data = snapshot?.data(),
                    let email = data["email"] as? String
                else {
                    completion(nil)
                    return
                }
                
                let name = data["name"] as? String
                let onboardingCompleted = data["onboardingCompleted"] as? Bool ?? false
                let onboardingStep = data["onboardingStep"] as? Int ?? 0
                
                completion(
                    UserProfile(
                        id: uid,
                        email: email,
                        name: name,
                        onboardingCompleted: onboardingCompleted,
                        onboardingStep: onboardingStep
                    )
                )
            }
    }
    
    func updateName(uid: String, name: String, completion: @escaping (Error?) -> Void) {
        db.collection(collection)
            .document(uid)
            .updateData(["name": name], completion: completion)
    }
    
    func updateOnboardingStep(uid: String, step: Int) {
        db.collection(collection)
            .document(uid)
            .updateData(["onboardingStep": step])
    }
    
    func markOnboardingCompleted(uid: String) {
        db.collection(collection)
            .document(uid)
            .updateData(["onboardingCompleted": true])
    }
    
    // Save the full UserModel under users/{uid}/userData
    func saveUserModel(uid: String, model: UserModel, completion: ((Error?) -> Void)? = nil) {
        let data = model.toFirestoreData()
        
        db.collection(collection)
            .document(uid)
            .setData(["userData": data], merge: true) { error in
                completion?(error)
            }
    }
    
    // Return ListenerRegistration so callers can remove() it.
    @discardableResult
    func listenToUserModel(uid: String, model: UserModel) -> ListenerRegistration {
        return db.collection(collection)
            .document(uid)
            .addSnapshotListener { snapshot, _ in
                guard
                    let data = snapshot?.data(),
                    let userData = data["userData"] as? [String: Any]
                else { return }
                
                // apply on main thread
                DispatchQueue.main.async {
                    model.applyFirestoreData(userData)
                }
            }
    }
    
    func updateEmail(uid: String, email: String, completion: ((Error?) -> Void)? = nil) {
        db.collection(collection)
            .document(uid)
            .updateData(["email": email], completion: completion)
    }
    
    // Delete the entire user document (including embedded userData)
    func deleteUser(uid: String, completion: ((Error?) -> Void)? = nil) {
        db.collection(collection)
            .document(uid)
            .delete(completion: completion)
    }
}

