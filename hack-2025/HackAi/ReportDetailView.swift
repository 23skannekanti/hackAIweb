import SwiftUI

struct ReportDetailView: View {
    let patientID: String
    let testType: String

    @State private var report: ReportDetail?
    @State private var errorMessage: String?
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

            VStack {
                Text("Report Details")
                    .font(.largeTitle)
                    .bold()
                    .padding(.bottom, 10)

                if isLoading {
                    ProgressView("Loading report details...")
                        .padding()
                } else if let error = errorMessage {
                    Text(" \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else if let report = report {
                    ScrollView {
                        VStack(spacing: 15) { // Adds spacing between report boxes
                            let sortedMetrics = report.metrics.sorted {
                                ($0.value.rangeStatus.contains("Abnormal") ? 0 : 1) < ($1.value.rangeStatus.contains("Abnormal") ? 0 : 1)
                            }
                            
                            ForEach(sortedMetrics, id: \.key) { key, metric in
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(key.uppercased())
                                        .font(.headline)
                                        .foregroundColor(.gray)

                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("**Value:** \(metric.value)")
                                        
                                        Text("**Status:** \(metric.rangeStatus)")
                                            .foregroundColor(metric.rangeStatus.contains("Abnormal") ? .red : .green)
                                        
                                        Text("**Reference Range:** \(metric.referenceRange)")
                                            .foregroundColor(.gray)

                                        Text("**Description:** \(metric.description ?? "No description available")")
                                            .foregroundColor(.black)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.9)) // White background for readability
                                    .cornerRadius(12) // Rounded corners
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1) // Soft shadow effect
                                }
                                .padding(.horizontal, 15)
                            }
                        }
                    }
                }
            }
            .padding(.top, 20)
            .onAppear {
                fetchReportDetails()
            }
        }
        .navigationTitle("Report Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    func fetchReportDetails() {
        print("Fetch Report Details triggered")

        let urlString = "http://127.0.0.1:5000/get_report_details?patientID=\(patientID)&testType=\(testType.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        print("API URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = " Network error: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    self.isLoading = false
                }
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON Response: \(jsonString)")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(ReportDetail.self, from: data)
                DispatchQueue.main.async {
                    self.report = decodedResponse
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

// Struct for Report Details
struct ReportDetail: Codable {
    let testType: String
    let metrics: [String: ReportMetric]
}

// Struct for Individual Metrics
struct ReportMetric: Codable {
    let value: String
    let referenceRange: String
    let rangeStatus: String  // Updated from "status" to "rangeStatus"
    let description: String?  // Nullable because some fields may not have descriptions
}

// Preview
#Preview {
    ReportDetailView(patientID: "123", testType: "Blood Test")
}
