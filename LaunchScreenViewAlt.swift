
import SwiftUI

// MARK: - Launch Screen View with Cinematic Animation
struct LaunchScreenViewAlt: View {
    @State private var isActive = false
    @State private var scaleEffect: CGFloat = 0.6
    @State private var opacity: Double = 0.2
    @State private var zoomOut = false
    @State private var hideContent = false

    var body: some View {
        ZStack {
            if isActive {
                HomeScreen()
                    .transition(.opacity)
            } else {
                Color.black.ignoresSafeArea()

                if !hideContent {
                    VStack {
                        Image("BB_LOGO") // Your logo image asset
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                            .scaleEffect(zoomOut ? 8.0 : scaleEffect)
                            .opacity(opacity)
                            .shadow(color: .red.opacity(0.7), radius: 30)

                        Text("Behavior Buddy")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .opacity(opacity)
                            .scaleEffect(scaleEffect)
                            .padding(.top, 20)
                            .opacity(zoomOut ? 0 : 1)
                    }
                    .onAppear {
                        // Initial fade and scale in
                        withAnimation(.easeInOut(duration: 1.2)) {
                            self.scaleEffect = 1.1
                            self.opacity = 1.0
                        }

                        // Delay then zoom in and fade out
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                self.zoomOut = true
                                self.opacity = 0
                            }

                            // Switch to main screen
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                                withAnimation(.easeOut(duration: 0.5)) {
                                    self.hideContent = true
                                    self.isActive = true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
struct LaunchScreenViewAlt_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenViewAlt()
    }
}
