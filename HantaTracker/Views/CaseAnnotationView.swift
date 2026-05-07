import SwiftUI

struct CaseAnnotationView: View {
    let severity: Severity
    @State private var pulsing = false

    private var color: Color {
        switch severity {
        case .high:       return Color(red: 1, green: 0.23, blue: 0.19)
        case .elevated:   return Color(red: 1, green: 0.58, blue: 0)
        case .monitoring: return Color(red: 1, green: 0.8, blue: 0)
        }
    }

    var body: some View {
        ZStack {
            if severity == .high {
                Circle()
                    .fill(color.opacity(0.3))
                    .frame(width: pulsing ? 28 : 20, height: pulsing ? 28 : 20)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: pulsing)
            }
            Circle()
                .fill(color)
                .frame(width: 13, height: 13)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.5), lineWidth: 1)
                )
        }
        .onAppear { pulsing = true }
    }
}
