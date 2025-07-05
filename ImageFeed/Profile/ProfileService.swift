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
    
    private init() {}
    
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
    
    private func makeURLRequest(_ token: String) -> URLRequest? {
        let host: String = "api.unsplash.com"
        let path: String = "/me"
        let headers: [String: String]? = ["Authorization": "Bearer \(token)"]
        
        return URLRequest.makeRequest(
            host: host,
            path: path,
            method: HTTPMethods.get,
            headers: headers
        )
    }
    
    func resetProfile() {
        profile = nil
    }
}
