//
//  Annotations.swift
//  FroopProof
//
//  Created by David Reed on 4/26/23.
//


import UIKit
import SwiftUI
import CoreLocation 
import MapKit
import Kingfisher


//struct FroopAnnotationViewS: View {
//    let froopPin: ApexAnnotationPin
//    @State private var froop: FroopData = FroopData()
//
//    var body: some View {
//        VStack {
//            if let froopHostUrl = froopPin.froopHostUrl {
//                KFImage(URL(string: froopHostUrl))
//                    .resizable()
//                    .frame(width: 60, height: 60)
//                    .clipShape(Circle())
//                    .overlay(Circle().stroke(Color(red: 249/255, green: 0/255, blue: 98/255), lineWidth: 3))
//            }
//            if let froopName = froopPin.froopName {
//                Text(froopName)
//                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
//                    .font(.system(size: 14, weight: .semibold))
//            }
//        }
//    }
//}

//struct GuestAnnotationViewS: View {
//    let guestPin: ApexAnnotationPin
//    @State private var user: UserData = UserData()
//
//    var body: some View {
//        VStack {
//            if let profileImageUrl = guestPin.profileImageUrl {
//                KFImage(URL(string: profileImageUrl))
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 40, height: 40)
//                    .clipShape(Circle())
//            }
//            if let name = guestPin.firstName {
//                Text(name)
//                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
//                    .font(.system(size: 14, weight: .semibold))
//            }
//        }
//    }
//}

//struct UserAnnotationViewS: View {
//    let guestPin: ApexAnnotationPin
//    @State private var guest: UserData = UserData()
//
//    var body: some View {
//        VStack {
//            if let profileImageUrl = guestPin.profileImageUrl {
//                KFImage(URL(string: profileImageUrl))
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 40, height: 40)
//                    .clipShape(Circle())
//            }
//            if let name = guestPin.firstName {
//                Text(name)
//                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
//                    .font(.system(size: 14, weight: .semibold))
//            }
//        }
//    }
//}

class ApexAnnotationPin: NSObject, Identifiable, MKAnnotation {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    var froopName: String?
    var froopHostUrl: String?
    var profileImageUrl: String?
    var firstName: String?
    var lastName: String?
    var froopUserID: String?
    var phoneNumber: String?
    var currentDistance: CLLocationDistance?
    var etaToFroop: TimeInterval?
    var pinType: PinType
    var title: String? {
        return froopName
    }
    var subtitle: String? {
        return froopHostUrl
    }

    enum PinType {
        case froopPin
        case userLocation
        case guestPin
    }

    init(coordinate: CLLocationCoordinate2D, pinType: PinType) {
        self.coordinate = coordinate
        self.pinType = pinType
    }

    static func == (lhs: ApexAnnotationPin, rhs: ApexAnnotationPin) -> Bool {
        return lhs.id == rhs.id
    }
}


class FroopAnnotationView: MKAnnotationView {
    var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupImageView()
    }
    
    func setupImageView() {
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        self.imageView.layer.masksToBounds = true
        self.addSubview(self.imageView)
    }
}

class GuestAnnotationView: MKAnnotationView {
    var imageView: UIImageView!
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.setupImageView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupImageView()
    }
    
    func setupImageView() {
        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.imageView.contentMode = .scaleAspectFill
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        self.imageView.layer.masksToBounds = true
        self.addSubview(self.imageView)
    }
}
