import SwiftUI
import Amplify
import Authenticator

struct NewCaregiverScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("hasLaunchedOnce") private var hasLaunchedOnce = false

    // NEW: Controls navigation to ContentView after clicking back button
    @State private var navigateToContentView = false

    var body: some View {
        ZStack {
            Color(red: 0.27, green: 0.48, blue: 0.61)
                .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // Top bar with back button (left) and sign-out (right)
                        HStack {
                            Button(action: {
                                navigateToContentView = true
                            }) {
                                Image(systemName: "arrow.backward")
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                            Spacer()
                            Button("Sign Out") {
                                Task { await Amplify.Auth.signOut() }
                            }
                            .foregroundColor(.white)
                        }
                        .padding([.leading, .trailing, .top], 20)
                        
                        Spacer().frame(height: 30)
                        
                        Image("BB_LOGO")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding(.bottom, 20)
                        
                        Text("WELCOME!")
                            .font(.custom("Open Sans", size: 36))
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                        
                        Authenticator { _ in
                            VStack(spacing: 20) {
                                NavigationLink(destination: CaregiverScreen()) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color(red: 0.92, green: 0.55, blue: 0.55))
                                            .frame(width: 250, height: 60)
                                        Text("Continue")
                                            .font(.title2)
                                            .bold()
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        
                        Spacer().frame(height: 40)
                        
                        Color.clear
                            .frame(height: 1)
                            .id("ScrollToBottom")
                    }
                    .padding()
                    .onAppear {
                        DispatchQueue.main.async {
                            withAnimation {
                                proxy.scrollTo("ScrollToBottom", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Perform any additional onAppear logic as needed
            }
        }
        .overlay(
            NavigationLink(
                destination: ContentView()
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true),
                isActive: $navigateToContentView
            ) {
                EmptyView()
            }
        )
        .preferredColorScheme(.dark)
    }
}
