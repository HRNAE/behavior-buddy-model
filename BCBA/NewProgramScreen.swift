import SwiftUI

struct NewProgramScreen: View {
    let clientName: String
    @Environment(\.presentationMode) var presentationMode
    @State private var targetWord: String = ""
    @State private var reinforcement: String = ""
    @State private var dropdownSelections: [String: String] = [
        "Prompting Type": "",
        "Prompting Level": "",
        "Reinforcement Type": "",
        "Reinforcement Schedule": "",
        "Data Collection": ""
    ]
    @State private var programChoices: [String] = ["Ball", "Cookie", "Down"]

    var body: some View {
        ZStack {
            // Background Color
            Color(red: 0.27, green: 0.48, blue: 0.61) // Blue #457B9D
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Back Button at Top Left
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Client's Name in Updated Color
                Text(clientName)
                    .font(.custom("MarkerFelt-Wide", size: 75)) // Childish Font
                    .foregroundColor(Color(red: 0.92, green: 0.55, blue: 0.55)) // Updated Light Red

                // NEW PROGRAM in Childish Font
                Text("NEW PROGRAM")
                    .font(.custom("MarkerFelt-Wide", size: 36)) // Childish Font
                    .foregroundColor(.white)

                Spacer().frame(height: 20)

                // Input Fields
                VStack(spacing: 10) {
                    // Target Word Box with Enter Button
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Target Word")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                            TextField("Enter word", text: $targetWord)
                                .padding()
                                .frame(height: 50)
                                .background(Color.gray.opacity(0.3)) // Grey background
                                .cornerRadius(8)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal, 20)
                        .background(Color.gray.opacity(0.1)) // Grey box
                        .cornerRadius(10)
                        .frame(height: 100)

                        Button(action: {
                            if !targetWord.isEmpty {
                                programChoices.append(targetWord)
                                targetWord = ""
                            }
                        }) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }

                    // Reinforcement Box
                    LargeInputBox(label: "Reinforcement", placeholder: "Enter word", text: $reinforcement)
                }

                // Other Boxes with Dropdowns
                VStack(spacing: 0) {
                    ForEach(dropdownSelections.keys.sorted(), id: \.self) { label in
                        DropdownBox(label: label, selection: Binding(
                            get: { dropdownSelections[label, default: ""] },
                            set: { dropdownSelections[label] = $0 }
                        ))
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

// Large Input Box with Label Inside
struct LargeInputBox: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.title2)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
            TextField(placeholder, text: $text)
                .padding()
                .frame(height: 50)
                .background(Color.gray.opacity(0.3)) // Grey background
                .cornerRadius(8)
                .shadow(radius: 5)
        }
        .padding(.horizontal, 20)
        .background(Color.gray.opacity(0.1)) // Grey box
        .cornerRadius(10)
        .frame(height: 100) // Adjusted height for smaller rectangle
    }
}

// Dropdown Box with Dropdown Button
struct DropdownBox: View {
    let label: String
    @Binding var selection: String

    var body: some View {
        HStack {
            Text(label)
                .font(.title2)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)

            Menu {
                Button("Option 1", action: { selection = "Option 1" })
                Button("Option 2", action: { selection = "Option 2" })
                Button("Option 3", action: { selection = "Option 3" })
            } label: {
                Image(systemName: "chevron.down")
                    .font(.title2)
                    .foregroundColor(.white)
                    .padding(.trailing, 20)
            }
        }
        .background(Color.gray.opacity(0.3)) // Grey background
        .cornerRadius(10)
        .padding(.horizontal, 20)
        .frame(height: 60) // Reduced height for smaller rectangle
    }
}
