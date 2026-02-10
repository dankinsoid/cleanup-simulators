import SwiftUI

struct InlineButtonStyle: ButtonStyle {
    var color: Color

    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.caption)
            .foregroundStyle(color)
            .frame(width: 20, height: 20)
            .background(
                Circle()
                    .strokeBorder(color.opacity(isHovered ? 0.6 : 0.3), lineWidth: 1)
                    .background(Circle().fill(color.opacity(isHovered ? 0.12 : 0)))
            )
            .scaleEffect(configuration.isPressed ? 0.85 : 1)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.15), value: isHovered)
            .onHover { isHovered = $0 }
    }
}
