//
//  MultiImagePicker.swift
//  Yurtify
//
//  Created by dark type on 29.06.2025.
//

import SwiftUI
import Photos
import UIKit
import PhotosUI

struct MultiImagePicker: UIViewControllerRepresentable {
    let onImagesSelected: ([UIImage]) -> Void
    let onCancel: () -> Void
    let maxSelection: Int
    
    init(maxSelection: Int = 10, onImagesSelected: @escaping ([UIImage]) -> Void, onCancel: @escaping () -> Void) {
        self.maxSelection = maxSelection
        self.onImagesSelected = onImagesSelected
        self.onCancel = onCancel
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = maxSelection
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MultiImagePicker
        
        init(_ parent: MultiImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.onCancel()
            
            guard !results.isEmpty else { return }
            
            var images: [UIImage] = []
            let group = DispatchGroup()
            
            for result in results {
                group.enter()
                
                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    defer { group.leave() }
                    
                    if let image = object as? UIImage {
                        DispatchQueue.main.async {
                            images.append(image)
                        }
                    }
                }
            }
            
            group.notify(queue: .main) {
                self.parent.onImagesSelected(images)
            }
        }
    }
}
