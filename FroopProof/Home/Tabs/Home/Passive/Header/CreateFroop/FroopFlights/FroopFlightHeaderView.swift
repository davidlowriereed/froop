//
//  FroopFlightHeaderView.swift
//  FroopProof
//
//  Created by David Reed on 5/3/24.
//

import SwiftUI

struct FroopFlightHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    @ObservedObject var timeZoneManager = TimeZoneManager.shared
    @State private var formattedDateString: String = ""

    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 260)
                .foregroundColor(.white)
            
            VStack {
                
                VStack {
                    
                    HStack {
                        Text("\(froopManager.selectedFroopHistory.flightData.airline?.name ?? "") Airlines")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Spacer()
                        
                        HStack {
                            Text("Flight:")
                                .font(.system(size: 14))
                                .fontWeight(.regular)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            Text("\(froopManager.selectedFroopHistory.flightData.number ?? "")")
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Flight from")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .opacity(0.5)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Spacer()
                        
                        Text("Departing (\(timeZoneManager.timeZoneAbbreviation(from: froopManager.selectedFroopHistory.flightData.departure?.airport.localTimeZoneIdentifier ?? "")))")
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .opacity(0.5)
                            .padding(.bottom, 5)
                    }
                    .padding(.leading, 15)
                    .padding(.trailing, 15)

                    HStack (spacing: 5) {

                        Image(systemName: "airplane.departure")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Text(froopManager.selectedFroopHistory.flightData.departure?.airport.municipalityName ?? "")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Text("\(froopManager.selectedFroopHistory.flightData.departure?.airport.iata ?? "")")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .opacity(0.5)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                       Spacer()
                        
                        Text("\(timeZoneManager.formatTime(for: flightManager.dateFromUTCString(froopManager.selectedFroopHistory.flightData.departure?.scheduledTime.utc ?? "") ?? Date(), in: TimeZone(identifier: froopManager.selectedFroopHistory.flightData.departure?.airport.localTimeZoneIdentifier ?? "") ?? TimeZone.current)) ")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                    }
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    .padding(.bottom, 10)
                    
                    HStack {
                        Text("Destination")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .opacity(0.5)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Spacer()
                        
                        Text("Arriving (\(timeZoneManager.timeZoneAbbreviation(from: froopManager.selectedFroopHistory.flightData.arrival?.airport.localTimeZoneIdentifier ?? "")))")
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .opacity(0.5)
                            .padding(.bottom, 5)
                        
                    }
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    
                    HStack (spacing: 5) {
                        
                        Image(systemName: "airplane.arrival")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Text(froopManager.selectedFroopHistory.flightData.arrival?.airport.municipalityName ?? "")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Text("\(froopManager.selectedFroopHistory.flightData.arrival?.airport.iata ?? "")")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .opacity(0.5)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Spacer()
                        
                        Text("\(timeZoneManager.formatTime(for: flightManager.dateFromUTCString(froopManager.selectedFroopHistory.flightData.arrival?.scheduledTime.utc ?? "") ?? Date(), in: TimeZone(identifier: froopManager.selectedFroopHistory.flightData.arrival?.airport.localTimeZoneIdentifier ?? "") ?? TimeZone.current)) ")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                    }
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    Spacer()
                }
                .padding(.leading, UIScreen.screenWidth * 0.05)
                .padding(.trailing, UIScreen.screenWidth * 0.05)
                .padding(.top, UIScreen.screenHeight * 0.025)
                Divider()
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 50.25)
                    .foregroundColor(.gray)
                    .opacity(0.5)
                    .padding(.top, 180)
                    .offset(y: -0.25)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .padding(.top, 180)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    Text("\(formattedDateString)")
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "calendar.circle.fill")
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(froopManager.selectedFroopHistory.flightData.status == "Unknown" ? .blue : .green)
                        
                        Text("Scheduled")
                            .font(.system(size: 16))
                            .fontWeight(.regular)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    }
                }
                .padding(.top, 190)
                .padding(.leading, 25)
                .padding(.trailing, 25)
                .frame(height: 50)
            }
                  
        }
        .onAppear{
            formattedDateString = timeZoneManager.formatFlightDateDetail(passedDate: froopManager.selectedFroopHistory.froop.froopStartTime)
            
            let flightNumber = froopManager.selectedFroopHistory.flightData.number
            let date = flightManager.formatDateForJSON(date: froopManager.selectedFroopHistory.froop.froopStartTime)
            Task {
                await FroopFlightDataManager.shared.fetchAndUpdateFlightDetails(for: flightNumber ?? "", date: date, in: froopManager.selectedFroopHistory)
            }
        }
    }
}


