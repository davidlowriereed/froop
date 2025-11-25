//
//  PrintControl.shared.swift
//  FroopProof
//
//  Created by David Reed on 5/9/23.
//

import Foundation

//MARK: PrintControl is a singleton
//MARK: var PrintControl = PrintControl.shared
//MARK: usage:  PrintControl.shared.<property>("Logging in...")

class PrintControl: ObservableObject {
    static let shared = PrintControl()
    
    @Published var developer: String = ""
    @Published var froopCounter: Int = 0
    @Published var printAppDelegate: Bool = false
    @Published var printAppState: Bool = false
    @Published var printAppStateSetupListener: Bool = false
    @Published var printData: Bool = false
    @Published var printErrorMessages: Bool = false
    @Published var printExtensions: Bool = false
    @Published var printFirebaseOperations: Bool = false
    @Published var printForEach: Bool = false
    @Published var printFriend: Bool = false
    @Published var printFriendList: Bool = false
    @Published var printFroopCreation: Bool = false
    @Published var printFroopData: Bool = false
    @Published var printFroopDataController: Bool = false
    @Published var printFroopDetails: Bool = false
    @Published var printFroopHistoryServices: Bool = false
    @Published var printFroopManager: Bool = false
    @Published var printFroopUpdates: Bool = false
    @Published var printImage: Bool = false
    @Published var printInviteFriends: Bool = false
    @Published var printLists: Bool = false
    @Published var printListeners: Bool = false
    @Published var printNavLocationServices: Bool = false
    @Published var printLogin: Bool = false
    @Published var printMap: Bool = false
    @Published var printMediaManager: Bool = false
    @Published var printMyData: Bool = false
    @Published var printNotifications: Bool = false
    @Published var printOnboarding: Bool = false
    @Published var printPhotoPicker: Bool = false
    @Published var printProfile: Bool = false
    @Published var printSettings: Bool = false
    @Published var printStartUp: Bool = false
    @Published var printTime: Bool = false
    @Published var printTimeZone: Bool = false
    @Published var printUserData: Bool = false
    @Published var printUserDataUpdates: Bool = false
    @Published var printVersion: Bool = false
    @Published var showAll: Bool = false

    
    private init() {}
    
    func printOnboarding(_ message: String) {
        if printOnboarding || showAll {
            print(message)
        }
    }
    
    func printForEach(_ message: String) {
        if printForEach || showAll {
            print(message)
        }
    }
    
    func printExtensions(_ message: String) {
        if printExtensions || showAll {
            print(message)
        }
    }
    
    func printSettings(_ message: String) {
        if printSettings || showAll {
            print(message)
        }
    }
    
    func printListeners(_ message: String) {
        if printListeners || showAll {
            print(message)
        }
    }
    
    func printData(_ message: String) {
        if printData || showAll {
            print(message)
        }
    }
    
    func printVersion(_ message: String) {
        if printVersion || showAll {
            print(message)
        }
    }
    
    func printFroopHistoryServices(_ message: String) {
        if printFroopHistoryServices || showAll {
            print(message)
        }
    }
    
    func printNotifications(_ message: String) {
        if printNotifications || showAll {
            print(message)
        }
    }
    
    func printStartUp(_ message: String) {
        if printStartUp || showAll {
            print(message)
        }
    }
    
    func printMap(_ message: String) {
        if printMap || showAll {
            print(message)
        }
    }
    
    func printFroopDataController(_ message: String) {
        if printFroopDataController || showAll {
            print(message)
        }
    }
    
    func printTimeZone(_ message: String) {
        if printTimeZone || showAll {
            print(message)
        }
    }
    
    func printImage(_ message: String) {
        if printImage || showAll {
            print(message)
        }
    }
    
    func printFroopData(_ message: String) {
        if printFroopData || showAll {
            print(message)
        }
    }
    
    func printMyData(_ message: String) {
        if printMyData || showAll {
            print(message)
        }
    }
    
    func printUserData(_ message: String) {
        if printUserData || showAll {
            print(message)
        }
    }
    
    func printMediaManager(_ message: String) {
        if printMediaManager || showAll {
            print(message)
        }
    }
    
    func printFroopManager(_ message: String) {
        if printFroopManager || showAll {
            print(message)
        }
    }
    
    func printFriend(_ message: String) {
        if printFriend || showAll {
            print(message)
        }
    }
    
    func printLists(_ message: String) {
        if printLists || showAll {
            print(message)
        }
    }
    
    func printTime(_ message: String) {
        if printTime || showAll {
            print(message)
        }
    }
    
    func printProfile(_ message: String) {
        if printProfile || showAll {
            print(message)
        }
    }
    
    func printPhotoPicker(_ message: String) {
        if printPhotoPicker || showAll {
            print(message)
        }
    }
    
    func printAppDelegate(_ message: String) {
        if printAppDelegate || showAll {
            print(message)
        }
    }
    
    func printLogin(_ message: String) {
        if printLogin || showAll {
            print(message)
        }
    }
    
    func printNavLocationServices(_ message: String) {
        if printNavLocationServices || showAll {
            print(message)
        }
    }
    
    func printFroopCreation(_ message: String) {
        if printFroopCreation || showAll {
            print(message)
        }
    }
    
    func printInviteFriends(_ message: String) {
        if printInviteFriends || showAll {
            print(message)
        }
    }
    
    func printFriendList(_ message: String) {
        if printFriendList || showAll {
            print(message)
        }
    }
    
    func printFroopDetails(_ message: String) {
        if printFroopDetails || showAll {
            print(message)
        }
    }
    
    func printFroopUpdates(_ message: String) {
        if printFroopUpdates || showAll {
            print(message)
        }
    }
    
    func printFirebaseOperations(_ message: String) {
        if printFirebaseOperations || showAll {
            print(message)
        }
    }
    
    func printErrorMessages(_ message: String, file: String = #file, line: Int = #line, function: String = #function) {
        if printPhotoPicker || showAll {
            let fileName = (file as NSString).lastPathComponent // To get just the file's name, not the whole path
            print("\(fileName):\(line) \(function) - \(message)")
        }
    }
    
    func printAppStateSetupListener(_ message: String) {
        if printAppStateSetupListener || showAll {
            print(message)
        }
    }
    
    func printAppState(_ message: String) {
        if printAppState || showAll {
            print(message)
        }
    }

    func printUserDataUpdates(_ message: String) {
        if printUserDataUpdates || showAll {
            print(message)
        }
    }
}
