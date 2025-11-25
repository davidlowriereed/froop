import Combine
import SwiftUI
import MapKit
import FirebaseFirestore
 
import FirebaseAuth

class FroopType: ObservableObject, Codable, Hashable, Equatable {
    @ObservedObject var printControl = PrintControl.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @Published var viewPositions: [Int] = []
    @Published var id: Int = 0
    @Published var order: String = ""
    @Published var name: String = ""
    @Published var subCategory = ""
    @Published var imageName: String = ""
    @Published var category: [String] = []
    var db = FirebaseServices.shared.db

    
    static func == (lhs: FroopType, rhs: FroopType) -> Bool {
        return lhs.id == rhs.id && lhs.order == rhs.order && lhs.name == rhs.name && lhs.subCategory == rhs.subCategory && lhs.imageName == rhs.imageName && lhs.category == rhs.category
    }
    
    func hash(into hasher: inout Hasher) {
        PrintControl.shared.printFroopCreation("-FroopType: Function: hash firing")
        hasher.combine(viewPositions)
        hasher.combine(id)
        hasher.combine(order)
        hasher.combine(name)
        hasher.combine(subCategory)
        hasher.combine(imageName)
        hasher.combine(category)
    }
    
    var dictionary: [String: Any] {
        return [
            "viewPositions": viewPositions,
            "order": order,
            "name": name,
            "subCategory": subCategory,
            "imageName": imageName,
            "category:": category
        ]
    }
    
    func encode(to encoder: Encoder) throws {
        PrintControl.shared.printFroopCreation("-FroopType: Function: encode firing")
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(viewPositions, forKey: .viewPositions)
        try container.encode(id, forKey: .id)
        try container.encode(order, forKey: .order)
        try container.encode(name, forKey: .name)
        try container.encode(subCategory, forKey: .subCategory)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(category, forKey: .category)
        PrintControl.shared.printFroopCreation("retrieving FroopTypeData Data")
    }
    
    enum CodingKeys: String, CodingKey {
        case viewPositions, id, order, name, subCategory, imageName, category
    }
    
    init(dictionary: [String: Any]) {
        self.viewPositions = dictionary["viewPositions"] as? [Int] ?? []
        self.id = dictionary["id"] as? Int ?? 0
        self.order = dictionary["order"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.subCategory = dictionary["subCategory"] as? String ?? ""
        self.imageName = dictionary["imageName"] as? String ?? ""
        self.category = dictionary["category"] as? [String] ?? []
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        viewPositions = try values.decode([Int].self, forKey: .viewPositions)
        id = try values.decode(Int.self, forKey: .id)
        order = try values.decode(String.self, forKey: .order)
        name = try values.decode(String.self, forKey: .name)
        subCategory = try values.decode(String.self, forKey: .subCategory)
        imageName = try values.decode(String.self, forKey: .imageName)
        category = try values.decode([String].self, forKey: .category)
    }

}



// Define a structure to manage Froop Types and their creation steps
struct FroopTypeManager {
    private let froopTypeFlows: [String: [String]] = [
        "Basic Get Together": ["Location", "Date/Time/Duration", "Name"],
        "Pick Me Up": ["SelectFriend", "Date/Time/Duration"]
        // Add other Froop Types and their flows here
    ]

    func getFroopCreationSteps(for froopType: String) -> [String]? {
        return froopTypeFlows[froopType]
    }
}


//category
//(array)
//
//0
//"Travel & Exploration"
//(string)
//
//1
//"Errands & Utility"
//(string)
//
//id
//5009
//(number)
//
//imageName
//"airplane.arrival"
//(string)
//
//name
//"Airport Pickup"
//(string)
//
//order
//"AirportPickup"
//(string)
//
//subCategory
//""
//(string)
//
//
//viewPositions
//(array)
//
//0
//1
//(number)
//
//1
//0
//(number)
//
//2
//2
//(number)
//
//3
//0
//(number)
//
//4
//5
//(number)
//
//5
//4
//(number)
//
//6
//3
//(number)
//
//7
//0
//(number)
//
//8
//0
//(number)
//
//9
//0
//(number)
//
//10
//0
//(number)
//
//11
//0
//(number)
//
//12
//0
//(number)
//
//13
//0
//(number)
//
//14
//0
//(number)
//
//15
//0
//(number)
//
//16
//0
//(number)
//
//17
//0
//(number)
//
//18
//0
//(number)
//
//19
//0
