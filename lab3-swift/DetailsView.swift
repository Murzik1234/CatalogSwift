import SwiftUI
import URLImage
import Firebase

struct DetailsView: View {
    let cardItem: CardItem
    @State private var isFavorite = false 
    
    var body: some View {
        VStack(spacing: 20) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    Spacer()
                    Spacer()
                    Spacer()
                    ForEach(cardItem.images, id: \.self) { imageUrl in
                        if let url = URL(string: imageUrl) {
                            URLImage(url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 200, height: 200)
                                    .cornerRadius(8)
                            }
                        } else {
                            Text("Invalid URL: \(imageUrl)")
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
            
            Text(cardItem.title)
                .font(.title)
                .fontWeight(.bold)
            
            Text("Price: \(cardItem.price)")
            
            Text(cardItem.description)
            
            Spacer()
            Button(action: {
                toggleFavorite()
            }) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(isFavorite ? .pink : .black)
                    .font(.title)
                    .padding()
            }
        }
        .padding()
        .navigationBarTitle("Details", displayMode: .inline)
        .onAppear {
            checkIfFavorite()
        }
    }
    
    private func toggleFavorite() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        let userDocument = db.collection("users").document(userId)
        
        if isFavorite {
            
            userDocument.updateData(["favorites": FieldValue.arrayRemove([cardItem.id])]) { error in
                if let error = error {
                    print("Error removing product from favorites: \(error.localizedDescription)")
                } else {
                    print("Product removed from favorites")
                    isFavorite = false
                }
            }
        } else {
            
            userDocument.updateData(["favorites": FieldValue.arrayUnion([cardItem.id])]) { error in
                if let error = error {
                    print("Error adding product to favorites: \(error.localizedDescription)")
                } else {
                    print("Product added to favorites")
                    isFavorite = true
                }
            }
        }
    }
    
    private func checkIfFavorite() {
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        let db = Firestore.firestore()
        let userDocument = db.collection("users").document(userId)
        
        userDocument.getDocument { snapshot, error in
            if let error = error {
                print("Error fetching user data: \(error.localizedDescription)")
            } else if let snapshot = snapshot, snapshot.exists {
                if let favorites = snapshot.data()?["favorites"] as? [String], favorites.contains(cardItem.id) {
                    isFavorite = true
                } else {
                    isFavorite = false
                }
            }
        }
    }
}
