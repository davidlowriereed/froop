//
//  SaveAnnotationView.swift
//  FroopProof
//
//  Created by David Reed on 7/19/23.
//


import SwiftUI
import UIKit
import CoreLocation
import MapKit
import SwiftUIBlurView
import FirebaseFirestore


struct SaveAnnotationView: View {
    @ObservedObject var annotation: FroopDropPin
    var appStateManager = AppStateManager.shared
    let db = FirebaseServices.shared.db
    @State private var title: String
    @State private var subtitle: String
    @State private var messageBody: String
    @State private var creatorUID: String
    @State private var pinImage: String

    init(annotation: FroopDropPin) {
        self.annotation = annotation
        self._title = State(initialValue: annotation.title )
        self._subtitle = State(initialValue: annotation.subtitle )
        self._messageBody = State(initialValue: annotation.messageBody )
        self._creatorUID = State(initialValue: annotation.creatorUID )
        self._pinImage = State(initialValue: annotation.pinImage )
    }

    var body: some View {
        ZStack {
            VStack {
                Spacer()
                ZStack {
                    if appStateManager.isAnnotationMade {
                        BlurView(style: .light)
                            .edgesIgnoringSafeArea(.bottom)
                            .transition(.move(edge: .bottom))
                            .frame(height: 350)
                            .border(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.5), width: 0.5)
                            .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.3), radius: 20)


                    }
                    
                    VStack {
                        Spacer()
                        Rectangle()
                            .fill(Color(red: 50/255, green: 46/255, blue: 62/255).gradient)
                            .opacity(0.5)
                            .frame(height: 350)
                    }
                    VStack (alignment: .leading) {
                        HStack {
                            Text("Latitude: \(annotation.coordinate.latitude)")
                            Text("Longitude: \(annotation.coordinate.longitude)")
                        }
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                        .fontWeight(.light)
                        .padding(.top, 45)
                        .padding(.leading, 15)
                        
                        // Only the creator can edit the TextFields
                        if creatorUID == FirebaseServices.shared.uid {
                            TextField("Title", text: $title)
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .fontWeight(.regular)
                                .padding(.top, 10)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 20)
                                .disabled(creatorUID != FirebaseServices.shared.uid)
                                .background(.white)
                                .frame(width: 350, height: 40)
                                
                            TextField("Subtitle", text: $subtitle)
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .fontWeight(.regular)
                                .padding(.top, 10)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 20)
                                .disabled(creatorUID != FirebaseServices.shared.uid)
                                .background(.white)
                                .frame(width: 350, height: 40)

                            TextField("Message Here", text: $messageBody)
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .fontWeight(.regular)
                                .padding(.top, 10)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 20)
                                .disabled(creatorUID != FirebaseServices.shared.uid)
                                .background(.white)
                                .frame(width: 350, height: 40)
                        } else {
                            Text(title)
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .fontWeight(.regular)
                                .padding(.top, 10)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 20)
                                .disabled(creatorUID != FirebaseServices.shared.uid)
                                
                            Text(subtitle)
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                                .multilineTextAlignment(.leading)
                                .padding(.leading, 20)
                                .disabled(creatorUID != FirebaseServices.shared.uid)

                            Text(messageBody)
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                                .multilineTextAlignment(.leading)
                                .padding(.top, 1)
                                .padding(.leading, 20)
                                .disabled(creatorUID != FirebaseServices.shared.uid)
                        }

                        Spacer()
                    }
                }
            }
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            self.appStateManager.isAnnotationMade = false
                            self.appStateManager.isFroopTabUp = true
                        }
                    }) {
                        Image(systemName: "xmark.square")
                            .fontWeight(.light)
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                            .padding(.trailing, 10)
                            .padding(.top, 25)
                    }
                }
                Spacer()
                if creatorUID == FirebaseServices.shared.uid {
                    Button(action: saveAnnotation) {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.clear)
                                .border(.gray, width: 0.5)
                                .frame(width: 150, height: 30)
                            Text("Save Pin")
                                .font(.system(size: 16))
                                .foregroundColor(.white)
                                .fontWeight(.light)
                        }
                    }
                    .padding(.bottom, 75)
                } else {
                    EmptyView()
                }
            }
        }
        .frame(minHeight: 350, maxHeight: 350)
    }

    func saveAnnotation() {
        annotation.title = title.isEmpty ? "No Title" : title
        annotation.subtitle = subtitle.isEmpty ? "No Subtitle" : subtitle
        annotation.messageBody = messageBody.isEmpty ? "Message Here" : messageBody
        annotation.creatorUID = creatorUID.isEmpty ? FirebaseServices.shared.uid : creatorUID
        annotation.pinImage = pinImage.isEmpty ? "mappin" : pinImage
        
        let froopHost = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.host.froopUserID
        let froopId = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopId
        let collectionPath = "users/\(String(describing: froopHost))/myFroops/\(String(describing: froopId))/annotations"
        let docData: [String: Any] = [
            "title": annotation.title ,
            "subtitle": annotation.subtitle ,
            "messageBody": annotation.messageBody ,
            "coordinate": geoPoint(from: annotation.coordinate ),
            "creatorUID": annotation.creatorUID ,
            "profileImageUrl": annotation.pinImage 
        ]
        
        db.collection(collectionPath).addDocument(data: docData) { err in
            if let err = err {
                PrintControl.shared.printMap("Error adding document: \(err)")
            } else {
                annotation.lastUpdated = Date()
                PrintControl.shared.printMap("Document added.")
            }
        }
    }

    func geoPoint(from coordinate: CLLocationCoordinate2D) -> GeoPoint {
        return GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

