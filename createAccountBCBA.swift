//
//  createAccountBCBA.swift
//  Behavior Buddy
//
//  Created by Thorat, Haren on 7/1/25.
//

import SwiftUI

struct createAccountBCBA: View {
    @State var email: String = ""
    @State var password: String = ""
    @State var confirm: String = ""

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

                    Text("Create Account")
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
                        Spacer().frame(height:10)
                        SecureField("Re-Enter your password", text: $password)
                            .padding()
                            .background(Color.gray.opacity(0.1).cornerRadius(10))
                            .foregroundColor(.black)
                            .frame(height: 44)
                        
                    }
                    .padding(.horizontal, 40)
                    
                }
                .padding(.horizontal, 40)

                    
                    Button(action: {
                       
                    }, label: {
                        Text("Create account")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 100)
                            .background(Color.teal.cornerRadius(10))
                            .position(x:200,y:720)
                    })

                    /*
                    Button(action: {
                      //  navigateToForgotPassword = true
                    }, label: {
                        Text("Forgot password")
                            .font(.caption)
                            .foregroundColor(.teal)
                    })
                    .padding(.top, 10)
                    
                    Button(action: {
                       // navigateToCreateAccount = true
                    }, label: {
                        Text("Create account")
                            .font(.caption)
                            .foregroundColor(.teal)
                    })
                    .padding(.top, 10)
                     */
                }

                
            
            }
        }
    }




struct createAccountBCBA_Previews: PreviewProvider {
    static var previews: some View {
        createAccountBCBA()
    }
}



