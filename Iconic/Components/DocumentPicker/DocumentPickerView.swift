//
//  DocumentPickerView.swift
//  Iconic
//
//  Created by Mohssen Fathi on 10/30/19.
//  Copyright © 2019 Mohssen Fathi. All rights reserved.
//

import SwiftUI
import MobileCoreServices

struct DocumentPickerView: View {
    var selectionHandler: ((UIImage) -> ())
    init(selectionHandler: @escaping ((UIImage) -> ())) {
        self.selectionHandler = selectionHandler
    }
    var body: some View {
        DocumentPickerViewController(selectionHandler: selectionHandler)
    }
}


struct DocumentPickerView_Preview: PreviewProvider {
    static var previews: some View {
        DocumentPickerView(selectionHandler: { _ in })
    }
}


/// DocumentPickerViewController
final class DocumentPickerViewController: NSObject, UIViewControllerRepresentable {
    
    typealias ImageSelectionHandler = ((UIImage) -> ())
    
    var selectionHandler: ImageSelectionHandler?
    
    init(selectionHandler: ImageSelectionHandler?) {
        self.selectionHandler = selectionHandler
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentPickerViewController>) -> UIDocumentPickerViewController {
        let documentController = UIDocumentPickerViewController(
            documentTypes: [kUTTypePNG as String],
            in: .import
        )
        documentController.delegate = self
        return documentController
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: UIViewControllerRepresentableContext<DocumentPickerViewController>) {
        
    }
}

extension DocumentPickerViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first,
            let data = try? Data(contentsOf: url),
            let image = UIImage(data: data) else {
                return
        }
        selectionHandler?(image)
    }
}
