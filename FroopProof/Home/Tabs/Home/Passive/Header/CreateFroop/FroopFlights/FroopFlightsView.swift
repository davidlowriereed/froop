//
//  FroopFlightsView.swift
//  FroopProof
//
//  Created by David Reed on 4/12/24.
//

import SwiftUI
import Combine
import MapKit
import CoreLocation


struct FroopFlightsView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var changeView = ChangeView.shared
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    @ObservedObject var timeZoneManager = TimeZoneManager.shared
    
    @State private var keyboard: UIKeyboardType = .default
    @State var currentFocus: TextFieldFocus = .none
    @State private var showInvalidFlightAlert = false
    @State var animationAmount = 1.0
    @State private var isEditing = false
    
    var onFroopNamed: (() -> Void)?
    
    var body: some View {
        
        ZStack {
            BackgroundLayer()
            
            FlightDataDisplay()
        }
        //        .padding(.top, UIScreen.screenHeight * 0.075)
        .modifier(KeyboardAdaptive())
        .alert(isPresented: $flightManager.showAlert) {
            Alert(title: Text("Error"), message: Text(flightManager.errorMessage), dismissButton: .default(Text("OK")))
        }
    }
}


private func formatDateForJSON(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.timeZone = TimeZone.current
    return dateFormatter.string(from: date)
}

