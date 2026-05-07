import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = OutbreakViewModel()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 120)
    )

    var body: some View {
        ZStack(alignment: .top) {
            Map(coordinateRegion: $region, annotationItems: viewModel.cases) { caseLocation in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: caseLocation.latitude,
                    longitude: caseLocation.longitude
                )) {
                    CaseAnnotationView(severity: caseLocation.severity)
                        .onTapGesture {
                            viewModel.selectedCase = caseLocation
                        }
                }
            }
            .colorScheme(.dark)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderView(lastUpdated: viewModel.lastUpdated, isLoading: viewModel.isLoading)
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $viewModel.selectedCase) { caseLocation in
            CaseDetailSheet(caseLocation: caseLocation)
                .presentationDetents([.medium])
                .presentationBackground(Color(white: 0.07))
        }
        .task {
            await viewModel.load()
        }
        .refreshable {
            await viewModel.load()
        }
    }
}
