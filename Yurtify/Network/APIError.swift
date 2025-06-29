//
//  APIError.swift
//  Yurtify
//
//  Created by dark type on 30.06.2025.
//

import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

// MARK: - API Error Types

enum APIError: Error, LocalizedError {
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .httpError(let statusCode):
            return "HTTP Error: \(statusCode)"
        case .decodingError(let error):
            return "Decoding Error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network Error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response format"
        }
    }
}

// MARK: - API Service

final class APIService : Sendable {
    private let client: Client
    private let jsonDecoder: JSONDecoder
    
    init(serverURL: URL = URL(string: "http://77.110.105.134:8080")!) {
        let transport = URLSessionTransport()
        self.client = Client(serverURL: serverURL, transport: transport)
        
        self.jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Helper Methods
    
    private func decodeResponse<T: Codable>(_ httpBody: HTTPBody, to type: T.Type) async throws -> T {
        do {
            let data = try await Data(collecting: httpBody, upTo: .max)
            return try jsonDecoder.decode(type, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    private func handleAPIError(statusCode: Int) -> APIError {
        return .httpError(statusCode: statusCode)
    }
}

// MARK: - Authentication

extension APIService {
    func login(request: Components.Schemas.LoginRequestDTO) async throws -> Components.Schemas.TokenResponseDTO {
        let input = Operations.login.Input(body: .json(request))
        
        do {
            let output = try await client.login(input)
            
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.TokenResponseDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func register(request: Components.Schemas.RegisterRequestDTO) async throws -> Components.Schemas.TokenResponseDTO {
        let input = Operations.register.Input(body: .json(request))
        
        do {
            let output = try await client.register(input)
            
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.TokenResponseDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func refresh(request: Components.Schemas.RefreshRequestDTO) async throws -> Components.Schemas.TokenResponseDTO {
        let input = Operations.refresh.Input(body: .json(request))
         
        do {
            let output = try await client.refresh(input)
             
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.TokenResponseDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func logout() async throws {
        let input = Operations.logout.Input()
        
        do {
            let output = try await client.logout(input)
            
            switch output {
            case .ok:
                return
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - User Profile

extension APIService {
    func getUserProfile() async throws -> Components.Schemas.UserDTO {
        let input = Operations.getUserProfile.Input()
        
        do {
            let output = try await client.getUserProfile(input)
            
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.UserDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func editUserProfile(request: Components.Schemas.UserProfileUpdateDTO) async throws -> Components.Schemas.UserDTO {
        let input = Operations.editUserProfile.Input(body: .json(request))
        
        do {
            let output = try await client.editUserProfile(input)
            
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.UserDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func changePassword(request: Components.Schemas.ChangePasswordDTO) async throws {
        let input = Operations.changePassword.Input(body: .json(request))
        
        do {
            let output = try await client.changePassword(input)
            
            switch output {
            case .ok:
                return
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func getUserPublicInfo(userId: String) async throws -> Components.Schemas.UserDTO {
        let input = Operations.getUserPublicInfo.Input(path: .init(id: userId))
        
        do {
            let output = try await client.getUserPublicInfo(input)
            
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.UserDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Housing

extension APIService {
    func getAllHousings(
        page: Int32? = nil,
        size: Int32? = nil,
        title: String? = nil,
        address: String? = nil,
        type: Operations.getAllHousings.Input.Query._typePayload? = nil
    ) async throws -> Components.Schemas.PageDTOHousingResponseDTO {
        let input = Operations.getAllHousings.Input(
            query: .init(
                page: page,
                size: size,
                title: title,
                address: address,
                _type: type
            )
        )
        
        do {
            let output = try await client.getAllHousings(input)
            
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.PageDTOHousingResponseDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func getHousingById(housingId: String) async throws -> Components.Schemas.HousingResponseDTO {
        let input = Operations.getHousingById.Input(path: .init(id: housingId))
        
        do {
            let output = try await client.getHousingById(input)
            
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.HousingResponseDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func createHousing(request: Components.Schemas.HousingCreateDTO) async throws -> Components.Schemas.HousingResponseDTO {
        let input = Operations.createHousing.Input(body: .json(request))
        
        do {
            let output = try await client.createHousing(input)
            
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.HousingResponseDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func getReservedDates(housingId: String) async throws -> [Components.Schemas.DateRangeDTO] {
        let input = Operations.getReservedDates.Input(path: .init(id: housingId))
           
        do {
            let output = try await client.getReservedDates(input)
               
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: [Components.Schemas.DateRangeDTO].self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    func getHousingsByOwnerId(
        ownerId: String,
        page: Int32? = nil,
        size: Int32? = nil
    ) async throws -> Components.Schemas.PageDTOHousingResponseDTO {
        let input = Operations.getHousingsByOwnerId.Input(
            path: .init(ownerId: ownerId),
            query: .init(page: page, size: size)
        )
           
        do {
            let output = try await client.getHousingsByOwnerId(input)
               
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.PageDTOHousingResponseDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Reservations

extension APIService {
    func createReservation(request: Components.Schemas.ReservationCreateDTO) async throws -> Components.Schemas.ReservationResponseDTO {
        let input = Operations.createReservation.Input(body: .json(request))
        
        do {
            let output = try await client.createReservation(input)
            
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.ReservationResponseDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func getUserReservations() async throws -> [Components.Schemas.ReservationResponseDTO] {
        let input = Operations.getUserReservations.Input()
          
        do {
            let output = try await client.getUserReservations(input)
              
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: [Components.Schemas.ReservationResponseDTO].self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func getOwnerReservations() async throws -> [Components.Schemas.ReservationResponseDTO] {
        let input = Operations.getOwnerReservations.Input()
            
        do {
            let output = try await client.getOwnerReservations(input)
                
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: [Components.Schemas.ReservationResponseDTO].self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    func updateReservationStatus(
        reservationId: String,
        request: Components.Schemas.ReservationStatusUpdateDTO
    ) async throws -> Components.Schemas.ReservationResponseDTO {
        let input = Operations.updateReservationStatus.Input(
            path: .init(id: reservationId),
            body: .json(request)
        )
        
        do {
            let output = try await client.updateReservationStatus(input)
            
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.ReservationResponseDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Favorites

extension APIService {
    func getUserFavorites(
        page: Int32? = nil,
        size: Int32? = nil
    ) async throws -> Components.Schemas.PageDTOHousingResponseDTO {
        let input = Operations.getUserFavorites.Input(
            query: .init(page: page, size: size)
        )
        
        do {
            let output = try await client.getUserFavorites(input)
            
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.PageDTOHousingResponseDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func addFavorite(housingId: String) async throws {
        let input = Operations.addFavorite.Input(path: .init(housingId: housingId))
        
        do {
            let output = try await client.addFavorite(input)
            
            switch output {
            case .ok:
                return
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func removeFavorite(housingId: String) async throws {
        let input = Operations.removeFavorite.Input(path: .init(housingId: housingId))
        
        do {
            let output = try await client.removeFavorite(input)
            
            switch output {
            case .ok:
                return
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Images

extension APIService {
//    func uploadImage(
//        imageData: Data,
//        filename: String
//    ) async throws -> Components.Schemas.ImageUploadResponseDTO {
//        let input = Operations.uploadImage.Input()
//        
//        do {
//            let output = try await client.uploadImage(input)
//            
//            switch output {
//            case .ok(let response):
//                return try await decodeResponse(response.body.any, to: Components.Schemas.ImageUploadResponseDTO.self)
//            case .undocumented(let statusCode, _):
//                throw handleAPIError(statusCode: statusCode)
//            }
//        } catch let error as APIError {
//            throw error
//        } catch {
//            throw APIError.networkError(error)
//        }
//    }
    func uploadImage(
        imageData: Data,
        filename: String
    ) async throws -> Components.Schemas.ImageUploadResponseDTO {
        let url = URL(string: "http://77.110.105.134:8080/images/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
            
            return try jsonDecoder.decode(Components.Schemas.ImageUploadResponseDTO.self, from: data)
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func getImage(imageId: String) async throws -> Data {
        let input = Operations.getImage.Input(path: .init(id: imageId))
        
        do {
            let output = try await client.getImage(input)
            
            switch output {
            case .ok(let response):
                return try await Data(collecting: response.body.any, upTo: .max)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}

// MARK: - Visit History

extension APIService {
    func addVisit(housingId: String) async throws {
        let input = Operations.addVisit.Input(body: .json(housingId))
        
        do {
            let output = try await client.addVisit(input)
            
            switch output {
            case .ok:
                return
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    func getVisitHistory(
        page: Int32? = nil,
        size: Int32? = nil
    ) async throws -> Components.Schemas.PageDTOHousingResponseDTO {
        let input = Operations.getVisitHistory.Input(
            query: .init(page: page, size: size)
        )
        
        do {
            let output = try await client.getVisitHistory(input)
            
            switch output {
            case .ok(let response):
                return try await decodeResponse(response.body.any, to: Components.Schemas.PageDTOHousingResponseDTO.self)
            case .undocumented(let statusCode, _):
                throw handleAPIError(statusCode: statusCode)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
