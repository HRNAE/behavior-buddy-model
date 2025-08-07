import SwiftUI
import UIKit
import Speech
import AVFoundation
import Amplify
import AWSPluginsCore

struct SpeechRecognitionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Speech-Related Properties
    @State private var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var audioRecorder: AVAudioRecorder?
    @State private var transcribedText: String = ""
    @State private var isRecording: Bool = false
    @State private var audioFileURL: URL?
    @State private var showLiveTranscription: Bool = false
    
    // MARK: - Session & Timer
    @AppStorage("sessionCounts") private var sessionCountsData: Data = Data()
    private var sessionKey: String { "\(clientName)|\(selectedProgram)" }
    @State private var sessionCount: Int = 0
    @State private var timeRemaining = 180
    @State private var isTimerRunning = false
    
    @State private var showMessage: String? = nil
    @State private var isAudioSaved = false  // Track if the current audio has been saved
    
    // MARK: - Navigation Variables
    @State private var navigateToSessionData = false
    @State private var navigateToSessionReports = false
    @State private var navigateToStats: Bool = false
    @State private var navigateToChooseChild = false
    @State private var navigateToContentView = false
    
    // MARK: - Menu & Delete Overlays
    @State private var isMenuOpen = false
    @State private var showDeleteConfirmation = false
    
    let clientName: String
    let selectedProgram: String
    
    // MARK: - Timer for UI Updates
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Background color (covers entire screen)
            Color(red: 0.27, green: 0.48, blue: 0.61)
                .ignoresSafeArea()
            
            // Main layout container
            VStack(spacing: 0) {
                
                // --- TOP BAR (pinned) ---
                HStack {
                    // Back button on the left
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    // Hamburger Menu on the right
                    Button(action: {
                        withAnimation {
                            isMenuOpen.toggle()
                        }
                    }) {
                        Image(systemName: "line.horizontal.3")
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
                .padding([.leading, .top, .trailing], 20)
                
                // --- SCROLLABLE MAIN CONTENT ---
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 15) {
                        
                        // Centered Session Name & "SESSION" Text
                        VStack(spacing: 0) {
                            Text(clientName)
                                .font(.custom("OpenSans-Bold", size: 75))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                            Text("SESSION")
                                .font(.custom("OpenSans-Bold", size: 35))
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 10)
                        
                        // Program Box
                        HStack(spacing: 8) {
                            Text("Program:")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                            
                            Text(selectedProgram)
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal, 20)
                        
                        // Session Count Box
                        HStack(spacing: 8) {
                            Text("Session:")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                            
                            Text("\(sessionCount)")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(8)
                                .shadow(radius: 5)
                        }
                        .padding(.horizontal, 20)
                        
                        // Timer Box
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.gray.opacity(0.3))
                                .frame(maxWidth: 300, minHeight: 80)
                            
                            Text(timeString(from: timeRemaining))
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }
                        .onReceive(timer) { _ in
                            if isTimerRunning && timeRemaining > 0 {
                                timeRemaining -= 1
                            } else if timeRemaining == 0 {
                                showMessage = "Session Ended!"
                                isTimerRunning = false
                            }
                        }
                        
                        // Toggle to show/hide live transcription
                        Button(action: {
                            showLiveTranscription.toggle()
                        }) {
                            Text("Show Live Transcription")
                                .foregroundColor(.white)
                        }
                        
                        if showLiveTranscription {
                            TextEditor(text: $transcribedText)
                                .font(.body)
                                .padding(8)
                                .frame(height: 150)
                                .border(Color.gray, width: 1)
                                .cornerRadius(8)
                                .padding(.horizontal, 20)
                        }
                        
                        // Start & End Buttons
                        HStack(spacing: 15) {
                            Button(action: startRecording) {
                                Text("Start")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(isRecording
                                                ? Color.gray
                                                : Color(red: 0.92, green: 0.55, blue: 0.55))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(isRecording)
                            
                            Button(action: stopRecording) {
                                Text("End")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(!isRecording
                                                ? Color.gray
                                                : Color(red: 0.92, green: 0.55, blue: 0.55))
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                            .disabled(!isRecording)
                        }
                        .padding(.horizontal, 20)
                        
                        // Save Button
                        Button(action: saveAudio) {
                            Text("Save")
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color(red: 0.92, green: 0.55, blue: 0.55))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal, 20)
                        
                        // ---------- DISCLAIMER ----------
                        // ---------- DISCLAIMER ----------
                        /// A more eye-catching, “fancy” look
                        VStack(alignment: .center, spacing: 6) {
                            Text("Set up your activity in a quiet area with few distractions.")
                            (
                                Text("Press ") +
                                Text("START").fontWeight(.bold) +
                                Text(" and start practicing!")
                            )
                            Text("Once you are done, save your session to view your feedback.")
                        }
                        .font(.custom("OpenSans-SemiBoldItalic", size: 17))
                        .foregroundColor(Color(red: 1.00, green: 0.95, blue: 0.85))   // warm cream text
                        .multilineTextAlignment(.center)
                        .padding(16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(red: 0.18, green: 0.23, blue: 0.33),   // deep slate-blue
                                    Color(red: 0.29, green: 0.42, blue: 0.54)    // steel-blue
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
                        .shadow(color: Color.black.opacity(0.4), radius: 8, x: 0, y: 4)
                        .padding(.horizontal, 24)
                        // ---------- DISCLAIMER ----------

                        // HIDDEN NAV LINKS
                        NavigationLink(
                            destination: ViewStatsView(clientName: clientName, selectedProgram: selectedProgram),
                            isActive: $navigateToStats
                        ) {
                            EmptyView()
                        }
                        .hidden()
                        
                        NavigationLink(destination: SessionDataView(), isActive: $navigateToSessionData) {
                            EmptyView()
                        }
                        .hidden()
                        
                        NavigationLink(destination: SessionReportsView(), isActive: $navigateToSessionReports) {
                            EmptyView()
                        }
                        .hidden()
                        
                        NavigationLink(destination: ChooseChildScreen(), isActive: $navigateToChooseChild) {
                            EmptyView()
                        }
                        .hidden()
                        
                        NavigationLink(destination: ContentView(), isActive: $navigateToContentView) {
                            EmptyView()
                        }
                        .hidden()
                        
                        Spacer().frame(height: 50)
                    }
                    .padding(.bottom, 10)
                    .onAppear {
                        UIApplication.shared.isIdleTimerDisabled = true
                        requestSpeechAuthorization()
                        loadSessionCount()
                    }
                    .onDisappear {
                        UIApplication.shared.isIdleTimerDisabled = false
                    }
                }
                .navigationBarHidden(true)
                .navigationBarBackButtonHidden(true)
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
                                Button("Delete Session") {
                                    showDeleteConfirmation = true
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
            
            // --- DELETE SESSION CONFIRMATION OVERLAY ---
            if showDeleteConfirmation {
                ZStack {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture { showDeleteConfirmation = false }
                    
                    VStack(spacing: 20) {
                        HStack {
                            Spacer()
                            Button(action: { showDeleteConfirmation = false }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.trailing, 10)
                        
                        Text("Are you sure you want to delete the whole session?")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                            .padding()
                        
                        HStack(spacing: 40) {
                            Button(action: {
                                deleteSession()
                                showDeleteConfirmation = false
                            }) {
                                Text("Yes")
                                    .bold()
                                    .frame(width: 100, height: 44)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            Button(action: {
                                showDeleteConfirmation = false
                            }) {
                                Text("No")
                                    .bold()
                                    .frame(width: 100, height: 44)
                                    .background(Color.gray)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .padding(.horizontal, 40)
                }
                .transition(.opacity)
                .animation(.easeInOut, value: showDeleteConfirmation)
            }
        }
    }
}

// MARK: - Private Methods for Session Handling
extension SpeechRecognitionView {
    
    /// Loads the stored session count for (clientName, selectedProgram).
    private func loadSessionCount() {
        // Decode dictionary from AppStorage
        let decoder = JSONDecoder()
        if let dict = try? decoder.decode([String: Int].self, from: sessionCountsData) {
            sessionCount = dict[sessionKey] ?? 0
        }
    }
    
    /// Saves the current session count to AppStorage
    private func saveSessionCount() {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        
        var dict: [String: Int] = [:]
        if let loaded = try? decoder.decode([String: Int].self, from: sessionCountsData) {
            dict = loaded
        }
        dict[sessionKey] = sessionCount
        
        if let encoded = try? encoder.encode(dict) {
            sessionCountsData = encoded
        }
    }
}

// MARK: - Recording Methods & Helpers
extension SpeechRecognitionView {
    
    private func startRecording() {
        do {
            // Increase session count, persist it
            sessionCount += 1
            saveSessionCount()
            
            transcribedText = ""
            isAudioSaved = false
            
            createRecordingsFolder()
            let recordingsFolder = getRecordingsFolder()
            let audioFileName = UUID().uuidString + ".m4a"
            audioFileURL = recordingsFolder.appendingPathComponent(audioFileName)
            
            // IMPROVED SETTINGS
            let audioRecorderSettings: [String: Any] = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVSampleRateKey: 48000.0, // better clarity
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue // highest quality
            ]
            
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth])
            try audioSession.setPreferredSampleRate(48000)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            let inputNode = audioEngine.inputNode
            audioRecorder = try AVAudioRecorder(url: audioFileURL!, settings: audioRecorderSettings)
            audioRecorder?.prepareToRecord()
            
            guard audioRecorder != nil else {
                print("Audio recorder is not initialized.")
                return
            }
            if audioRecorder?.prepareToRecord() == false {
                print("Failed to prepare audio recorder.")
                return
            }
            
            audioRecorder?.record()
            
            recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
            guard let recognitionRequest = recognitionRequest else {
                fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object")
            }
            recognitionRequest.shouldReportPartialResults = true
            
            recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
                if let result = result {
                    transcribedText = result.bestTranscription.formattedString
                }
                if error != nil || result?.isFinal == true {
                    self.audioEngine.stop()
                    inputNode.removeTap(onBus: 0)
                    self.recognitionRequest = nil
                    self.recognitionTask = nil
                }
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, when in
                self.recognitionRequest?.append(buffer)
            }
            
            audioEngine.prepare()
            try audioEngine.start()
            
            timeRemaining = 180
            isTimerRunning = true
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
        isTimerRunning = false
    }
    
    private func saveAudio() {
        guard let audioFileURL = audioFileURL else {
            print("No audio file to save")
            return
        }
        isAudioSaved = true
        print("Saved audio file locally: \(audioFileURL.path)")
        
        // Changed notification text to "Please wait.."
        showMessage = "Please wait.."
        
        Task {
            let identityString = await getIdentityID()
            let dateS = dateString()
            let s3FileName = dateS + "_" + selectedWord + "_" + selectedProgram + ".m4a"
            print(s3FileName)
            _ = Amplify.Storage.uploadFile(
                path: .fromString("recordings/\(identityString)/\(s3FileName)"),
                local: audioFileURL
            )
        }
        
        // After a few seconds, navigate to stats
        DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
            navigateToStats = true
            showMessage = nil
        }
    }
    
    private func deleteSession() {
        guard !isAudioSaved else {
            print("Cannot delete. Audio already saved.")
            return
        }
        
        // Decrement session count if possible, then persist
        if sessionCount > 0 {
            sessionCount -= 1
            saveSessionCount()
        }
        
        if let url = audioFileURL {
            do {
                if FileManager.default.fileExists(atPath: url.path) {
                    try FileManager.default.removeItem(at: url)
                    print("Deleted local audio file: \(url.path)")
                }
            } catch {
                print("Error deleting local file: \(error)")
            }
        }
        audioFileURL = nil
        timeRemaining = 180
        isTimerRunning = false
    }
    
    private func timeString(from seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
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
    
    private func closeMenu() {
        withAnimation {
            isMenuOpen = false
        }
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
    
    private func createRecordingsFolder() {
        let folder = getRecordingsFolder()
        do {
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true, attributes: nil)
            print("Recordings folder created at: \(folder.path)")
        } catch {
            print("Failed to create recordings folder: \(error.localizedDescription)")
        }
    }
    
    private func getRecordingsFolder() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("SPEECH RECORDINGS")
    }
}
