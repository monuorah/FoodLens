//
//  FoodLensApp.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//


import SwiftUI
import FirebaseCore

// code given by Firebase setup
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
struct FoodLensApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate // code given by Firebase setup
    
    @StateObject private var authVM = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootRouterView()
                .environmentObject(authVM)
        }
    }
}

