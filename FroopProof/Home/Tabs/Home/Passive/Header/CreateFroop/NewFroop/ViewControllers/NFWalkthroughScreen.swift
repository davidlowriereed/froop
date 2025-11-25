//
//  NFWalkthroughScreen.swift
//  FroopProof
//
//  Created by David Reed on 1/19/23.
//

import SwiftUI
import iPhoneNumberField
import Firebase
import FirebaseFirestore
 



class ChangeView: ObservableObject {
    static let shared = ChangeView()
    @ObservedObject var printControl = PrintControl.shared
    @ObservedObject var froopData = FroopData.shared
    @ObservedObject var appStateManager = AppStateManager.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    @Published var froopTypeData: FroopType?
    @ObservedObject var myData = MyData.shared
    @Published var nextView: Bool = false
    @Published var pageNumber: Int = 1
    @Published var currentViewBuildOrder: [Int] = [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    @Published var froopAdded = false
    @Published var showNFWalkthroughScreen = false
    @Published var tempFroopType: Int = 0
    @Published var froopHolder: Froop = (Froop(dictionary: [:]) ?? Froop(dictionary: [:]) ?? Froop.emptyFroop())
    @Published var confirmedFriends: [UserData] = []
    @Published var singleUserData: UserData = UserData()
    @Published var friendSelected: Bool = false
    @Published var froopIsEditing: Bool = false

    
    //MARK: Controlling the Summary View
    @Published var showType: Int = 0
    @Published var showTitle: Int = 0
    @Published var showLocation: Int = 0
    @Published var showDate: Int = 0
    @Published var showDuration: Int = 0
    @Published var showName: Int = 0
    @Published var showGuest: Int = 0
    @Published var showGuests: Int = 0
    @Published var showSummary: Int = 0
    @Published var addressAtMyLocation: Bool = false
    @Published var locDerivedTitle: String? = nil
    @Published var locDerivedSubtitle: String? = nil
    @Published var invitedFriends: [UserData] = []
    

    func configureViewBuildOrder() {
        guard let viewPositions = froopTypeData?.viewPositions else { return }
        var order: [(position: Int, value: Int)] = []

        for (index, value) in viewPositions.enumerated() {
            if value > 0 {
                // Append a tuple of (position, value) to 'order'
                order.append((position: index + 1, value: value))
            }
        }

        // Sort by the values, then map to the positions
        currentViewBuildOrder = order.sorted(by: { $0.value < $1.value }).map { $0.position }
        print("✅ currentViewBuildOrder \(String(describing: currentViewBuildOrder))")

        // Reset all show properties to 0 (or another default value indicating "not shown")
        showType = 0
        showTitle = 0
        showLocation = 0
        showDate = 0
        showDuration = 0
        showGuest = 0
        if froopData.template {
            showGuests = 1
        } else {
            showGuests = 0
        }
        showSummary = 0

        // Iterate over the sorted order to set the show properties based on their new positions
        for (newPosition, originalPosition) in currentViewBuildOrder.enumerated() {
            switch originalPosition {
                case 1:
                    showType = newPosition + 1
                case 2:
                    showLocation = newPosition + 1
                case 3:
                    showDate = newPosition + 1
                case 4:
                    showTitle = newPosition + 1
                case 5:
                    showSummary = newPosition + 1
                case 6:
                    showGuest = newPosition + 1
                case 7:
                    showGuests = newPosition + 1
                // Add additional cases as needed
                default:
                    break
            }
        }
    }
    
    func navigateToNextOrEditingPage() {
        DispatchQueue.main.async {
            if self.froopIsEditing {
                // When editing, navigate to the last view defined in the currentViewBuildOrder
                if let lastIndex = self.currentViewBuildOrder.last, !self.currentViewBuildOrder.isEmpty {
                    self.pageNumber = lastIndex
                }
            } else {
                // When not editing, simply proceed to the next page
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.pageNumber += 1
                }
            }
        }
    }
    
    func currentPageView(locationViewModel: LocationSearchViewModel) -> some View {
        guard let nextPageIndex = currentViewBuildOrder.indices.contains(pageNumber - 1) ? currentViewBuildOrder[pageNumber - 1] : nil else {
            return AnyView(Text("End of Flow"))
        }
        
        switch nextPageIndex {
            case 1:
                return AnyView(FroopTypeOrTemplate(froopData: froopData).environmentObject(locationViewModel))
            case 2:
                return AnyView(FroopLocationSearchView(froopData: froopData).environmentObject(locationViewModel))
            case 3:
                return AnyView(FroopDateView(froopData: froopData).environmentObject(locationViewModel))
            case 4:
                return AnyView(FroopNameView(froopData: froopData).environmentObject(locationViewModel))
            case 5:
                return AnyView(FroopSummaryView(froopData: froopData).environmentObject(locationViewModel))
            case 6:
                return AnyView(FroopSingleFriendSelectView(froopData: froopData, timestamp: Date()).environmentObject(locationViewModel))
            case 7:
                return AnyView(FroopFlightsView(froopData: froopData).environmentObject(locationViewModel))
            case 8:
                return AnyView(EmptyView().environmentObject(locationViewModel))
            case 9:
                return AnyView(EmptyView().environmentObject(locationViewModel))
            case 10:
                return AnyView(EmptyView().environmentObject(locationViewModel))
            case 11:
                return AnyView(EmptyView().environmentObject(locationViewModel))
            case 12:
                return AnyView(EmptyView().environmentObject(locationViewModel))
            case 13:
                return AnyView(EmptyView().environmentObject(locationViewModel))
            case 14:
                return AnyView(EmptyView().environmentObject(locationViewModel))
            case 15:
                return AnyView(EmptyView().environmentObject(locationViewModel))
            case 16:
                return AnyView(EmptyView().environmentObject(locationViewModel))
            case 17:
                return AnyView(EmptyView().environmentObject(locationViewModel))
            case 18:
                return AnyView(EmptyView().environmentObject(locationViewModel))
            case 19:
                return AnyView(EmptyView().environmentObject(locationViewModel))
            case 20:
                return AnyView(EmptyView().environmentObject(locationViewModel))
            default:
                return AnyView(Text("Invalid Page"))
        }
    }
    
    func changeThePageNumber() {
        PrintControl.shared.printProfile("-ChangeView: Function: changeThePageNumber is firing!")
        if self.nextView == true {
            self.pageNumber += 1
            self.nextView = false
        }
    }
}

struct NFWalkthroughScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @State var locationViewModel = LocationSearchViewModel()
    @ObservedObject var myData = MyData.shared
    @ObservedObject var changeView = ChangeView.shared
    @State private var homeViewModel = HomeViewModel()
    @Binding var froopAdded: Bool
    
    private func currentPageView() -> some View {
        changeView.currentPageView(locationViewModel: locationViewModel)
    }
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Button {
                        changeView.pageNumber -= 1
                    } label: {
                        Image(systemName: "arrow.backward.square.fill")
                            .font(.system(size: 24))
                            .foregroundColor(colorScheme == .dark ? Color(red: 50/255, green: 46/255, blue: 62/255) : Color(red: 50/255, green: 46/255, blue: 62/255))
                            .opacity(changeView.pageNumber >= 2 ? 0.0 : 1.0)
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding(.top, 20)
            .padding(.leading, 20)
            
            // Dynamically serve the current page view based on the flow defined in ChangeView
            currentPageView() // This is where the currentPageView is incorporated into the ZStack
                .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
                .animation(.default, value: changeView.pageNumber) // Animate the transition between views
        }
    }
}
