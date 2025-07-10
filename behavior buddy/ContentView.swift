//
//  ContentView.swift
//  behavior buddy
//
//  Created by Thorat, Haren on 7/8/25.
//
import Amplify
import Authenticator
import SwiftUI


    struct ContentView: View {
        var body: some View {
            Authenticator { state in
                VStack {
                    Button("Sign out") {
                        Task {
                            await state.signOut()
                        }
                    }
                }
            }
        }
    }


#Preview {
    ContentView()
}
