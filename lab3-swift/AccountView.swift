import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AccountView: View {
    @State private var dateText: String = ""
    @State private var emailText: String = ""
    @State private var nameText: String = ""
    @State private var surnameText: String = ""
    @State private var patronymicText: String = ""
    @State private var profileDescriptionText: String = ""
    @State private var interestsText: String = ""
    @State private var educationIndex: Int = 0
    @State private var petText: String = ""
    @State private var selectedDate = Date()
    @State private var isAuthenticated = true
    
    @Binding var loginViewPresented: Bool
    
    
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                TextField("Email", text: $emailText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .padding()
                TextField("Имя", text: $nameText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.default)
                    .padding()
                TextField("Фамилия", text: $surnameText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.default)
                    .padding()
                TextField("Отчество", text: $patronymicText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.default)
                    .padding()
                
                TextField("Дата рождения", text: $dateText)
                                   .textFieldStyle(RoundedBorderTextFieldStyle())
                                   .disabled(true)
                                   .padding()

                               // DatePicker для выбора даты
                               DatePicker("", selection: $selectedDate, displayedComponents: .date)
                                   .datePickerStyle(WheelDatePickerStyle())
                                   .padding()
                                   .labelsHidden()
                                   .onChange(of: selectedDate) {
                                       dateText = formatDate($0)
                                   }
                TextField("Описание профиля", text: $profileDescriptionText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.default)
                    .padding()
                TextField("Интересы", text: $interestsText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.default)
                    .padding()
                TextField("Питомец", text: $petText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.default)
                    .padding()
                Picker("Образование", selection: $educationIndex) {
                    Text("Высшее").tag(0)
                    Text("Среднее").tag(1)
                    Text("Начальное").tag(2)
                }
                .padding()
                Button(action: saveUserData) {
                    Text("Сохранить")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding()
                
                NavigationLink(
                    destination: LoginView(catalogueViewPresented: $isAuthenticated),
                    isActive: $loginViewPresented,
                    label: {
                        EmptyView()
                    }
                )
                .hidden()

                Button(action: signOut) {
                    Text("Выйти")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding()

                Button(action: deleteAccount) {
                    Text("Удалить аккаунт")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .padding()
               
            }
            .onAppear {
                loadUserData()
            }
        }
    }
    
    
    
    func loadUserData() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Current user ID not available")
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(currentUserID)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Error getting user document: \(error)")
                return
            }
            
            guard let document = document, document.exists else {
                print("User document does not exist")
                return
            }
            
            let data = document.data()
            dateText = data?["dob"] as? String ?? ""
            emailText = data?["email"] as? String ?? ""
            nameText = data?["name"] as? String ?? ""
            surnameText = data?["surname"] as? String ?? ""
            patronymicText = data?["patronymic"] as? String ?? ""
            profileDescriptionText = data?["profileDescription"] as? String ?? ""
            interestsText = data?["interests"] as? String ?? ""
            let education = data?["education"] as? String ?? ""
            educationIndex = getEducationIndex(education)
            petText = data?["pet"] as? String ?? ""
            if let date = getDateFromString(dateText) {
                        selectedDate = date
                        dateText = formatDate(date)
                    }
        }
    }
    func formatDate(_ date: Date) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            return dateFormatter.string(from: date)
        }

        
        func getDateFromString(_ dateString: String) -> Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            return dateFormatter.date(from: dateString)
        }
    
    func getEducationIndex(_ education: String) -> Int {
        switch education {
            case "Среднее": return 1
            case "Начальное": return 2
            default: return 0
        }
    }
    
    func saveUserData() {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Current user ID not available")
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(currentUserID)
        
        let userData: [String: Any] = [
            "dob": dateText,
            "email": emailText,
            "name": nameText,
            "surname": surnameText,
            "patronymic": patronymicText,
            "profileDescription": profileDescriptionText,
            "interests": interestsText,
            "education": getEducationText(educationIndex),
            "pet": petText
        ]
        
        userRef.updateData(userData) { error in
            if let error = error {
                print("Error updating user data: \(error)")
            } else {
                print("User data updated successfully")
            }
        }
    }
    
    func getEducationText(_ index: Int) -> String {
        switch index {
            case 1: return "Среднее"
            case 2: return "Начальное"
            default: return "Высшее"
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            print("User signed out successfully")
            isAuthenticated = false
            loginViewPresented = true
        } catch let signOutError as NSError {
            print("Error signing out: \(signOutError)")
        }
    }
    
    func deleteAccount() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Current user not available")
            return
        }
        
        currentUser.delete { error in
            if let error = error {
                print("Error deleting user: \(error)")
            } else {
                print("User deleted successfully")
                isAuthenticated = false
                loginViewPresented = true
                
            }
        }
    }
}


