//
//  NewFroopSummary.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI


struct FroopSummaryView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var formattedDateString: String = ""
    @State private var showMap = false
    
    var body: some View {
        ZStack{
            //MARK:  Background Layout Objects
            Rectangle()
                .foregroundColor(.clear)
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
            
            //MARK:  Backgrounds
            ZStack (alignment: .top) {
                
                //MARK: Full View Background
                VStack {
                    
                    Spacer()
                    
                    Rectangle()
                        .foregroundColor(.black)
                        .opacity(0.15)
                        .frame(height: UIScreen.main.bounds.height * 1.1)
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .ignoresSafeArea()
                
                //MARK:  Top Screen Background Bar
                VStack {
                    Rectangle()
                        .fill(Color.black)
                        .opacity(0.5)
                        .frame(height: UIScreen.main.bounds.height * 0.15 + 44 + 20)
                    Spacer()
                    
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .ignoresSafeArea()
                
            }
            .frame(minWidth: 0,maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
            //MARK: Content
            ZStack (alignment: .top){
                
                //MARK: Froop Content
                VStack (alignment: .center){
                    
                    //MARK:  Host Picture and Name
                    ZStack (alignment: .center){
                        VStack (alignment: .center) {
                            ZStack {
                                Circle()
                                    .frame(width: 128, height: 128, alignment: .center)
                                
                                Image(systemName: "Circle.fill")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 128, height: 128, alignment: .center)
                                    .clipShape(Circle())
                            }
                            .padding(.top, 35)
                            
                            HStack (alignment: .top){
                                Spacer()
                                Text("Host:")
                                    .font(.system(size: 18))
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                    .frame(alignment: .leading)
                                Text("David Reed")
                                    .font(.system(size: 18))
                                    .fontWeight(.light)
                                    .foregroundColor(.white)
                                    .frame(alignment: .leading)
                                Spacer()
                            }
                            .frame(width: 200)
                        }
                        .ignoresSafeArea(.keyboard)
                        .padding(.top, 25)
                        Spacer()
                    }
                    .padding(.bottom, 15)
                    
                    VStack {
                        //MARK: Title
                        VStack {
                            HStack {
                                Text("Tap section to make changes")
                                    .font(.system(size: 14))
                                    .fontWeight(.regular)
                                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                            }
                            Spacer()
                        }
                        .frame(height: 35)
                        
                        ZStack {
                            VStack {
                                VStack (alignment: .leading) {
                                    Text("FROOP TITLE")
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .padding(.leading, 15)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                            .frame(minHeight: 50, maxHeight: 100)
                                            .padding(.leading, 15)
                                            .padding(.trailing, 15)
                                        
                                        HStack (spacing: 0 ){
                                            Image(systemName: "t.circle")
                                                .frame(width: 60, height: 50)
                                                .scaledToFill()
                                                .font(.system(size: 24))
                                                .fontWeight(.medium)
                                                .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                                                .padding(.leading, 25)
                                                .frame(alignment: .center)
                                            Text("Back Yard Barbeque")
                                                .font(.system(size: 20))
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                                .lineLimit(2)
                                                .padding(.trailing, 25)
                                            Spacer()
                                        }
                                        .frame(maxWidth: 400, maxHeight: 50)
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: 400, maxHeight: 75)
                        .padding(.bottom, 15)
                        
                        
                        //MARK: Froop Date
                        
                        ZStack {
                            VStack {
                                VStack (alignment: .leading) {
                                    Text("DATE")
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .padding(.leading, 15)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                            .frame(height: 50)
                                            .padding(.leading, 15)
                                            .padding(.trailing, 15)
                                        
                                        VStack (alignment: .leading) {
                                            HStack (spacing: 0 ){
                                                Image(systemName: "clock")
                                                    .frame(width: 60, height: 50)
                                                    .scaledToFill()
                                                    .font(.system(size: 24))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                                                    .padding(.leading, 25)
                                                    .frame(alignment: .center)
                                                Text("Thursday, Oct 12, 9:00 PM")
                                                    .font(.system(size: 16))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.black)
                                                    .lineLimit(2)
                                                    .padding(.trailing, 25)
                                                Spacer()
                                            }
                                            .frame(maxWidth: 400, maxHeight: 50)
                                            
                                        }
                                    }
                                    .frame(maxWidth: 400, maxHeight: 75)
                                    .padding(.bottom, 15)
                                }
                            }
                        }
    
                        //MARK: Froop Location
                        ZStack {
                            VStack {
                                VStack (alignment: .leading) {
                                    Text("ADDRESS")
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .padding(.leading, 15)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                            .frame(height: 75)
                                            .padding(.leading, 15)
                                            .padding(.trailing, 15)
                                        VStack {
                                            HStack (spacing: 0 ){
                                                Image(systemName: "mappin.and.ellipse")
                                                    .frame(width: 60, height: 60)
                                                    .scaledToFill()
                                                    .font(.system(size: 24))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                                                    .padding(.leading, 25)
                                                    .frame(alignment: .center)
                                                VStack (alignment: .leading){
                                                    Text("Dana Hills High School")
                                                        .font(.system(size: 16))
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.black)
                                                        .padding(.trailing, 25)
                                                    Text("33333 Golden Lantern, Dana Point, CA 92629, United States")
                                                        .font(.system(size: 14))
                                                        .fontWeight(.light)
                                                        .foregroundColor(.black)
                                                        .lineLimit(2)
                                                        .padding(.trailing, 25)
                                                }
                                                Spacer()
                                            }
                                            .frame(maxWidth: 400, maxHeight: 75)
                                        
                                            
                                        }
                                    }
                                    .frame(maxWidth: 400, maxHeight: 75)
                                    .padding(.bottom, 15)
                                }
                            }
                        }
                       
                        
                      
                        
                        //MARK: Froop Duration
                        ZStack {
                            VStack {
                                VStack (alignment: .leading) {
                                    Text("DURATION")
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .padding(.leading, 15)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                            .frame(height: 50)
                                            .padding(.leading, 15)
                                            .padding(.trailing, 15)
                                        VStack {
                                            HStack (spacing: 0 ){
                                                Image(systemName: "hourglass.tophalf.filled")
                                                    .frame(width: 60, height: 50)
                                                    .scaledToFill()
                                                    .font(.system(size: 24))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                                                    .padding(.leading, 25)
                                                    .frame(alignment: .center)
                                                Text("Duration: 01 hour 00 min")
                                                    .font(.system(size: 16))
                                                    .fontWeight(.medium)
                                                    .foregroundColor(.black)
                                                    .lineLimit(2)
                                                    .padding(.trailing, 25)
                                                
                                                Spacer()
                                            }
                                            .frame(maxWidth: 400, maxHeight: 50)
                                        }
                                    }
                                    .frame(maxWidth: 400, maxHeight: 50)
                                    .padding(.bottom, 15)
                                }
                            }
                        }
                       
                   
                        
                        //MARK: Froop Type
                        ZStack {
                            VStack {
                                VStack (alignment: .leading) {
                                    Text("TYPE OF FROOP")
                                        .font(.system(size: 14))
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .padding(.leading, 15)
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .foregroundColor(.white)
                                            .frame(height: 50)
                                            .padding(.leading, 15)
                                            .padding(.trailing, 15)
                                        VStack {
                                            HStack (spacing: 0 ){
                                                    Image(systemName: "people.fill")
                                                        .frame(width: 60, height: 50)
                                                        .scaledToFill()
                                                        .font(.system(size: 24))
                                                        .fontWeight(.medium)
                                                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255 ))
                                                        .padding(.leading, 25)
                                                        .frame(alignment: .center)
                                                    Text("It's a Simple Gathering")
                                                        .font(.system(size: 16))
                                                        .fontWeight(.medium)
                                                        .foregroundColor(.black)
                                                        .lineLimit(2)
                                                        .padding(.trailing, 25)
                                                
                                                Spacer()
                                            }
                                            .frame(maxWidth: 400, maxHeight: 50)
                                        }
                                    }
                                    .frame(maxWidth: 400, maxHeight: 50)
                                    .padding(.bottom, 15)
                                }
                            }
                        }
                       
                   
                    }
                    
                    Spacer()
                    
                    //MARK: Save Froop Button
                    VStack {
                        HStack {
                            ZStack {
                                Rectangle()
                                    .foregroundColor(.clear)
                                    .frame(height: 75)
                                    .padding(.leading, 15)
                                    .padding(.trailing, 15)
                                Button {
                                    
                                } label: {
                                    Text("Save Froop")
                                        .font(.system(size: 28, weight: .thin))
                                        .foregroundColor(.white)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 225, height: 45)
                                        .border(Color.white, width: 0.25)
                                        .padding(.top)
                                }
                            }
                        }
                    }
                    
                }
                .padding(.bottom, 20)
            }
        }
    }
    
    func formatDuration(durationInSeconds: Int) -> String {
        let hours = durationInSeconds / 3600
        let minutes = (durationInSeconds % 3600) / 60

        let hourString = hours == 1 ? "hour" : "hours"
        let minuteString = minutes == 1 ? "min" : "min"

        return String(format: "%02d \(hourString) %02d \(minuteString)", hours, minutes)
    }

    func formatTime(creationTime: Date) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .hour, .day]
        formatter.unitsStyle = .abbreviated
        
        let currentTime = Date()
        let timeSinceCreation = currentTime.timeIntervalSince(creationTime)
        
        let formattedTime = formatter.string(from: timeSinceCreation) ?? ""
        
        return formattedTime
    }
}

#Preview {
    FroopSummaryView()
}

