import SwiftUI
import Speech
import AVFoundation
import Amplify
import AWSPluginsCore

struct CaregiverSessionView: View {
    let parentName: String
    let childName: String

    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var audioRecorder: AVAudioRecorder?
    @State private var transcribedText: String = ""
    @State private var isRecording: Bool = false
    @State private var audioFileURL: URL?
    @State private var showLiveTranscription: Bool = false
    @State private var showMessage: String? = nil

    // Hamburger menu state
    @State private var isMenuOpen: Bool = false

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            // Background color
            Color(red: 0.27, green: 0.48, blue: 0.61)
                .edgesIgnoringSafeArea(.all)

            // Main VStack
            VStack(spacing: 0) {
                // ------------------------------------------------------------------
                // TOP BAR (Back arrow on the left, Title in the center, Hamburger on the right)
                // ------------------------------------------------------------------
                HStack {
                    // Left: Back arrow
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.leading, 16)
                    }

                    Spacer()

                    // Center: Title
                    Text("VOICE RECOGNITION SETUP")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundColor(Color(red: 0.92, green: 0.55, blue: 0.55))
                        .multilineTextAlignment(.center)

                    Spacer()

                    // Right: Hamburger menu
                    Button(action: {
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(.trailing, 16)
                    }
                }
                .padding(.vertical, 12)
                .background(Color(red: 0.27, green: 0.48, blue: 0.61))

                // ------------------------------------------------------------------
                // SCROLLABLE CONTENT
                // ------------------------------------------------------------------
                ScrollView {
                    VStack(spacing: 12) {
                        // Instruction paragraph
                        Group {
                            Text("Setting up the voice recognition will help the app to understand you better.\n\nPress ")
                            + Text("START").bold()
                            + Text(" and then read the paragraph below out loud.\n\nSpeak ")
                            + Text("CLEARLY").bold()
                            + Text(" and at a ")
                            + Text("NORMAL PACE").bold()
                        }
                        .font(.body)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)

                        // Black box automatically sized to text
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.black)