struct ActiveFlightHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    @ObservedObject var timeZoneManager = TimeZoneManager.shared
    @State private var formattedDateString: String = ""
    @State private var arrivalTZ: String = ""
    @State private var departureTZ: String = ""

    var body: some View {
        ZStack {
            Rectangle()
                .frame(height: 260)
                .foregroundColor(.white)
            
            VStack {
                
                VStack {
                    
                    HStack {
                        Text("\(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.airline?.name ?? "") Airlines")
                            .font(.system(size: 18))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Spacer()
                        
                        HStack {
                            Text("Flight:")
                                .font(.system(size: 14))
                                .fontWeight(.regular)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            Text("\(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.number ?? "")")
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Flight from")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .opacity(0.5)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Spacer()
                        
                        Text("Departing (\(departureTZ))")
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .opacity(0.5)
                            .padding(.bottom, 5)
                    }
                    .padding(.leading, 15)
                    .padding(.trailing, 15)

                    HStack (spacing: 5) {

                        Image(systemName: "airplane.departure")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Text(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.departure?.airport.municipalityName ?? "")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Text("\(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.departure?.airport.iata ?? "")")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .opacity(0.5)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                       Spacer()
                        
                        Text("\(timeZoneManager.formatTime(for: flightManager.dateFromUTCString(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.departure?.scheduledTime.utc ?? "") ?? Date(), in: TimeZone(identifier: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.departure?.airport.localTimeZoneIdentifier ?? "") ?? TimeZone.current))")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                    }
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    .padding(.bottom, 10)
                    
                    HStack {
                        Text("Destination")
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .opacity(0.5)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Spacer()
                        
                        Text("Arriving (\(arrivalTZ))")
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.system(size: 12))
                            .fontWeight(.semibold)
                            .opacity(0.5)
                            .padding(.bottom, 5)
                        
                    }
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    
                    HStack (spacing: 5) {
                        
                        Image(systemName: "airplane.arrival")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Text(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.arrival?.airport.municipalityName ?? "")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Text("\(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.arrival?.airport.iata ?? "")")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .opacity(0.5)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                        Spacer()
                        
                        Text("\(timeZoneManager.formatTime(for: flightManager.dateFromUTCString(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.arrival?.scheduledTime.utc ?? "") ?? Date(), in: TimeZone(identifier: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.arrival?.airport.localTimeZoneIdentifier ?? "") ?? TimeZone.current)) ")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        
                    }
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    Spacer()
                }
                .padding(.leading, UIScreen.screenWidth * 0.05)
                .padding(.trailing, UIScreen.screenWidth * 0.05)
                .padding(.top, UIScreen.screenHeight * 0.025)
                Divider()
            }
            
            ZStack {
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 50.25)
                    .foregroundColor(.gray)
                    .opacity(0.5)
                    .padding(.top, 180)
                    .offset(y: -0.25)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                RoundedRectangle(cornerRadius: 0)
                    .frame(height: 50)
                    .foregroundColor(.white)
                    .padding(.top, 180)
                
                HStack {
                    Image(systemName: "calendar")
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    Text("\(formattedDateString)")
                        .font(.system(size: 16))
                        .fontWeight(.bold)
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: "calendar.circle.fill")
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.status == "Unknown" ? .blue : .green)
                        
                        Text(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.status ?? "")
                            .font(.system(size: 16))
                            .fontWeight(.regular)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    }
                }
                .padding(.top, 190)
                .padding(.leading, 25)
                .padding(.trailing, 25)
                .frame(height: 50)
            }
                  
        }
        .onAppear{
            formattedDateString = timeZoneManager.formatFlightDateDetail(passedDate: froopManager.selectedFroopHistory.froop.froopStartTime)
            
            let flightNumber = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.number
            let date = flightManager.formatDateForJSON(date: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopStartTime ?? Date())
            Task {
                await FroopFlightDataManager.shared.fetchAndUpdateFlightDetails(for: flightNumber ?? "", date: date, in: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI] ??
                                                                                FroopHistory(
                                                                                    froop: Froop(dictionary: [:]) ?? Froop(dictionary: [:]) ?? Froop.emptyFroop(),
                                                                                    host: UserData(),
                                                                                    invitedFriends: [],
                                                                                    confirmedFriends: [],
                                                                                    declinedFriends: [],
                                                                                    pendingFriends: [],
                                                                                    images: [],
                                                                                    videos: [],
                                                                                    froopGroupConversationAndMessages: ConversationAndMessages(conversation: Conversation(), messages: [], participants: []), froopMediaData: FroopMediaData(
                                                                                        froopImages: [],
                                                                                        froopDisplayImages: [],
                                                                                        froopThumbnailImages: [],
                                                                                        froopIntroVideo: "",
                                                                                        froopIntroVideoThumbnail: "",
                                                                                        froopVideos: [],
                                                                                        froopVideoThumbnails: []
                                                                                    ),
                                                                                    flightData: ScheduledFlightAPI.FlightDetail.empty()
                                                                                )
                )
            }
            arrivalTZ = getArrivalTZ()
            departureTZ = getDepartureTZ()
        }
        .onChange(of: appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData) {
            arrivalTZ = getArrivalTZ()
            departureTZ = getDepartureTZ()
        }
    }
    func getDepartureTZ() -> String {
        guard let timeZoneIdentifier = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.departure?.airport.localTimeZoneIdentifier else {
            return "Unknown Time Zone"
        }

        return timeZoneManager.timeZoneAbbreviation(from: timeZoneIdentifier)
    }

    
    func getArrivalTZ() -> String {
        guard let timeZoneIdentifier = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.arrival?.airport.localTimeZoneIdentifier else {
            return "Unknown Time Zone"
        }

        return timeZoneManager.timeZoneAbbreviation(from: timeZoneIdentifier)
    }

}


