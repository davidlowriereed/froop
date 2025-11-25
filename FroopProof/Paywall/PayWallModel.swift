//
//  PayWallModel.swift
//  FroopProof
//
//  Created by David Reed on 1/25/24.
//

import Foundation
import SwiftUI

class PaywallModel: ObservableObject, Codable {
    let id: UUID = UUID()
    @Published var title: String = ""
    @Published var subTitle: String = ""
    @Published var headerImage: String = ""
    @Published var stretchyHeader: Bool = false
    @Published var stickyHeader: Bool = false
    @Published var stickyHeaderTitle: String = ""
    @Published var points: [Point] = []
    @Published var reviews: [Review] = []
    @Published var showReviews: Bool = false
    @Published var showDefaultView: Bool = false
    
    static func == (lhs: PaywallModel, rhs: PaywallModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum CodingKeys: CodingKey {
        case id
        case title
        case subTitle
        case headerImage
        case stretchyHeader
        case stickyHeader
        case stickyHeaderTitle
        case points
        case reviews
        case showReviews
        case showDefaultView
    }
    
    var dictionary: [String: Any] {
        var dict = [String: Any]()
        dict["id"] = id.uuidString
        dict["title"] = title
        dict["subTitle"] = subTitle
        dict["headerImage"] = headerImage
        dict["stretchyHeader"] = stretchyHeader
        dict["stickyHeaderTitle"] = stickyHeaderTitle
        dict["points"] = points
        dict["reviews"] = reviews
        dict["showReviews"] = showReviews
        dict["showDefaultView"] = showDefaultView
        return dict
    }
    
    init(dictionary: [String: Any], froopUserID: String? = nil) {
        self.title = dictionary["title"] as? String ?? ""
        self.subTitle = dictionary["subTitle"] as? String ?? ""
        self.headerImage = dictionary["headerImage"] as? String ?? ""
        self.stretchyHeader = dictionary["stretchyHeader"] as? Bool ?? false
        self.stickyHeaderTitle = dictionary["stickyHeaderTitle"] as? String ?? ""
        self.points = dictionary["points"] as? [Point] ?? []
        self.reviews = dictionary["reviews"] as? [Review] ?? []
        self.showReviews = dictionary["showReviews"] as? Bool ?? false
        self.showDefaultView = dictionary["showDefaultView"] as? Bool ?? false
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String?.self, forKey: .title) ?? ""
        subTitle = try container.decode(String?.self, forKey: .subTitle) ?? ""
        headerImage = try container.decode(String?.self, forKey: .headerImage) ?? ""
        stretchyHeader = try container.decode(Bool?.self, forKey: .stretchyHeader) ?? false
        points = try container.decode([Point]?.self, forKey: .points) ?? []
        reviews = try container.decode([Review]?.self, forKey: .reviews) ?? []
        showReviews = try container.decode(Bool?.self, forKey: .showReviews) ?? false
        showDefaultView = try container.decode(Bool?.self, forKey: .showDefaultView) ?? false
    }
    
    func encode(to encoder: Encoder) throws {
        PrintControl.shared.printInviteFriends("-PaywallModel: Function: encode firing")
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(subTitle, forKey: .subTitle)
        try container.encode(headerImage, forKey: .headerImage)
        try container.encode(stretchyHeader, forKey: .stretchyHeader)
        try container.encode(points, forKey: .points)
        try container.encode(reviews, forKey: .reviews)
        try container.encode(showReviews, forKey: .showReviews)
        try container.encode(showDefaultView, forKey: .showDefaultView)
    }
    
    class Point: Identifiable, Codable {
        let id: UUID = .init()
        var symbol: String
        var content: String
        var color: String
        
        enum CodingKeys: CodingKey {
            case symbol
            case content
            case color
        }
        
        var colorValue: Color {
            switch color {
            case "Green":
                return .green
            case "Red":
                return .red
            case "Yellow":
                return .yellow
            case "Blue":
                return Color(red: 255/255, green: 49/255, blue: 97/255)
            case "Orange":
                return .orange
            case "Purple":
                return .purple
            case "Cyan" :
                return .cyan
            default:
                return .primary
            }
        }
    }
    
    class Review: Identifiable, Codable {
        let id: UUID = .init()
        var name: String
        var rating: Int
        var content: String
        
        enum CodingKeys: CodingKey {
            case name
            case rating
            case content
        }
    }
}
