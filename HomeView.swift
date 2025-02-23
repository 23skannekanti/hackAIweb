import SwiftUI

struct HomeView: View {
    @State private var showChatbot = false
    @State private var username: String = UserDefaults.standard.string(forKey: "name") ?? "User"

    // 2-column grid layout for the feature buttons
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        TabView {
            NavigationView {
                ZStack {
                    GradientBackground() // Adds the gradient background

                    VStack(spacing: 20) { // Keep spacing consistent
                                            
                        // **LOGO - BIG & CENTERED**
                        Image("logo-transparent")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 500, height: 300) // Adjusted size
                            .padding(.top, -175) // Moves it up slightly
                            .padding(.bottom, -50) // Reduces gap under logo
                            .offset(x: -20)

                        // **User Greeting**
                        Text("Hello, \(username)!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.top, -75) // Ensures it's closer to the logo
                            .padding(.bottom, 5) // Reduces gap under greeting

                        // **Feature Buttons Grid (Centered)**
                        LazyVGrid(columns: columns, spacing: 25) { // Reduced spacing for better layout
                            NavigationLink(destination: AppointmentsView()) {
                                FeatureBox(icon: "calendar.badge.plus", title: "Appointments")
                            }
                            NavigationLink(destination: BillingView()) {
                                FeatureBox(icon: "creditcard.fill", title: "Billing")
                            }
                            NavigationLink(destination: NutriCareView()) {
                                FeatureBox(icon: "leaf.fill", title: "NutriCare")
                            }
                            NavigationLink(destination: HealthDataView()) {
                                FeatureBox(icon: "heart.fill", title: "Health Data")
                            }
                        }
                        .padding(.horizontal, 70) // Ensures grid stays centered
                        .padding(.top, 5) // Adjust top padding to remove excess space

                        Spacer()

                        // **Chatbot Button**
                        VStack {
                            Button(action: {
                                showChatbot.toggle()
                            }) {
                                HStack {
                                    Image(systemName: "bubble.left.and.bubble.right.fill")
                                        .foregroundColor(.white)
                                    Text("Chat with Jeek")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(12)
                                .shadow(color: Color.blue.opacity(0.4), radius: 6, x: 0, y: 4)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 5)// Adjusted bottom padding
                        }
                    }
                    .navigationBarHidden(true) // Hides back navigation in HomeView
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            MedicationsView()
                .tabItem {
                    Image(systemName: "pills.fill")
                    Text("Medications")
                }
            
            LiveView()
                .tabItem {
                    Image(systemName: "play.circle.fill")
                    Text("Live")
                }

            ReportsView()
                .tabItem {
                    Image(systemName: "doc.plaintext")
                    Text("Reports")
                }

            AccountsView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Accounts")
                }
        }
        .fullScreenCover(isPresented: $showChatbot) {
            ChatbotView()
        }
    }
}


// **Feature Box Component**
struct FeatureBox: View {
    var icon: String
    var title: String

    var body: some View {
        VStack {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundColor(.blue)
                .padding(.bottom, 5)
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
        }
        .frame(width: 150, height: 120)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
    }
}

// **Placeholder Views**
struct BillingView: View {
    var body: some View {
        Text("Billing Page")
            .font(.largeTitle)
            .padding()
    }
}

struct NutriCareView: View {
    var body: some View {
        Text("NutriCare Page")
            .font(.largeTitle)
            .padding()
    }
}

struct HealthDataView: View {
    var body: some View {
        Text("Health Data Page")
            .font(.largeTitle)
            .padding()
    }
}

// **Message Model**
struct Message: Identifiable {
    let id = UUID()
    let role: Role
    let content: String

    enum Role {
        case user
        case bot
    }
}
