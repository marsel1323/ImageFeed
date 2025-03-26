//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 26.03.2025.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("Invalid URL: \(UnsplashAuthorizeURLString)")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: AccessKey),
            URLQueryItem(name: "client_secret", value: SecretKey),
            URLQueryItem(name: "redirect_uri", value: RedirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            assertionFailure("Unable to construct unsplashAuthorizeURL: \(urlComponents)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else { return }
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    guard let self else { return }
                    
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    
                    let response = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    
                    completion(.success(response.accessToken))
                } catch {
                    print("Failed to decode OAuth token response: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("Failed to fetch OAuth token: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
