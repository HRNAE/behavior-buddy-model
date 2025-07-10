import SwiftUI

struct CareGiver: View {
    @State var email: String = ""
    @State var password: String = ""
    @State private var navigateToForgotPassword = false
    @State private var navigateToCreateAccount = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.lightCyan.ignoresSafeArea()

                VStack(spacing: 20) {
                    Image("BB_LOGO")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding(.top, 40)

                    Text("WELCOME!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.teal)

                    Text("Caregiver Sign In")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.teal)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("Email")
                            .font(.title2)
                            .foregroundColor(.teal)

                        TextField("Enter your email", text: $email)
                            .padding()
                            .background(Color.gray.opacity(0.1).cornerRadius(10))
                            .foregroundColor(.black)
                            .frame(height: 44)

                        Text("Password")
                            .font(.title2)
                            .foregroundColor(.teal)

                        SecureField("Enter your password", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.1).cornerRadius(10))
                            .foregroundColor(.black)
                            .frame(height: 44)
                    }
                    .padding(.horizontal, 40)

                   
                    Button(action: {
                       
                    }, label: {
                        Text("Sign In")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 100)
                            .background(Color.teal.cornerRadius(10))
                    })

                    
                    Button(action: {
                        navigateToForgotPassword = true
                    }, label: {
                        Text("Forgot password")
                            .font(.caption)
                            .foregroundColor(.teal)
                    })
                    .padding(.top, 10)
                    
                    Button(action: {
                        navigateToCreateAccount = true
                    }, label: {
                        Text("Create account")
                            .font(.caption)
                            .foregroundColor(.teal)
                    })
                    .padding(.top, 10)
                }

                
                NavigationLink(
                    destination: forgotPasswordCaregiver(),
                    isActive: $navigateToForgotPassword
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: createAccountCaregiver(),
                    isActive: $navigateToCreateAccount
                ) {
                    EmptyView()
                }
            }
        }
    }
}




struct CareGiver_Previews: PreviewProvider {
    static var previews: some View {
        CareGiver()
    }
}



