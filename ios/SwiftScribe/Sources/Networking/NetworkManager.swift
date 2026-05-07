import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
}

struct SummarizationRequest: Encodable {
    let text: String
    let max_length: Int
    let min_length: Int
}

struct SummarizationResponse: Decodable {
    let original_length: Int
    let summary_length: Int
    let summary: String
    let cached: Bool
    let processing_time_ms: Double
}

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "http://localhost:8000/api/v1"
    
    private init() {}
    
    func summarize(text: String) async throws -> SummarizationResponse {
        guard let url = URL(string: "\(baseURL)/summarize") else {
            throw NetworkError.invalidURL
        }
        
        let requestBody = SummarizationRequest(text: text, max_length: 130, min_length: 30)
        let jsonData = try JSONEncoder().encode(requestBody)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.serverError("Invalid response")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError("Status code: \(httpResponse.statusCode)")
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(SummarizationResponse.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.decodingError
        }
    }
}
