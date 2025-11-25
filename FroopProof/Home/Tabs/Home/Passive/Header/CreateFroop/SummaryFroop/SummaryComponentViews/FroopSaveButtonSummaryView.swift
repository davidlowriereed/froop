//
//  FroopSaveButtonSummaryView.swift
//  FroopProof
//
//  Created by David Reed on 3/22/24.
//

import SwiftUI
import CoreLocation

struct FroopSaveButtonSummaryView: View {
    @ObservedObject var appStateManager = AppStateManager.shared
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var changeView = ChangeView.shared
    @ObservedObject var flightManager = FroopFlightDataManager.shared
    @ObservedObject var vm = LocationSearchViewModel.shared

    let uid = FirebaseServices.shared.uid
    
    //    @State var froopHolder: Froop = Froop(dictionary: [:])
    
    var body: some View {
        ZStack {
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(height: 75)
                .padding(.leading, 15)
                .padding(.trailing, 15)
            Button {
                print("🛜 \(String(describing: froopData.froopLocationCoordinate))")
                Task {
                    do {
                        // Preparations before saving the Froop
                        FroopManager.shared.froopHolder.froopHost = FirebaseServices.shared.uid
                        changeView.froopIsEditing = false
                        if LocationManager.shared.locationUpdateTimerOn == true {
                            TimerServices.shared.shouldCallupdateUserLocationInFirestore = true
                        }
                        if AppStateManager.shared.stateTransitionTimerOn == true {
                            TimerServices.shared.shouldCallAppStateTransition = true
                        }
                        PrintControl.shared.printFroopCreation("Attempting to Save Froop")
                        froopData.froopHostPic = MyData.shared.profileImageUrl
                        froopData.froopHost = MyData.shared.froopUserID
                        if froopData.froopType == 5009 {
                            froopData.froopLocationtitle = changeView.locDerivedTitle ?? "Unspecified"
                            froopData.froopLocationsubtitle = changeView.locDerivedSubtitle ?? ""
                        }
                        if changeView.addressAtMyLocation {
                            froopData.froopLocationCoordinate = MyData.shared.coordinate
                            froopData.froopLocationtitle = changeView.locDerivedTitle ?? "Unspecified"
                            froopData.froopLocationsubtitle = changeView.locDerivedSubtitle ?? ""
                        }
//                        froopData.froopType = changeView.froopTypeData.id
                        if froopData.froopType == 5001 {
                            froopData.froopName = ("Picking up \(MyData.shared.firstName) \(MyData.shared.lastName)")
                        } 
                        // Save the Froop document and obtain the froopId
                        let froopId = try await froopData.saveData()
                        
                        // Create the invitation using the completion handler instead of await
                        froopData.createInvite(froopId: froopId) { result in
                            switch result {
                                case .success(let inviteUrl):
                                    print("Invite URL: \(inviteUrl)")
                                   
                                case .failure(let error):
                                    print("🚫 Error creating invitation: \(error.localizedDescription)")
                            }
                        }

                        // Schedule notifications
                        let userNotificationsController = UserNotificationsController()
                        userNotificationsController.scheduleLocationTrackingNotification(froopId: froopData.froopId, froopName: froopData.froopName, froopStartTime: froopData.froopStartTime)
                        userNotificationsController.scheduleFroopReminderNotification(froopId: froopData.froopId, froopName: froopData.froopName, froopStartTime: froopData.froopStartTime)
                        
                        // Schedule the Froop reminder notification
                        userNotificationsController.scheduleFroopReminderNotification(froopId: froopData.froopId, froopName: froopData.froopName, froopStartTime: froopData.froopStartTime)
                        
                        changeView.froopAdded = true
                        changeView.showNFWalkthroughScreen = false
                        froopData.resetData()  // Resetting FroopData for future use
                        appStateManager.selectedTabTwo = 1
                        FroopManager.shared.createFroopHistoryArray { froopHistory in
                            PrintControl.shared.printFroopHistoryServices("froopHistory created \(froopHistory.count)")
                        }
                        vm.results = []
                        vm.places = []
                        vm.showDetails = false
                        vm.queryFragment = ""
                    } catch {
                        print("🚫 Error in Froop creation or invitation process: \(error.localizedDescription)")
                    }
                }
            } label: {
                Text("Save Froop")
                    .font(.system(size: 28, weight: .thin))
                    .foregroundColor(.white).opacity(1)
                    .multilineTextAlignment(.center)
                    .frame(width: 225, height: 45)
                    .border(Color(.white).opacity(1), width: 0.25)
                    .padding(.top)
            }
        }
        .ignoresSafeArea()
    }
}