                            // Paragraph text
                            Text(paragraphText())
                                .foregroundColor(.white)
                                .font(.title2)
                                .padding(16)
                                .multilineTextAlignment(.leading)
                        }
                        .padding(.horizontal, 24)

                        // Start & End Buttons with dynamic backgrounds and disabled states
                        HStack(spacing: 16) {
                            Button(action: startRecording) {
                                Text("Start")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        isRecording
                                        ? Color.gray
                                        : Color(red: 0.92, green: 0.55, blue: 0.55)
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(isRecording)

                            Button(action: stopRecording) {
                                Text("End")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        !isRecording
                                        ? Color.gray
                                        : Color(red: 0.92, green: 0.55, blue: 0.55)
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(!isRecording)
                        }
                        .padding(.horizontal, 24)

                        // Save & Upload
                        Button(action: saveAndUploadAudio) {
                            Text("Save and Upload")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 0.92, green: 0.55, blue: 0.55))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 24)

                        // Show any message
                        if let message = showMessage {
                            Text(message)
                                .font(.body)
                                .bold()
                                .foregroundColor(Color(red: 0.92, green: 0.55, blue: 0.55))
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                                .padding(.horizontal, 24)
                        }

                        // Navigation link -> NewCaregiverScreen
                        NavigationLink(destination: ChooseChildScreen()) {
                            Text("Continue")
                                .font(.body)
                                .bold()
                                .foregroundColor(.white)
                                .frame(width: 280, height: 50)
                                .background(Color(red: 0.92, green: 0.55, blue: 0.55))
                                .cornerRadius(10)
                        }
                        .padding(.vertical, 24)
                    }
                    // A little extra padding inside the scroll
                    .padding(.top, 12)
                }
            }

            // ------------------------------------------------------------------
            // HAMBURGER MENU OVERLAY
            // ------------------------------------------------------------------
            if isMenuOpen {
                // Example overlay. You can adjust as needed.
                ZStack {
                    // Dimmed background
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                isMenuOpen = false
                            }
                        }

                    // A simple side menu
                    VStack {
                        HStack {
                            Spacer()
                            VStack(spacing: 20) {
                                Text("Menu Item 1")
                                    .foregroundColor(.white)
                                Text("Menu Item 2")
                                    .foregroundColor(.white)
                                Text("Menu Item 3")
                                    .foregroundColor(.white)
                            }
                            .font(.title2)
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
        }
        .navigationBarHidden(true)
        .onAppear {
            requestSpeechAuthorization()
        }
    }

    // MARK: - Paragraph
    private func paragraphText() -> String {
        """
        Hey, my name is \(parentName), and I’m excited to be leading a session with \(childName) today! \
        This is a test recording for the Behavior Buddy App. The words I am saying will be used to help \
        the app remember who I am. I am very excited to be using the app. Some key words and sentences \
        you might hear me say are “What do you want?”, “Ball, please,” “I want the ball,” and “buh.” \
        Thank you very much!"!
        """
    }

    // MARK: - Recording Logic
    private func requestSpeechAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            switch authStatus {
            case .authorized:
                print("Speech recognition authorized")
            case .denied, .restricted, .notDetermined:
                print("Speech recognition not authorized")
            @unknown default:
                print("Unknown authorization status")
            }
        }
    }

    private func startRecording() {
        do {
            transcribedText = ""
            createRecordingsFolder()
            let recordingsFolder = getRecordingsFolder()
            let audioFileName = UUID().uuidString + ".m4a"
            audioFileURL = recordingsFolder.appendingPathComponent(audioFileName)

            let audioRecorderSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

            let inputNode = audioEngine.inputNode
            audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: audioRecorderSettings)
            audioRecorder?.prepareToRecord()

            guard audioRecorder != nil, audioRecorder!.prepareToRecord() else {
                print("Audio recorder failed to initialize or prepare.")
                return
            }

            audioRecorder?.record()

            // Prepare speech recognition
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create SFSpeechAudioBufferRecognitionRequest.")
            }
            recognitionRequest.shouldReportPartialResults = true

            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    transcribedText = result.bestTranscription.formattedString
                }
                if error != nil || result?.isFinal == true {
                    audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                }
            }

            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                self.recognitionRequest?.append(buffer)
            }

            audioEngine.prepare()
            try audioEngine.start()
            print("Audio engine started")

            isRecording = true
        } catch {
            print("Failed to start recording: \(error.localizedDescription)")
        }
    }

    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        audioRecorder?.stop()
        isRecording = false
    }

    // MARK: - Save & Upload Combined
    private func saveAndUploadAudio() {
        guard let audioFileURL = audioFileURL else {
            print("No audio file to save/upload")
            return
        }

        showMessage = "Saving and Uploading..."

        // Local file is recorded at audioFileURL
        print("Audio file locally saved at: \(audioFileURL.path)")

        // Upload to S3
        Task {
            let identityString = await getIdentityID()
            print("Identity ID: \(identityString)")
            let dateS = dateString()
            let s3FileName = "SpeechRecognition" + ".m4a"
            print("Uploading file: \(s3FileName) to S3")

            let uploadTask = Amplify.Storage.uploadFile(
                path: .fromString("recordings/\(identityString)/\(s3FileName)"),
                local: audioFileURL
            )

            do {
                _ = try await uploadTask.value
                print("Upload completed.")
                showMessage = "Successfully saved & uploaded!"
            } catch {
                print("Upload failed: \(error)")
                showMessage = "Upload failed. Please try again."
            }
        }
    }

    // MARK: - File Helpers
    private func getRecordingsFolder() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("SPEECH RECORDINGS")
    }

    private func createRecordingsFolder() {
        let recordingsFolder = getRecordingsFolder()
        do {
            try FileManager.default.createDirectory(at: recordingsFolder, withIntermediateDirectories: true, attributes: nil)
            print("Recordings folder created at: \(recordingsFolder.path)")
        } catch {
            print("Failed to create recordings folder: \(error.localizedDescription)")
        }
    }

    private func dateString() -> String {
        let date = Date()
        let format = Date.VerbatimFormatStyle(
            format: """
            \(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)_\(hour: .twoDigits(
            clock: Date.FormatStyle.Symbol.VerbatimHour.Clock.twentyFourHour,
            hourCycle: Date.FormatStyle.Symbol.VerbatimHour.HourCycle.zeroBased
            ))-\(minute: .twoDigits)-\(second: .twoDigits)
            """,
            locale: .autoupdatingCurrent,
            timeZone: .autoupdatingCurrent,
            calendar: .init(identifier: .gregorian)
        )
        return date.formatted(format)
    }

    func getIdentityID() async -> String {
        do {
            let session = try await Amplify.Auth.fetchAuthSession()
            if let identityProvider = session as? AuthCognitoIdentityProvider {
                let identityId = try identityProvider.getIdentityId().get()
                return identityId
            }
        } catch let error as AuthError {
            print("Fetch auth session failed: \(error)")
        } catch {
            print("Unknown error: \(error)")
        }
        return "ErrorRetrievingIdentity"
    }
}
