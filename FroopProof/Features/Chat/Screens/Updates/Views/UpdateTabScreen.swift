//
//  UpdateTabScreen.swift
//  FroopChatApp
//
//  Created by David Reed on 6/12/24.
//

import SwiftUI

struct UpdatesTabScreen: View {
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                
                
                StatusSectionHeader()
                    .listRowBackground(Color.clear)
                
                StatusSection()
                
                Section {
                    RecentUpdatesItemView()
                } header: {
                    Text("Recent Updates")
                }
                
                Section {
                    ChannelListView()
                } header: {
                    channelSectionheader(text: "Channels")
                }
            
            
            }
            .listStyle(.grouped)
            .navigationTitle("Updates")
            .searchable(text: $searchText)
            
        }
    }
    
    private func channelSectionheader(text: String) -> some View {
        HStack {
            Text(text)
                .bold()
                .font(.title3)
                .textCase(nil)
                .foregroundStyle(.black)
            
            Spacer()
            
            Button {
                
            } label: {
                Image(systemName: "plus")
                    .padding(7)
                    .background(Color(.systemGray5))
                    .clipShape(Circle())
            }
        }
    }
    
}

private struct StatusSectionHeader: View {
    var body: some View {
        VStack () {
            HStack {
                Text("Status")
                    .bold()
                    .font(.title3)
                    .textCase(nil)
                    .foregroundStyle(.black)
            Spacer()
            }
            .padding(.vertical)
            HStack (alignment: .top) {
                Image(systemName: "circle.dashed")
                    .foregroundColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                    .imageScale(.large)
                
                (
                    Text("Use Status to share photos, text and videos that disappear in 24 hours.")
                    +
                    Text(" ")
                    +
                    Text("Status Privacy")
                        .foregroundColor(.blue).bold()
                )
                
                Image(systemName: "xmark")
                    .foregroundColor(.gray)
                
            }
            .padding()
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

private struct StatusSection: View {
    var body: some View {
        HStack {
            Circle()
                .frame(width: UpdatesTabScreen.Constant.imageDimen, height: UpdatesTabScreen.Constant.imageDimen)
            VStack(alignment: .leading) {
                Text("My Status")
                    .font(.callout)
                    .bold()
                
                Text("Add to my status")
                    .foregroundStyle(.gray)
                    .font(.system(size: 15))
            }
            
            Spacer()
            
            cameraButton()
            pencilButton()
            
           
            
        }
    }
    
    private func cameraButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "camera.fill")
                .padding(10)
                .background(Color(.systemGray5))
                .clipShape(Circle())
                .bold()
        }
    }
    
    private func pencilButton() -> some View {
        Button {
            
        } label: {
            Image(systemName: "pencil")
                .padding(10)
                .background(Color(.systemGray5))
                .clipShape(Circle())
                .bold()
        }
    }
}



extension UpdatesTabScreen {
    enum Constant {
        static let imageDimen: CGFloat = 55
    }
}

private struct  RecentUpdatesItemView: View {
    var body: some View {
       
        HStack {
            Circle()
                .frame(width: UpdatesTabScreen.Constant.imageDimen, height: UpdatesTabScreen.Constant.imageDimen)
            VStack(alignment: .leading) {
                Text("David Reed")
                    .font(.callout)
                    .bold()
                
                Text("1h ago")
                    .foregroundStyle(.gray)
                    .font(.system(size: 15))
            }
            
            Spacer()
            
        }
    }
}

private struct ChannelListView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("Stay updated on topics that matter to you.  Find channels to follow below.")
                .foregroundStyle(.gray)
                .font(.callout)
                .padding(.horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0..<10) { _ in
                        ChannelItemView()
                    }
                }
            }
            
            Button("Explore More") {}
                .tint(Color(.blue))
                .bold()
                .buttonStyle(.borderedProminent)
                .clipShape(Capsule())
                .padding(.vertical)
        }
    }
}

private struct ChannelItemView: View {
    var body: some View {
        VStack {
            Circle()
                .frame(width: 55, height: 55)
            
            Text("Real Madrid C.F.")
            
            Button {
                
            } label: {
                Text("Follow")
                    .bold()
                    .padding(5)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
}

#Preview {
    UpdatesTabScreen()
}
