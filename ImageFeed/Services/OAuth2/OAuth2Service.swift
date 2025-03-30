//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 26.03.2025.
//

import Foundation

enum HTTPMethods {
    static let post = "POST"
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private init() {}
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            return
        }
        print("Request: \(request)")
        
        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {                    
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
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: Constants.unsplashOauthTokenURLString) else {
            assertionFailure("Invalid URL: \(Constants.unsplashAuthorizeURLString)")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            assertionFailure("Unable to construct unsplashAuthorizeURL: \(urlComponents)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethods.post
        
        return request
    }
}
