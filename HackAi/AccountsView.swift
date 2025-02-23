import SwiftUI

struct AccountsView: View {
    @State private var familyMembers: [FamilyMember] = []
    @State private var selectedMember: String = UserDefaults.standard.string(forKey: "name") ?? "You"
    @State private var isAddingMember = false
    @State private var showLogoutConfirmation = false
    @State private var isLoggedOut = false

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
                    List {
                        Section(header: Text("Family Members")) {
                            Picker("Switch Member", selection: $selectedMember) {
                                ForEach(familyMembers, id: \.userID) { member in
                                    Text(member.name).tag(member.name)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: selectedMember) { newValue in
                                switchToMember(newValue)
                            }
                            
                            Button(action: { isAddingMember.toggle() }) {
                                Label("Add Family Member", systemImage: "plus")
                            }
                        }
                        
                        Section {
                            Button(action: { showLogoutConfirmation.toggle() }) {
                                Text("Logout")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .background(Color.clear) // Ensure list does not override gradient
                    .scrollContentBackground(.hidden) // Hide default background
                }
                .navigationTitle("Accounts")
                .onAppear { fetchFamilyMembers() }
                .alert(isPresented: $showLogoutConfirmation) {
                    Alert(
                        title: Text("Logout"),
                        message: Text("Are you sure you want to logout?"),
                        primaryButton: .destructive(Text("Logout")) {
                            logout()
                        },
                        secondaryButton: .cancel()
                    )
                }
                .fullScreenCover(isPresented: $isLoggedOut) {
                    LoginView().navigationBarBackButtonHidden(true)
                }
                .sheet(isPresented: $isAddingMember) {
                    AddFamilyMemberView(onAdded: fetchFamilyMembers)
                }
            }
        }
    }

    func fetchFamilyMembers() {
        guard let familyID = UserDefaults.standard.string(forKey: "familyID") else { return }
        
        guard let url = URL(string: "http://127.0.0.1:5000/get_family_members?familyID=\(familyID)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode([FamilyMember].self, from: data) {
                    DispatchQueue.main.async {
                        self.familyMembers = decodedResponse
                    }
                }
            }
        }.resume()
    }

    func switchToMember(_ name: String) {
        if let selected = familyMembers.first(where: { $0.name == name }) {
            UserDefaults.standard.set(selected.userID, forKey: "patientID")
            UserDefaults.standard.set(selected.name, forKey: "name")
        }
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        UserDefaults.standard.removeObject(forKey: "patientID")
        UserDefaults.standard.removeObject(forKey: "name")
        isLoggedOut = true
    }
}

// Family Member Struct
struct FamilyMember: Codable {
    let userID: String
    let name: String
}

// Add Family Member View with Gradient
struct AddFamilyMemberView: View {
    var onAdded: () -> Void
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.2)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .edgesIgnoringSafeArea(.all)

                VStack {
                    TextField("Full Name", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                        .padding()

                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()

                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()

                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    }

                    Button(action: addFamilyMember) {
                        Text("Add Family Member")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding()

                    Spacer()
                }
                .padding()
                .navigationBarTitle("Add Family Member", displayMode: .inline)
            }
        }
    }

    func addFamilyMember() {
        guard let familyID = UserDefaults.standard.string(forKey: "familyID") else { return }
        
        let body: [String: Any] = [
            "username": username,
            "email": email,
            "password": password,
            "familyID": familyID
        ]
        
        guard let url = URL(string: "http://127.0.0.1:5000/register_family_member"),
              let jsonData = try? JSONSerialization.data(withJSONObject: body) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                DispatchQueue.main.async {
                    onAdded()
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                DispatchQueue.main.async {
                    errorMessage = "Failed to add member"
                }
            }
        }.resume()
    }
}

// Preview
#Preview {
    AccountsView()
}
