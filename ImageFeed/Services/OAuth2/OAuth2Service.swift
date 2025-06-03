//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 26.03.2025.
//

import Foundation

final class OAuth2Service {
    static let shared = OAuth2Service()
    
    private var lastCode: String?
    private var task: URLSessionTask?
    
    private init() {}
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if lastCode == code {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, any Error>) in
            guard let self else { return }
            
            switch result {
            case .success(let responseBody):
                completion(.success(responseBody.accessToken))
            case .failure(let error):
                print("Ошибка при запросе: \(error.localizedDescription), url: \(request)")
                completion(.failure(error))
            }
            self.task = nil
            self.lastCode = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        let host: String = "unsplash.com"
        let path: String = "/oauth/token"
        let method: String = HTTPMethods.post
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]

        return URLRequest.makeRequest(host: host, path: path, method: method, queryItems: queryItems)
    }
}
