//
//  CreatePinButton.swift
//  Design_Layouts
//
//  Created by David Reed on 12/7/23.
//

import SwiftUI

struct CreatePinButton: View {
    var body: some View {
      
        HStack (spacing: 15) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 18))
                .fontWeight(.regular)
                .foregroundColor(.black)
                .offset(x: 7)
            Text("ADD PIN")
                .fontWeight(.semibold)
                .font(.system(size: 14))
        }
    }
}

#Preview {
    CreatePinButton()
}
