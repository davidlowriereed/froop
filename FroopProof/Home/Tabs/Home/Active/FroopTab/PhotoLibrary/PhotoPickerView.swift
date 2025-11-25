//
//  PhotoPickerView.swift
//  FroopProof
//
//  Created by David Reed on 11/7/23.
//

import SwiftUI
import Photos
import PhotosUI

class PhotoPickerViewModel: ObservableObject {
    @Published var selectedImage: UIImage? = nil
    @Published var imageSelection: [PhotosPickerItem] = []
}
    
struct PhotoPickerView: View {
    @State var viewModel = PhotoPickerViewModel()
    @Binding var instanceFroop: FroopHistory
   
    
    var body: some View {
//        let dateFilter = PHPickerFilter.data(from: .init(instanceFroop.froop.froopStartTime), to: .init(instanceFroop.froop.froopEndTime))
        
        PhotosPicker(
            selection: $viewModel.imageSelection,
            selectionBehavior: .default,
            matching: .images,
            preferredItemEncoding: .current,
            photoLibrary: .shared()
        ) {
            Text("Open Picker")
                .foregroundColor(.red)
        }
        .photosPickerStyle(.inline)
    }
}


