//
//  PinDetailsView.swift
//  Design_Layouts
//
//  Created by David Reed on 12/6/23.
//

import SwiftUI
import MapKit

struct PinDetailsView: View {
    @State var froopDropPin: FroopDropPin = FroopDropPin()
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Rectangle()
                    .foregroundColor(Color(.black).opacity(0.05))
                    .ignoresSafeArea()
               
                VStack (spacing: 0){
                    HStack {
                        Text("TITLE:")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .frame(width: UIScreen.screenWidth * 0.18, alignment: .leading)
                        TextField("Tap here to edit.", text: Binding(get: { froopDropPin.title ?? "" }, set: { froopDropPin.title = $0 }))
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                            .fontWeight(.light)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            .frame(width: .infinity)
                            .border(Color.black.opacity(0.25), width: 0.25)
                            .background(.white)
                    }
                    .padding(.bottom, 5)

                    HStack {
                        Text("SUBTITLE:")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .frame(width: UIScreen.screenWidth * 0.18, alignment: .leading)
                        TextField("Tap here to edit.", text: Binding(get: { froopDropPin.subtitle ?? "" }, set: { froopDropPin.subtitle = $0 }))
                            .font(.system(size: 18))
                            .foregroundColor(.black)
                            .fontWeight(.light)
                            .padding(.leading, 5)
                            .padding(.trailing, 5)
                            .border(Color.black.opacity(0.25), width: 0.25)
                            .background(.white)
                    }
                    .padding(.bottom, 5)

                    ZStack(alignment: .topLeading) {
                        HStack {
                            VStack {
                                Text("BODY:")
                                    .font(.system(size: 12))
                                    .foregroundColor(.black)
                                    .fontWeight(.bold)
                                    .frame(width: UIScreen.screenWidth * 0.18, alignment: .leading)
                                Spacer()
                            }
                            .padding(.top, 10)
                            TextEditor(text: Binding(get: { froopDropPin.messageBody ?? "" }, set: { froopDropPin.messageBody = $0 }))
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                                .padding(.top, 5)
                                .padding(.leading, 5)
                                .padding(.trailing, 5)
                                .padding(.bottom, 5)
                                .frame(height: UIScreen.main.bounds.height * 0.125)
                                .border(Color.black.opacity(0.25), width: 0.25)
                                .background(Color.white)
                            
                        }
                    }
                    
                    HStack {
                        Text("COLOR")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.top, UIScreen.screenHeight * 0.01)
                    
                    HStack {
                        Spacer()
                        Rectangle()
                            .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            .foregroundColor(.white)
                        Rectangle()
                            .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            .foregroundColor(.black)
                        Rectangle()
                            .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            .foregroundColor(.blue)
                        Rectangle()
                            .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            .foregroundColor(.green)
                        Rectangle()
                            .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            .foregroundColor(.yellow)
                        Rectangle()
                            .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            .foregroundColor(.red)
                        Rectangle()
                            .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            .foregroundColor(.orange)
                        Rectangle()
                            .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            .foregroundColor(.purple)

                        Spacer()
                    }
                    .padding(.top, UIScreen.screenHeight * 0.01)

                    HStack {
                        Text("ICON")
                            .font(.system(size: 12))
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.top, UIScreen.screenHeight * 0.01)
                    
                    HStack {
                        Spacer()
                        ZStack {
                            Rectangle()
                                .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            Image(systemName: "pin.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                        }
                        .onTapGesture {
                            froopDropPin.pinImage = "pin.fill"
                        }
                        ZStack {
                            Rectangle()
                                .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                        }
                        ZStack {
                            Rectangle()
                                .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            Image(systemName: "tent.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                        }
                        ZStack {
                            Rectangle()
                                .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            Image(systemName: "car.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                        }
                        ZStack {
                            Rectangle()
                                .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            Image(systemName: "balloon.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                        }
                        ZStack {
                            Rectangle()
                                .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            Image(systemName: "camera.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                        }
                        ZStack {
                            Rectangle()
                                .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            Image(systemName: "figure.run")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                        }
                        ZStack {
                            Rectangle()
                                .frame(width: UIScreen.screenHeight * 0.04, height: UIScreen.screenHeight * 0.04)
                            Image(systemName: "flame.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                        }
                        
                       
                        Spacer()
                    }
                    .padding(.top, UIScreen.screenHeight * 0.01)
                    Spacer()
                }
                .padding(.top, UIScreen.screenHeight * 0.035)
                .padding(.leading, UIScreen.screenWidth * 0.05)
                .padding(.trailing, UIScreen.screenWidth * 0.05)
                
                VStack {
                    HStack {
                        Spacer()
                            .frame(width: UIScreen.screenWidth * 0.2)
                        Text("ANNOTATION DETAILS")
                            .font(.system(size: 12))
                            .foregroundColor(Color(.black).opacity(0.1))
                            .fontWeight(.bold)
                            .frame(width: UIScreen.screenWidth * 0.5)

                        Spacer()
                        Text("Save")
                            .font(.system(size: 16))
                            .foregroundColor(Color(.blue).opacity(0.75))
                            .fontWeight(.bold)
                            .padding(.trailing, UIScreen.screenWidth * 0.05)
                            .frame(width: UIScreen.screenWidth * 0.2, alignment: .trailing)

                    }
                    .padding(.horizontal)
                    Spacer()
                }
                .padding(.top, 5)
            }
            .frame(height: UIScreen.screenHeight * 0.4)
        }
    }
}

#Preview {
    PinDetailsView()
}





class FroopDropPin: NSObject, Codable, ObservableObject, Identifiable {
    
    let id: UUID
    @Published var lastUpdated: Date
    @Published var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    @Published var title: String?
    @Published var subtitle: String?
    @Published var messageBody: String?
    @Published var color: UIColor?
    @Published var creatorUID: String?
    @Published var pinImage: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, messageBody, latitude, longitude, color, creatorUID, pinImage
    }
    
    init(coordinate: CLLocationCoordinate2D? = nil, title: String? = nil, subtitle: String? = nil, messageBody: String? = nil, color: UIColor? = nil, creatorUID: String? = nil, pinImage: String? = nil) {
        self.id = UUID()
        self.lastUpdated = Date()
        self.coordinate = coordinate ?? CLLocationCoordinate2D()
        self.title = title
        self.subtitle = subtitle
        self.messageBody = messageBody
        self.color = color
        self.creatorUID = creatorUID
        self.pinImage = pinImage
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
        title = try container.decode(String?.self, forKey: .title)
        subtitle = try container.decode(String?.self, forKey: .subtitle)
        messageBody = try container.decode(String?.self, forKey: .messageBody)
        let colorString = try container.decode(String?.self, forKey: .color)
        color = colorString.flatMap { UIColor(named: $0) }
        creatorUID = try container.decode(String?.self, forKey: .creatorUID)
        pinImage = try container.decode(String?.self, forKey: .pinImage)
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
