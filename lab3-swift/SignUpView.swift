import SwiftUI
import Firebase

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
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
                
                SecureField("Введите пароль ещё раз", text: $repeatPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 8)
                
                Button(action: {
                    signUp()
                }) {
                    Text("Регистрация")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding(.bottom, 16)
                NavigationLink(
                    destination: CatalogueView(),
                    isActive: $catalogueViewPresented,
                    label: {
                        EmptyView()
                    }
                )
                .hidden()
                
                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Результат регистрации"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                    if isRegistered {
                        navigateToCatalogueView()
                    }
                })
            }
        }
        .navigationBarBackButtonHidden(true) // Скрыть кнопку "назад"
        .navigationBarHidden(true)
    }
    private func navigateToCatalogueView() {
        catalogueViewPresented = isRegistered
    }
    private func signUp() {
        if password != repeatPassword {
            errorMessage = "Пароли не совпадают"
            alertMessage = errorMessage
            showAlert = true
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = error.localizedDescription
                alertMessage = errorMessage
                showAlert = true
                isRegistered = false
            } else {
                
                alertMessage = "Регистрация прошла успешно!"
                showAlert = true
                isRegistered = true
                createFirestoreUser()
                
            }
        }
    }
    private func createFirestoreUser() {
            guard let userId = Auth.auth().currentUser?.uid else {
                return
            }
            
            let db = Firestore.firestore()
            let userDocument = db.collection("users").document(userId)
            
            let userData: [String: Any] = [
                "email": email,
                "dob": "",
                "education": "",
                "gender": "",
                "interests": "",
                "name": "",
                "surname": "",
                "patronymic": "",
                "pet": "",
                "profileDescription": "",
                "favorites": []
            ]
            
            userDocument.setData(userData) { error in
                if let error = error {
                    print("Error creating user document: \(error.localizedDescription)")
                } else {
                    print("User document created successfully")
                }
            }
        }
}
