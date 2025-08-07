import SwiftUI
import Amplify
import AWSAPIPlugin
import AWSCognitoAuthPlugin
import AWSS3StoragePlugin
import Authenticator
import Foundation

// MARK: - Color Extensions
extension Color {
    static let lightPink = Color(red: 1.0, green: 0.87, blue: 0.87) // Light pink
    static let lightCyan = Color(red: 0.88, green: 1.0, blue: 1.0)   // Light cyan
    static let lightSkyBlue = Color(red: 0.678, green: 1, blue: 1) // Light sky blue
    static let darkSkyBlue = Color(red: 0.0156, green: 0.968, blue: 0.968) // Dark sky blue
    static let customOrange = Color(red: 1.0, green: 0.855, blue: 0.655) // Orange #ffdba7
    static let customRed = Color(red: 0.98, green: 0.502, blue: 0.463) // Red #fa8076
}

// MARK: - Main App
@main
struct Behavior_BuddyApp: App {
    init() {
        let awsApiPlugin = AWSAPIPlugin(modelRegistration: AmplifyModels())
        do {
            Amplify.Logging.logLevel = .verbose
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: awsApiPlugin)
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure(with: .amplifyOutputs)
            print("Amplify configured with Auth, API, and Storage plugins")
        } catch {
            print("Could not initialize Amplify: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            LaunchScreenView() // Start with animated splash
        }
    }
}

// MARK: - Launch Screen View with Cinematic Animation
struct LaunchScreenView: View {
    @State private var isActive = false
    @State private var scaleEffect: CGFloat = 0.6
    @State private var opacity: Double = 0.2
    @State private var zoomOut = false
    @State private var hideContent = false

    var body: some View {
        ZStack {
            if isActive {
                ContentView()
                    .transition(.opacity)
            } else {
                Color.black.ignoresSafeArea()

                if !hideContent {
                    VStack {
                        Image("BB_LOGO") // Your logo image asset
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .scaleEffect(zoomOut ? 8.0 : scaleEffect)
                            .opacity(opacity)
                            .shadow(color: .red.opacity(0.7), radius: 30)

                        Text("Behavior Buddy")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .opacity(opacity)
                            .scaleEffect(scaleEffect)
                            .padding(.top, 20)
                            .opacity(zoomOut ? 0 : 1)
                    }
                    .onAppear {
                        // Initial fade and scale in
                        withAnimation(.easeInOut(duration: 1.2)) {
                            self.scaleEffect = 1.1
                            self.opacity = 1.0
                        }

                        // Delay then zoom in and fade out
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                self.zoomOut = true
                                self.opacity = 0
                            }

                            // Switch to main screen
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    self.hideContent = true
                                    self.isActive = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
