import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = OutbreakViewModel()
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 20, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 120, longitudeDelta: 120)
        )
    )

    var body: some View {
        ZStack(alignment: .top) {
            Map(position: $position) {
                ForEach(viewModel.cases) { caseLocation in
                    Annotation(
                        caseLocation.country,
                        coordinate: CLLocationCoordinate2D(
                            latitude: caseLocation.latitude,
                            longitude: caseLocation.longitude
                        ),
                        anchor: .center
                    ) {
                        CaseAnnotationView(severity: caseLocation.severity)
                            .onTapGesture {
                                viewModel.selectedCase = caseLocation
                            }
                    }
                    .annotationTitles(.hidden)
                }
            }
            .mapStyle(.standard(elevation: .flat, emphasis: .muted, pointsOfInterest: .excludingAll))
            .colorScheme(.dark)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                HeaderView(lastUpdated: viewModel.lastUpdated, isLoading: viewModel.isLoading)
                Spacer()
            }
        }
        .preferredColorScheme(.dark)
        .sheet(item: $viewModel.selectedCase) { caseLocation in
            CaseDetailSheet(caseLocation: caseLocation, viewModel: viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(white: 0.07))
        }
        .task {
            await viewModel.load()
        }
    }
}
