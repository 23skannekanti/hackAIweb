import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            ReportsView()
                .tabItem {
                    Label("Reports", systemImage: "doc.text")
                }
            
            LiveView()
                .tabItem {
                    Label("Live", systemImage: "play.circle")
                }
                
            MedicationsView()
                .tabItem {
                    Label("Medications", systemImage: "pills")
                }
            
            AccountsView()
                .tabItem {
                    Label("Accounts", systemImage: "person.crop.circle")
                }
        }
        .accentColor(.blue) // Highlight color for selected tab
    }
}


// MARK: - Other Tab Views
struct ReportsViews: View {
    var body: some View {
        Text("Reports Page")
            .font(.largeTitle)
            .padding()
    }
}

