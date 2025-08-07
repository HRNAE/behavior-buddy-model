import SwiftUI
import Amplify
import AWSPluginsCore


struct SessionDataView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var isMenuOpen = false
    @State private var navigateToChooseChild = false
    @State private var navigateToContentView = false

    @State private var sessionData: [(date: Date, path: String)] = []

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Top Bar
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
                .background(Color(red: 0.27, green: 0.48, blue: 0.61))

                ScrollView {
                    VStack(spacing: 10) {
                        Image("BB_LOGO")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                            .padding(.top, 5)

                        Text("Session Details")
                            .font(.title)
                            .foregroundColor(.white)

                        ForEach(Array(sessionData.prefix(5).enumerated()), id: \.element.path) { idx, session in
                            DisclosureGroup("Session \(idx + 1)") {
                                Text("Date: \(session.date, formatter: dateFormatter)")
                                    .foregroundColor(.white)
                                Text("Time: \(session.date, formatter: timeFormatter)")
                                    .foregroundColor(.white)
                                Text("Opportunities:")
                                    .foregroundColor(.white)
                                Text("Child Communication:")
                                    .foregroundColor(.white)
                                Text("Avg. Caregiver Fidelity:")
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(8)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .background(Color(red: 0.27, green: 0.48, blue: 0.61).ignoresSafeArea())
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .onAppear {
                fetchReports()
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
                                    navigateToChooseChild = true
                                    closeMenu()
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

            NavigationLink(destination: ChooseChildScreen().navigationBarHidden(true), isActive: $navigateToChooseChild) { EmptyView() }

            NavigationLink(destination: ContentView().navigationBarHidden(true), isActive: $navigateToContentView) { EmptyView() }
        }
    }

    private func closeMenu() {
        withAnimation { isMenuOpen = false }
    }

    private func fetchReports() {
        Task {
            let id = await getIdentityID()
            let folder = "recordings/\(id)/LLMxLogic_parent/"
            do {
                let items = try await Amplify.Storage.list(path: .fromString(folder)).items
                let sorted = items
                    .filter { $0.key.hasSuffix(".txt") }
                    .sorted { ($0.lastModified ?? .distantPast) > ($1.lastModified ?? .distantPast) }

                let topFive = sorted.prefix(5).map { item in
                    (date: item.lastModified ?? Date(), path: item.key)
                }

                await MainActor.run {
                    sessionData = topFive
                }
            } catch {
                print("Error fetching session reports:", error)
            }
        }
    }

    private func getIdentityID() async -> String {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            if let provider = session as? AuthCognitoIdentityProvider {
                return try provider.getIdentityId().get()
            }
        } catch {
            print("Auth error:", error)
        }
        return ""
    }

    // MARK: - Formatters
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }
}
