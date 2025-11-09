//
//  tappyApp.swift
//  tappy
//
//  Created by Maria Jose Cordova igartua on 11/9/25.
//
// tappyApp.swift
// tappyApp.swift
import SwiftUI
import Firebase

@main
struct tappyApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
