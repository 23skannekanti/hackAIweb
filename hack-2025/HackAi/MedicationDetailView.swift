import SwiftUI

struct MedicationDetailView: View {
    let medication: Medication
    @State private var summary: String = "Loading..."
    @State private var isLoading = true

    var body: some View {
        ZStack {
            // Full-screen gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text(medication.name) // Medication Name at the Top
                        .font(.largeTitle)
                        .bold()
                        .padding(.bottom, 10)

                    if isLoading {
                        ProgressView("Fetching summary...") // Loading Indicator
                            .padding()
                    } else {
                        Text(summary) // Show Summary
                            .font(.body)
                            .padding()
                            .background(Color.white.opacity(0.9)) // White background for readability
                            .cornerRadius(10)
                            .shadow(radius: 2)
                    }

                    Spacer()
                }
                .padding()
                .onAppear {
                    fetchMedicationSummary()
                }
            }
        }
        .navigationTitle("Medication Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Fetch Medication Summary from GPT API
    func fetchMedicationSummary() {
        let urlString = "http://127.0.0.1:5000/medication_summary"
        guard let url = URL(string: urlString) else { return }

        let requestBody: [String: Any] = [
            "medication": medication.name,
            "dosage": medication.dosage ?? "N/A",
            "frequency": medication.frequency ?? "N/A"
        ]

        let jsonData = try? JSONSerialization.data(withJSONObject: requestBody)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false
            }

            if let data = data {
                do {
                    let response = try JSONDecoder().decode(MedicationSummaryResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.summary = response.summary
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.summary = "❌ Failed to fetch summary."
                    }
                    print("❌ Error decoding summary: \(error)")
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self.summary = "❌ Network error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}

// Medication Summary Response Model
struct MedicationSummaryResponse: Codable {
    let medication: String
    let summary: String
}

// Preview
#Preview {
    MedicationDetailView(
        medication: Medication(name: "Ibuprofen", dosage: "200mg", frequency: "Twice a day")
    )
}
