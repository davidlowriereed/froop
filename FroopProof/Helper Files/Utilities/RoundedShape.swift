//
//  RoundedShape.swift
//  FroopProof
//
//  Created by David Reed on 1/20/23.
//

import SwiftUI

struct RoundedShape: Shape {
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: 32, height: 32))
        return Path(path.cgPath)
    }
}
