//
//  UserService.swift
//  FoodLens
//
//  Created by Melanie Escobar on 12/1/25.
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
    
    func listenToUser(uid: String, completion: @escaping (UserProfile?) -> Void) {
        db.collection(collection)
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
}
