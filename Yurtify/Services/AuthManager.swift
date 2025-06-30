//
//  UserState.swift
//  Yurtify
//
//  Created by dark type on 14.06.2025.
//
import Combine
import Foundation

@MainActor
final class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var isInitializing = true
    
    private let userDefaultsService = UserDefaultsService()
    private let keychainService = KeychainService()
    private let apiService: APIService
    private let tokenManager: TokenManager
    
    private var cancellables = Set<AnyCancellable>()
    private var tokenValidationTask: Task<Void, Never>?
    
    init(apiService: APIService) {
        self.apiService = apiService
        self.tokenManager = TokenManager(keychainService: keychainService, apiService: apiService)
        
        Task {
            await initializeAuth()
        }
    }
    
    
    // MARK: - Initial Setup
    
    private func initializeAuth() async {
        let shouldBeAuthenticated = userDefaultsService.shouldBeAuthenticated
        let userData = keychainService.getUserData()
        
        await MainActor.run {
            if shouldBeAuthenticated, let userData = userData {
                currentUser = userData
                isAuthenticated = true
                
                Task {
                    await validateInitialTokens(for: userData)
                }
            } else {
                if shouldBeAuthenticated {
                    userDefaultsService.setShouldBeAuthenticated(false)
                }
                isAuthenticated = false
            }
            
            isInitializing = false
            startTokenMonitoring()
        }
    }
    
    // MARK: - Authentication Actions
    
    func login(phoneNumber: String, password: String) async throws {
        guard !isLoading else {
            throw AuthError.loginInProgress
        }
        
        tokenValidationTask?.cancel()
        tokenValidationTask = nil
        
        isLoading = true
        
        do {
            let (accessToken, refreshToken) = try await apiService.login(
                phoneNumber: phoneNumber,
                password: password
            )
            
            let user = User(
                id: UUID().uuidString, // Temporary ID
                name: "User", // Default name
                surname: "",
                patronymic: nil,
                phoneNumber: phoneNumber,
                email: "", // Default - fetch from profile if needed
                accessToken: accessToken,
                refreshToken: refreshToken,
                accessTokenExpiresAt: Date().addingTimeInterval(15 * 60),
                refreshTokenExpiresAt: Date().addingTimeInterval(24 * 60 * 60),
                password: password
            )
            
            try keychainService.storeUser(user)
            userDefaultsService.setShouldBeAuthenticated(true)
            
            await MainActor.run {
                currentUser = user
                isAuthenticated = true
                isLoading = false
                objectWillChange.send()
            }
            
        } catch {
            await MainActor.run {
                isLoading = false
            }
            throw error
        }
    }
    
    func register(data: RegistrationData) async throws {
        isLoading = true
        
        do {
            let (accessToken, refreshToken) = try await apiService.register(data: data)
            
            
            let user = User(
                id: UUID().uuidString, // Generate a temporary ID
                name: data.name,
                surname: data.surname,
                patronymic: data.patronymic,
                phoneNumber: data.phoneNumber,
                email: data.email,
                accessToken: accessToken,
                refreshToken: refreshToken,
                accessTokenExpiresAt: Date().addingTimeInterval(15 * 60), // 15 minutes default
                refreshTokenExpiresAt: Date().addingTimeInterval(24 * 60 * 60), // 24 hours default
                password: data.password
            )
            
            try keychainService.storeUser(user)
            userDefaultsService.setShouldBeAuthenticated(true)
            
            await MainActor.run {
                currentUser = user
                isAuthenticated = true
                isLoading = false
            }
            
        } catch {
            await MainActor.run {
                isLoading = false
            }
            throw error
        }
    }
    
    func logout() {
        print("🔄 Starting logout process")
           
        tokenValidationTask?.cancel()
        tokenValidationTask = nil
           
        cancellables.removeAll()
           
        keychainService.clearUserData()
        userDefaultsService.setShouldBeAuthenticated(false)
           
        currentUser = nil
        isAuthenticated = false
        isLoading = false
           
        Task {
            try? await Task.sleep(nanoseconds: 100_000_000)
            await MainActor.run {
                startTokenMonitoring()
            }
        }
    }
    
    // MARK: - Token Management
    
    private func validateInitialTokens(for userData: User) async {
        do {
            let updatedUser = try await tokenManager.validateTokens(for: userData)
            await MainActor.run {
                if updatedUser != userData {
                    currentUser = updatedUser
                }
            }
        } catch {
            await MainActor.run {
                logout()
            }
        }
    }
    
    private func startTokenMonitoring() {
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task {
                    await self?.validateCurrentTokens()
                }
            }
            .store(in: &cancellables)
    }
    
    private func validateCurrentTokens() async {
        guard let user = currentUser, isAuthenticated else { return }
           
        tokenValidationTask = Task {
            do {
                let updatedUser = try await tokenManager.validateTokens(for: user)
                   
                if Task.isCancelled { return }
                   
                await MainActor.run {
                    if isAuthenticated && currentUser?.id == user.id && updatedUser != user {
                        currentUser = updatedUser
                    }
                }
            } catch {
                if Task.isCancelled { return }
                   
                await MainActor.run {
                    if isAuthenticated && currentUser?.id == user.id {
                        logout()
                    }
                }
            }
        }
           
        await tokenValidationTask?.value
    }
}

extension AuthManager {
    // MARK: - Guest Mode
    
    func continueAsGuest() {
        keychainService.clearUserData()
        userDefaultsService.setShouldBeAuthenticated(false)
        
        currentUser = nil
        isAuthenticated = false
        isLoading = false
    }
}
