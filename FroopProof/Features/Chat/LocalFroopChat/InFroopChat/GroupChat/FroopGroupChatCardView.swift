


import SwiftUI

struct FroopGroupChatCardView: View {
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var froopManager = FroopManager.shared
    @Binding var chatViewOpen: Bool
    @Binding var selectedChatType: ChatType
    
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .frame(width: UIScreen.screenWidth, height: 80)
                    .foregroundColor(Color(red: 250/255, green: 250/255, blue: 250/255))
                HStack {
                    Image("pinkLogo")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.7)
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .padding(.leading, 15)
                    VStack (alignment: .leading) {
                        HStack {
                            Text("All Guests: \(appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopName ?? "")")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                                .padding(.top, 5)
                            Spacer()
                            Text(lastMessageTimestamp)
                                .font(.system(size: 16))
                                .fontWeight(.regular)
                                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                .opacity(/*@START_MENU_TOKEN@*/0.8/*@END_MENU_TOKEN@*/)
                            
                        }
                        Text(lastMessageText)
                            .font(.system(size: 18))
                            .fontWeight(.light)
                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .padding(.top, 3)
                    }
                    .padding(.leading, 10)
                    .padding(.trailing, 5)
                    Spacer()
                }
            }
        }
        .onTapGesture {
            selectedChatType = .group
            froopManager.chatViewOpen = true
            print(selectedChatType)
            print(chatViewOpen)
        }
    }
    
    var lastMessageText: String {
        let currentUserUID = FirebaseServices.shared.uid
        let currentFroopHistory = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]
        let otherMessages = currentFroopHistory?.froopGroupConversationAndMessages.messages.filter { $0.senderId != currentUserUID }
        return otherMessages?.sorted { $0.timestamp > $1.timestamp }.first?.text ?? "no messages..."
        }
    
    var lastMessageTimestamp: String {
        guard let lastMessage = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froopGroupConversationAndMessages.messages.sorted(by: { $0.timestamp > $1.timestamp }).first else {
                return ""
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "h:mm a" // e.g., 12:30 PM
            return dateFormatter.string(from: lastMessage.timestamp)
        }
}
