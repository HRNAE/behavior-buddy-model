import SwiftUI
import Amplify

struct ViewChildDetailScreen: View {
    @Environment(\.presentationMode) var presentationMode
    let childName: String

    @State private var isMenuOpen = false
    @State private var navigateToContentView = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.27, green: 0.48, blue: 0.61)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Top Bar
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        Spacer()
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
                    .padding([.leading, .trailing, .top], 20)

                    // Logo
                    Image("BB_LOGO")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.top, 40)

                    Spacer()

                    Text(childName)
                        .font(.custom("Open Sans", size: 48))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 60)

                    // Buttons
                    VStack(spacing: 20) {
                        NavigationLink(destination: CaregiverTargetWord(childName: childName)) {
                            Text("Start Practice")
                                .font(.title2)
                                .bold()
                                .frame(width: 300, height: 60)
                                .background(Color(red: 0.92, green: 0.55, blue: 0.55))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }

                        NavigationLink(destination: ChildProgressReportView()) {
                            Text("View Progress")
                                .font(.title2)
                                .bold()
                                .frame(width: 300, height: 60)
                                .background(Color(red: 0.92, green: 0.55, blue: 0.55))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }

                    Spacer()
                }
                .padding()

                // Hamburger Menu
                if isMenuOpen {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture { closeMenu() }

                        VStack {
                            HStack {
                                Spacer()
                                VStack(spacing: 20) {
                                    Button("Child Selection") {
                                        presentationMode.wrappedValue.dismiss()
                                        closeMenu()
                                    }

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
            .navigationTitle("")
            .navigationBarHidden(true)
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
    }

    private func closeMenu() {
        withAnimation {
            isMenuOpen = false
        }
    }
}
