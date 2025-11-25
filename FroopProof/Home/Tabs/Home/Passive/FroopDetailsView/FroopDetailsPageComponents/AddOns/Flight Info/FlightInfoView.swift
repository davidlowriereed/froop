//
//  FlightInfoView.swift
//  FroopProof
//
//  Created by David Reed on 6/23/23.
//

import SwiftUI

struct FlightInfoView: View, TaskAddon {
    var systemImageName: String { return "airplane.arrival" }
    var description: String { return "Flight Info" }

    func action() {
        // Open URL or other action
    }
    
    var body: some View {
        VStack {
            Image(systemName: systemImageName)
                .font(.system(size: 35))
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                .opacity(0.7)
                .fontWeight(.thin)
                .frame(maxWidth: 50, maxHeight: 40)
            Text(description)
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                .font(.system(size: 14))
                .fontWeight(.light)
        }
        .onTapGesture { action() }
        .padding(.trailing, 20)
    }
    
    func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
            return
        }

        UIApplication.shared.open(url)
    }
    
}
