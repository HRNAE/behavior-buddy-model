
import SwiftUI

struct BCBAClientSelection: View {
    @Environment(\.presentationMode) var presentationMode
    let clients = ["Micah", "Brian", "Luke", "Ayush", "Manan", "Michael"]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.lightPink
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "arrow.left")
                            Text("Back")
                        }
                        .font(.title2)
                        .foregroundColor(.blue)
                        .padding()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

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

                    Text("Children's")
                        .font(.title2)
                        .foregroundColor(.black)
                        .padding(.top, 10)

                    ScrollView {
                        VStack(spacing: 10) {
                            ForEach(clients, id: \.self) { client in
                                Button(action: {
                                    // Action for each client button, if needed
                                    print("Selected client: \(client)")
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white.opacity(0.8))
                                            .frame(height: 50)
                                            .shadow(radius: 5)
                                        //The client informationn would begin from here.

                                        Text(client)
                                            .font(.custom("Chalkduster", size: 24))
                                            .foregroundColor(.black)
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding()

                    Spacer()

                    ZStack {
                        RoundedRectangle (cornerRadius: 15)
                            .fill(Color.gray)
                            .frame(width: 150, height: 50)
                        HStack {
                            Text("Add a Child")
                                .foregroundColor(.white)
                                .bold()
                            Image(systemName: "plus.circle")
                                .foregroundColor(.white)
                        }
                    }
                    .padding()

                    Spacer()
                }
                .padding()
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

struct BCBAClientSelection_Previews: PreviewProvider {
    static var previews: some View {
        BCBAClientSelection()
    }
}
