//
//  FroopLocationSummaryView.swift
//  FroopProof
//
//  Created by David Reed on 3/22/24.
//

import SwiftUI
import CoreLocation

struct FroopLocationSummaryView: View {
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var changeView = ChangeView.shared
    @ObservedObject var locationManager = LocationManager.shared
    @ObservedObject var myData = MyData.shared
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    
    var editable: Bool {
        if ChangeView.shared.froopTypeData?.viewPositions[1] != 0 {
            return true
        } else {
            return false
        }
    }


    var body: some View {
        VStack (alignment: .leading) {
            
            Text("ADDRESS")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.9))
//                .padding(.leading, 15)
                .offset(y: 5)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.white)
                    .opacity(0.8)
                    .frame(height: 75)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.25), lineWidth: 0.25)
                    )
//                    .padding(.leading, 15)
//                    .padding(.trailing, 15)
                
                HStack (spacing: 0 ){
                    Image(systemName: "mappin.and.ellipse")
                        .frame(width: 60, height: 60)
                        .scaledToFill()
                        .font(.system(size: 24))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
//                        .padding(.leading, 25)
                        .frame(alignment: .center)
                    
                        VStack (alignment: .leading) {
                            Text(changeView.addressAtMyLocation || froopData.froopType == 5009 ? changeView.locDerivedTitle ?? "Address Not Available" : froopData.froopLocationtitle)
                                .font(.system(size: 16))
                                .fontWeight(.medium)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .padding(.trailing, 25)
                            Text(changeView.addressAtMyLocation || froopData.froopType == 5009 ? changeView.locDerivedSubtitle ?? "" : froopData.froopLocationsubtitle)
                                .font(.system(size: 14))
                                .fontWeight(.light)
                                .lineLimit(2)
                                .minimumScaleFactor(0.5)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .lineLimit(2)
                                .padding(.trailing, 10)
                        }
                        Spacer()
                    }
                
            }
        }
        .onAppear {
            Task {
                if froopData.froopType == 5009 {
                    let (title, subtitle) = await flightManager.fetchAddressTitleAndSubtitle(for: CLLocationCoordinate2D(latitude: flightManager.flights[0].arrival?.airport.location.lat ?? 0.0, longitude: flightManager.flights[0].arrival?.airport.location.lon ?? 0.0))
                    await MainActor.run {
                        print("😏 Title:  \(String(describing: title))")
                        print("Title:  \(String(describing: subtitle))")

                        // This block is guaranteed to run on the main thread.
                        changeView.locDerivedTitle = title
                        changeView.locDerivedSubtitle = subtitle
                    }
                } else {
                    let (title, subtitle) = await myData.fetchAddressTitleAndSubtitle()
                    await MainActor.run {
                        // This block is guaranteed to run on the main thread.
                        changeView.locDerivedTitle = title
                        changeView.locDerivedSubtitle = subtitle
                    }
                }
            }
        }
        .frame(width: UIScreen.screenWidth - 40, height: 100)
        .onTapGesture {
            if editable {
                changeView.pageNumber = changeView.showLocation
            }
        }
    }
}

