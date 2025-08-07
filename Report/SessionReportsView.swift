import SwiftUI

struct SessionReportsView: View {
    @State private var progress: CGFloat = 0.0
    @State private var showReports = false

    // 🔧 Optional adjustable size and position values
    let imageScale: CGFloat = 1 // percent of screen width
    let verticalOffset: CGFloat = 0 // shift image up/down if needed

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.27, green: 0.48, blue: 0.61)
                    .ignoresSafeArea()

                // ✅ Adjustable PushAWS image
                GeometryReader { geo in
                    Image("PushAws4")
                        .resizable()
                        .scaledToFit()
                        .frame(
                            width: geo.size.width * imageScale,
                            height: geo.size.height * imageScale
                        )
                        .position(
                            x: geo.size.width / 2,
                            y: geo.size.height / 2 + verticalOffset
                        )
                        .allowsHitTesting(false)
                }

                if showReports {
                    SessionReportListView()
                        .transition(.opacity)
                    
                } else {
                    VStack {
                        Spacer()
                        VStack(spacing: 14) {
                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.3))
                                        .frame(width: geo.size.width * 0.65, height: 12)

                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color(red: 0.92, green: 0.55, blue: 0.55))
                                        .frame(width: geo.size.width * 0.65 * progress, height: 12)

                                    Image("KidWalking")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 30, height: 30)
                                        .offset(x: geo.size.width * 0.65 * progress - 15, y: -10)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                            }
                            .frame(height: 30)

                            Text("Buddy is working hard on your report")
                                .font(.headline)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                        }
                        .padding(.bottom, 40)
                    }
                    .onAppear {
                        withAnimation(.linear(duration: 10)) {
                            progress = 1.0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                            withAnimation {
                                showReports = true
                            }
                        }
                    }
                }
            }
            // ✅ This line hides the blue back button
            .navigationBarBackButtonHidden(true)
        }
    }
}
