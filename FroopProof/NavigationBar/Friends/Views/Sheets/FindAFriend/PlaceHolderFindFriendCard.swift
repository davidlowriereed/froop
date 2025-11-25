//
//  PlaceHolderFindFriendCard.swift
//  FroopProof
//
//  Created by David Reed on 4/5/23.
//

//
//  textFriendOutsideFroop.swift
//  FroopProof
//
//  Created by David Reed on 3/12/23.
//

import SwiftUI
import UIKit
import Kingfisher
import MessageUI

struct PlaceHolderFindFriendCard: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
 
    
    var body: some View {
        ZStack (alignment: .top){
            RoundedRectangle(cornerRadius: 10)
                .frame(width: UIScreen.screenWidth * 0.9, height: 280)
                .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : .offWhite)
                .padding(.leading, 10)
                .padding(.trailing, 10)
            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 80))
                .frame(width: 150, height: 150)
                .padding(.leading, 10)
                .foregroundColor(colorScheme == .dark ? Color(.white) : Color(red: 50/255, green: 46/255, blue: 62/255))
                .opacity(0.85)
        }
        Spacer()
    }
}

