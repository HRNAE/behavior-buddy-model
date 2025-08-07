import SwiftUI

struct AdminPanelView: View {
    @State private var usernameToAdd: String = ""
    @State private var output: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("👑 Admin Panel")
                .font(.title)
                .bold()

            TextField("Username to add to Editors", text: $usernameToAdd)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Add User to Editors") {
                Task {
                    await addToGroup(username: usernameToAdd, groupName: "Editors")
                }
            }
            .padding()
            .background(Color.green.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("List Users in Editors") {
                Task {
                    await listUsersInGroup(groupName: "Editors", limit: 10)
                }
            }
            .padding()
            .background(Color.blue.opacity(0.7))
            .foregroundColor(.white)
            .cornerRadius(8)

            Spacer()
        }
        .padding()
    }
}
