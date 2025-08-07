import SwiftUI
import Amplify

struct ViewStatsView: View {
    let clientName: String
    let selectedProgram: String
    
    @Environment(\.presentationMode) var presentationMode
    
    // Hamburger menu overlay state
    @State private var isMenuOpen = false
    
    // Same sign-out approach
    @State private var navigateToChooseChild = false
    @State private var navigateToContentView = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                // -- TOP BAR --
                HStack {
                    // Back button on the left
                    Button(action: {
                        // Pop back to the previous screen (likely SessionDetailScreen)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    
                    // Hamburger menu on the right
                    Button(action: {
                        withAnimation { isMenuOpen.toggle() }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding([.leading, .top, .trailing], 20)
                .background(Color(red: 0.27, green: 0.48, blue: 0.61))
                
                VStack(spacing: 10) {
                    Image("BB_LOGO")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .padding(.top, 5)
                    
                    // Program Info
                    HStack(spacing: 8) {
                        Text("Program:")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                        
                        Text(selectedProgram)
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer().frame(height: 10)
                    
                    // Placeholder for Graph
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(maxWidth: 250, minHeight: 100)
                        .cornerRadius(8)
                    
                    // Session Data Button
                    NavigationLink(destination: SessionDataView()) {
                        Text("Session Summary")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.92, green: 0.55, blue: 0.55))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    
                    // Fetch Session Reports Button
                    NavigationLink(destination: SessionReportsView()) {
                        Text("Session Feedback")
                            .font(.title2)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.92, green: 0.55, blue: 0.55))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 5)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .background(Color(red: 0.27, green: 0.48, blue: 0.61).ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            
            // -- Hamburger Menu Overlay --
            if isMenuOpen {
                ZStack {
                    // Dim background that dismisses the menu on tap
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture { closeMenu() }
                    
                    // Menu itself, aligned top-right
                    VStack {
                        HStack {
                            Spacer()
                            VStack(spacing: 20) {
                                Button("Child Selection") {
                                    navigateToChooseChild = true
                                    closeMenu()
                                }
                               
                                // Sign-out approach
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
            
            // Hidden NavigationLinks for hamburger menu
            NavigationLink(
                destination: ChooseChildScreen()
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true),
                isActive: $navigateToChooseChild
            ) {
                EmptyView()
            }
            
            NavigationLink(
                destination: ContentView()
                    .navigationBarHidden(true)
                    .navigationBarBackButtonHidden(true),
                isActive: $navigateToContentView
            ) {
                EmptyView()
            }
        }
    }
    
    // Helper to close the menu with animation
    private func closeMenu() {
        withAnimation {
            isMenuOpen = false
        }
    }
}
