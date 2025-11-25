//
//  TimeViewController.swift
//  FroopProof
//
//  Created by David Reed on 2/1/23.
//

import UIKit
import SwiftUI

class ViewController: UIViewController, UITextFieldDelegate {
    @ObservedObject var printControl = PrintControl.shared
    // @ObservedObject var froopDataListener = FroopDataListener.shared
    let textField = UITextField()

    override func viewDidLoad() {
//        print("-ViewController: Function: viewDidLoad is firing!")
        super.viewDidLoad()
        textField.delegate = self
        textField.frame = CGRect(x: 0, y: 0, width: 400, height: 120)
        textField.font = UIFont.systemFont(ofSize: 120, weight: .thin)
        textField.backgroundColor = UIColor(red: 50/255, green: 46/255, blue: 62/255, alpha: 1.0)
        textField.textAlignment = .center
        textField.keyboardType = .numberPad
        textField.text = "00 : 00"
        view.addSubview(textField)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        print("-ViewController: Function: textField is firing!")
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        let timeComponents = newText.split(separator: ":")
        if timeComponents.count != 2 {
            return false
        }
        let hours = Int(timeComponents[0]) ?? 0
        let minutes = Int(timeComponents[1]) ?? 0
        return hours >= 0 && hours <= 12 && minutes >= 0 && minutes <= 59
    }
}
