//
//  FroopTypeView.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import iPhoneNumberField
import Firebase
import FirebaseFirestore
import Foundation
import UIKit


struct FroopTypeView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var onboardingData = OnboardingData.shared
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    @ObservedObject var changeView = ChangeView.shared
//    @ObservedObject var froopData = FroopData.shared
    var onFroopNamed: (() -> Void)?
    @State private var showAlert = false
    @ObservedObject var froopTypeStore = FroopTypeStore.shared
    @Binding var searchText: String
    @State var selectedFroopType: FroopType?
    @State var selectedTopic: String? = nil
    var genericFroopType: Array = [1,2,3,4,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    let db = FirebaseServices.shared.db
    
    var body: some View {
        ZStack {
            Color.offWhite
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .font(.system(size: 18))
                    Text("Froop Types with Black Icons are Generic")
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                    Spacer()

                }
                HStack {
                    Image(systemName: "circle.fill")
                        .foregroundColor(Color(red: 249/255, green: 0/255, blue: 98/255))
                        .font(.system(size: 18))
                    Text("Froop Types with Pink Icons have Custom Rules")
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .font(.system(size: 14))
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
            .padding(.bottom, 50)
            .padding(.leading, 25)
            
            VStack {
                ScrollView (showsIndicators: false) {
                    VStack(spacing: 10) {
                        ForEach(
                            froopTypeStore.froopTypes
                                .filter { froopType in
                                    // Check for topics only if searchText is empty.
                                    if searchText.isEmpty {
                                        if let topics = selectedTopic {
                                            return froopType.category.contains(topics)
                                        } else {
                                            return froopType.category.contains("Return to Topics")
                                        }
                                    } else {
                                        // Ignore topics if searchText is not empty.
                                        return true
                                    }
                                }
                                .sorted(by: { $0.order.lowercased() < $1.order.lowercased() })
                                .filter { froopType in
                                    searchText.isEmpty ? true : froopType.name.localizedCaseInsensitiveContains(searchText)
                                }
                                .chunked(into: 3), id: \.self[0].id
                        ) { froopTypeGroup in
                            HStack(spacing: 10) {
                                ForEach(froopTypeGroup, id: \.id) { froopType in
                                    VStack {
                                        Image(systemName: froopType.imageName)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(maxWidth: 100, maxHeight: 100)
                                            .foregroundColor(froopType.viewPositions == genericFroopType ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 249/255, green: 0/255, blue: 98/255))
                                            .padding(.top, 20)
                                            .padding(.trailing, 20)
                                            .padding(.leading, 20)
                                        Text(froopType.name)
                                            .font(.system(size: 12))
                                            .fontWeight(.medium)
                                            .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                                            .padding(5)
                                            .padding(.bottom, 10)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(minWidth: 100, maxWidth: 120, minHeight: 100, maxHeight: 120)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    // .border(Color.gray, width: 1)
                                    .background(RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.offWhite))
                                    .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.2), radius: 7, x: 7, y: 7)
                                    .shadow(color: Color.white.opacity(0.7), radius: 7, x: -4, y: -4)
                                    .ignoresSafeArea()
                                    .onTapGesture {
                                        FroopData.shared.froopType = froopType.id
                                        if froopType.id == 5009 {
                                            flightManager.isAirportPickup = true
                                        }
                                        print("🚼froopData.froopType \(FroopData.shared.froopType) / \(froopType.id)")
                                        changeView.froopTypeData = froopType
                                        
                                        if changeView.froopTypeData?.viewPositions[1] == 0 && FroopData.shared.froopType != 5009 {
                                            changeView.addressAtMyLocation = true
                                        } else {
                                            changeView.addressAtMyLocation = false
                                        }
                                        
                                        changeView.configureViewBuildOrder()
                                        //uploadFroopTypes()
//                                        print(froopTypeStore.froopTypes)
//                                        withAnimation(.spring()) {
//                                            mapState = .searchingForLocation
//                                        }
                                        // If this froop type has associated topics, show them, otherwise proceed.
                                        if hasAssociatedTopics(for: froopType) {
                                            selectedTopic = froopType.name
                                        } else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                                                if changeView.froopIsEditing {
                                                    withAnimation(.easeInOut(duration: 0.5)) {
                                                        // Get the last index of the currentViewBuildOrder
                                                        // Make sure the array is not empty to avoid crashes
                                                        if let lastIndex = changeView.currentViewBuildOrder.last, !changeView.currentViewBuildOrder.isEmpty {
                                                            changeView.pageNumber = lastIndex
                                                        }
                                                    }
                                                } else {
                                                    changeView.pageNumber = 2
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.trailing, 20)
                        }
                    }
                }
                .padding(.leading, 10)
                //                .padding(.trailing, 15)
            }
            .padding(.leading, 10)
            //            .padding(.trailing, 10)
        }
                .ignoresSafeArea()
                .onAppear {
                    appStateManager.updateOnboardingState(for: .createFroopType)
                    print("onboardingData.createFroopTypeOnboarding: \(String(describing: onboardingData.createFroopTypeOnboarding))")
                    print("appStateManager.currentViewID: \(String(describing: appStateManager.currentViewID))")
                    print("appStateManager.showCreateFroopTypeOnboarding: \(String(describing: appStateManager.showCreateFroopTypeOnboarding))")
                }
    }
    
    func uploadFroopTypes() {
        let allFroopTypes = [
            FroopTypeListOne.shared.froopTypesMain,
            FroopTypeListOne.shared.froopTypesSports,
            FroopTypeListOne.shared.froopTypesHealth,
            FroopTypeListOne.shared.froopTypesEdu,
            FroopTypeListOne.shared.froopTypesTravel,
            FroopTypeListOne.shared.froopTypesSocial,
//            FroopTypeListOne.shared.froopTypesProfessional,
            FroopTypeListOne.shared.froopTypesCommunity,
            FroopTypeListOne.shared.froopTypesCultural,
            FroopTypeListOne.shared.froopTypesErrands
//            FroopTypeListOne.shared.froopTypesCivic
        ]
        
        for froopTypes in allFroopTypes {
            for froopType in froopTypes {
                let documentID = "\(froopType.id)"  // Assuming the 'id' of the FroopType will be the document ID in Firestore.
                
                db.collection("froopTypes").document(documentID).setData([
                    "viewPositions": froopType.viewPositions,
                    "id": froopType.id,
                    "order": froopType.order,
                    "name": froopType.name,
                    "imageName": froopType.imageName,
                    "category": froopType.category,
                    "subCategory": froopType.subCategory
                ], merge: true) { error in
                    if let error = error {
                        print("🚫Error adding document: \(error)")
                    } else {
                        PrintControl.shared.printFroopCreation("Froop Type - Document successfully written!")
                    }
                }
            }
        }
    }
}
    
    
    
    
    
    
    
    
    
