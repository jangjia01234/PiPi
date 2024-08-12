//
//  SelectedMapView.swift
//  PiPi
//
//  Created by Byeol Kim on 8/3/24.
//

import SwiftUI
import MapKit

struct SelectedMapView: View {
    
    let coordinates: CLLocationCoordinate2D
    
    @State private var region: MKCoordinateRegion
    @Environment(\.dismiss) private var dismiss
    
    init(coordinate: Coordinates) {
        self.coordinates = coordinate.toCLLocationCoordinate2D
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinates,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: [Annotation(coordinate: coordinates)]) { annotation in
                MapAnnotation(coordinate: annotation.coordinate) {
                    Image(systemName: "mappin.and.ellipse")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.accent)
                        .offset(y: -11.5)
                        .zIndex(2)
                }
            }
            
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.gray)
                            .padding()
                    }
                }
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}

struct Annotation: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

extension Coordinates {
    var toCLLocationCoordinate2D: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}
#Preview {
    SelectedMapView(coordinate: .init(latitude: 36.015501, longitude: 129.322548))
}
