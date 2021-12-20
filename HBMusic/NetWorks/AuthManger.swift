//
//  AuthManger.swift
//  HBMusic
//
//  Created by 徐浩博 on 2021/11/17.
//

import Foundation

final class AuthManger {
    static let shared = AuthManger()
    
    struct Constants {
        static let clientID = _ClientID
        static let clientSecret = _ClientSecret
        static let tokenApiURL = "https://accounts.spotify.com/api/token"
        static let scope = "user-read-private%20playlist-modify-private%20playlist-read-private%20playlist-modify-public%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    private init() {}
    
    private var refreshingToken = false
    
    public var signInURL: URL? {
        let base = "https://accounts.spotify.com/authorize"
        let scope = Constants.scope
        let redirect_uri = _RedirectURI
        let str = "\(base)?response_type=code&client_id=\(Constants.clientID)&scope=\(scope)&redirect_uri=\(redirect_uri)&show_dialog=true"
        return URL(string: str)
    }
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpiresDate: Date? {
        return UserDefaults.standard.object(forKey: "expires_date") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expiresDate = tokenExpiresDate else {
            return false
        }
        let currentDate = Date()
        let fiveMin: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMin) >= expiresDate
    }
    
    public func exchangeToken(with code: String, completion: @escaping ((Bool) -> Void)) {
        guard let url = URL(string: Constants.tokenApiURL) else {
            return
        }
        
        var compoment = URLComponents()
        compoment.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: _RedirectURI),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let basicToken = "\(Constants.clientID):\(Constants.clientSecret)"
        let basicTokenData = basicToken.data(using: .utf8)
        guard let base64String = basicTokenData?.base64EncodedString() else {
            print("base64String falied")
            completion(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.httpBody = compoment.query?.data(using: .utf8)
        
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.cacheToken(response: authResponse)
                completion(true)
            } catch {
                completion(false)
            }
        }.resume()
        completion(true)
    }
    
    private func cacheToken(response: AuthResponse) {
        UserDefaults.standard.setValue(response.access_token, forKey: "access_token")
        if let rt = response.refresh_token {
            UserDefaults.standard.setValue(rt, forKey: "refresh_token")
        }
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(response.expires_in)), forKey: "expires_date")
    }
    
    private var onRefreshingBlocks: [((String) -> Void)] = []
    
    public func withValidToken(completion: @escaping ((String) -> Void)) {
        guard !refreshingToken else {
            // append completions
            onRefreshingBlocks.append(completion)
            return
        }
        if shouldRefreshToken {
            refreshIfNeeded { [weak self] success in
                if let token = self?.accessToken, success {
                    completion(token)
                }
            }
        } else if let token = accessToken {
            completion(token)
        }
    }
    
    public func refreshIfNeeded(completion: ((Bool) -> Void)?) {
        guard !refreshingToken else {
            return
        }
        guard shouldRefreshToken else {
            completion?(true)
            return
        }
        guard let refreshToken = self.refreshToken else {
            return
        }
        
        
        guard let url = URL(string: Constants.tokenApiURL) else {
            return
        }
        
        refreshingToken = true
        
        var compoment = URLComponents()
        compoment.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let basicToken = "\(Constants.clientID):\(Constants.clientSecret)"
        let basicTokenData = basicToken.data(using: .utf8)
        guard let base64String = basicTokenData?.base64EncodedString() else {
            print("base64String falied")
            completion?(false)
            return
        }
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.httpBody = compoment.query?.data(using: .utf8)
        
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            self?.refreshingToken = false
            guard let data = data, error == nil else {
                completion?(false)
                return
            }
            
            do {
                let authResponse = try JSONDecoder().decode(AuthResponse.self, from: data)
                self?.onRefreshingBlocks.forEach({ block in
                    block(authResponse.access_token)
                })
                self?.onRefreshingBlocks.removeAll()
                self?.cacheToken(response: authResponse)
                completion?(true)
            } catch {
                completion?(false)
            }
        }.resume()
        completion?(true)
    }
    
    public func signOut(completion: (Bool) -> Void) {
        UserDefaults.standard.setValue(nil, forKey: "access_token")
        UserDefaults.standard.setValue(nil, forKey: "refresh_token")
        UserDefaults.standard.setValue(nil, forKey: "expires_date")
        completion(true)
    }
}
