import SwiftUI
import Amplify
import AWSPluginsCore

struct ChildProgressReportView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var fileInfoList: [(path: String, displayName: String)] = []
    @State private var isMenuOpen = false
    @State private var navigateToContentView = false
    private let pollTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    // Background Color
                    Color(red: 0.27, green: 0.48, blue: 0.61)
                        .ignoresSafeArea()

                    // Background Image
                    Image("Recent3")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height * 0.48)
                        .position(x: geo.size.width / 1.85, y: geo.size.height / 1.60)
                        .ignoresSafeArea()

                    // Main Content
                    ScrollView {
                        VStack(spacing: 0) {
                            // Top bar
                            HStack {
                                Button {
                                    presentationMode.wrappedValue.dismiss()
                                } label: {
                                    Image(systemName: "arrow.left")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                                Spacer()
                                Text("Session Reports")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                Spacer()
                                Button {
                                    withAnimation { isMenuOpen.toggle() }
                                } label: {
                                    Image(systemName: "line.horizontal.3")
                                        .font(.title)
                                        .foregroundColor(.white)
                                }
                            }
                            .padding([.leading, .top, .trailing], 20)
                            .background(Color(red: 0.27, green: 0.48, blue: 0.61).opacity(0.8))

                            // Subtitle
                            Text("View your 10 most recent reports here")
                                .font(.title3)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.top, 3)
                        }
                    }

                    // Report Cards (positioned manually)
                    ZStack {
                        ForEach(Array(fileInfoList.enumerated()), id: \.element.path) { idx, file in
                            NavigationLink(destination: ReportViewerView(filePath: file.path)) {
                                Text("\(idx + 1). Session: \(file.displayName)")
                                    .font(.system(size: 18, weight: .medium, design: .rounded))
                                    .foregroundColor(Color(red: 0.29, green: 0.18, blue: 0.07))
                                    .multilineTextAlignment(.leading)
                                    .frame(width: 320, height: 120)
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                            }
                            .position(
                                x: geo.size.width / 2,
                                y: CGFloat(geo.size.height * 0.35 + CGFloat(idx) * 150)
                            )
                        }
                    }

                    // Hamburger Menu
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
                                            closeMenu()
                                            presentationMode.wrappedValue.dismiss()
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
                    }
                }
                .navigationBarHidden(true)
                .onReceive(pollTimer) { _ in fetchReports() }
                .onAppear { fetchReports() }
                .overlay(
                    NavigationLink(destination: ContentView()
                        .navigationBarHidden(true)
                        .navigationBarBackButtonHidden(true),
                                   isActive: $navigateToContentView) {
                        EmptyView()
                    }
                )
            }
        }
    }

    // MARK: - Helpers

    private func closeMenu() {
        withAnimation { isMenuOpen = false }
    }

    private func fetchReports() {
        Task {
            let id = await getIdentityID()
            let folder = "recordings/\(id)/"
            do {
                let items = try await Amplify.Storage.list(path: .fromString(folder)).items
                let sorted = items
                    .filter { $0.key.hasSuffix("_feedback.txt") }
                    .sorted { ($0.lastModified ?? .distantPast) > ($1.lastModified ?? .distantPast) }

                let topTen = sorted.prefix(3).map { item in
                    let dateString = formatDate(item.lastModified ?? Date())
                    return (path: item.key, displayName: dateString)
                }

                await MainActor.run {
                    fileInfoList = topTen
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

    private func formatDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd EEE hh:mm a"
        return fmt.string(from: date)
    }
}
