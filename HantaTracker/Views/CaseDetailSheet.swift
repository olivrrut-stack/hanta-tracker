import SwiftUI

struct CaseDetailSheet: View {
    let caseLocation: CaseLocation

    private var severityLabel: String {
        switch caseLocation.severity {
        case .high:       return "HIGH ACTIVITY"
        case .elevated:   return "ELEVATED"
        case .monitoring: return "MONITORING"
        }
    }

    private var severityColor: Color {
        switch caseLocation.severity {
        case .high:       return Color(red: 1, green: 0.23, blue: 0.19)
        case .elevated:   return Color(red: 1, green: 0.58, blue: 0)
        case .monitoring: return Color(red: 1, green: 0.8, blue: 0)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(caseLocation.country)
                        .font(.system(size: 24, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    if let region = caseLocation.region {
                        Text(region)
                            .font(.system(size: 13, weight: .regular, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                Text(severityLabel)
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
                    .foregroundColor(severityColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(severityColor.opacity(0.15))
                    .cornerRadius(4)
            }

            Divider().background(Color.gray.opacity(0.3))

            if let count = caseLocation.confirmedCount {
                HStack(spacing: 4) {
                    Text("\(count)")
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                    Text("confirmed cases")
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            }

            Text(caseLocation.description)
                .font(.system(size: 14, design: .monospaced))
                .foregroundColor(Color(white: 0.8))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            HStack {
                Text("Last updated: \(caseLocation.lastUpdated)")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
                Spacer()
                if let urlString = caseLocation.sourceURL, let url = URL(string: urlString) {
                    Link("VIEW SOURCE →", destination: url)
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(.green)
                }
            }

            Spacer()
        }
        .padding(24)
        .background(Color(white: 0.07))
    }
}