struct FlightDataDisplay: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    @ObservedObject var timeZoneManager = TimeZoneManager.shared
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var changeView = ChangeView.shared
    
    @FocusState private var focusedField: FieldFocus?
    @FocusState private var enumFlightCarrier: Bool
    @FocusState private var enumFlightNum: Bool
    @FocusState private var enumAirport: Bool
    
    var body: some View {
        Rectangle()
            .foregroundColor(flightManager.showFlightData ? .black : .clear)
            .opacity(0.25)
        
        VStack(spacing: 20) {
            VStack() {
                Text("FLIGHT DETIALS")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.white.opacity(1))
                HStack {
                    Text(flightManager.flightCarrier.count == 2 && flightManager.flightSearchResults == [] ? "UNRECOGNIZED" : "FLIGHT NUMBER \(flightManager.flightNumberText)")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.75))
                        .padding(.top, UIScreen.screenHeight * 0.01)
                    Spacer()
                }
                ZStack {
                    HStack(spacing: UIScreen.screenWidth * 0.01 ) {
                        Spacer()
                        ZStack {
                            TextField("", text: $flightManager.flightCarrier)
                                .keyboardType(.default)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: 24))
                                .multilineTextAlignment(.center)
                                .fontWeight(.light)
                                .focused($enumFlightCarrier)
                                .onReceive(Just(flightManager.flightCarrier)) { newValue in
                                    let filtered = newValue.uppercased().filter { "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".contains($0) }
                                    if filtered != newValue || filtered.count > 2 {
                                        self.flightManager.flightCarrier = String(filtered.prefix(2))
                                    }
                                }
                                .onChange(of: flightManager.flightCarrier.count) { oldValue, newValue in
                                    if newValue < 2 {
                                        flightManager.list1Manage = false
                                    }
                                }
                                .frame(width: UIScreen.screenWidth * 0.19)
                            Text("AA")
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: 18))
                                .foregroundStyle(flightManager.flightCarrier == "" ? Color.gray.opacity(0.75) : .clear)
                                .fontWeight(.light)
                                .frame(width: UIScreen.screenWidth * 0.19)
                                .onAppear {
                                    enumFlightCarrier = true
                                }
                        }
                        
                        ZStack(alignment: .leading) {
                            TextField("", text: $flightManager.flightNum)
                                .keyboardType(.numberPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .font(.system(size: 24))
                                .fontWeight(.light)
                                .focused($enumFlightNum)
                                .frame(width: UIScreen.screenWidth * 0.6)
                            VStack (alignment: .leading) {
                                Text("0000")
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .font(.system(size: 18))
                                    .multilineTextAlignment(.leading)
                                    .foregroundStyle(flightManager.flightCarrier == "" ? Color.gray.opacity(0.75) : .clear)
                                    .fontWeight(.light)
                                    .frame(width: 75)
                            }
                        }
                        Spacer()
                    }
                    RoundedRectangle(cornerRadius: 5)
                        .background(.clear)
                        .foregroundColor(.clear)
                        .frame(height: 50)
                        .border(Color(red: 33/255, green: 31/255, blue: 39/255))
                }
                .onTapGesture {
                    flightManager.list1Manage = true
                    flightManager.flightNum = ""
                    flightManager.showDestination = false
                    enumFlightCarrier = true
                    flightManager.flightCarrier = ""
                    flightManager.flightNumberText = ""
                    flightManager.flightCarrierText = ""
                    flightManager.arrivalAirportText = ""
                    flightManager.arrivalAirport = ""
                    flightManager.disableAirportText = false
                    flightManager.airportSearchResults = []
                    
                }
                .onChange(of: flightManager.flightCarrier) { oldValue, newValue in
                    withAnimation(.easeInOut(duration: 0.5)) {
                        if newValue.count == 2 {  // Start searching from 2 characters
                            flightManager.flightSearchResults = flightManager.airlineCodes.searchAirlines(query: newValue)
                        } else {
                            flightManager.flightSearchResults = []
                        }
                    }
                }
                .onChange(of: flightManager.flightNum) { oldValue, newValue in
                    if newValue.count >= 4 {
                        enumAirport = true
                        flightManager.list2Manage = false
                    }
                }
                
                if flightManager.flightNum != "" {
                    HStack {
                        Spacer()
                        FlightFetchButton(flightManager: flightManager, timeZoneManager: timeZoneManager, froopData: froopData)
                            .padding(.trailing, 25)
                    }
                }
                
                if !flightManager.flightSearchResults.isEmpty && !flightManager.list1Manage {
                    ScrollView(showsIndicators: false) {
                        ForEach(flightManager.flightSearchResults, id: \.self) { result in
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(height: 50)
                                    .background(.clear)
                                
                                Text(result)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .font(.system(size: 18))
                                    .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : .white)
                                    .background(Color.clear)
                            }
                            .padding(.bottom, 1)
                            .frame(maxHeight: 65)
                            .onTapGesture {
                                enumFlightCarrier = false
                                enumFlightNum = true
                                flightManager.flightNumberText = String(result)
                                flightManager.list1Manage = true
                            }
                        }
                    }
                    .frame(minHeight: 0, maxHeight: 200) // Control the height of the drop-down list
                    .transition(.flipFromBottom(duration: 0.25).combined(with: .opacity))
                    .animation(.easeOut, value: flightManager.flightSearchResults.isEmpty)
                    .background(Color.clear)
                    
                }
                
            }
            .padding(.top, UIScreen.screenHeight * 0.05)
            
            VStack() {
                HStack {
                    Text("DESTINATION: \(flightManager.arrivalAirportText)")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.white.opacity(0.75))
                    Spacer()
                }
                
                TextField("Enter Airport", text: $flightManager.arrivalAirport)
                    .keyboardType(.default)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.system(size: 24))
                    .fontWeight(.light)
                    .focused($enumAirport)
                    .frame(width: UIScreen.screenWidth * 0.8, height: 40)
                    .disabled(flightManager.disableAirportText)
                    .onReceive(Just(flightManager.arrivalAirport)) { newValue in
                        let filtered = newValue.uppercased()
                        if filtered != newValue {
                            self.flightManager.arrivalAirport = filtered
                        }
                    }
                    .onChange(of: flightManager.arrivalAirport) { oldValue, newValue in
                        withAnimation(.easeInOut(duration: 0.5)) {
                            if newValue.count >= 3 {
                                flightManager.airportSearchResults = flightManager.airportCodes.searchAirports(query: newValue)
                            } else {
                                flightManager.airportSearchResults = []
                            }
                            if newValue.count == 0 {
                                flightManager.arrivalAirportText = ""
                            }
                            
                        }
                    }
                
                if !flightManager.airportSearchResults.isEmpty && flightManager.list1Manage == false {
                    ScrollView(showsIndicators: false) {
                        ForEach(flightManager.airportSearchResults, id: \.self) { airport in
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .background(.clear)
                                
                                Text(airport)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(.white)
                                    .background(Color.clear)
                            }
                            .padding(.bottom, 1)
                            .frame(width: UIScreen.screenWidth * 0.8, height: 40)
                            .frame(maxHeight: 45)
                            .onTapGesture {
                                flightManager.flightNumber = "\(flightManager.flightCarrier)\(flightManager.flightNum)"
                                flightManager.arrivalAirport = String(airport.prefix(3))
                                flightManager.arrivalAirportText = String(airport)
                                flightManager.list2Manage = true
                                flightManager.disableAirportText = true
                                print("Flight Number: \(flightManager.flightNumber)")
                                //                                    print("Date: \(flightManager.formatDateForJSON(date: flightManager.froopData.froopStartTime))")
                                print("Destination: \(flightManager.arrivalAirport)")
                            }
                        }
                    }
                    .frame(maxHeight: UIScreen.screenHeight * 0.2)  // Limiting the size of the dropdown
                    .transition(.flipFromBottom(duration: 0.25).combined(with: .opacity))
                    .animation(.easeOut, value: flightManager.airportSearchResults.isEmpty)
                }
            }
            .onChange(of: flightManager.flightNum) { oldValue, newValue in
                if newValue.count > 0 {
                    withAnimation(.smooth) {
                        flightManager.showDestination = false
                    }
                } else {
                    flightManager.showDestination = false
                }
            }
            .opacity(flightManager.showDestination ? 1 : 0)
            .padding(.top, 0)
            .background(.clear)
            
            Spacer()
        }
        .frame(width: UIScreen.screenWidth * 0.8)
        .padding(.leading, UIScreen.screenWidth * 0.01)
        .padding(.trailing, UIScreen.screenWidth * 0.01)
        .blur(radius: flightManager.showFlightData ? 5 : 0)
        
        if flightManager.showFlightData {
            VStack {
                if flightManager.showFlightData {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(.offWhite)
                            .onTapGesture {
                                print("Printing Departure Date")
                                print(flightManager.dateFromUTCString(flightManager.flights[safe: 0]?.departure?.scheduledTime.utc ?? "") as Any)
                                print("Printing Arrival Date")
                                print(flightManager.dateFromUTCString(flightManager.flights[safe: 0]?.arrival?.scheduledTime.utc ?? "") as Any)
                            }
                        
                        VStack {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(flightManager.flights[0].departure?.airport.iata ?? "")
                                        .font(.system(size: 32))
                                        .fontWeight(.bold)
                                    Text(flightManager.flights[0].departure?.airport.municipalityName ?? "")
                                }
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .padding(.leading, 20)
                                
                                Spacer()
                                
                                VStack(alignment: .center) {
                                    Image(systemName: "airplane.departure")
                                        .foregroundColor(Color(red: 100/255, green: 155/255, blue: 255/255))
                                        .font(.system(size: 24))
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing) {
                                    Text(flightManager.flights[0].arrival?.airport.iata ?? "")
                                        .font(.system(size: 32))
                                        .fontWeight(.bold)
                                    Text(flightManager.flights[0].arrival?.airport.municipalityName ?? "")
                                }
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .padding(.trailing, 20)
                            }
                            .padding(.top, 25)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text("\(flightManager.flights[0].airline?.name ?? "") Airlines")
                                            .font(.system(size: 20))
                                            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                        
                                        Spacer()
                                        
                                        Text(flightManager.flights[0].number ?? "")
                                            .font(.system(size: 16))
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                                    }
                                    Text(flightManager.flights[0].aircraft?.model ?? "Unknown Aircraft Model")
                                        .font(.system(size: 14))
                                        .fontWeight(.regular)
                                }
                                .frame(height: 35)
                                
                            }
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .padding(.top, 10)
                            .padding(.leading, 20)
                            .padding(.trailing, 20)
                            
                            HStack {
                                Spacer()
                                VStack {
                                    Text(String(describing: flightManager.dateFromUTCString(flightManager.flights[safe: 0]?.departure?.scheduledTime.utc ?? "")))
                                    Text(String(describing: flightManager.flights[safe: 0]?.departure?.airport.localTimeZoneIdentifier ?? ""))
                                    Text(String(describing: flightManager.dateFromUTCString(flightManager.flights[safe: 0]?.arrival?.scheduledTime.utc ?? "")))
                                }
//                                Text(timeZoneManager.formatDate(for: froopData.froopStartTime, in: nil, formatType: DateForm.froopFlightView))

                                Spacer()
                            }
                            .padding(.top, 20)
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Departing")
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                    
                                    Text("\(timeZoneManager.formatTime(for: flightManager.dateFromUTCString(flightManager.flights[safe: 0]?.departure?.scheduledTime.utc ?? "") ?? Date(), in: TimeZone(identifier: flightManager.flights[safe: 0]?.departure?.airport.localTimeZoneIdentifier ?? "") ?? TimeZone.current))")
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(red: 100/255, green: 155/255, blue: 255/255))

                                    Text("\(timeZoneManager.timeZoneAbbreviation(from: flightManager.flights[safe: 0]?.departure?.airport.localTimeZoneIdentifier ?? ""))")
                                        .font(.system(size: 12))
                                        .fontWeight(.regular)
                                    
                                }
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .padding(.leading, 20)
                                
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 5) {
                                    Text("Arriving")
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                    
                                    Text("\(timeZoneManager.formatTime(for: flightManager.dateFromUTCString(flightManager.flights[safe: 0]?.arrival?.scheduledTime.utc ?? "") ?? Date(), in: TimeZone(identifier: flightManager.flights[safe: 0]?.arrival?.airport.localTimeZoneIdentifier ?? "") ?? TimeZone.current))")
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                        .foregroundColor(Color(red: 100/255, green: 155/255, blue: 255/255))
                                    
                                    Text("\(timeZoneManager.timeZoneAbbreviation(from: flightManager.flights[safe: 0]?.arrival?.airport.localTimeZoneIdentifier ?? ""))")
                                        .font(.system(size: 12))
                                        .fontWeight(.regular)
                                    
                                }
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .padding(.trailing, 20)
                                .onAppear {
                                    if let departure = flightManager.flights.first?.departure,
                                       let arrival = flightManager.flights.first?.arrival {
                                        timeZoneManager.updateTimeZonesForFlight(
                                            departureLat: departure.airport.location.lat,
                                            departureLon: departure.airport.location.lon,
                                            arrivalLat: arrival.airport.location.lat,
                                            arrivalLon: arrival.airport.location.lon,
                                            apiKey: Secrets.googleTimeZoneAPI
                                        ) { departingTimeZone, arrivingTimeZone, error in
                                            if let error = error {
                                                print("Error updating time zones: \(error)")
                                                return
                                            }
                                            DispatchQueue.main.async {
                                                flightManager.flights[0].departure?.airport.localTimeZoneIdentifier = departingTimeZone?.timeZoneId
                                                flightManager.flights[0].arrival?.airport.localTimeZoneIdentifier = arrivingTimeZone?.timeZoneId
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, 10)
                            
                            Spacer()
                            
                            VStack (spacing: 2) {
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .padding(.leading, 5)
                                    .padding(.trailing, 5)
                                    .padding(.top, 25)
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .padding(.leading, 25)
                                    .padding(.trailing, 25)
                            }
                            .opacity(0.5)
                            
                            Spacer()
                            
                            HStack {
                                VStack(alignment: .center) {
                                    Text("Is this your Flight?")
                                        .font(.system(size: 22))
                                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                        .fontWeight(.bold)
                                }
                            }
                            .padding(.top, 10)
                            
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: UIScreen.screenWidth * 0.25, height: 50)
                                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    
                                    Text("Change")
                                        .font(.system(size: 16))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .onTapGesture {
                                    flightManager.showFlightData = false
                                }
                                
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: UIScreen.screenWidth * 0.25, height: 50)
                                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    
                                    Text("Yes")
                                        .font(.system(size: 16))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .onTapGesture {
                                    froopData.flightData = flightManager.flights[0]
                                    froopData.froopName = "Pick up \(MyData.shared.firstName) from Airport"
                                    froopData.froopLocationtitle = flightManager.locDerivedTitle ?? ""
                                    froopData.froopLocationsubtitle = flightManager.locDerivedSubtitle ?? ""
                                    froopData.froopLocationCoordinate = CLLocationCoordinate2D(latitude: flightManager.flights[0].arrival?.airport.location.lat ?? 0.0, longitude: flightManager.flights[0].arrival?.airport.location.lon ?? 0.0)
                                    froopData.froopStartTime = flightStartTime() ?? Date()
                                    froopData.froopEndTime = flightEndTime() ?? Date()
                                    froopData.froopDuration = flightDuration() ?? 1
                                    print("FroopData.locationTitle: \(froopData.froopLocationtitle)")
                                    print("FroopData.locationSubtitle: \(froopData.froopLocationsubtitle)")
                                    print("Flight Details: \(String(describing: froopData.flightData))")
                                    print(froopData.froopLocationCoordinate)


                                    changeView.pageNumber = 4
                                    
                                }
                                
                            }
                            .padding(.top, 15)
                            .padding(.leading, 50)
                            .padding(.trailing, 50)
                            .padding(.bottom, 50)
                            
                            Spacer()
                        }
                    }
                    .frame(width: UIScreen.screenWidth * 0.8, height: UIScreen.screenHeight * 0.45)
                    
                }
                Spacer()
            }
            .padding(.top, UIScreen.screenHeight * 0.15)
        }
    }
    
    func flightStartTime() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mmZ"
        formatter.timeZone = TimeZone(identifier: "UTC")
        
        guard let departureDate = formatter.date(from: self.flightManager.flights[0].departure?.scheduledTime.utc ?? "") else {
            print("Error parsing dates")
            return nil
        }
        return departureDate - 7200
    }
    
    func flightEndTime() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mmZ"
        formatter.timeZone = TimeZone(identifier: "UTC")

        guard let arrivalDate = formatter.date(from: self.flightManager.flights[0].arrival?.scheduledTime.utc ?? "") else {
            print("Error parsing dates")
            return nil
        }
        return arrivalDate + 7200
    }
    
    func flightDuration() -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mmZ"
        
        guard let departureDate = formatter.date(from: self.flightManager.flights[0].departure?.scheduledTime.utc ?? ""),
              let arrivalDate = formatter.date(from: self.flightManager.flights[0].arrival?.scheduledTime.utc ?? "") else {
            print("Error parsing dates")
            return nil
        }
        let durationSeconds = arrivalDate.timeIntervalSince(departureDate)
        return Int(durationSeconds + 7200)
    }
    
    func formattedFlightDuration() -> String {
        guard let duration = self.flightDuration() else {
            return "Duration unavailable"
        }
        
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
}

