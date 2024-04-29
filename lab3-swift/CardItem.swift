
import Foundation
class CardItem {
    var id: String = ""
    var title: String = ""
    var price: String = ""
    var description: String = ""
    var images: [String] = []
    var currentIndex: Int = 0
    
    init(id: String, title: String, price: String, description: String, images: [String], currentIndex: Int) {
        self.id = id
        self.title = title
        self.price = price
        self.description = description
        self.images = images
        self.currentIndex = currentIndex
        precondition(!images.isEmpty, "Images list must not be empty")
    }
}
extension CardItem: Identifiable {}
