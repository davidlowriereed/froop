


import SwiftUI
import MapKit

class FroopDropPin: NSObject, Codable, ObservableObject, Identifiable {

    let id: UUID
    @Published var lastUpdated: Date
    @Published var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @Published var title: String = "Your Title"
    @Published var subtitle: String = "Your Subtitle"
    @Published var messageBody: String = "Add Details Here"
    @Published var color: UIColor?
    @Published var creatorUID: String = MyData.shared.froopUserID
    @Published var pinImage: String = "mappin.circle.fill"
    
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, messageBody, latitude, longitude, color, creatorUID, pinImage
    }
    
    init(id: UUID = UUID(), coordinate: CLLocationCoordinate2D? = nil, title: String? = nil, subtitle: String? = nil, messageBody: String? = nil, color: UIColor? = nil, creatorUID: String? = nil, pinImage: String? = nil) {
        self.id = id
        self.lastUpdated = Date()
        self.coordinate = coordinate ?? CLLocationCoordinate2D()
        self.title = title ?? ""
        self.subtitle = subtitle ?? ""
        self.messageBody = messageBody ?? ""
        self.color = color
        self.creatorUID = creatorUID ?? ""
        self.pinImage = pinImage ?? ""
    }
    
    var dictionary: [String: Any] {
        var dict = [String: Any]()
        dict["id"] = id.uuidString
        dict["title"] = title
        dict["subtitle"] = subtitle
        dict["messageBody"] = messageBody
        dict["latitude"] = coordinate.latitude
        dict["longitude"] = coordinate.longitude
        dict["color"] = color?.toHexString()
        dict["creatorUID"] = creatorUID
        dict["pinImage"] = pinImage
        dict["lastUpdated"] = lastUpdated
        return dict
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let latitude = try container.decode(Double.self, forKey: .latitude)
        let longitude = try container.decode(Double.self, forKey: .longitude)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String?.self, forKey: .title) ?? ""
        subtitle = try container.decode(String?.self, forKey: .subtitle) ?? ""
        messageBody = try container.decode(String?.self, forKey: .messageBody) ?? ""
        let colorString = try container.decode(String?.self, forKey: .color)
        color = colorString.flatMap { UIColor(named: $0) }
        creatorUID = try container.decode(String?.self, forKey: .creatorUID) ?? ""
        pinImage = try container.decode(String?.self, forKey: .pinImage) ?? ""
        lastUpdated = Date()
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(messageBody, forKey: .messageBody)
        try container.encode(color?.toHexString(), forKey: .color)
        try container.encode(creatorUID, forKey: .creatorUID)
        try container.encode(pinImage, forKey: .pinImage)
    }
    
    private func toHexString() -> String? {
        return color?.toHexString()
    }
}

extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
