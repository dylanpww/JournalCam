//
//  CameraPreview.swift
//  JournalCam
//
//  Created by student on 29/05/26.
//

import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    let service: CameraService

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        if let layer = service.previewLayer {
            layer.frame = UIScreen.main.bounds
            view.layer.addSublayer(layer)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

