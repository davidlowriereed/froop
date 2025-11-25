//
//  SharedViewModel.swift
//  FroopProof
//
//  Created by David Reed on 4/1/23.
//

import Foundation


class SharedViewModel: ObservableObject {
    
    func eveningText () -> String {
        let date = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        
        var greeting: String
        if hour < 12 {
            greeting = "Good Morning"
        } else if hour < 17 {
            greeting = "Good Afternoon"
        } else {
            greeting = "Good Evening"
        }
        
        return greeting
    }
    
}
