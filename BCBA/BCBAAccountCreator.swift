 import SwiftUI

struct BCBAAccountCreator: View {
    @Environment(\.presentationMode) var presentationMode
    @State var newEmail = ""
    @State var newPassword = ""
    @State var fullName = ""
    @State var bacbID = ""

    var body: some View {
        ZStack {
            Color.lightSkyBlue
                .ignoresSafeArea()

            VStack(spacing: 10) {
                // Back Button (Only Arrow)
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title)
                        .foregroundColor(.blue)
                        .padding(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Move Behavior Buddy and BCBA Account Creation to the top
                VStack(spacing: 0) {
                    Text("Behavior")
                        .font(.custom("Chalkduster", size: 36))
                        .bold()
                        .foregroundColor(.darkSkyBlue)
                        .multilineTextAlignment(.center)

                    Text("Buddy")
                        .font(.custom("Chalkduster", size: 36))
                        .bold()
                        .foregroundColor(.darkSkyBlue)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, -10) // Adjust padding to align closely with back button

                Text("BCBA Account Creation")
                    .font(.custom("Chalkduster", size: 28))
                    .foregroundColor(Color.orange.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.top, 5)

                ScrollView {
                    VStack(spacing: 15) {
                        VStack(spacing: 15) {
                            TextField("Email", text: $newEmail)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)

                            SecureField("Enter your password", text: $newPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }

                        Spacer().frame(height: 20)

                        VStack(spacing: 15) {
                            TextField("Enter your full name", text: $fullName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)

                            TextField("Enter your BACB-ID#", text: $bacbID)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                }

                Spacer()

                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.green)
                        .frame(width: 180, height: 30)
                    Text("Create Account")
                        .foregroundStyle(.white)
                }
                .onTapGesture {
                    print(newEmail, newPassword, fullName, bacbID)
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct BCBAAccountCreator_Previews: PreviewProvider {
    static var previews: some View {
        BCBAAccountCreator()
    }
}
