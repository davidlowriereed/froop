//
//  Month.swift
//  Design_Layouts
//
//  Created by David Reed on 6/11/23.
//

import SwiftUI

struct Month: Identifiable {
    let id = UUID()
    let name: String
    let listItems: [ListItem]
    
    static let preview: [Month] =
    [
        Month(name: "January", listItems: [
            ListItem(), ListItem()
        ]),
       
        
        Month(name: "February", listItems: [
            
        ]),
        Month(name: "March", listItems: [
            ListItem()
            
        ]),
        Month(name: "April", listItems: [
            ListItem()
            
        ]),
        Month(name: "May", listItems: [
            ListItem()
            
        ]),
        Month(name: "June", listItems: [
            ListItem()
            
        ]),
        Month(name: "July", listItems: [
            ListItem()
            
        ]),
        Month(name: "August", listItems: [
            ListItem()
            
        ]),
        Month(name: "September", listItems: [
            ListItem()
            
        ]),
        Month(name: "October", listItems: [
            ListItem()
            
        ]),
        Month(name: "November", listItems: [
            ListItem()
            
        ]),
        Month(name: "December", listItems: [
            ListItem()
            
        ]),
    ]
}
