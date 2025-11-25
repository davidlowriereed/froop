//
//  FroopPassiveView.swift
//  FroopProof
//
//  Created by David Reed on 5/18/23.
//

import SwiftUI

struct CopyableTextView: View {
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .frame(width: UIScreen.screenWidth - 40, height: UIScreen.screenHeight / 1.5)
                .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
                .shadow(color: Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.4), radius: 4, x: 4, y: 4)
            VStack {
                Rectangle()
                    .frame(width: UIScreen.screenWidth - 40, height: UIScreen.screenHeight / 2)
                    .foregroundColor(.white)
                    .padding(.top, 60)
                Spacer()
            }
            
            VStack (spacing: 5){
                ZStack {
                    HStack {
                        Text("FROOP INVITE LINK")
                            .foregroundStyle(.white)
                            .font(.headline)
                            .fontWeight(.bold)
                            .padding(.leading, 35)
                            .padding(.trailing, 35)
                        
                    }
                }
                .padding(.top, 30)
                
                VStack(spacing: 5){
                    HStack {
                        Text("Froop Invite Links are an easy way to send invitations to anyone via Texting, Email, or Posting to your Social Media.")
                            .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.body)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    Divider()
                        .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                        .padding()
                    HStack {
                        Text("HERE'S HOW IT WORKS")
                            .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.subheadline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    HStack {
                        Text("If the guest is in your Friend List...")
                            .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.callout)
                            .fontWeight(.thin)
                        Spacer()
                    }
                    .padding(.leading, 15)
                    .padding(.top, 10)
                    
                    
                    BulletPointTextView(text: "They are added to the Froop's Confirmed List as soon as they accept the invitation.")
                        .padding(.leading, 15)
                        .padding(.top, 10)
                    BulletPointTextView(text: "Status:  They Are Trusted")
                        .padding(.leading, 15)
                        .padding(.top, 10)


                    
                    HStack {
                        Text("If the guest is NOT yet a Friend...")
                            .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                            .font(.callout)
                            .fontWeight(.thin)
                        Spacer()
                    }
                    .padding(.leading, 15)
                    .padding(.top, 10)
                    BulletPointTextView(text: "After they have accepted the invitation, you will need to 'Approve' them before they can join your Froop.")
                    
                        .padding(.leading, 15)
                        .padding(.top, 10)
                    BulletPointTextView(text: "Status: Requires Verification")
                    
                        .padding(.leading, 15)
                        .padding(.top, 10)

                    
                    Spacer()
                    
                }
                .padding(.top, 15)
                .padding(.leading, 35)
                .padding(.trailing, 35)
                
                Text("COPY FROOP LINK NOW")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.bottom, 35)
                    .overlay(
                        Group {
//                            if showCopyConfirmation {
//                                Text("Copied!")
//                                    .font(.caption)
//                                    .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255))
//                                    .padding(8)
//                                    .background(Color(red: 50/255, green: 46/255, blue: 62/255).opacity(0.25))
//                                    .clipShape(Capsule())
//                                    .transition(.scale.combined(with: .opacity))
//                                    .zIndex(1)
//                            }
                        }
                    )
//                    .animation(.easeInOut, value: showCopyConfirmation)
//                Spacer()
            }
           
        }
        .frame(height: UIScreen.screenHeight / 1.5)
    }
}

struct CopyableTextView_Previews: PreviewProvider {
    static var previews: some View {
        CopyableTextView()
    }
}


struct BulletPointTextView: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "circle.fill")
                .foregroundStyle(Color(red: 50/255, green: 46/255, blue: 62/255))
                .font(.system(size: 8))
                .opacity(0.25)
                .padding(.top, 3)
            
            Text(text)
                .font(.footnote)
                .fontWeight(.regular)
            Spacer()
        }
    }
}
