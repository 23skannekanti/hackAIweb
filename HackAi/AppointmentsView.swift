import SwiftUI

struct AppointmentsView: View {
    @State private var selectedDate = Date()
    @State private var upcomingAppointments: [Appointment] = []
    @State private var pastAppointments: [Appointment] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ZStack {
                // Full-screen gradient background
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all) // Extends gradient fully

                ScrollView {
                    VStack(spacing: 15) {
                        Text("📅 Schedule Appointment")
                            .font(.title2)
                            .bold()
                            .padding(.top, -50)

                        // **Calendar View**
                        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(GraphicalDatePickerStyle())
                            .padding()
                            .background(Color.white.opacity(0.2)) // Helps with visibility
                            .cornerRadius(10)

                        Button(action: scheduleAppointment) {
                            HStack {
                                Image(systemName: "pin.fill")
                                Text("Add Appointment")
                                    .font(.headline)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)

                        Divider().padding(.vertical, 10)

                        // **Upcoming Appointments**
                        Text("📆 Upcoming Appointments")
                            .font(.headline)
                            .padding(.bottom, 5)

                        if isLoading {
                            ProgressView()
                                .padding()
                        } else if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .padding()
                        } else if upcomingAppointments.isEmpty {
                            Text("No upcoming appointments.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            VStack {
                                ForEach(upcomingAppointments) { appointment in
                                    AppointmentRow(appointment: appointment, isPast: false)
                                        .padding(.horizontal)
                                }
                            }
                        }

                        Divider().padding(.vertical, 10)

                        // **Past Appointments**
                        Text("🕰 Past Appointments")
                            .font(.headline)
                            .padding(.bottom, 5)

                        if pastAppointments.isEmpty {
                            Text("No past appointments.")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            VStack {
                                ForEach(pastAppointments) { appointment in
                                    AppointmentRow(appointment: appointment, isPast: true)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            fetchAppointments()
        }
    }

    // Fetch Appointments from API
    func fetchAppointments() {
        guard let patientID = UserDefaults.standard.string(forKey: "patientID") else {
            errorMessage = " No patient ID found."
            return
        }

        let urlString = "http://127.0.0.1:5000/get_appointments?patientID=\(patientID)"
        guard let url = URL(string: urlString) else {
            errorMessage = " Invalid API URL."
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = " Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = " No data received."
                }
                return
            }

            if let jsonString = String(data: data, encoding: .utf8) {
                print("🔹 Raw API Response: \(jsonString)")
            }

            do {
                let decodedResponse = try JSONDecoder().decode(AppointmentsResponse.self, from: data)

                DispatchQueue.main.async {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"  // Matches API format
                    formatter.timeZone = .current

                    let today = Date()

                    upcomingAppointments = decodedResponse.upcoming.compactMap { appointment in
                        guard let parsedDate = formatter.date(from: appointment.date) else {
                            print(" Failed to parse date: \(appointment.date)")
                            return nil
                        }
                        return Appointment(from: appointment, date: parsedDate)
                    }.filter { $0.date >= today }

                    pastAppointments = decodedResponse.past.compactMap { appointment in
                        guard let parsedDate = formatter.date(from: appointment.date) else {
                            print(" Failed to parse date: \(appointment.date)")
                            return nil
                        }
                        return Appointment(from: appointment, date: parsedDate)
                    }.filter { $0.date < today }

                    print(" Processed \(upcomingAppointments.count) upcoming & \(pastAppointments.count) past appointments.")
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = " Failed to decode response: \(error.localizedDescription)"
                }
            }
        }.resume()
    }

    // Schedule a New Appointment
    func scheduleAppointment() {
        guard let patientID = UserDefaults.standard.string(forKey: "patientID") else {
            errorMessage = "❌ No patient ID found."
            return
        }

        let urlString = "http://127.0.0.1:5000/add_appointment"
        guard let url = URL(string: urlString) else {
            errorMessage = "❌ Invalid API URL."
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"  // Ensure API consistency

        let appointmentData: [String: Any] = [
            "patientID": patientID,
            "date": formatter.string(from: selectedDate),  // Format before sending
            "time": "10:00 AM",
            "doctor": "Dr. Smith"
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: appointmentData)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }

            DispatchQueue.main.async {
                fetchAppointments()  // Refresh after scheduling
            }
        }.resume()
    }
}

// Reusable Appointment Row Component
struct AppointmentRow: View {
    let appointment: Appointment
    let isPast: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("📅 \(appointment.dateFormatted)")
                    .font(.body)
                Text("🩺 \(appointment.doctor)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: isPast ? "clock.arrow.circlepath" : "calendar")
                .foregroundColor(isPast ? .gray : .blue)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(8)
    }
}

// API Response Struct
struct AppointmentsResponse: Codable {
    let upcoming: [AppointmentData]
    let past: [AppointmentData]
}

// Appointment Data from API
struct AppointmentData: Codable {
    let appointmentID: String
    let date: String
    let time: String
    let doctor: String
}

// Appointment Struct
struct Appointment: Identifiable {
    let id = UUID()
    let appointmentID: String
    let date: Date
    let time: String
    let doctor: String

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeZone = .current
        return formatter.string(from: date)
    }

    init(from data: AppointmentData, date: Date) {
        self.appointmentID = data.appointmentID
        self.date = date
        self.time = data.time
        self.doctor = data.doctor
    }
}

#Preview {
    AppointmentsView()
}
