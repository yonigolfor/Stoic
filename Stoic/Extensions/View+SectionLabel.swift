import SwiftUI

extension View {
    func asSectionLabel() -> some View {
        self
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(Color.stoicAccent)
            .textCase(.uppercase)
            .tracking(1.4)
    }
}

struct SectionLabel: View {
    let title: String

    var body: some View {
        Text(title).asSectionLabel()
    }
}
