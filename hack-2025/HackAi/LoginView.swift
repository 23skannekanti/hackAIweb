import SwiftUI

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLoading = false
    @State private var isLoggedIn = false  // Controls navigation to HomeView

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Login")
                    .font(.largeTitle)
                    .bold()

                TextField("Username", text: $username)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding()

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                if let error = errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .padding()
                }

                if isLoading {
                    ProgressView()
                        .padding()
                }

                Button(action: {
                    login()
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(isLoading ? Color.gray : Color.blue)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(isLoading)

                NavigationLink(destination: SignupView()) {
                    Text("Don't have an account? Sign up here")
                        .foregroundColor(.blue)
                        .underline()
                }

                Spacer()
            }
            .padding()
            .navigationBarHidden(true) // Fixes back button stacking
            .fullScreenCover(isPresented: $isLoggedIn) {
                HomeView()
            }
        }
    }

    // Function to call Flask API for login
    func login() {
        guard !username.isEmpty, !password.isEmpty else {
            errorMessage = " Please enter both username and password"
            return
        }

        isLoading = true
        errorMessage = nil

        let url = URL(string: "http://127.0.0.1:5000/login")!
        let body: [String: Any] = ["username": username, "password": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    errorMessage = "No response from server"
                }
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let error = json["error"] as? String {
                        DispatchQueue.main.async {
                            errorMessage = "\(error)"
                        }
                    } else if let authToken = json["token"] as? String,
                              let patientID = json["patientID"] as? String,
                              let name = json["name"] as? String {
                        // Store user details in UserDefaults
                        DispatchQueue.main.async {
                            UserDefaults.standard.set(authToken, forKey: "authToken")
                            UserDefaults.standard.set(patientID, forKey: "patientID")
                            UserDefaults.standard.set(name, forKey: "name")
                            isLoggedIn = true  // Redirect to HomeView
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    errorMessage = "Failed to decode response"
                }
            }
        }.resume()
    }
}

// PREVIEW FOR XCODE
#Preview {
    LoginView()
}
