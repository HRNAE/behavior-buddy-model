import SwiftUI
import Amplify
import AWSPluginsCore

struct ReportViewerView: View {
    let filePath: String

    @Environment(\.presentationMode) var presentationMode

    @State private var textFile: String = ""
    @State private var downloadToFileUrl = URL(fileURLWithPath: "")
    @State private var isLoading = true

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // ✅ Background color
                Color(red: 0.27, green: 0.48, blue: 0.61)
                    .ignoresSafeArea()

                // ✅ HoldAWS background image (very back)
                let awsImageScale: CGFloat = 2.2
                let awsImageX: CGFloat = geo.size.width / 2
                let awsImageY: CGFloat = geo.size.height / 1.91

                Image("HoldAWS")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width * awsImageScale)
                    .position(x: awsImageX, y: awsImageY)

                // ✅ Main content
                VStack {
                    // 🔙 Top bar with back button
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding(8)
                        }
                        Spacer()
                    }
                    .padding([.top, .leading, .trailing], 20)
                    .background(Color(red: 0.27, green: 0.48, blue: 0.61))

                    // 📄 Report text or loader
                    if isLoading {
                        ProgressView("Loading Report...")
                            .foregroundColor(.white)
                            .padding(.top, 50)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 20) {
                                Text(textFile)
                                    .font(.system(size: 22, weight: .bold, design: .rounded))
                                    .foregroundColor(Color(red: 0.29, green: 0.18, blue: 0.07))
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                        }
                    }

                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
        .task {
            await downloadTxtFile(from: filePath)
        }
    }

    // MARK: - Download .txt file from S3
    private func downloadTxtFile(from filePath: String) async {
        do {
            downloadToFileUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                .appendingPathComponent("DownloadedFile.txt")

            let downloadTask = Amplify.Storage.downloadFile(path: .fromString(filePath), local: downloadToFileUrl)

            for await progress in await downloadTask.progress {
                print("Download progress: \(progress)")
            }

            try await downloadTask.value

            if let contents = try? String(contentsOf: downloadToFileUrl) {
                textFile = contents
            } else {
                textFile = "Unable to read text from downloaded file."
            }

        } catch {
            textFile = "Error downloading file: \(error.localizedDescription)"
        }

        isLoading = false
    }
}
