import SwiftUI
import Amplify

struct PracticeSessionScreen: View {
    @Environment(\.presentationMode) var presentationMode
    let childName: String
    @AppStorage("programChoices") var programChoicesData: Data = Data()
    @State private var programChoices: [String] = []

    @State private var isMenuOpen = false
    @State private var navigateToChooseChild = false
    @State private var navigateToContentView = false

    // Dropdown state
    @State private var isDropdownOpen = false

    // Add program popup
    @State private var showAddProgramPopup = false
    @State private var newProgramName = ""

    // Delete program mode
    @State private var isDeleteMode = false
    @State private var programToDelete: String?
    @State private var showDeleteConfirmation = false

    init(childName: String) {
        self.childName = childName
        if let tasks = try? JSONDecoder().decode([String].self, from: programChoicesData) {
            _programChoices = State(initialValue: tasks)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Color
                Color(red: 0.27, green: 0.48, blue: 0.61)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // -- TOP BAR --
                    HStack {
                        Button(action: { presentationMode.wrappedValue.dismiss() }) {
                            Image(systemName: "arrow.left")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button(action: {
                            withAnimation { isMenuOpen.toggle() }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .padding([.leading, .top, .trailing], 20)

                    Image("BB_LOGO")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .padding(.top, 20)

                    VStack(spacing: 0) {
                        Text(childName)
                            .font(.custom("OpenSans-Bold", size: 45))
                            .foregroundColor(.white)
                        Text("Practice")
                            .font(.custom("Open Sans", size: 30))
                            .foregroundColor(.white)
                    }

                    Spacer().frame(height: 30)

                    // -- DROPDOWN MENU --
                    VStack(spacing: 15) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.4)) {
                                isDropdownOpen.toggle()
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text("Choose Program")
                                    .font(.title2)
                                    .bold()
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: isDropdownOpen ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(isDropdownOpen ? 180 : 0))
                                    .animation(.easeInOut, value: isDropdownOpen)
                            }
                            .padding()
                            .background(
                                BlurView(style: .systemThinMaterialDark)
                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                    .shadow(radius: 5)
                            )
                        }

                        if isDropdownOpen {
                            VStack {
                                ScrollView {
                                    VStack(spacing: 12) {
                                        ForEach(programChoices, id: \.self) { choice in
                                            HStack {
                                                if isDeleteMode {
                                                    Button(action: {
                                                        programToDelete = choice
                                                        showDeleteConfirmation = true
                                                    }) {
                                                        Image(systemName: "trash")
                                                            .foregroundColor(.red)
                                                            .scaleEffect(1.2)
                                                            .padding(.trailing, 5)
                                                    }
                                                    .transition(.scale)
                                                }
                                                NavigationLink(
                                                    destination: SessionDetailScreen(childName: childName, selectedSession: choice)
                                                ) {
                                                    Text(choice)
                                                        .frame(maxWidth: .infinity)
                                                        .padding()
                                                        .background(
                                                            RoundedRectangle(cornerRadius: 10)
                                                                .fill(Color.white.opacity(0.15))
                                                                .overlay(
                                                                    RoundedRectangle(cornerRadius: 10)
                                                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                                                )
                                                        )
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.bottom, 10)
                                }
                                .frame(maxHeight: 250)
                                .background(
                                    BlurView(style: .systemMaterialLight)
                                        .opacity(0.3)
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .shadow(radius: 5)
                                )
                                .padding(.horizontal)
                                .transition(.asymmetric(
                                    insertion: AnyTransition.opacity.combined(with: .move(edge: .top)),
                                    removal: AnyTransition.opacity.combined(with: .move(edge: .top))
                                ))
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding()

                // Hamburger Menu Overlay
                if isMenuOpen {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture { closeMenu() }

                        VStack {
                            HStack {
                                Spacer()
                                VStack(spacing: 20) {
                                    Button("Child Selection") {
                                        navigateToChooseChild = true
                                        closeMenu()
                                    }
                                    Button("Add Program") {
                                        showAddProgramPopup = true
                                        closeMenu()
                                    }
                                    Button("Delete Program") {
                                        isDeleteMode.toggle()
                                        isMenuOpen = false
                                    }
                                    Button("Sign Out") {
                                        Task {
                                            await Amplify.Auth.signOut()
                                            navigateToContentView = true
                                        }
                                        closeMenu()
                                    }
                                }
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(20)
                                .background(Color.black)
                                .cornerRadius(10)
                                .padding(.trailing, 20)
                                .padding(.top, 80)
                            }
                            Spacer()
                        }
                    }
                    .transition(.move(edge: .trailing))
                    .animation(.easeInOut, value: isMenuOpen)
                }

                // Add Program Popup
                if showAddProgramPopup {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showAddProgramPopup = false } }

                    VStack(spacing: 20) {
                        Text("Add a Program")
                            .font(.title2)
                            .bold()
                            .foregroundColor(.white)
                        TextField("Type program name...", text: $newProgramName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                        HStack {
                            Button("Cancel") {
                                withAnimation { showAddProgramPopup = false }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                            Button("OK") {
                                if !newProgramName.trimmingCharacters(in: .whitespaces).isEmpty {
                                    programChoices.append(newProgramName)
                                    savePrograms()
                                    newProgramName = ""
                                    withAnimation { showAddProgramPopup = false }
                                }
                            }
                            .padding()
                            .background(Color.green.opacity(0.7))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(BlurView(style: .systemThinMaterialDark))
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                    .transition(.scale.combined(with: .opacity))
                }

                // Delete Confirmation Popup
                if showDeleteConfirmation, let program = programToDelete {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { withAnimation { showDeleteConfirmation = false } }

                    VStack(spacing: 20) {
                        Text("Are you sure you want to delete '\(program)'?")
                            .multilineTextAlignment(.center)
                            .font(.title3)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        Text("Deleting this program will erase all data related to it.")
                            .multilineTextAlignment(.center)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal)
                        HStack {
                            Button("Back") {
                                withAnimation { showDeleteConfirmation = false }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                            Button("Delete") {
                                if let index = programChoices.firstIndex(of: program) {
                                    programChoices.remove(at: index)
                                    savePrograms()
                                }
                                withAnimation {
                                    showDeleteConfirmation = false
                                    isDeleteMode = false
                                }
                            }
                            .padding()
                            .background(Color.red.opacity(0.7))
                            .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(BlurView(style: .systemThinMaterialDark))
                    .cornerRadius(15)
                    .padding(.horizontal, 40)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .navigationTitle("")
            .navigationBarHidden(true)
        }
        .overlay(
            NavigationLink(destination: ChooseChildScreen()
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true),
                           isActive: $navigateToChooseChild) {
                EmptyView()
            }
        )
        .overlay(
            NavigationLink(destination: ContentView()
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true),
                           isActive: $navigateToContentView) {
                EmptyView()
            }
        )
    }

    private func closeMenu() {
        withAnimation { isMenuOpen = false }
    }

    private func savePrograms() {
        if let data = try? JSONEncoder().encode(programChoices) {
            programChoicesData = data
        }
    }
}

// Glassy background using UIVisualEffectView
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}



