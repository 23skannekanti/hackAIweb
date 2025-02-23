import SwiftUI

struct MedicationsView: View {
    @State private var medications: [Medication] = []
    @State private var isLoading = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    Text("Medications")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 10)

                    ScrollView {
                        VStack(spacing: 15) { // Adds spacing between items
                            ForEach(medications) { medication in
                                NavigationLink(destination: MedicationDetailView(medication: medication)) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 5) {
                                            HStack {
                                                Image(systemName: "pills.fill")
                                                    .foregroundColor(.blue)
                                                Text(medication.name)
                                                    .font(.headline)
                                            }
                                            if let dosage = medication.dosage {
                                                Text("Dosage: \(dosage)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                            if let frequency = medication.frequency {
                                                Text("Frequency: \(frequency)")
                                                    .font(.subheadline)
                                                    .foregroundColor(.gray)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right") // Arrow added
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading) // Full width
                                    .background(Color.white.opacity(0.9)) // Box effect
                                    .cornerRadius(12)
                                    .shadow(radius: 2)
                                    .padding(.horizontal, 20) // Keeps it centered
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    .onAppear {
                        fetchMedications()
                    }
                }
            }
        }
    }

    // Fetch Medications from Backend
    func fetchMedications() {
        guard let patientID = UserDefaults.standard.string(forKey: "patientID") else { return }
        let urlString = "http://127.0.0.1:5000/medications?patientID=\(patientID)"

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode(MedicationsResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.medications = decodedResponse.medications
                    }
                } catch {
                    print("❌ Error decoding medications: \(error)")
                }
            } else if let error = error {
                print("❌ Error fetching medications: \(error.localizedDescription)")
            }
        }.resume()
    }
}

// Medication Model
struct Medication: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let dosage: String?
    let frequency: String?
}

// Response Model for API
struct MedicationsResponse: Codable {
    let medications: [Medication]
}

// Preview
#Preview {
    MedicationsView()
}
