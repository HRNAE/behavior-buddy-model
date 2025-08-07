import SwiftUI
import Amplify
import AWSPluginsCore

struct CaregiverScreen: View {
    @State private var parentName: String = ""
    @State private var childName: String = ""
    @AppStorage("programChoices") private var programChoicesData: Data = Data()
    @State private var programChoices: [String] = []

    @Environment(\.presentationMode) private var presentationMode
    @State private var navigateToNext: Bool = false
    @State private var navigateToChooseChild: Bool = false
    @State private var isUploading: Bool = false
    @State private var uploadMessage: String?

    // Onboarding flag
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color(red: 0.27, green: 0.48, blue: 0.61).ignoresSafeArea()

            VStack(spacing: 20) {
                //-- Top bar ---------------------------------------------------
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                }
                .padding([.leading, .trailing], 20)
                .padding(.top, 10)

                Spacer()

                //-- Caregiver name input -------------------------------------
                VStack(alignment: .leading, spacing: 5) {
                    Text("Caregiver's Name")
                        .font(.headline)
                        .foregroundColor(.white)

                    TextField("Enter caregiver name", text: $parentName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 40)

                //-- Child name input -----------------------------------------
                VStack(alignment: .leading, spacing: 5) {
                    Text("Child's Name")
                        .font(.headline)
                        .foregroundColor(.white)

                    TextField("Enter child's name", text: $childName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 40)

                //-- Save & Next button ---------------------------------------
                Button {
                    isUploading = true
                    uploadMessage = "Uploading..."
                    saveAndUploadCaregiverInfo()
                } label: {
                    Text("Save & Next")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(isUploading ? Color.gray : Color(red: 0.92, green: 0.55, blue: 0.55))
                        .cornerRadius(10)
                }
                .disabled(isUploading)
                .padding(.top, 30)

                //-- Upload status --------------------------------------------
                if let msg = uploadMessage {
                    Text(msg)
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding(.top, 4)
                }

                Spacer()
            }

            //-- SKIP Button (bottom-right corner) ---------------------------
            Button(action: { navigateToNext = true }) {
                Text("Skip")
                    .font(.body)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
            }
            .background(Color.black.opacity(0.3))
            .cornerRadius(12)
            .padding(.bottom, 20)
            .padding(.trailing, 20)
        }
        .onAppear {
            // decode saved program choices
            if let decoded = try? JSONDecoder().decode([String].self, from: programChoicesData) {
                programChoices = decoded
            }
            // Check if onboarding was seen
            if hasSeenOnboarding {
                // Automatically navigate to ChooseChildScreen
                navigateToChooseChild = true
            }
        }
        .background(
            VStack {
                NavigationLink(
                    destination: CaregiverSessionView(parentName: parentName, childName: childName),
                    isActive: $navigateToNext
                ) { EmptyView() }

                NavigationLink(
                    destination: ChooseChildScreen(),  // use your existing ChooseChildScreen here
                    isActive: $navigateToChooseChild
                ) { EmptyView() }
            }
        )
        .navigationBarHidden(true)
        .fullScreenCover(isPresented: .constant(!hasSeenOnboarding), onDismiss: {
            hasSeenOnboarding = true
        }) {
            OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
        }
    }

    // MARK: - Save & Upload Logic
    private func saveAndUploadCaregiverInfo() {
        let date = dateString()
        let fileName = "\(parentName)\(date).txt"
        let fileContent = """
        Caregiver: \(parentName)
        Child: \(childName)
        Programs: \(programChoices.joined(separator: ", "))
        """

        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localFileURL = documentsURL.appendingPathComponent(fileName)

        do {
            try fileContent.write(to: localFileURL, atomically: true, encoding: .utf8)
            print("✅ Text file saved at: \(localFileURL.path)")
        } catch {
            print("❌ Failed to save text file: \(error)")
            uploadMessage = "File save error."
            isUploading = false
            return
        }

        Task {
            let identityString = await getIdentityID()
            let s3Key = "recordings/\(identityString)/\(parentName)/\(fileName)"

            let uploadTask = Amplify.Storage.uploadFile(
                path: .fromString(s3Key),
                local: localFileURL
            )

            do {
                _ = try await uploadTask.value
                print("✅ Upload complete: \(s3Key)")
                uploadMessage = "Upload successful!"
                isUploading = false
                navigateToNext = true
            } catch {
                print("❌ Upload failed: \(error)")
                uploadMessage = "Upload failed. Check AWS permissions."
                isUploading = false
            }
        }
    }

    private func dateString() -> String {
        let date = Date()
        let format = Date.VerbatimFormatStyle(
            format: """
            \(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)_\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased))-\(minute: .twoDigits)-\(second: .twoDigits)
            """,
            locale: .autoupdatingCurrent,
            timeZone: .autoupdatingCurrent,
            calendar: .init(identifier: .gregorian)
        )
        return date.formatted(format)
    }

    private func getIdentityID() async -> String {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            if let provider = session as? AuthCognitoIdentityProvider {
                let id = try provider.getIdentityId().get()
                return id
            }
        } catch {
            print("❌ Identity ID fetch failed: \(error)")
        }
        return "unknown"
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool

    var body: some View {
        VStack {
            Spacer()
            Text("Welcome to Behavior Buddy!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding()
            Text("This app helps caregivers manage programs and sessions. Let’s get started!")
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding()

            Spacer()

            Button(action: {
                hasSeenOnboarding = true
            }) {
                Text("Get Started")
                    .font(.title2).bold()
                    .foregroundColor(.white)
                    .frame(width: 200, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.bottom, 50)
        }
        .background(Color(red: 0.27, green: 0.48, blue: 0.61).ignoresSafeArea())
    }
}

struct CaregiverScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CaregiverScreen()
        }
        .navigationBarHidden(true)
    }
}
