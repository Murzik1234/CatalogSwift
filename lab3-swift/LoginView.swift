import SwiftUI
import Firebase

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var isAuthenticated = false
    @State private var isRegistered = false
    @Binding var catalogueViewPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                TextField("Введите Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .padding(.bottom, 8)
                
                SecureField("Введите пароль", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 8)
                
                Button(action: {
                    signIn()
                }) {
                    Text("Войти")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding(.bottom, 16)
                
                NavigationLink(
                    destination: SignUpView(catalogueViewPresented: $isRegistered),
                    label: {
                        Text("Регистрация")
                            .foregroundColor(.black)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.bottom, 16)
                    }
                )
                
                Spacer()
                NavigationLink(
                    destination: CatalogueView(),
                    isActive: $catalogueViewPresented,
                    label: {
                        EmptyView() 
                    }
                )
                .hidden()
                
            }
            .padding()
            .navigationTitle("Авторизация")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Результат авторизации"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    if isAuthenticated {
                        navigateToCatalogueView()
                    }
                })
            }
            
        }
        .navigationBarBackButtonHidden(true) // Скрыть кнопку "назад"
        .navigationBarHidden(true)
        
    }
    private func navigateToCatalogueView() {
        catalogueViewPresented = isAuthenticated
    }
    
    private func signIn() {
        Auth.auth().signIn(withEmail: email.lowercased(), password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                alertMessage = errorMessage
                showAlert = true
                isAuthenticated = false
                password = ""
                email = ""
            } else {
                alertMessage = "Авторизация прошла успешно!"
                showAlert = true
                isAuthenticated = true
            }
        }
    }
}

