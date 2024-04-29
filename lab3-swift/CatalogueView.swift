import SwiftUI
import URLImage
import FirebaseFirestore


struct CatalogueView: View {
    @State private var cardItems: [CardItem] = []
    @State private var selectedCardItem: CardItem? = nil
    @State private var searchText: String = ""
    @State private var loginViewPresented = false
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {}) {
                        NavigationLink(destination: AccountView(loginViewPresented: $loginViewPresented)) {
                            Image(systemName: "person")
                                .foregroundColor(.pink)
                                .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    
                    Button(action: {}) {
                        NavigationLink(destination: FavoritesView()) {
                            Image(systemName: "heart")
                                .foregroundColor(.black)
                                .padding()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.top, 10)
                .padding(.trailing, 10)
                
                TextField("Поиск", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filteredCardItems, id: \.id) { cardItem in
                            Button(action: {
                                selectedCardItem = cardItem
                            }) {
                                CardView(cardItem: cardItem)
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
            .navigationTitle("Каталог")
            .onAppear {
                fetchCardItems()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
    
    private func fetchCardItems() {
        let db = Firestore.firestore()
        let productsRef = db.collection("products")
        
        productsRef.getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching products: \(error.localizedDescription)")
                return
            }
            
            guard let snapshot = snapshot else {
                print("No documents in products collection")
                return
            }
            
            var items: [CardItem] = []
            for document in snapshot.documents {
                let data = document.data()
                if let id = data["id"] as? String,
                   let title = data["name"] as? String,
                   let price = data["cost"] as? String,
                   let description = data["description"] as? String,
                   let images = data["images"] as? [String] {
                    let cardItem = CardItem(id: id, title: title, price: price, description: description, images: images, currentIndex: 0)
                    items.append(cardItem)
                }
            }
            cardItems = items
        }
    }
    
    private var filteredCardItems: [CardItem] {
        if searchText.isEmpty {
            return cardItems
        } else {
            return cardItems.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct CardView: View {
    let cardItem: CardItem
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(.horizontal, showsIndicators: false) {
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
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}
#Preview {
    CatalogueView()
}
