//
//  Protocols.swift
//  FroopProof
//
//  Created by David Reed on 6/23/23.
//

import Foundation
import SwiftUI
import Combine
import UIKit
import MessageUI
import ContactsUI
import MapKit
import CoreLocation



protocol TaskAddon {
    var systemImageName: String { get }
    var description: String { get }
    func action()
}

protocol FroopNotificationDelegate: AnyObject {
    func froopParticipantsChanged(_ froopHistory: FroopHistory)
    func froopStatusChanged(_ froopHistory: FroopHistory)
}

protocol KeyboardReadable {
    var keyboardPublisher: AnyPublisher<Bool, Never> { get }
}

protocol CustomPickerDelegate: UIPickerViewDelegate {
    func didSelectRow(_ row: Int, _ component: Int)
}

protocol MessagesViewDelegate: AnyObject {
    func messageCompletion(result: MessageComposeResult)
}

protocol EmbeddedContactPickerViewControllerDelegate: AnyObject {
    func embeddedContactPickerViewControllerDidCancel(_ viewController: EmbeddedContactPickerViewController)
    func embeddedContactPickerViewController(_ viewController: EmbeddedContactPickerViewController, didSelect contact: CNContact)
}

protocol MovableAnnotation: AnyObject {
    var coordinate: CLLocationCoordinate2D { get set }
    var title: String? { get set }
    var guest: UserData { get set }
}
