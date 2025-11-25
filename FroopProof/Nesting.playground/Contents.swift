import SwiftUI
import Combine
import PlaygroundSupport

class Macro_Container: ObservableObject, Identifiable {
    let id = UUID()
    @Published var title: String
    @Published var name: String
    @Published var containers: [Container]
    @Published var containerNum: Int
    
    init(title: String, name: String, containers: [Container], containerNum: Int) {
        self.title = title
        self.name = name
        self.containers = containers
        self.containerNum = containerNum
    }
}


class Container: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String
    @Published var quantity: Int
    
    init(name: String, quantity: Int) {
        self.name = name
        self.quantity = quantity
    }
}

class Mocro_Container: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String
    @Published var quantity: Int
    
    init(name: String, quantity: Int) {
        self.name = name
        self.quantity = quantity
    }
}

class ObjectOne: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String
    @Published var quantity: Int
    
    init(name: String, quantity: Int) {
        self.name = name
        self.quantity = quantity
    }
}

class ObjectTwo: ObservableObject, Identifiable {
    let id = UUID()
    @Published var name: String
    @Published var quantity: Int
    
    init(name: String, quantity: Int) {
        self.name = name
        self.quantity = quantity
    }
}



struct NestedObjectsView: View {
    @StateObject var store: StoreModel
    
    var body: some View {
        VStack {
            Text("Store: \(store.storeName)")
                .font(.title)
            
            Text("User: \(store.currentUser.name)")
                .font(.headline)
            
            Text("Total Items in Cart: \(store.currentUser.cart.totalItems)")
            
            List(store.currentUser.cart.items) { item in
                HStack {
                    Text(item.name)
                    Spacer()
                    Text("Quantity: \(item.quantity)")
                }
            }
            
            Button("Update Data") {
                store.storeName = "Updated Store"
                store.currentUser.name = "Updated User"
                store.currentUser.cart.items[0].quantity += 1
                store.currentUser.cart.items[1].quantity += 1
            }
        }
    }
}

// Create the nested structure
let item1 = ItemModel(name: "Apple", quantity: 3)
let item2 = ItemModel(name: "Banana", quantity: 2)
let cart = CartModel(items: [item1, item2])
let user = UserModel(name: "John Doe", cart: cart)
let store = StoreModel(storeName: "Fruit Market", currentUser: user)

// Use in SwiftUI
let contentView = NestedObjectsView(store: store)

// Wrap the content view in a UIHostingController
let hostingController = UIHostingController(rootView: contentView)

// Set a frame for the hosting controller's view
hostingController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 667) // iPhone 8 size

// Set the live view to the hosting controller
PlaygroundPage.current.liveView = hostingController
