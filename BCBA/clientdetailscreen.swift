import SwiftUI

struct ClientDetailScreen: View {
    let clientName: String
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Background Color
            Color(red: 0.27, green: 0.48, blue: 0.61) // Blue #457B9D
                .ignoresSafeArea()

            VStack(spacing: 20) {
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

                // Client's Name in Childish Font
                Text(clientName)
                    .font(.custom("MarkerFelt-Wide", size: 75)) // Childish Font
                    .foregroundColor(.white)

                Spacer().frame(height: 40) // Gap before buttons

                // Large Rectangle Box for New Program
                NavigationLink(destination: NewProgramScreen(clientName: clientName)) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(red: 0.92, green: 0.55, blue: 0.55)) // Light Red #EA8C8C
                            .frame(width: 300, height: 100)
                            .shadow(radius: 5)
                        Text("New Program")
                            .font(.title)
                            .bold()
                            .foregroundColor(.white)
                    }
                }

                // Large Rectangle Box for Data
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(red: 0.92, green: 0.55, blue: 0.55)) // Light Red #EA8C8C
                        .frame(width: 300, height: 100)
                        .shadow(radius: 5)
                    Text("Data")
                        .font(.title)
                        .bold()
                        .foregroundColor(.white)
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
    ClientDetailScreen(clientName: "Sample Client")
}
