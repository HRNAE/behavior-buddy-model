//
//  behavior_buddyApp.swift
//  behavior buddy
//
//  Created by Thorat, Haren on 7/8/25.
//
import SwiftUI
import Amplify
//import AWSAPIPlugin
import AWSCognitoAuthPlugin
//import AWSS3StoragePlugin
import Authenticator
//import Foundation
import SwiftUI

@main
struct behavior_buddyApp: App {
    init() {
            do {
                try Amplify.add(plugin: AWSCognitoAuthPlugin())
                try Amplify.configure(with: .amplifyOutputs)
            } catch {
                print("Unable to configure Amplify \(error)")
            }
        }

        var body: some Scene {
            WindowGroup {
                ContentView()
            }
        }
    
}


