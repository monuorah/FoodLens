//
//  AuthService.swift
//  FoodLens
//
//  Created by Melanie Escobar on 12/1/25.
//

import FirebaseAuth

struct AuthService {
    func signIn(email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }

    func signUp(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }
}
