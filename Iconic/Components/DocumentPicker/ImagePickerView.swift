//
//  ImagePickerView.swift
//  Iconic
//
//  Created by Mohssen Fathi on 11/25/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import SwiftUI
import Photos

struct ImagePickerView: View {
    var selectionHandler: ((UIImage) -> ())
    init(selectionHandler: @escaping ((UIImage) -> ())) {
        self.selectionHandler = selectionHandler
    }
    
    var body: some View {
        ImagePickerViewController(selectionHandler: selectionHandler)
    }
}

struct ImagePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePickerView(selectionHandler: { _ in
            
        })
    }
}


final class ImagePickerViewController: NSObject, UIViewControllerRepresentable {
    
    typealias ImageSelectionHandler = ((UIImage) -> ())
    
    var selectionHandler: ImageSelectionHandler?
    
    init(selectionHandler: ImageSelectionHandler?) {
        self.selectionHandler = selectionHandler
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePickerViewController>) -> UIImagePickerController {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        return imagePicker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePickerViewController>) {
        
    }
}

extension ImagePickerViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        selectionHandler?(image)
    }
}
