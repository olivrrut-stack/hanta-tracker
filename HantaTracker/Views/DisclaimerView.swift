import SwiftUI

struct DisclaimerView: View {
    @Binding var accepted: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color(red: 1, green: 0.23, blue: 0.19))
                        .frame(width: 10, height: 10)
                    Text("BEFORE YOU CONTINUE")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(Color(red: 1, green: 0.23, blue: 0.19))
                }

                Text("Not Medical Advice")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)

                Text("HantaWatch displays publicly available hantavirus outbreak data for informational purposes only. It is not a medical device and does not provide medical advice.")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color(white: 0.7))
                    .lineSpacing(4)

                Text("Do not use this app to make medical decisions. Data may be outdated or incomplete. In a medical emergency, call emergency services immediately.")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color(white: 0.7))
                    .lineSpacing(4)

                Button {
                    UserDefaults.standard.set(true, forKey: "disclaimer_accepted")
                    accepted = true
                } label: {
                    Text("I UNDERSTAND — CONTINUE")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(6)
                }
                .padding(.top, 4)
            }
            .padding(28)
            .background(Color(white: 0.07))
            .cornerRadius(16)
            .padding(.horizontal, 16)

            Spacer().frame(height: 32)
        }
        .background(Color(white: 0.03).ignoresSafeArea())
    }
}
