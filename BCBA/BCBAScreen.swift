import SwiftUI
import Amplify
import Authenticator

struct BCBAScreen: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Updated Background Color
            Color(red: 0.27, green: 0.48, blue: 0.61) // Blue #457B9D
                .ignoresSafeArea(.all)

            VStack {
                HStack {
                    // Back Button in Top Left Corner
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    Spacer()
                    // Sign Out Button in Top Right Corner
                    Button("Sign Out") {
                        Task {
                            await Amplify.Auth.signOut()
                        }
                    }
                    .foregroundColor(.white)
                }
                .padding([.leading, .trailing], 20)
                .padding(.top, 10)

                Spacer()

                // Centered Image
                Image("BB_LOGO")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200) // Adjust as needed
                    .padding(.bottom, 20)

                // Centered WELCOME! Text
                Text("WELCOME!")
                    .font(.custom("Open Sans", size: 36)) // Childish font
                    .foregroundColor(.white)
                    .padding(.bottom, 20)

                // Authenticator View with Buttons
                Authenticator { state in
                    VStack(spacing: 20) {
                        // ACCOUNT Button
                        Button(action: {
                            // Action for the ACCOUNT button
                            print("Account button pressed")
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(red: 0.92, green: 0.55, blue: 0.55)) // Light Red #EA8C8C
                                    .frame(width: 250, height: 60)
                                Text("Account")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                        }

                        // Choose Clients Button
                        NavigationLink(destination: ChooseClientsScreen()) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color(red: 0.92, green: 0.55, blue: 0.55)) // Light Red #EA8C8C
                                    .frame(width: 250, height: 60)
                                Text("Choose Clients")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    BCBAScreen()
}
