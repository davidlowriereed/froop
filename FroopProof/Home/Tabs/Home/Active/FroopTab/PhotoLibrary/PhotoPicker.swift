//
//  PhotoPicker.swift
//  FroopProof
//
//  Created by David Reed on 11/7/23.
//

import SwiftUI
import Photos
import PhotosUI
import UIKit

class PhotoViewController: UIViewController, ObservableObject, PHPickerViewControllerDelegate {
    static var shared = PhotoViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
    }
    
    @objc func didTapAdd() {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = 15
        config.filter = .images
        let vc = PHPickerViewController(configuration: config)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else {
                    return
                }
                print(image)
            }
        }
    }
}
    
