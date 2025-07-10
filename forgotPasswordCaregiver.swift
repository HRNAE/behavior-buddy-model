//
//  forgotPasswordCaregiver.swift
//  Behavior Buddy
//
//  Created by Thorat, Haren on 7/1/25.
//

import SwiftUI


struct forgotPasswordCaregiver: View {
    
    
    
    @State private var navigateToHomeScreen = false
    @State var email: String = ""
    
    var body: some View {
        NavigationStack{
            //padding(.top, -20)
            ZStack{
                
                Color.lightCyan.ignoresSafeArea(edges: .all)
                Text("Reset your password")
                    .font(.title)
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.teal)
                    .padding()
                    .position(x:120,y:175)
                    .frame(width: 300, height: 375,
                           alignment: .leading)
                
                Text("Email")
                    .font(.title2)
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.teal)
                    .padding()
                    .position(x:-10,y:250)
                    .frame(width: 250, height: 425,
                           alignment: .leading)
                
                TextField("Enter your email", text: $email)
                //.position(x:-10,y:100)
                    .padding()
                    .background(Color.gray.opacity(0.1).cornerRadius(10))
                    .frame(width: 250, height: 30)
                    .position(x:180,y:460)
                
                Button(action:{
                }, label: {
                    Text("Send Code")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical,5)
                        .padding(.horizontal,120)
                        .background(
                            Color.teal
                                .cornerRadius(10)
                        )
                        .position(x:200,y:550)
                })
                Button(action:{
                    navigateToHomeScreen = true
                }, label: {
                    Text("Back to Sign In")
                        .font(.title3)
                        .foregroundColor(.teal)
                        .padding(.top, 40)
                        .position(x:200,y:580)
                    
                    
                    //.shadow(radius:10)
                    
                })
                
                VStack(
                    //olor(.blue).edgesIgnoringSafeArea(.all)
                    alignment: .leading,
                    spacing: 10
                ) {
                    
                    Image("BB_LOGO")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding()
                        .position(x:200,y:150)
                    //background(Color.blue)
                    //Color(.blue).edgesIgnoringSafeArea(.all)
                    Text("WELCOME!")
                        .font(.largeTitle)
                        .font(.system(size: 30, weight: .bold, design: .default))
                        .foregroundColor(.teal)
                        .padding()
                        .position(x:200,y:-100)
                    
                    
                    
                }
                
                .navigationDestination(isPresented: $navigateToHomeScreen) {
                    CareGiver()
                }

                
                
            }
        }
    }

}

struct forgotPasswordCaregiver_Previews: PreviewProvider {
    static var previews: some View {
        forgotPasswordCaregiver()
    }
}



