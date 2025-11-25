//
//  NavigationAppsDropDown.swift
//  FroopProof
//
//  Created by David Reed on 10/3/24.
//

import SwiftUI

struct NavigationAppsDropdown: View {
    @Binding var isShowing: Bool
    
    let navigationApps: [(name: String, icon: String, urlScheme: String, appStoreId: String)] = [
        ("Google Maps", "googleMapsLogo", "comgooglemaps://", "585027354"),
        ("Waze", "wazeLogoRound", "waze://", "323229106"),
        ("Apple Maps", "appleMapsLogo", "maps://", ""),
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                if isShowing {
                    VStack(alignment: .center, spacing: 0) {
                        // Navigation Apps Container
                        ZStack {
                            RoundedRectangle(cornerRadius: 15)
                                .fill(.pink)
                                .frame(width: 65, height: 250)
                            
                            VStack(spacing: 20) {
                                ForEach(navigationApps, id: \.name) { app in
                                    NavigationAppIcon(app: app)
                                        .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.vertical)
                        }
                        .frame(height: 250)
                        
                        // Close Button
                        Button(action: {
                            withAnimation {
                                isShowing = false
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.black)
                                    .frame(width: 36, height: 36)
                                
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                            }
                        }
                        .position(x: 32.5, y: -5)
                    }
                    .frame(width: 65)
                    .position(x: geometry.size.width - 32.5, y: 150) // Position from the top
                } else {
                    Button(action: {
                        withAnimation {
                            isShowing = true
                        }
                    }) {
                        Image(systemName: "map.circle")
                            .font(.system(size: 36))
                            .fontWeight(.thin)
                            .foregroundColor(.white)
                    }
                    .position(x: geometry.size.width - 32.5, y: 25)
                }
            }
        }
    }
}

struct NavigationAppIcon: View {
    let app: (name: String, icon: String, urlScheme: String, appStoreId: String)
    
    var body: some View {
        Button(action: {
            print("Tapping \(app.name)")
            openApp(urlScheme: app.urlScheme, appStoreId: app.appStoreId)
        }) {
            Image(app.icon)
                .resizable()
                .scaledToFit()
                .clipShape(Circle())
                .frame(width: 50, height: 50)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func openApp(urlScheme: String, appStoreId: String) {
        if let url = URL(string: urlScheme), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else if !appStoreId.isEmpty, let appStoreURL = URL(string: "https://apps.apple.com/app/id\(appStoreId)") {
            UIApplication.shared.open(appStoreURL, options: [:], completionHandler: nil)
        }
    }
}
