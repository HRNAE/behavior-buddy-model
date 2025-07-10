import SwiftUI

struct HomeScreen: View {
    @State private var navigateToCareGiver = false
    @State private var navigateToBCBA = false
    @State private var navigateToAdmin = false
    

    var body: some View {
        NavigationStack {
            ZStack {
                Color.lightCyan.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 10) {
                    Image("BB_LOGO")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .padding()

                    Spacer().frame(height: 20)

                 
                    Button(action: {
                        navigateToCareGiver = true
                    }, label: {
                        Text("Caregiver")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 35)
                            .background(Color.teal.cornerRadius(10))
                    })

                    Spacer().frame(height: 20)
                    
                    
                    Button(action: {
                        navigateToBCBA = true
                    }, label: {
                        Text("BCBA")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.vertical, 20)
                            .padding(.horizontal, 65)
                            .background(Color.teal.cornerRadius(10))
                    })
                }

                
                Button(action: {
                    navigateToAdmin = true
                }, label: {
                    Text("Admin")
                        .font(.title3)
                        .foregroundColor(.teal)
                        .padding(5)
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(5)
                })
                .position(x: 340, y: 5)
            }

            .navigationDestination(isPresented: $navigateToCareGiver) {
                CareGiver()
            }
            
            .navigationDestination(isPresented: $navigateToBCBA) {
                BCBA()
            }
            .navigationDestination(isPresented: $navigateToAdmin) {
                Admin()
            }
            
            
        }
    }
}


struct HomeScreen_Previews: PreviewProvider {
    static var previews: some View {
        HomeScreen()
    }
}
