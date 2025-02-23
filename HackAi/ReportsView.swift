import SwiftUI

struct ReportsView: View {
    @State private var reports: [Report] = []
    @State private var errorMessage: String?
    @State private var isLoading = true  // Added loading state

    var body: some View {
        NavigationView {
            ZStack {
                // Full-screen gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    // Keeps "Reports" title in the correct position
                    Text("Reports")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 10)

                    if isLoading {
                        ProgressView("Loading reports...") // Shows loading state
                            .padding()
                    } else if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else if reports.isEmpty {
                        Text("No reports found")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ScrollView {
                            VStack(spacing: 15) { // Adds spacing between boxes
                                ForEach(reports, id: \.testType) { report in
                                    NavigationLink(destination: ReportDetailView(patientID: report.patientID, testType: report.testType)) {
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(report.testType)
                                                    .font(.headline)
                                                    .bold()
                                                    .foregroundColor(.primary)
                                                Text("Tap to view details") // Helpful text
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            Spacer()
                                            // Keeps the arrow icon
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.gray)
                                        }
                                        .padding(20) // Increased padding inside the box
                                        .frame(minHeight: 80) // Makes each box taller
                                        .background(Color.white.opacity(0.9)) // White background for readability
                                        .cornerRadius(12) // Rounded corners
                                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1) // Soft shadow effect
                                    }
                                }
                            }
                            .padding(.horizontal, 15) // Adds padding on the sides
                        }
                    }
                }
                .padding(.top, -50) // Ensures "Reports" stays up
                .onAppear {
                    fetchReports()
                }
            }
        }
    }

    func fetchReports() {
        print("🔹 Fetch Reports triggered") // Debugging log

        guard let patientID = UserDefaults.standard.string(forKey: "patientID") else {
            errorMessage = "No patient ID found"
            print("No patient ID found")
            isLoading = false
            return
        }

        let urlString = "http://127.0.0.1:5000/get_reports?patientID=\(patientID)"
        print("🔹 API URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL"
            print("Invalid URL")
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    print("Network error: \(error.localizedDescription)")
                    self.isLoading = false
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.errorMessage = "No data received"
                    print("No data received")
                    self.isLoading = false
                }
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("🔹 Raw JSON Response: \(jsonString)")
            }

            do {
                let decodedReports = try JSONDecoder().decode([Report].self, from: data)
                DispatchQueue.main.async {
                    self.reports = decodedReports
                    print(" Reports updated: \(decodedReports.count) reports received")
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                    print("Failed to decode response: \(error.localizedDescription)")
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

// Struct for Reports
struct Report: Codable {
    let testType: String  // Keeps test type for filtering
    let patientID: String // Added patientID
}

// Preview
#Preview {
    ReportsView()
}
