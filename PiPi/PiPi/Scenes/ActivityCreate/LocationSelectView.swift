//
//  LocationSelectView.swift
//  PiPi
//
//  Created by 정상윤 on 8/1/24.
//

import SwiftUI
import MapKit

struct LocationSelectView: View {
    
    @Environment(\.dismiss) private var dismiss
    @State private var centerCoordinate: CLLocationCoordinate2D = .init()
    @State private var position: MapCameraPosition
    
    @Binding var coordinates: Coordinates?
    
    private let cameraBoundary = MKCoordinateRegion.cameraBoundary
    
    init(coordinates: Binding<Coordinates?>) {
        if let coordinates = coordinates.wrappedValue {
            self.position = .camera(.init(centerCoordinate: .init(coordinates), distance: 1000))
        } else {
            let rect = MKMapRect(origin: .init(.postech), size: .init(width: 2000, height: 2000))
            let region = MKCoordinateRegion(rect)
            self.position = .region(region)
        }
        
        self._coordinates = coordinates
    }
    
    var body: some View {
        ZStack {
            topBackButton
                .zIndex(2)
            
            Map(position: $position)
                .onMapCameraChange { context in
                    centerCoordinate = context.camera.centerCoordinate
                    enforceRegionLimit()
                }
            
            Image(systemName: "mappin.and.ellipse")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                .foregroundStyle(.accent)
                .offset(y: -11.5)
                .zIndex(2)
            
            bottomSubmitButton
                .zIndex(2)
        }
    }
    
    private func enforceRegionLimit() {
        let maxLat = cameraBoundary.center.latitude + (cameraBoundary.span.latitudeDelta / 2)
        let minLat = cameraBoundary.center.latitude - (cameraBoundary.span.latitudeDelta / 2)
        let maxLon = cameraBoundary.center.longitude + (cameraBoundary.span.longitudeDelta / 2)
        let minLon = cameraBoundary.center.longitude - (cameraBoundary.span.longitudeDelta / 2)
        
        if centerCoordinate.latitude > maxLat || centerCoordinate.latitude < minLat ||
            centerCoordinate.longitude > maxLon || centerCoordinate.longitude < minLon {
            position = .region(cameraBoundary)
        }
    }
}

private extension LocationSelectView {
    
    var topBackButton: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "arrow.backward")
                        .fontWeight(.semibold)
                }
                .frame(width: 36, height: 36)
                .background(.white)
                .tint(.black)
                .clipShape(Circle())
                .setShadow()
                
                Spacer()
            }
            Spacer()
        }
        .padding(.horizontal)
    }
    
    var bottomSubmitButton: some View {
        VStack {
            Spacer()
            Button("해당 위치 선택") {
                coordinates = .init(
                    latitude: centerCoordinate.latitude,
                    longitude: centerCoordinate.longitude
                )
                dismiss()
            }
            .frame(maxWidth: .infinity, maxHeight: 48)
            .background(.accent)
            .tint(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .bold()
            .zIndex(2)
        }
        .padding(.horizontal)
    }
    
}

#Preview {
    LocationSelectView(coordinates: .constant(nil))
}
