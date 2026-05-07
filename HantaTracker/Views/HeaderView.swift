import SwiftUI

struct HeaderView: View {
    let lastUpdated: Date?
    let isLoading: Bool

    private var updatedText: String {
        guard let date = lastUpdated else { return "BUNDLED DATA" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return "UPDATED \(formatter.localizedString(for: date, relativeTo: Date()).uppercased())"
    }

    var body: some View {
        HStack(spacing: 12) {
            Text("HANTAWATCH")
                .font(.system(size: 16, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            Spacer()

            if isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            } else {
                Text(updatedText)
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial.opacity(0.9))
    }
}
