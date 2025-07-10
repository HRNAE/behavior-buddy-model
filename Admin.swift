//
//  Admin.swift
//  Behavior Buddy
//
//  Created by Thorat, Haren on 7/1/25.
//

import SwiftUI


struct Admin: View {
    
    @State var task: String = ""
    
    var body: some View {
        //padding(.top, -20)
        ZStack{
            Color.cyan.ignoresSafeArea(edges: .all)
            VStack(
                //alignment: .leading,
                //spacing: 10
                
            ){
                //Spacer().frame(height: 0)
                Text("Welcome to the Admin Panel")
                    .font(.largeTitle)
                    .font(.system(size: 30, weight: .bold, design: .default))
                    .foregroundColor(.black)
                    //.position(x:202,y:155)
                    .multilineTextAlignment(.center)
                    .baselineOffset(10.0)
                
                Spacer().frame(height: 10)
                
                Text("Please provide a task to the Caregiver:")
                    .font(.title2)
                    .font(.system(size: 30, weight: .bold, design: .default))
                    //.position(x:190,y:-175)
                    .foregroundColor(.black)
                    .padding()
                    //.multilineTextAlignment(.center)
                Spacer().frame(height: 30)
                TextField("", text: $task, prompt: Text("Enter new task here").foregroundColor(.white).font(.system(size: 20)))
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.black))
                    .frame(width: 350)
                Spacer().frame(height: 40)
                Button(action:{
                }, label: {
                    Text("Save Task")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .padding(.vertical,20)
                        .padding(.horizontal,20)
                        .background(
                            Color.lightSkyBlue
                                .cornerRadius(10)
                        )
                        //.position(x:200,y:650)
                })
                
            }
            
        }
                
            
                
                
    }
            
}
    



struct Admin_Previews: PreviewProvider {
    static var previews: some View {
        Admin()
    }
}

extension Color {
    static let lightCyan = Color(red: 224 / 255, green: 255 / 255, blue: 255 / 255)
}

extension Color {
    static let lightSkyBlue = Color(red: 135 / 255, green: 206 / 255, blue: 250 / 255)
}


