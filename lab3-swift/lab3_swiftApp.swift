
import SwiftUI
import FirebaseCore
@main
struct lab3_swiftApp: App {
    @State private var isAuthenticated = true
    
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView(catalogueViewPresented: $isAuthenticated)
            //CatalogueView()
            
        }
    }
}
