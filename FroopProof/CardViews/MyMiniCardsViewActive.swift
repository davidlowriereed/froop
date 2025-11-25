//
//  MyCardsView.swift
//  FroopProof
//
//  Created by David Reed on 8/9/23.
//




import SwiftUI
import Kingfisher

struct MyMinCardsViewActive: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    @ObservedObject var froopManager = FroopManager.shared
    @ObservedObject var froopTypeStore = FroopTypeStore.shared
    @State private var previousAppState: AppState?
    @Binding var openFroop: Bool
    @State private var randomImage: String?

    let froopHistory: FroopHistory
    @State private var isBlinking = false
    @State private var iconName: String = ""
    
    private var cardHeight: CardHeight {
        if !openFroop {
            return .collapsed
        }
        
        switch froopHistory.froopStatus {
            case .invited:
                return .expandedInvite
            case .confirmed:
                return .expandedConfirmed
            case .declined, .archived, .memory:
                return .expandedArchived
            case .none:
                return .collapsed
        }
    }
    
    var cardBackgroundColor: LinearGradient {
        let isConfirmed = froopHistory.froopStatus == .confirmed
        let topColor = isConfirmed ? Color(red: 255/255, green: 255/255, blue: 255/255) : Color(red: 245/255, green: 245/255, blue: 245/255)
        let bottomColor = isConfirmed ? Color(red: 250/255, green: 250/255, blue: 250/255) : Color(red: 255/255, green: 255/255, blue: 255/255)
        
        return LinearGradient(gradient: Gradient(colors: [topColor, bottomColor]), startPoint: .top, endPoint: .bottom)
    }
    
    var body: some View {
        let windowWidth = UIScreen.screenWidth
    
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(cardBackgroundColor)
                .frame(width: windowWidth)
            
            if openFroop {
                froopHistory.cardForStatus(openFroop: $openFroop, invitedFriends: froopHistory.invitedFriends)
                    .padding(.bottom, 10)
            } else {
                
                VStack {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .background(RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.offWhite))
                                .frame(width: 55, height: 55)
                            
                            if let imageUrl = randomImage {
                                KFImage(URL(string: imageUrl))
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 55, height: 55)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } else {
                                Image(systemName: iconName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: 50, maxHeight: 50)
                                    .foregroundColor(froopHistory.colorForStatus())
                            }
                            
                            
                        }
                        VStack(alignment: .leading) {
                            HStack(alignment: .center) {
                                Text(froopHistory.froop.froopName)
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .multilineTextAlignment(.leading)
                                Spacer()
                                ZStack {
                                    if appStateManager.currentFilteredFroopHistory.contains(where: { $0.froop.froopId == froopHistory.froop.froopId }) {
                                        Text("IN PROGRESS")
                                            .font(.system(size: 12))
                                            .fontWeight(.semibold)
                                            .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                                            .opacity(isBlinking ? 0.0 : 1.0)
                                            .onChange(of: appStateManager.appState) { oldValue, newValue in
                                                withAnimation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                                                    self.isBlinking = true
                                                }
                                            }
                                    } else {
                                        Text(froopHistory.textForStatus())
                                            .font(.system(size: 14))
                                            .fontWeight(.semibold)
                                            .foregroundColor(froopHistory.colorForStatus())
                                            .multilineTextAlignment(.leading)
                                        
                                        if !froopHistory.froop.froopImages.isEmpty {
                                            Image(systemName: "camera.circle")
                                                .font(.system(size: 20))
                                                .fontWeight(.regular)
                                                .foregroundColor(froopHistory.colorForStatus())
                                                .multilineTextAlignment(.leading)
                                                .offset(y: 25)
                                        }
                                    }
                                }
                                .padding(.trailing, 15)
                            }
                            .offset(y: 0)
                            
                            HStack(alignment: .center) {
                                Text("Host:")
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .multilineTextAlignment(.leading)
                                
                                Text(froopHistory.host.firstName)
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .multilineTextAlignment(.leading)
                                
                                Text(froopHistory.host.lastName)
                                    .font(.system(size: 14))
                                    .fontWeight(.light)
                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                    .multilineTextAlignment(.leading)
                                    .offset(x: -5)
                            }
                            .offset(y: 6)
                            
                            Text(formatDate(for: froopHistory.froop.froopStartTime))
                                .font(.system(size: 14))
                                .fontWeight(.thin)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .multilineTextAlignment(.leading)
                                .padding(.top, 2)
                                .offset(y: -6)
                        }
                        .padding(.leading, 10)
                        .padding(.top, 5)
                        
                        Spacer()
                    }
                    .background(Color.clear)
                    .padding(.horizontal, 10)
                    .frame(maxHeight: 75)
                }
                
            }
        }
        .background(.white)
        .frame(width: windowWidth, height: cardHeight.height)
        .animation(.easeInOut(duration: 0.3), value: openFroop)
        .animation(.easeInOut(duration: 0.3), value: cardHeight)
        .onTapGesture {
            withAnimation(.spring()) {
                openFroop.toggle()
            }
        }
        .onAppear {
            if iconName.isEmpty {
                if let foundFroopType = froopTypeStore.froopTypes.first(where: { $0.id == froopHistory.froop.froopType }) {
                    self.iconName = foundFroopType.imageName
                } else {
                    self.iconName = "questionmark.circle" // fallback icon
                }
            }
            
            if !froopHistory.froop.froopThumbnailImages.isEmpty {
                self.randomImage = froopHistory.froop.froopThumbnailImages.randomElement()
            } else {
                self.randomImage = nil
            }
            print(String(describing: randomImage))
        }
    }

    func formatDate(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MMM.dd.yyyy 'at' h:mm a"
        return formatter.string(from: date)
    }
}
