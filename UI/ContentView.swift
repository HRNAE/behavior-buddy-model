import SwiftUI
import Amplify

struct ContentView: View {
    @State private var isAdmin: Bool = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                // Background Color
                Color(red: 0.27, green: 0.48, blue: 0.61)
                    .ignoresSafeArea()

                // Admin Button at top right
                adminButton
                    .padding()

                // Centered content (Logo, Caregiver, BCBA)
                VStack(spacing: 40) {
                    Image("BB_LOGO")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)

                    caregiverButton
                    bcbaButton
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .onAppear {
            Task {
                await checkIfAdmin()
            }
        }
    }

    // Check if user is in Admin group
    func checkIfAdmin() async {
        do {
            let userAttributes = try await Amplify.Auth.fetchUserAttributes()
            let groups = userAttributes.first(where: { $0.key.rawValue == "cognito:groups" })?.value ?? ""
            isAdmin = groups.contains("Admins")
        } catch {
            print("Error fetching user groups: \(error)")
            isAdmin = false
        }
    }

    // Admin Button updated to show AdminScreen and AdminPanelView
    var adminButton: some View {
        Group {
            if isAdmin {
                Menu {
                    NavigationLink("Admin Tasks", destination: AdminScreen())
                    NavigationLink("Manage Groups", destination: AdminPanelView())
                } label: {
                    Text("Admin")
                        .font(.title3)
                        .bold()
                        .foregroundColor(.white)
                }
            } else {
                EmptyView()
            }
        }
    }
}

// MARK: - Buttons
var caregiverButton: some View {
    ZStack {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color(red: 0.92, green: 0.55, blue: 0.55))
            .frame(width: 250, height: 100)

        NavigationLink("Caregiver", destination: NewCaregiverScreen())
            .font(.largeTitle)
            .bold()
            .foregroundColor(.white)
    }
}

var bcbaButton: some View {
    ZStack {
        RoundedRectangle(cornerRadius: 15)
            .fill(Color(red: 0.92, green: 0.55, blue: 0.55))
            .frame(width: 250, height: 100)

        NavigationLink("BCBA", destination: BCBAScreen())
            .font(.largeTitle)
            .bold()
            .foregroundColor(.white)
    }
}

#Preview {
    ContentView()
}
