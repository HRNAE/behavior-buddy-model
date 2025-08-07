import SwiftUI

struct AdminScreen: View {
    @AppStorage("programChoices") var programChoicesData: Data = Data()
    @State private var newTask: String = ""
    @State private var programChoices: [String] = []

    @Environment(\.dismiss) private var dismiss

    init() {
        if let tasks = try? JSONDecoder().decode([String].self, from: programChoicesData) {
            _programChoices = State(initialValue: tasks)
        }
    }

    var body: some View {
        ZStack {
            Color(red: 0.27, green: 0.48, blue: 0.61)
                .ignoresSafeArea()

            VStack(alignment: .center, spacing: 20) {
                Text("Welcome to the Admin Panel")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding(.top, 40)

                Text("Please provide a Task to the Caregiver:")
                    .foregroundColor(.white)
                    .font(.headline)

                TextField("Enter new task here", text: $newTask)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Save Task") {
                    addNewTask()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(10)

                VStack {
                    ForEach(programChoices, id: \.self) { choice in
                        Text(choice)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                Spacer()
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(.white)
                }
            }
        }
    }

    func addNewTask() {
        guard !newTask.isEmpty else { return }
        programChoices.append(newTask)
        newTask = ""
        saveTasks()
    }

    func saveTasks() {
        if let encoded = try? JSONEncoder().encode(programChoices) {
            programChoicesData = encoded
        }
    }
}
