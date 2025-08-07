

import SwiftUI
public var selectedWord = ""
struct CaregiverTargetWord: View {
    @State public var selectedItem = "Car"
    @State private var newWord: String = ""
    @State private var items = ["Car", "Gummy", "Sand", "Bear", "Train", "Ball", "Tablet", "Dinosaur"]
    @State private var navigate = false
    let childName: String
    init(childName: String) {
        self.childName = childName
        
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Get ready to practice for\n3 minutes")
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .foregroundColor(.black)
                    .padding(.top)
                
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color(red: 255, green: 255, blue: 255))
                        .frame(width: 350, height: 70)
                    Text("Today we will be practicing\nwith these items or snacks:")
                        .offset(x: 0, y: -10)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.black)
                        .padding(.top)
                }
                
                Picker("Select an item", selection: $selectedItem) {
                    ForEach(items, id: \.self) { item in
                        Text(item).tag(item)
                            
                    }
                    
                }
                .pickerStyle(MenuPickerStyle())
                .frame(width: 250)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white)
                        .frame(width: 380, height: 70)
                    
                    HStack {
                        TextField("If word not present enter word:", text: $newWord)
                            .padding(.leading, 10)
                            .frame(height: 50)
                            .background(Color.black.opacity(0.1))
                            .cornerRadius(8)
                            .foregroundColor(.black)
                        
                        Button(action: {
                            
                            let trimmed = newWord.trimmingCharacters(in: .whitespacesAndNewlines)
                            if !trimmed.isEmpty && !items.contains(trimmed) {
                                items.append(trimmed)
                                selectedItem = trimmed
                                newWord = ""
                            }
                        }) {
                            Image(systemName: "plus")
                                .foregroundColor(.red)
                                .font(.system(size: 30, weight: .bold))
                        }
                        .padding(.trailing, 15)
                    }
                    .frame(width: 350)
                }
                
                // Button
                Button(action: {
                    selectedWord = selectedItem
                    print("Selected: \(selectedItem)")
                    navigate = true
                }) {
                    Text("Got it")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(12)
                }

                NavigationLink(
                    destination: PracticeSessionScreen(childName: childName),
                    isActive: $navigate,
                    label: { EmptyView() }
                )
                .padding()
                
                Spacer()
            }
            .padding()
            .background(Color(red: 0.2, green: 0.35, blue: 0.5).ignoresSafeArea())
        }
    }
}

struct CaregiverTargetWord_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            CaregiverTargetWord(childName: "Haren")
        }
    }
}
