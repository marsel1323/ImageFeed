//
//  ProfileService.swift
//  ImageFeed
//
//  Created by mnabdrakhmanov on 28.05.2025.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    
    private(set) var profile: Profile?
    private var task: URLSessionTask?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            task?.cancel()
            return
        }
        
        guard let request = makeURLRequest(token) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<ProfileResult, any Error>) in
            guard let self else { return }
            switch result {
            case .success(let responseBody):
                let profile = Profile(from: responseBody)
                self.profile = profile
                completion(.success(profile))
            case .failure(let error):
                print("Ошибка при запросе: \(error.localizedDescription), url: \(request)")
                completion(.failure(error))
            }
            self.task = nil
        }
        
        self.task = task
        task.resume()
    }
    
    private func makeURLRequest(_ username: String) -> URLRequest? {
        guard let token = OAuth2TokenStorage.shared.token else {
            assertionFailure("oauth token is required")
            return nil
        }
        
        let method: String = HTTPMethods.get
        let scheme: String = "https"
        let host: String = "api.unsplash.com"
        let path: String = "/me"
        let queryItems: [URLQueryItem]? = nil
        let headers: [String: String]? = ["Authorization": "Bearer \(token)"]
        let body: Data? = nil
        
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            assertionFailure("Unable to construct URLRequest for \(host)\(path)")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}
