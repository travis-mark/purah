//  Purah - PhotosView.swift
//  Created by Travis Luckenbaugh on 6/3/23.

import SwiftUI
import PhotosUI

// TODO: Photos View
// TODO: Photos Details
// TODO: Thumbnail sizes
struct PhotosView: View {
    @State private var photos: [UIImage] = []
        
    var body: some View {
        List(photos, id: \.self) { photo in
            Image(uiImage: photo)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .onAppear {
            loadPhotos()
        }
    }
        
    func loadPhotos() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            if status == .authorized {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                if fetchResult.count > 0 {
                    for i in 0..<fetchResult.count {
                        let asset = fetchResult.object(at: i)
                        let manager = PHImageManager.default()
                        let options = PHImageRequestOptions()
                        options.isSynchronous = true
                        options.deliveryMode = .highQualityFormat
                        manager.requestImage(for: asset, targetSize: CGSize(width: 200, height: 200), contentMode: .aspectFit, options: options) { image, info in
                            if let image = image {
                                self.photos.append(image)
                            }
                        }
                    }
                }
            } else {
                // TODO: Photos handle error
            }
        }
    }
}
