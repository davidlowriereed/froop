//
//  FroopDetailsView.swift
//  Design_Layouts
//
//  Created by David Reed on 6/20/23.
//

import SwiftUI

struct FroopDetailsView2: View {
    @State private var formattedDateString: String = ""
    
    var body: some View {
        ZStack (){
            VStack (spacing: 0) {
                DetailsHeaderView()
                
                ScrollView {
                    
                    VStack (spacing: 0) {
                        
                        FroopDetailsMediaView()
                        
                        DetailsGuestView()
                        
                        DetailsCalendarView()
                        
                        DetailsMapView()
                        
                        DetailsTasksAndInformationView()
                        
                        DetailsDeleteView()
                        
                        Spacer()
                    }
                }
            }
            
            VStack {
                Spacer()
                DetailsAddFriendsView()
            }
            .ignoresSafeArea()
            
        }
        .ignoresSafeArea()
    }
}





struct FroopDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        FroopDetailsView2()
    }
}
