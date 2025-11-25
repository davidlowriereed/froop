//
//  TimeModel.swift
//  FroopProof
//
//  Created by David Reed on 1/30/23.
//

import Foundation
import UIKit
import SwiftUI
import Combine

struct TimeModel {
    
    
    
    @ObservedObject var printControl = PrintControl.shared
   
    // @ObservedObject var froopDataListener = FroopDataListener.shared
   
 
    
    let hours: [Int]
    let minutes: [Int]
    let amPm: [String]

    init() {
        hours = Array(1...12)
        minutes = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55]
        amPm = ["AM", "PM"]
    }
}



//class CustomPickerClass: UIPickerView {
//    weak var customDelegate: CustomPickerDelegate?
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.delegate = self
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        customDelegate?.didSelectRow(row, component)
//    }
//}
