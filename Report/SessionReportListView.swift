import SwiftUI
import Amplify
import AWSPluginsCore

struct SessionReportListView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var fileInfoList: [(path: String, displayName: String)] = []
    @State private var isMenuOpen = false
    @State private var navigateToContentView = false
    @State private var isActive = true

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // --- BACKGROUND COLOR ---
                Color(red: 0.27, green: 0.48, blue: 0.61)
                    .ignoresSafeArea()

                // --- FULL-SCREEN HOLDER DOG IMAGE ---
                Image("HolderDog1")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * 1.7,
                           height: geo.size.height * 1.7)
                    .position(x: geo.size.width / 2.3,
                              y: geo.size.height / 2)

                // ---------- DISCLAIMER CARD (text-only) ----------
                VStack(alignment: .center, spacing: 10) {
                    Text("Click below to read your report!")
                        .font(.system(size: 19, weight: .bold, design: .rounded))

                    Text("Reports may take a few minutes to generate and will appear automatically.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(Color(red: 1.00, green: 0.95, blue: 0.85))
                .padding(16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.18, green: 0.23, blue: 0.33), // deep slate-blue
                            Color(red: 0.29, green: 0.42, blue: 0.54)  // steel-blue
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.yellow.opacity(0.9), lineWidth: 2)
                )
                .cornerRadius(14)
                .shadow(color: Color.black.opacity(0.4),
                        radius: 8, x: 0, y: 4)
                .padding(.horizontal, 24)
                .position(
                    x: geo.size.width / 2,
                    y: geo.size.height * 0.13       // <- moved higher
                )
                // ---------- END DISCLAIMER CARD ----------

                // --- SESSION TIME LINKS ---
                ZStack {
                    let baseX = geo.size.width * 0.43
                    let baseY = geo.size.height * 0.57
                    let verticalSpacing = geo.size.height * 0.07

                    let positions: [(x: CGFloat, y: CGFloat)] = [
                        (x: baseX, y: baseY),
                        (x: baseX, y: baseY + verticalSpacing),
                        (x: baseX, y: baseY + verticalSpacing * 2)
                    ]

                    Text("SESSION")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.29, green: 0.18, blue: 0.07))
                        .position(x: baseX, y: baseY - verticalSpacing * 0.9)

                    ForEach(Array(fileInfoList.enumerated()), id: \.element.path) { index, file in
                        let currentPosition = positions.indices.contains(index)
                                          ? positions[index]
                                          : (x: 100, y: 100)
                        let timeOnly = file.displayName.components(separatedBy: " - ").last ?? file.displayName

                        NavigationLink(destination: ReportViewerView(filePath: file.path)) {
                            Text(timeOnly)
                                .font(.system(size: 19, weight: .bold, design: .rounded))
                                .foregroundColor(Color(red: 0.29, green: 0.18, blue: 0.07))
                        }
                        .position(x: currentPosition.x, y: currentPosition.y)
                    }
                }

                // --- TOP BAR (Back + Menu) ---
                VStack {
                    HStack {
                        Button { presentationMode.wrappedValue.dismiss() } label: {
                            Image(systemName: "arrow.left")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                        Spacer()
                        Button { withAnimation { isMenuOpen.toggle() } } label: {
                            Image(systemName: "line.horizontal.3")
                                .font(.title)
                                .foregroundColor(.white)
                        }
                    }
                    .padding([.leading, .top, .trailing], 20)
                    .background(Color(red: 0.27, green: 0.48, blue: 0.61).opacity(0.95))
                    Spacer()
                }

                // --- HAMBURGER MENU OVERLAY ---
                if isMenuOpen {
                    ZStack {
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture { closeMenu() }

                        VStack {
                            HStack {
                                Spacer()
                                VStack(spacing: 20) {
                                    Button("Child Selection") { closeMenu() }
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

                // --- HIDDEN NAVIGATION TO LOGIN ---
                NavigationLink(destination: ContentView()
                               .navigationBarHidden(true)
                               .navigationBarBackButtonHidden(true),
                               isActive: $navigateToContentView) { EmptyView() }
            }
            .navigationBarHidden(true)
            .task { await startPollingReports() }
            .onDisappear { isActive = false }
        }
    }

    // MARK: - Helper Functions
    private func closeMenu() { withAnimation { isMenuOpen = false } }

    private func fetchReports() async {
        do {
            let id = try await getIdentityID()
            let folder = "recordings/\(id)/LLMxLogic_parent/"
            let items = try await Amplify.Storage.list(path: .fromString(folder)).items

            let sorted = items
                .filter { $0.key.hasSuffix(".txt") }
                .sorted { ($0.lastModified ?? .distantPast) > ($1.lastModified ?? .distantPast) }

            let topThree = sorted.prefix(3).map { item in
                let dateString = formatDate(item.lastModified ?? Date())
                return (path: item.key, displayName: dateString)
            }

            await MainActor.run { fileInfoList = topThree }
        } catch { print("Error fetching session reports: \(error)") }
    }

    private func getIdentityID() async throws -> String {
        let session = try await Amplify.Auth.fetchAuthSession()
        if let provider = session as? AuthCognitoIdentityProvider {
            return try provider.getIdentityId().get()
        }
        throw NSError(domain: "SessionError", code: 1,
                      userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity ID"])
    }

    private func formatDate(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "E hh:mm a, M/d/yyyy"; return f.string(from: date)
    }

    private func startPollingReports() async {
        while isActive {
            await fetchReports()
            try? await Task.sleep(nanoseconds: 4 * 1_000_000_000) // 4 seconds
        }
    }
}
