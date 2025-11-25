//
//  UserInfoView.swift
//  FroopProof
//
//  Created by David Reed on 2/23/23.
//

import SwiftUI
import iPhoneNumberField

struct UserInfoView: View {
    
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var navLocationServices = NavLocationServices.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
 
    
    @ObservedObject var myData = MyData.shared
    var body: some View {
        VStack {
            Text("Name: \(MyData.shared.firstName) \(MyData.shared.lastName)")
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
            iPhoneNumberField("Phone Number:", text: $myData.phoneNumber)
            Text("toUserInfo: \(MyData.shared.froopUserID)")
            
        }
    }
}
