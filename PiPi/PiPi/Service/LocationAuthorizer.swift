//
//  LocationAuthorizer.swift
//  PiPi
//
//  Created by 정상윤 on 9/7/24.
//

import CoreLocation

struct LocationAuthorizer {
    
    private let kakaoAPIKey = "1b6731d96624bcd37dfb4878a44ab451"
    private let url = "https://dapi.kakao.com/v2/local/geo/coord2address.json"
    private let locationManager = LocationManager()
    
    func authorize() async -> Result<Bool, Error> {
        locationManager.requestLocation()
        
        while locationManager.currentLocation == nil {}
        
        guard let coordinate = locationManager.currentLocation else {
            return .failure(LocationAuthorizeError.locationFailed)
        }
        
        switch await fetchResopnse(coordinate: coordinate) {
        case .success(let response):
            guard let document = response.documents.first else {
                return .failure(LocationAuthorizeError.invalidData)
            }
            
            return .success(addressValidation(document.address))
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func addressValidation(_ address: Address) -> Bool {
        address.region3depthName == "지곡동" || address.region3depthName == "효자동"
    }
    
    private func fetchResopnse(coordinate: CLLocationCoordinate2D) async -> Result<Response, Error> {
        guard let urlRequest = createRequest(coordinate: coordinate) else {
            return .failure(LocationAuthorizeError.invalidURL)
        }
        
        do {
            let data = try await URLSession.shared.data(for: urlRequest).0
            let response = try JSONDecoder().decode(Response.self, from: data)
            
            return .success(response)
        } catch {
            return .failure(error)
        }
    }
    
    private func createRequest(coordinate: CLLocationCoordinate2D) -> URLRequest? {
        guard let url = URL(string: "\(url)?x=\(coordinate.longitude)&y=\(coordinate.latitude)") else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("KakaoAK \(kakaoAPIKey)", forHTTPHeaderField: "Authorization")
        
        return urlRequest
    }
    
    enum LocationAuthorizeError: LocalizedError {
        
        case invalidURL
        case invalidData
        case locationFailed
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                "유효하지 않은 URL입니다."
            case .invalidData:
                "유효하지 않은 데이터가 응답으로 왔습니다."
            case .locationFailed:
                "사용자의 현재 위치를 불러올 수 없습니다."
            }
        }
        
    }
    
}

private struct Response: Decodable {
    
    let meta: Meta
    let documents: [Document]
    
}

private struct Meta: Decodable {
    
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
    }
    
}

private struct Document: Decodable {
    
    let roadAddress: RoadAddress
    let address: Address
    
    enum CodingKeys: String, CodingKey {
        
        case roadAddress = "road_address"
        case address
        
    }
    
}

private struct RoadAddress: Decodable {
    
    let addressName: String
    let region1depthName: String
    let region2depthName: String
    let region3depthName: String
    let roadName: String
    let undergroundYn: String
    let mainBuildingNo: String
    let subBuildingNo: String
    let buildingName: String
    let zoneNo: String
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case region1depthName = "region_1depth_name"
        case region2depthName = "region_2depth_name"
        case region3depthName = "region_3depth_name"
        case roadName = "road_name"
        case undergroundYn = "underground_yn"
        case mainBuildingNo = "main_building_no"
        case subBuildingNo = "sub_building_no"
        case buildingName = "building_name"
        case zoneNo = "zone_no"
    }
    
}

private struct Address: Decodable {
    
    let addressName: String
    let region1depthName: String
    let region2depthName: String
    let region3depthName: String
    let mountainYn: String
    let mainAddressNo: String
    let subAddressNo: String
    
    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case region1depthName = "region_1depth_name"
        case region2depthName = "region_2depth_name"
        case region3depthName = "region_3depth_name"
        case mountainYn = "mountain_yn"
        case mainAddressNo = "main_address_no"
        case subAddressNo = "sub_address_no"
    }
    
}
