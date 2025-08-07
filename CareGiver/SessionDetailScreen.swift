import SwiftUI
import Amplify

struct SessionDetailScreen: View {
    @Environment(\.presentationMode) var presentationMode
    let childName: String
    let selectedSession: String

    @State private var navigateToSpeechRecognition = false
    @State private var navigateToChooseChild = false
    @State private var navigateToPreparePage = false

    // Controls the hamburger menu overlay
    @State private var isMenuOpen = false
    // For sign-out approach
    @State private var navigateToContentView = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Color
                Color(red: 0.27, green: 0.48, blue: 0.61)
                    .ignoresSafeArea()

                // Main layout container
                VStack(spacing: 0) {
                    // ======================
                    // Top Bar (pinned)
                    // ======================
                    HStack {
                        // Back Button on the left
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        // Hamburger Menu Button on the right
                        Button(action: {
                            withAnimation {
                                isMenuOpen.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .padding([.leading, .top, .trailing], 20)

                    // ======================
                    // Scrollable Content
                    // ======================
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 20) {
                            // Child Name and "SESSION" Title
                            VStack(spacing: 0) {
                                Text(childName)
                                    .font(.custom("OpenSans-Bold", size: 75))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)               // Allows wrapping to 2 lines if needed
                                    .minimumScaleFactor(0.5)    // Scale text if still too large
                                    .padding(.horizontal, 20)

                                Text("SESSION")
                                    .font(.custom("OpenSans-Bold", size: 35))
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                            }

                            Spacer().frame(height: 20)

                            // Session Box
                            HStack {
                                Text("Program:")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(8)

                                Text(selectedSession)
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)               // Allows wrapping
                                    .minimumScaleFactor(0.5)    // Scale text if needed
                                    .padding()
                                    .background(Color.gray.opacity(0.3))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 20)

                            Spacer().frame(height: 30)

                            // Functional Buttons
                            VStack(spacing: 15) {
                                // "Start Now"
                                NavigationLink(
                                    destination: SpeechRecognitionView(clientName: childName, selectedProgram: selectedSession),
                                    isActive: $navigateToSpeechRecognition
                                ) {
                                    Button(action: { navigateToSpeechRecognition = true }) {
                                        Text("Start Now")
                                            .font(.title)
                                            .bold()
                                            .frame(width: 300, height: 80)
                                            .background(Color(red: 0.92, green: 0.55, blue: 0.55))
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }

                                // Space
                                Spacer().frame(height: 20)

                                // "Prepare"
                                NavigationLink(
                                    destination: PreparePage(),
                                    isActive: $navigateToPreparePage
                                ) {
                                    Button(action: { navigateToPreparePage = true }) {
                                        Text("Prepare")
                                            .font(.title3)
                                            .bold()
                                            .frame(width: 200, height: 50)
                                            .background(Color(red: 0.92, green: 0.55, blue: 0.55))
                                            .foregroundColor(.white)
                                            .cornerRadius(10)
                                    }
                                }
                            }

                            Spacer().frame(height: 50)
                        }
                        .padding(.bottom, 20)
                    }
                }
                .navigationTitle("")
                .navigationBarHidden(true)

                // Hidden NavigationLink to ChooseChildScreen
                NavigationLink(destination: ChooseChildScreen(), isActive: $navigateToChooseChild) {
                    EmptyView()
                }

                // =====================
                // Hamburger Menu Overlay
                // =====================
                if isMenuOpen {
                    ZStack {
                        // Dim background
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture { closeMenu() }

                        VStack {
                            HStack {
                                Spacer()
                                VStack(spacing: 20) {
                                    Button("Child Selection") {
                                        navigateToChooseChild = true
                                        closeMenu()
                                    }
                                   
                                    // Sign Out approach
                                    Button("Sign Out") {
                                        Task {
                                            await Amplify.Auth.signOut()
                                            navigateToContentView = true
                                        }
                                        closeMenu()
                                    }
                                }
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color.black)
                                .cornerRadius(10)
                                .padding(.trailing, 20)
                                .padding(.top, 80)
                            }
                            Spacer()
                        }
                    }
                    .transition(.move(edge: .trailing))
                    .animation(.easeInOut, value: isMenuOpen)
                }
            }
            // Hidden NavigationLink to ContentView for sign-out redirection
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
        }
    }

    // Closes the menu with animation
    private func closeMenu() {
        withAnimation { isMenuOpen = false }
    }
}
