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
    case userAlreadyExists
    var errorDescription: String? {
        switch self {
        case .httpError(let statusCode):
            return "HTTP Error: \(statusCode)"
        case .decodingError(let error):
            return "Decoding Error: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network Error: \(error.localizedDescription)"
        case .userAlreadyExists:
            return "User already exists"
        case .invalidResponse:
            return "Invalid response format"
        }
    }
}

// MARK: - API Service

final class APIService: Sendable, ObservableObject {
    private let client: Client
    private let jsonDecoder: JSONDecoder
    private let baseURL: String
    init(serverURL: URL = URL(string: "http://77.110.105.134:8080")!) {
        let transport = URLSessionTransport()
        self.client = Client(serverURL: serverURL, transport: transport)
        self.baseURL = serverURL.absoluteString
          
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

    // MARK: - Token Management
        
    private func getAccessToken() -> String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
        
    private func getRefreshToken() -> String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
        
    private func saveTokens(accessToken: String, refreshToken: String) {
        UserDefaults.standard.set(accessToken, forKey: "access_token")
        UserDefaults.standard.set(refreshToken, forKey: "refresh_token")
    }
        
    private func clearTokens() {
        UserDefaults.standard.removeObject(forKey: "access_token")
        UserDefaults.standard.removeObject(forKey: "refresh_token")
    }
        
    private func createAuthenticatedRequest(url: URL, method: String = "GET") -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
        if let accessToken = getAccessToken() {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }
            
        return request
    }

    private func formatPhoneNumber(_ phoneNumber: String) -> String {
        let digits = phoneNumber.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        
        if digits.count == 10 {
            let areaCode = String(digits.prefix(3))
            let number = String(digits.suffix(7))
            return "+(\(areaCode)).\(number)"
        } else if digits.count == 11 && digits.hasPrefix("1") {
            let areaCode = String(digits.dropFirst().prefix(3))
            let number = String(digits.dropFirst(4))
            return "+(\(areaCode)).\(number)"
        } else {
            if digits.count >= 7 {
                let areaCode = String(digits.prefix(3))
                let number = String(digits.dropFirst(3))
                return "+(\(areaCode)).\(number)"
            }
        }
        
        
        return "+(\(digits.prefix(3))).\(digits.dropFirst(3))"
    }
}

// MARK: - Authentication

