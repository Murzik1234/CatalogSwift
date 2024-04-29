import SwiftUI
import URLImage
import FirebaseFirestore
import Firebase

struct FavoritesView: View {
    @State private var cardItems: [CardItem] = []
    @State private var selectedCardItem: CardItem? = nil
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Поиск", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filteredCardItems, id: \.id) { cardItem in
                            Button(action: {
                                selectedCardItem = cardItem
                            }) {
                                CardDelView(cardItem: cardItem, onDelete: {
                                    removeFromFavorites(cardItem)
                                })
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                .sheet(item: $selectedCardItem) { selectedItem in
                    DetailsView(cardItem: selectedItem)
                }
            }
            .navigationTitle("Избранное")
            .onAppear {
                if let currentUserID = Auth.auth().currentUser?.uid {
                    fetchFavoriteProducts(for: currentUserID)
                } else {
                    print("Current user ID not available")
                }
            }
        }
    }
    private var filteredCardItems: [CardItem] {
        if searchText.isEmpty {
            return cardItems
        } else {
            return cardItems.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    private func removeFromFavorites(_ cardItem: CardItem) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            print("Current user ID not available")
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUserID)
        
        userRef.updateData([
            "favorites": FieldValue.arrayRemove([cardItem.id])
        ]) { error in
            if let error = error {
                print("Error removing product from favorites: \(error)")
            } else {
                cardItems.removeAll(where: { $0.id == cardItem.id })
            }
        }
    }
    
    private func fetchFavoriteProducts(for userId: String) {
        let db = Firestore.firestore()
        
        
        let userRef = db.collection("users").document(userId)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Error getting user document: \(error)")
                return
            }
            
            guard let document = document, document.exists else {
                print("User document does not exist")
                return
            }
            
            
            let favorites = document.get("favorites") as? [String] ?? []
            
            
            let productsRef = db.collection("products")
            productsRef.whereField("id", in: favorites).getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching favorite products: \(error)")
                    return
                }
                
                guard let snapshot = snapshot else {
                    print("No documents in favorite products collection")
                    return
                }
                
                var favoriteProductList: [CardItem] = []
                
                for document in snapshot.documents {
                    let data = document.data()
                    if let id = data["id"] as? String,
                       let title = data["name"] as? String,
                       let price = data["cost"] as? String,
                       let description = data["description"] as? String,
                       let images = data["images"] as? [String] {
                        let currentIndex = 0
                        let cardItem = CardItem(id: id, title: title, price: price, description: description, images: images, currentIndex: currentIndex)
                        favoriteProductList.append(cardItem)
                    }
                }
                
                cardItems = favoriteProductList
            }
        }
    }
}

struct CardDelView: View {
    let cardItem: CardItem
    let onDelete: () -> Void
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer()
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                    }
                }
                HStack(spacing: 10) {
                    Spacer()
                    ForEach(cardItem.images, id: \.self) { imageUrl in
                        if let url = URL(string: imageUrl) {
                            URLImage(url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(8)
                            }
                        } else {
                            Text("Invalid URL: \(imageUrl)")
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 10)
            }
            Text(cardItem.title)
                .fontWeight(.bold)
            Text(cardItem.price)
                .fontWeight(.bold)
            
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}

struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoritesView()
    }
}
