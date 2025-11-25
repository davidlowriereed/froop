//
//  CustomAnnotationPin.swift
//  FroopProof
//
//  Created by David Reed on 7/13/23.
//

import SwiftUI
import UIKit
import CoreLocation
import MapKit

class CustomAnnotationView: MKAnnotationView {
    var customCalloutView: UIView?
    var editButton: UIButton?
    

    override var annotation: MKAnnotation? {
        willSet {
            customCalloutView?.removeFromSuperview()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            let hostingController = UIHostingController(rootView: AnnotationDetailView(title: "Title Here"))
            hostingController.view.frame = CGRect(x: 0, y: 0, width: 120, height: 200)
            hostingController.view.backgroundColor = UIColor.clear
            addSubview(hostingController.view)
            customCalloutView = hostingController.view

            editButton = UIButton(frame: CGRect(x: 0, y: 0, width: 120, height: 30))
            editButton?.backgroundColor = .blue
            editButton?.setTitle("Edit", for: .normal)
            editButton?.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
            addSubview(editButton!)
        } else {
            customCalloutView?.removeFromSuperview()
            customCalloutView = nil
            editButton?.removeFromSuperview()
            editButton = nil
        }
    }

    @objc func editButtonTapped() {
        // Handle the edit action
    }
}

struct AnnotationDetailView: View {
    var title: String
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 10)
            // .foregroundColor(Color(red: 50/255, green: 46/255, blue: 62/255)).gradient
                .fill(Color(red: 50/255, green: 46/255, blue: 62/255).gradient)
                .opacity(0.7)
                .frame(minWidth: 120, maxWidth: 120, minHeight: 200, maxHeight: 200)
            VStack (alignment: .leading){
                Text("Annotation Title")
                    .foregroundColor(.white)
                    .font(.system(size: 12))
                    .fontWeight(.semibold)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                Text("SubTitle")
                    .foregroundColor(.white)
                    .font(.system(size: 10))
                    .fontWeight(.regular)
                    .padding(.top, 1)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                
                Text("Ipsum lorum dolores sumpre compre sseder erre es werelkdh")
                    .foregroundColor(.white)
                    .font(.system(size: 10))
                    .fontWeight(.light)
                    .padding(.top, 5)
                    .padding(.leading, 5)
                    .padding(.trailing, 5)
                Spacer()
                
                HStack {
                    Spacer()
                    ZStack {
                        Rectangle()
                            .foregroundColor(.clear)
                            .border(.white, width: 0.5)
                            .frame(width: 50, height: 25)
                        
                        Text("Edit")
                            .foregroundColor(.white)
                            .font(.system(size: 12))
                            .fontWeight(.thin)
                    }
                    Spacer()
                }
                .padding(.bottom, 10)
            }
            .padding(.top, 10)
        }
        .frame(minWidth: 120, maxWidth: 120, minHeight: 200, maxHeight: 200)
        .background(.clear)
    }
}