extension APIService {
    func login(phoneNumber: String, password: String) async throws -> (accessToken: String, refreshToken: String) {
        let url = URL(string: "\(baseURL)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        
        let formattedPhone = formatPhoneNumber(phoneNumber)
        
        
        let loginRequest = [
            "phone": formattedPhone,
            "password": password
        ]
        
        print("🌐 Login API Call Debug:")
        print("   URL: \(url)")
        print("   Request body: \(loginRequest)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: loginRequest)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Server Response:")
                print("   Status Code: \(httpResponse.statusCode)")
                
                let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                print("   Response Body: \(responseString)")
                
                switch httpResponse.statusCode {
                case 200...299:
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let accessToken = json["accessToken"] as? String,
                       let refreshToken = json["refreshToken"] as? String
                    {
                        saveTokens(accessToken: accessToken, refreshToken: refreshToken)
                        return (accessToken: accessToken, refreshToken: refreshToken)
                    } else {
                        throw AuthError.loginFailed
                    }
                case 401:
                    print("❌ 401 Unauthorized - Invalid credentials")
                    throw AuthError.invalidCredentials
                case 400:
                    print("❌ 400 Bad Request - Invalid data format")
                    throw AuthError.invalidData
                default:
                    print("❌ Unexpected status code: \(httpResponse.statusCode)")
                    throw AuthError.loginFailed
                }
            }
            
            throw APIError.networkError(NSError(domain: "Unknown response", code: -1))
            
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ Network/JSON Error: \(error)")
            throw APIError.networkError(error)
        }
    }
    
    func register(data: RegistrationData) async throws -> (accessToken: String, refreshToken: String) {
        let url = URL(string: "\(baseURL)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
       
        let formattedPhone = formatPhoneNumber(data.phoneNumber)
        
        
        let registerRequest: [String: Any] = [
            "email": data.email,
            "password": data.password,
            "fullName": [
                "name": data.name,
                "surname": data.surname,
                "patronymic": data.patronymic ?? ""
            ],
            "phone": formattedPhone
        ]
        
        print("🌐 Registration API Call Debug:")
        print("   URL: \(url)")
        print("   Request body: \(registerRequest)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: registerRequest)
            
            let (responseData, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Server Response:")
                print("   Status Code: \(httpResponse.statusCode)")
                
                let responseString = String(data: responseData, encoding: .utf8) ?? "No response body"
                print("   Response Body: \(responseString)")
                
                switch httpResponse.statusCode {
                case 200...299:
                    if let json = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                       let accessToken = json["accessToken"] as? String,
                       let refreshToken = json["refreshToken"] as? String
                    {
                        saveTokens(accessToken: accessToken, refreshToken: refreshToken)
                        return (accessToken: accessToken, refreshToken: refreshToken)
                    } else {
                        throw AuthError.registrationFailed
                    }
                case 400:
                    print("❌ 400 Bad Request - Server says data is invalid")
                    throw AuthError.invalidData
                case 409:
                    print("❌ 409 Conflict - User already exists")
                    throw AuthError.registrationFailed
                default:
                    print("❌ Unexpected status code: \(httpResponse.statusCode)")
                    throw AuthError.registrationFailed
                }
            }
            
            throw APIError.networkError(NSError(domain: "Unknown response", code: -1))
            
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ Network/JSON Error: \(error)")
            throw APIError.networkError(error)
        }
    }
    
    func refreshTokens(refreshToken: String) async throws -> String {
        let url = URL(string: "\(baseURL)/auth/refresh")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
         
        
        let refreshRequest = ["refreshToken": refreshToken]
        request.httpBody = try JSONSerialization.data(withJSONObject: refreshRequest)
         
        let (data, response) = try await URLSession.shared.data(for: request)
         
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 Refresh Token Response:")
            print("   Status Code: \(httpResponse.statusCode)")
            let responseString = String(data: data, encoding: .utf8) ?? "No response body"
            print("   Response Body: \(responseString)")
             
            switch httpResponse.statusCode {
            case 200...299:
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let accessToken = json["accessToken"] as? String
                {
                    UserDefaults.standard.set(accessToken, forKey: "access_token")
                    return accessToken
                } else {
                    throw AuthError.tokenRefreshFailed
                }
            case 401:
                clearTokens()
                throw AuthError.refreshTokenExpired
            default:
                throw AuthError.tokenRefreshFailed
            }
        }
         
        throw APIError.networkError(NSError(domain: "Unknown response", code: -1))
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
        let url = URL(string: "\(baseURL)/housing/create")!
        var urlRequest = createAuthenticatedRequest(url: url, method: "POST")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                return try jsonDecoder.decode(Components.Schemas.HousingResponseDTO.self, from: data)
            case 401:
                if let refreshToken = getRefreshToken() {
                    _ = try await refreshTokens(refreshToken: refreshToken)
                    return try await createHousing(request: request)
                } else {
                    throw AuthError.tokenRefreshFailed
                }
            default:
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
        }
        
        throw APIError.networkError(NSError(domain: "Unknown response", code: -1))
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
        let url = URL(string: "\(baseURL)/reservations/create")!
        var urlRequest = createAuthenticatedRequest(url: url, method: "POST")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                return try jsonDecoder.decode(Components.Schemas.ReservationResponseDTO.self, from: data)
            case 401:
                if let refreshToken = getRefreshToken() {
                    _ = try await refreshTokens(refreshToken: refreshToken)
                    return try await createReservation(request: request)
                } else {
                    throw AuthError.tokenRefreshFailed
                }
            default:
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
        }

        throw APIError.networkError(NSError(domain: "Unknown response", code: -1))
    }

//    func getUserReservations() async throws -> [Components.Schemas.ReservationResponseDTO] {
//        var headers = Operations.getUserReservations.Input.Headers()
//            if let token = getAccessToken() {
//                headers._customHeaders = ["Authorization": "Bearer \(token)"]
//            }
//            let input = Operations.getUserReservations.Input(headers: headers)
//
//        do {
//            let output = try await client.getUserReservations(input)
//
//            switch output {
//            case .ok(let response):
//                return try await decodeResponse(response.body.any, to: [Components.Schemas.ReservationResponseDTO].self)
//            case .undocumented(let statusCode, _):
//                throw handleAPIError(statusCode: statusCode)
//            }
//        } catch let error as APIError {
//            throw error
//        } catch {
//            throw APIError.networkError(error)
//        }
//    }
//
//    func getOwnerReservations() async throws -> [Components.Schemas.ReservationResponseDTO] {
//        var headers = Operations.getUserReservations.Input.Headers()
//            if let token = getAccessToken() {
//                headers._customHeaders = ["Authorization": "Bearer \(token)"]
//            }
//        let input = Operations.getOwnerReservation.Input(headers: headers)
//
//        do {
//            let output = try await client.getOwnerReservations(input)
//
//            switch output {
//            case .ok(let response):
//                return try await decodeResponse(response.body.any, to: [Components.Schemas.ReservationResponseDTO].self)
//            case .undocumented(let statusCode, _):
//                throw handleAPIError(statusCode: statusCode)
//            }
//        } catch let error as APIError {
//            throw error
//        } catch {
//            throw APIError.networkError(error)
//        }
//    }
//
//    func updateReservationStatus(
//        reservationId: String,
//        request: Components.Schemas.ReservationStatusUpdateDTO
//    ) async throws -> Components.Schemas.ReservationResponseDTO {
//        if let token = getAccessToken() {
//            headers._customHeaders = ["Authorization": "Bearer \(token)"]
//        }
//        let input = Operations.updateReservationStatus.Input(
//            path: .init(id: reservationId),
//            body: .json(request),
//            headers : headers
//        )
//
//        do {
//            let output = try await client.updateReservationStatus(input)
//
//            switch output {
//            case .ok(let response):
//                return try await decodeResponse(response.body.any, to: Components.Schemas.ReservationResponseDTO.self)
//            case .undocumented(let statusCode, _):
//                throw handleAPIError(statusCode: statusCode)
//            }
//        } catch let error as APIError {
//            throw error
//        } catch {
//            throw APIError.networkError(error)
//        }
//    }
}

