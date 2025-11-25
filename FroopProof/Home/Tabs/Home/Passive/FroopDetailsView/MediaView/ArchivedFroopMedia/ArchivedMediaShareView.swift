

//
//  ArchivedMediaShare.swift
//  FroopProof
//
//  Created by David Reed on 7/10/23.
//

import SwiftUI

struct ArchivedMediaShareView: View {
    @ObservedObject var froopManager = FroopManager.shared
    @Environment(\.colorScheme) var colorScheme
    @State private var selectedTab = 0
    var body: some View {
        ZStack {
           
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                    .opacity(0.5)
                    .ignoresSafeArea()
                    .background(.ultraThinMaterial)
                
                VStack {
                    Text(froopManager.archivedSelectedTab == 0 ? "This Froop's Media" : "Upload Media from your Library")
                        .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .fontWeight(.semibold)
                        .font(.system(size: 22))
                        .multilineTextAlignment(.center)
                        .padding(.top, 25)
                        .padding(.bottom, 10)
                    Picker("", selection: $froopManager.archivedSelectedTab) {
                        Text("All Froop Images").tag(0)
                        Text("Your Photo Library").tag(1)
                    }
                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    Spacer()
                }
            }
            ZStack {
                VStack {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(height: 125)
                    TabView(selection: $froopManager.archivedSelectedTab) {
                        ArchivedMediaFeedView()
                            .frame(width: UIScreen.screenWidth)
                            .tag(0)
                        ArchivedLibraryView()
                            .frame(width: UIScreen.screenWidth)
                            .tag(1)
                    }
                }
            }
        }
    }
}