struct FlightFetchButton: View {
    @ObservedObject var flightManager: FroopFlightDataManager
    @ObservedObject var timeZoneManager: TimeZoneManager
    @ObservedObject var froopData: FroopData

    var body: some View {
        Button(action: fetchFlightsAndUpdateTimezone, label: {
            Text("Find Flight")
                .padding()
                .background(flightManager.flightNum.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
                .disabled(flightManager.flightNum.isEmpty)
        })
        .padding(.top, 20)
    }

    private func fetchFlightsAndUpdateTimezone() {
        flightManager.flightNumber = "\(flightManager.flightCarrier)\(flightManager.flightNum)"
        Task {
            do {
                let flights = try await flightManager.fetchFlightDetails(for: flightManager.flightNumber, date: formatDateForJSON(date: froopData.froopStartTime))
                print("⏱️⏱️\(froopData.froopStartTime)")
                print("⏱️ \(formatDateForJSON(date: froopData.froopStartTime))")
                let updatedFlights = await updateFlightDetailsWithTimezone(flights: flights)
                flightManager.flights = updatedFlights
                print(String(describing: updatedFlights))
            } catch {
                print("An error occurred while fetching flights or updating time zones: \(error.localizedDescription)")
            }
        }
    }

    private func updateFlightDetailsWithTimezone(flights: [ScheduledFlightAPI.FlightDetail]) async -> [ScheduledFlightAPI.FlightDetail] {
        let updatedFlights = flights
        for i in 0..<flights.count {
            let departure = flights[i].departure?.airport
            let arrival = flights[i].arrival?.airport
            let departureTimeZone = await timeZoneManager.fetchTimeZone(latitude: departure?.location.lat ?? 0.0, longitude: departure?.location.lon ?? 0.0)
            let arrivalTimeZone = await timeZoneManager.fetchTimeZone(latitude: arrival?.location.lat ?? 0.0, longitude: arrival?.location.lon ?? 0.0)
            updatedFlights[i].departure?.airport.localTimeZoneIdentifier = departureTimeZone?.identifier ?? TimeZone.current.identifier
            updatedFlights[i].arrival?.airport.localTimeZoneIdentifier = arrivalTimeZone?.identifier ?? TimeZone.current.identifier
        }
        return updatedFlights
    }
}


struct BackgroundLayer: View {
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    @ObservedObject var froopData = FroopData.shared
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
            VStack {
                Rectangle()
                    .foregroundColor(Color(red: 0/255, green: 0/255, blue: 0/255))
                Spacer()
            }
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(Color(red: 33/255, green: 31/255, blue: 39/255))
                    .frame(height: UIScreen.screenHeight * 0.4)
                RoundedRectangle(cornerRadius: 25)
                    .foregroundColor(Color(red: 48/255, green: 46/255, blue: 55/255))
                    .frame(height: UIScreen.screenHeight * 0.6)
            }
        }
    }
}

