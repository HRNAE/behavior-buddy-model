import SwiftUI
import Amplify

struct ChooseChildScreen: View {
    @Environment(\.presentationMode) var presentationMode

    @AppStorage("childNames") private var childNamesData = Data()
    @State private var childNames: [String] = []
    @State private var newChildName: String = ""

    @State private var isMenuOpen = false
    @State private var navigateToContentView = false
    @State private var navigateToNewCaregiverScreen = false

    // Delete Child Mode
    @State private var isDeleteMode = false
    @State private var childToDelete: String?
    @State private var showDeleteConfirmation = false

    init() {
        if let names = try? JSONDecoder().decode([String].self, from: childNamesData) {
            _childNames = State(initialValue: names)
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.27, green: 0.48, blue: 0.61)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        navigateToNewCaregiverScreen = true
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(.white)
                    }

                    Spacer()

                    Button(action: {
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding([.leading, .trailing, .top], 20)

                ScrollView {
                    VStack(spacing: 20) {
                        Image("BB_LOGO")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .padding(.top, 20)

                        Text("Choose Your Child:")
                            .font(.custom("Open Sans", size: 28))
                            .bold()
                            .foregroundColor(.white)

                        VStack(spacing: 15) {
                            ForEach(childNames, id: \.self) { name in
                                HStack {
                                    if isDeleteMode {
                                        Button(action: {
                                            childToDelete = name
                                            showDeleteConfirmation = true
                                        }) {
                                            Image(systemName: "trash")
                                                .foregroundColor(.red)
                                                .scaleEffect(1.2)
                                                .padding(.trailing, 5)
                                        }
                                        .transition(.scale)
                                    }
                                    NavigationLink(destination: ViewChildDetailScreen(childName: name)) {
                                        Text(name)
                                            .frame(width: 300, height: 50)
                                            .background(Color(red: 0.92, green: 0.55, blue: 0.55))
                                            .cornerRadius(8)
                                            .shadow(radius: 5)
                                            .multilineTextAlignment(.center)
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                        }
                        .padding(.top, 10)

                        HStack(spacing: 10) {
                            TextField("Add Your Child's Name:", text: $newChildName)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(width: 220, height: 40)
                                .background(Color.white)
                                .foregroundColor(.black)
                                .cornerRadius(8)

                            Button("Add") {
                                addNewChild()
                            }
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(8)
                        }
                        .padding(.bottom, 40)
                    }
                }
            }

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
                                    navigateToContentView = true
                                    closeMenu()
                                }
                                Button("Delete Child") {
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

            // Delete Confirmation Popup
            if showDeleteConfirmation, let child = childToDelete {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation { showDeleteConfirmation = false } }

                VStack(spacing: 20) {
                    Text("Are you sure you want to delete this child?")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    Text("Removing the child would remove all the session information and reports for this child. Are you sure you want to proceed?")
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
                            if let index = childNames.firstIndex(of: child) {
                                childNames.remove(at: index)
                                saveChildNames()
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
        .overlay(
            Group {
                NavigationLink(
                    destination: ContentView()
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true),
                    isActive: $navigateToContentView
                ) { EmptyView() }

                NavigationLink(
                    destination: NewCaregiverScreen()
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true),
                    isActive: $navigateToNewCaregiverScreen
                ) { EmptyView() }
            }
        )
    }

    // MARK: - Helpers

    func addNewChild() {
        guard !newChildName.isEmpty else { return }
        childNames.append(newChildName)
        newChildName = ""
        saveChildNames()
    }

    func saveChildNames() {
        if let encoded = try? JSONEncoder().encode(childNames) {
            childNamesData = encoded
        }
    }

    private func closeMenu() {
        withAnimation {
            isMenuOpen = false
        }
    }
}
