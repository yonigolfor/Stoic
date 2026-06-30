import SwiftUI

struct StoicButton: View {
    let title: String
    var style: ButtonVariant = .primary
    let action: () -> Void

    enum ButtonVariant {
        case primary, secondary
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 17, weight: .semibold, design: .default))
                .foregroundStyle(style == .primary ? Color.stoicBackground : Color.stoicAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(style == .primary ? Color.stoicAccent : Color.stoicSurface)
                )
        }
        .buttonStyle(.plain)
    }
}