// MARK: - Favorites

extension APIService {
    func getUserFavorites(
        page: Int32? = nil,
        size: Int32? = nil
    ) async throws -> Components.Schemas.PageDTOHousingResponseDTO {
        let url = URL(string: "\(baseURL)/favorites")!
        var request = createAuthenticatedRequest(url: url, method: "GET")
        
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = []
        
        if let page = page {
            queryItems.append(URLQueryItem(name: "page", value: String(page)))
        }
        
        if let size = size {
            queryItems.append(URLQueryItem(name: "size", value: String(size)))
        }
        
        if !queryItems.isEmpty {
            urlComponents.queryItems = queryItems
            request = createAuthenticatedRequest(url: urlComponents.url!, method: "GET")
        }
        
        print("🔖 Getting user favorites - Page: \(page ?? 0), Size: \(size ?? 20)")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("📡 Favorites Response:")
                print("   Status Code: \(httpResponse.statusCode)")
                
                let responseString = String(data: data, encoding: .utf8) ?? "No response body"
                print("   Response Body: \(responseString)")
                
                switch httpResponse.statusCode {
                case 200...299:
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        let content = json["content"] as? [[String: Any]] ?? []
                        let totalPages = json["totalPages"] as? Int32 ?? 0
                        let currentPage = json["currentPage"] as? Int32 ?? 0
                        let pageSize = json["pageSize"] as? Int32 ?? 20
                        let totalItems = json["totalItems"] as? Int64 ?? 0
                        
                        let contentData = try JSONSerialization.data(withJSONObject: content)
                        let housingDTOs = try jsonDecoder.decode([Components.Schemas.HousingResponseDTO].self, from: contentData)
                        
                        let pageResponse = Components.Schemas.PageDTOHousingResponseDTO(
                            content: housingDTOs,
                            currentPage: currentPage,
                            pageSize: pageSize,
                            totalItems: totalItems,
                            totalPages: totalPages
                        )
                        
                        print("✅ Loaded \(housingDTOs.count) favorite properties")
                        return pageResponse
                    } else {
                        throw APIError.decodingError(DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "Invalid JSON response")))
                    }
                    
                case 401:
                    if let refreshToken = getRefreshToken() {
                        _ = try await refreshTokens(refreshToken: refreshToken)
                        return try await getUserFavorites(page: page, size: size)
                    } else {
                        throw AuthError.tokenRefreshFailed
                    }
                    
                default:
                    print("❌ Unexpected status code: \(httpResponse.statusCode)")
                    throw APIError.httpError(statusCode: httpResponse.statusCode)
                }
            }
            
            throw APIError.networkError(NSError(domain: "Unknown response", code: -1))
            
        } catch let error as APIError {
            throw error
        } catch let error as AuthError {
            throw error
        } catch {
            print("❌ Network/JSON Error: \(error)")
            throw APIError.networkError(error)
        }
    }

    func addFavorite(housingId: String) async throws {
        let url = URL(string: "\(baseURL)/favorites/\(housingId)")!
        let request = createAuthenticatedRequest(url: url, method: "POST")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                return
            case 401:
                if let refreshToken = getRefreshToken() {
                    _ = try await refreshTokens(refreshToken: refreshToken)
                    return try await addFavorite(housingId: housingId)
                } else {
                    throw AuthError.tokenRefreshFailed
                }
            default:
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
        }
        
        throw APIError.networkError(NSError(domain: "Unknown response", code: -1))
    }
    
    func removeFavorite(housingId: String) async throws {
        let url = URL(string: "\(baseURL)/favorites/\(housingId)")!
        let request = createAuthenticatedRequest(url: url, method: "DELETE")
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                return
            case 401:
                if let refreshToken = getRefreshToken() {
                    _ = try await refreshTokens(refreshToken: refreshToken)
                    return try await removeFavorite(housingId: housingId)
                } else {
                    throw AuthError.tokenRefreshFailed
                }
            default:
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
        }
        
        throw APIError.networkError(NSError(domain: "Unknown response", code: -1))
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
        let url = URL(string: "\(baseURL)/visit/post")!
        var request = createAuthenticatedRequest(url: url, method: "POST")
        
        let visitRequest = [housingId]
        request.httpBody = try JSONSerialization.data(withJSONObject: visitRequest)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 200...299:
                return
            case 401:
                if let refreshToken = getRefreshToken() {
                    _ = try await refreshTokens(refreshToken: refreshToken)
                    return try await addVisit(housingId: housingId)
                } else {
                    throw AuthError.tokenRefreshFailed
                }
            default:
                throw APIError.httpError(statusCode: httpResponse.statusCode)
            }
        }
        
        throw APIError.networkError(NSError(domain: "Unknown response", code: -1))
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