struct FroopSummaryFlightHeaderView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    @ObservedObject var timeZoneManager = TimeZoneManager.shared
    @State private var formattedDateString: String = ""

    var body: some View {
        
        VStack (alignment: .leading) {
            Text("FLIGHT DETAILS")
                .font(.system(size: 14))
                .fontWeight(.semibold)
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.9))
                .offset(y: 5)
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: UIScreen.screenWidth - 40, height: 260)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.25), lineWidth: 0.25)
                    )
                
                VStack {
                    
                    VStack {
                        
                        HStack {
                            Text("\(flightManager.flights[safe: 0]?.airline?.name ?? "") Airlines")
                                .font(.system(size: 18))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            
                            Spacer()
                            
                            HStack {
                                Text("Flight:")
                                    .font(.system(size: 14))
                                    .fontWeight(.regular)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                Text("\(flightManager.flights[safe: 0]?.number ?? "")")
                                    .font(.system(size: 18))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Flight from")
                                .font(.system(size: 12))
                                .fontWeight(.semibold)
                                .opacity(0.5)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            
                            Spacer()
                            
                            Text("Departing (\(timeZoneManager.timeZoneAbbreviation(from: flightManager.flights[safe: 0]?.departure?.airport.localTimeZoneIdentifier ?? "")))")
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .font(.system(size: 12))
                                .fontWeight(.semibold)
                                .opacity(0.5)
                                .padding(.bottom, 5)
                        }
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                        
                        HStack (spacing: 5) {
                            
                            Image(systemName: "airplane.departure")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            
                            Text(flightManager.flights[safe: 0]?.departure?.airport.municipalityName ?? "")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            
                            Text("\(flightManager.flights[safe: 0]?.departure?.airport.iata ?? "")")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .opacity(0.5)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            
                            Spacer()
                            
                            Text("\(timeZoneManager.formatTime(for: flightManager.dateFromUTCString(flightManager.flights[safe: 0]?.departure?.scheduledTime.utc ?? "") ?? Date(), in: TimeZone(identifier: flightManager.flights[safe: 0]?.departure?.airport.localTimeZoneIdentifier ?? "") ?? TimeZone.current)) ")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            
                        }
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                        .padding(.bottom, 10)
                        
                        HStack {
                            Text("Destination")
                                .font(.system(size: 12))
                                .fontWeight(.semibold)
                                .opacity(0.5)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            
                            Spacer()
                            
                            Text("Arriving (\(timeZoneManager.timeZoneAbbreviation(from: flightManager.flights[safe: 0]?.arrival?.airport.localTimeZoneIdentifier ?? "")))")
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .font(.system(size: 12))
                                .fontWeight(.semibold)
                                .opacity(0.5)
                                .padding(.bottom, 5)
                            
                        }
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                        
                        HStack (spacing: 5) {
                            
                            Image(systemName: "airplane.arrival")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            
                            Text(flightManager.flights[safe: 0]?.arrival?.airport.municipalityName ?? "")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            
                            Text("\(flightManager.flights[safe: 0]?.arrival?.airport.iata ?? "")")
                                .font(.system(size: 16))
                                .fontWeight(.bold)
                                .opacity(0.5)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            
                            Spacer()
                            
                            Text("\(timeZoneManager.formatTime(for: flightManager.dateFromUTCString(flightManager.flights[safe: 0]?.arrival?.scheduledTime.utc ?? "") ?? Date(), in: TimeZone(identifier: flightManager.flights[safe: 0]?.arrival?.airport.localTimeZoneIdentifier ?? "") ?? TimeZone.current)) ")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            
                        }
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                        Spacer()
                    }
                    .padding(.leading, UIScreen.screenWidth * 0.05)
                    .padding(.trailing, UIScreen.screenWidth * 0.05)
                    .padding(.top, UIScreen.screenHeight * 0.025)
                    Divider()
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 50.25)
                        .foregroundColor(.gray)
                        .opacity(0.5)
                        .padding(.top, 180)
                        .offset(y: -0.25)
                        .padding(.leading, 15)
                        .padding(.trailing, 15)
                    RoundedRectangle(cornerRadius: 0)
                        .frame(height: 50)
                        .foregroundColor(.white)
                        .padding(.top, 180)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.system(size: 20))
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        Text("\(formattedDateString)")
                            .font(.system(size: 16))
                            .fontWeight(.bold)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        Spacer()
                        
                        HStack {
                            Spacer()
                            
                            Image(systemName: "calendar.circle.fill")
                                .font(.system(size: 20))
                                .fontWeight(.semibold)
                                .foregroundColor(flightManager.flights[safe: 0]?.status == "Unknown" ? .blue : .green)
                            
                            Text("Scheduled")
                                .font(.system(size: 16))
                                .fontWeight(.regular)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        }
                    }
                    .padding(.top, 190)
                    .padding(.leading, 25)
                    .padding(.trailing, 25)
                    .frame(height: 50)
                }
                
            }
        }
        .frame(width: UIScreen.screenWidth - 40, height: 290)
        .onAppear{
            formattedDateString = timeZoneManager.formatFlightDateDetail(passedDate: froopData.froopStartTime)
        }
    }
}
