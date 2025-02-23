import Foundation

class ChatGPTService {
    private let openAiApiKey = "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" // 🔹 Replace with a valid OpenAI API key
    private let apiUrl = "https://api.openai.com/v1/chat/completions"

    // MARK: - Send message to ChatGPT API
    func sendMessage(prompt: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: apiUrl) else {
            completion("Invalid API URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(openAiApiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 100
        ]

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            completion("Failed to encode request")
            return
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion("Request failed: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion("No data received")
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    DispatchQueue.main.async {
                        completion(content)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion("Invalid response from AI")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion("Failed to decode response")
                }
            }
        }

        task.resume()
    }
}
