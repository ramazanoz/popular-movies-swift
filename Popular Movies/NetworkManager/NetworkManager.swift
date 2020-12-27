//
//  APIManager.swift
//  Popular Movies
//
//  Created by Ramazan Öz on 27.12.2020.
//

import Foundation

public enum PMResponse<U: Decodable> {
    case success(U)
    case failure(Error)
}

protocol Request {
    var path: String { get }
    var additionalParams: [String : String]? { get }
}

public enum NetworkManagerError: Error {
    case unexpectedError
    case unexpectedResponseError
    case jsonDecodingError
    case connectionError
    case responseParseError
}

class NetworkManager: NSObject {
    static let sharedInstance = NetworkManager()
    private let APIBaseUrl = "https://api.themoviedb.org/3/movie/"
    private let APIKey = "fd2b04342048fa2d5f728561866ad52a"
    private let language = "en-US"
    private let session: URLSession

    private var pageId = 1
    
    public override init() {
        self.session = URLSession(configuration: .default,
                                  delegate: nil,
                                  delegateQueue: OperationQueue.main)
    }
}

extension NetworkManager {
    func pushRequest<T: Request, U: Decodable>(_ request: T, completion: @escaping (PMResponse<U>?) -> Void) {
        var queryParams = [
            "language" : self.language,
            "api_key" : self.APIKey
        ]
        
        if let additionalParams = request.additionalParams {
            for (key,value) in additionalParams {
                queryParams.updateValue(value, forKey:key)
            }
        }
        
        let urlString = APIBaseUrl + request.path + "?" + buildQueryStringWith(params: queryParams)
        guard let url = URL(string: urlString) else {
            completion(PMResponse.failure(NetworkManagerError.unexpectedError))
            print("Error: Cannot create URL from string")
            return
        }
        
        let request = URLRequest(url: url)
        let task = session.dataTask(with: request) { (data, response, error) in
            switch (data, response, error) {
            case (_, _, let error?):
                if let err = error as NSError? {
                    if err.code == NSURLErrorNotConnectedToInternet {
                        completion(PMResponse.failure(NetworkManagerError.connectionError))
                    }
                }

                completion(PMResponse.failure(NetworkManagerError.connectionError))
            case (let data?, let response?, _):
                if case (200..<300)? = (response as? HTTPURLResponse)?.statusCode {
                    print(String(describing: U.self))
                    if let responseLogString = String(data: data, encoding: .utf8) {
                        print("Response:\n \(responseLogString)")
                    }
                    
                    do {
                        let decoder = JSONDecoder()
                        let decodedResponse = try decoder.decode(U.self, from: data)
                        
                        completion(PMResponse.success(decodedResponse))
                    } catch let error {
                        print("Error creating response from JSON: \(error.localizedDescription)")
                        completion(PMResponse.failure(NetworkManagerError.responseParseError))
                    }
                } else {
                    completion(PMResponse.failure(NetworkManagerError.responseParseError))
                }
            default:
                fatalError("invalid response combination \(data.debugDescription), \(response.debugDescription), \(error.debugDescription).")
            }
        }
        task.resume()
    }
    
    private func buildQueryStringWith(params: [String: String]) -> String {
        var keyValPairs = [String]()
        for (key, val) in params {
            if let val = val.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                keyValPairs.append(key + "=" + val)
            }
        }
        return keyValPairs.joined(separator: "&")
    }
}
