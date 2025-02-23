import SwiftUI

struct GradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(.systemBlue).opacity(0.2), Color(.systemPurple).opacity(0.2)]),
            startPoint: .top,
            endPoint: .bottom
        )
        .edgesIgnoringSafeArea(.all) // Covers the entire screen
    }
}
