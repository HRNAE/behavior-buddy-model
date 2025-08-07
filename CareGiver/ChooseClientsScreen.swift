import SwiftUI

struct ChooseClientsScreen: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var clientNames = ["Charlie", "Amy", "Maggie", "Dan"]

    var body: some View {
        ZStack {
            // Background Color
            Color(red: 0.27, green: 0.48, blue: 0.61) // Blue #457B9D
                .ignoresSafeArea()

            VStack {
                // Back Button at Top Left
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Centered Top Image
                Image("BB_LOGO")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200) // Adjust size as needed
                    .padding(.top, 10)

                Spacer().frame(height: 20)

                // Choose Your Clients Text
                Text("Choose Your Clients")
                    .font(.custom("MarkerFelt-Wide", size: 36)) // Childish Font
                    .foregroundColor(.white)
                    .padding(.bottom, 10)

                // Client Name Boxes
                VStack(spacing: 20) { // Increased spacing for balance
                    ForEach(clientNames, id: \.self) { name in
                        NavigationLink(destination: ClientDetailScreen(clientName: name)) {
                            Text(name)
                                .frame(width: 300, height: 50)
                                .background(Color(red: 0.92, green: 0.55, blue: 0.55)) // Light Red #EA8C8C
                                .cornerRadius(8)
                                .shadow(radius: 5)
                                .multilineTextAlignment(.center)
                                .font(.title2)
                                .foregroundColor(.white)
                        }
                    }
                }

                Spacer() // Added spacer to push buttons lower
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

#Preview {
    ChooseClientsScreen()
}
