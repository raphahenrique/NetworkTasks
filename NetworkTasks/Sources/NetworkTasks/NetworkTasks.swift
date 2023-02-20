import Foundation

public enum Result<T> {
    case success(T)
    case failure(Error)
}

public enum NetworkError: Error {
    case invalidURL
    case emptyData
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public protocol NetworkRequest {
    associatedtype ResponseType: Decodable
    var endpoint: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
}

public class NetworkTasks {
    
    public typealias CompletionHandler<T: Decodable> = (Result<T>) -> Void
    
    public static let shared = NetworkTasks()
    
    private let session = URLSession.shared
    
    public func send<T: Decodable>(_ request: any NetworkRequest, completion: @escaping CompletionHandler<T>) {
        guard let url = URL(string: request.endpoint) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        if let parameters = request.parameters {
            if request.method == .get {
                let queryItems = parameters.map {
                    URLQueryItem(name: $0.key, value: "\($0.value)")
                }
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
                urlComponents?.queryItems = queryItems
                urlRequest.url = urlComponents?.url
            } else {
                let data = try? JSONSerialization.data(withJSONObject: parameters, options: [])
                urlRequest.httpBody = data
            }
        }

        if let headers = request.headers {
            headers.forEach { key, value in
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }

        session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NetworkError.emptyData))
                return
            }

            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