struct FlightAnnotationView: View {
    
    var body: some View {
        
        Image(systemName: "airplane")
            .font(.system(size: 24))
            .foregroundColor(.white)
        
    }
}


struct AirportAnnotationArrivalView: View {
    @ObservedObject var appStateManager = AppStateManager.shared
    
    @State var airport: ScheduledFlightAPI.AirportDetails

    var body: some View {
        VStack {
            Text(airport.name)
                .font(.caption)
                .foregroundColor(.white)
                .padding(5)
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(radius: 3)
            Image(systemName: "airplane")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.blue)
        }
        .padding(.top, 5)
        .onAppear {
            airport = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.arrival?.airport ?? ScheduledFlightAPI.AirportDetails.empty()
        }
    }
}

struct AirportAnnotationDepartureView: View {
    @ObservedObject var appStateManager = AppStateManager.shared
    
    @State var airport: ScheduledFlightAPI.AirportDetails

    var body: some View {
        VStack {
            Text(airport.name)
                .font(.caption)
                .foregroundColor(.white)
                .padding(5)
                .background(Color.blue)
                .cornerRadius(10)
                .shadow(radius: 3)
            Image(systemName: "airplane")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.red)
        }
        .padding(.top, 5)
        .onAppear {
            airport = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.flightData.departure?.airport ?? ScheduledFlightAPI.AirportDetails.empty()
        }
    }
}
