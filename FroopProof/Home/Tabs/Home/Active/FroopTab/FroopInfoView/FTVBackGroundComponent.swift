//
//  FTVBackGroundComponent.swift
//  FroopProof
//
//  Created by David Reed on 5/5/23.
//

import SwiftUI
import UIKit


struct FTVBackGroundComponent: View {
    var db = FirebaseServices.shared.db
    @State private var typeName: String = ""
    var appStateManager: AppStateManager {
        return AppStateManager.shared
    }
    
    var body: some View {
        ZStack (alignment: .top){
            
            Image(backgroundImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: UIScreen.main.bounds.width)
                .scaleEffect(x: 1, y: -1)
                .offset(y: 785)
                .ignoresSafeArea(.all, edges: .bottom)
            
            Image(backgroundImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: UIScreen.main.bounds.width)
                .ignoresSafeArea()
                .padding(.top, -67)
           
            VStack{
                Text(AppStateManager.shared.appState == .active ? "It's a" : "")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .padding(.top, 100)
                    .shadow(radius: 10)
                   
                Text(appStateManager.froopTypes[appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopType ?? 1] ?? "")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                    .shadow(radius: 10)
                Spacer()
            }
           
            .toolbar{
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    
                }
            }
        }
    }
    
    func backgroundImage() -> String {
        let froopType = appStateManager.currentFilteredFroopHistory[safe: appStateManager.aFHI]?.froop.froopType
        switch froopType {
        case 1: return "Bar"
        case 2: return "BirthDay"
        case 3: return "DinnerParty"
        case 4: return "Golf1"
        case 5: return "Camping"
        case 6: return "F_bkg1"
        case 7: return "WinterSport"
        case 8: return "BeachDay"
        case 9: return "Bar2"
        case 10: return "Bar"
        case 11: return "DinnerParty"
        case 12: return "Concert"
        case 13: return "Karaoke"
        case 14: return "MovieNight"
        case 15: return "BurningMan"
        case 16: return "BurningMan"
        case 17: return "PoolParty2"
        case 18: return "Concert"
        case 19: return "Concert"
        case 20: return "BeachDay"
        case 21: return "PoolParty1"
        case 22: return "PoolParty2"
        case 23: return "DinnerParty"
        case 24: return "MovieNight"
        case 25: return "Karaoke"
        case 26: return "Concert"
        case 27: return "Background_Froop"
        default: return "BirthDay"
        }
    }
}

