//
//  UserProfile.swift
//  FoodLens
//
//  Created by Melanie & Muna on 12/1/25.
//

import Foundation

struct UserProfile: Identifiable {
    let id: String      // Firebase UID
    let email: String
    let name: String?   // made optional bc they are not asked at signup
    
    let onboardingCompleted: Bool // so users when logged back in if they not complete will go to onboard
    let onboardingStep: Int // what step they are in onboard so they go there
}
