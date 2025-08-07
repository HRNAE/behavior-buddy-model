import SwiftUI

struct PreparePage: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("programChoices") var programChoicesData: Data = Data()
    @State private var programChoices: [String] = []
    @State private var isMenuOpen = false
    @State private var showVideo = false

    var mostRecentProgram: String {
        programChoices.last ?? "Program"
    }

    init() {
        if let tasks = try? JSONDecoder().decode([String].self, from: programChoicesData) {
            _programChoices = State(initialValue: tasks)
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.27, green: 0.48, blue: 0.61)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top Bar
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 20)

                    Spacer()

                    Button(action: {
                        withAnimation { isMenuOpen.toggle() }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 10)

                ScrollView {
                    VStack(spacing: 30) {
                        // Target Box
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.15))
                            VStack(spacing: 8) {
                                Text("Target")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(mostRecentProgram)
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }

                        // Expansion Box
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.15))
                            VStack(spacing: 8) {
                                Text("Expansion")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("\(mostRecentProgram) + please")
                                    .font(.title3)
                                    .bold()
                                    .foregroundColor(.white)
                            }
                            .padding()
                        }

                        Text("""
                            Set up some activities to practice for 3 minutes.
                            And don't forget the rule of 3.
                            """)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)

                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.15))
                            Text("""
                                Give your child 3 chances to say the target word \
                                with three seconds between each chance.
                                """)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .frame(minHeight: 100)

                        VStack(spacing: 10) {
                            Text("If your child says the target word, give access immediately, repeat and expand.")
                            Text("If they don't say it, that's okay. Give them the item after the third try while repeating the target.")
                        }
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                        // Buttons
                        VStack(spacing: 20) {
                            Button(action: {
                                showVideo = true
                            }) {
                                Text("Video Example")
                                    .font(.title3)
                                    .bold()
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .foregroundColor(.white)
                                    .background(Color(red: 0.92, green: 0.55, blue: 0.55))
                                    .cornerRadius(8)
                                    .shadow(radius: 5)
                            }

                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Got It")
                                    .font(.title3)
                                    .bold()
                                    .frame(maxWidth: .infinity, minHeight: 50)
                                    .foregroundColor(.white)
                                    .background(Color(red: 0.92, green: 0.55, blue: 0.55))
                                    .cornerRadius(8)
                                    .shadow(radius: 5)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.vertical, 30)
                }
            }

            // Optional Hamburger Menu
            if isMenuOpen {
                ZStack {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation { isMenuOpen = false }
                        }

                    VStack {
                        HStack {
                            Spacer()
                            VStack(spacing: 20) {
                                Button("Menu") { isMenuOpen = false }
                                Button("About") { isMenuOpen = false }
                                Button("Home Screen") { isMenuOpen = false }
                                Button("Sign Out") { isMenuOpen = false }
                            }
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(20)
                            .background(Color.black)
                            .cornerRadius(10)
                            .padding(.trailing, 20)
                            .padding(.top, 60)
                        }
                        Spacer()
                    }
                }
                .transition(.move(edge: .trailing))
                .animation(.easeInOut, value: isMenuOpen)
            }
        }
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: $showVideo) {
            NavigationStack {
                VideoExampleScreen()
            }
        }
    }
}

struct PreparePage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            PreparePage()
        }
    }
}
