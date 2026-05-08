import SwiftUI

struct CaseDetailSheet: View {
    let caseLocation: CaseLocation
    @ObservedObject var viewModel: OutbreakViewModel

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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // --- Header ---
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

                // --- Case count ---
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

                // --- Description ---
                Text(caseLocation.description)
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(Color(white: 0.8))
                    .lineSpacing(4)

                // --- Source link ---
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

                // --- News section ---
                Divider().background(Color.gray.opacity(0.3)).padding(.top, 4)

                HStack {
                    Text("LATEST NEWS")
                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                        .foregroundColor(.gray)
                    Spacer()
                    if viewModel.isLoadingNews {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                            .scaleEffect(0.7)
                    }
                }

                if Config.gNewsAPIKey == "YOUR_GNEWS_API_KEY_HERE" {
                    Text("Add your GNews API key in Config.swift to enable live news.")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                } else if viewModel.news.isEmpty && !viewModel.isLoadingNews {
                    Text("No recent news found for this region.")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 12) {
                        ForEach(viewModel.news) { article in
                            NewsArticleRow(article: article)
                        }
                    }
                }

                Spacer(minLength: 32)
            }
            .padding(24)
        }
        .background(Color(white: 0.07))
        .task {
            await viewModel.fetchNews(for: caseLocation.country)
        }
        .onDisappear {
            viewModel.clearNews()
        }
    }
}

struct NewsArticleRow: View {
    let article: NewsArticle

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(article.title)
                .font(.system(size: 13, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .lineLimit(3)

            HStack {
                Text(article.source.name.uppercased())
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(.gray)
                Text("·")
                    .foregroundColor(.gray)
                Text(article.publishedDate)
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)
                Spacer()
                if let url = URL(string: article.url) {
                    Link("READ →", destination: url)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.green)
                }
            }
        }
        .padding(12)
        .background(Color(white: 0.11))
        .cornerRadius(6)
    }
}
