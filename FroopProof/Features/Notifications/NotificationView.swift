//
//  NotificationView.swift
//  FroopProof
//
//  Created by David Reed on 10/3/23.
//

import SwiftUI
import Kingfisher

struct NotificationView: View {
    @Binding var showNotificationSheet: Bool
    var body: some View {
        ZStack {
            HStack {
                KFImage(URL(string: MyData.shared.profileImageUrl))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(.circle)
                    
                
                VStack (alignment: .leading, spacing: 6, content: {
                    Text("User Name")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                    
                    Text("Hello, this is User Name")
                        .textScale(.secondary)
                        .foregroundColor(.white)
                })
                .padding(.top, 20)
                
                Spacer(minLength: 0)
                
                Button(action: {
                    showNotificationSheet.toggle()
                }, label: {
                    Image(systemName: "speaker.slash.fill")
                        .font(.title2)
                })
                .buttonStyle(.bordered)
                .buttonBorderShape(.circle)
                .tint(.white)
            }
            .padding(15)
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .fill(.ultraThinMaterial)
            }
        }
    }
}


