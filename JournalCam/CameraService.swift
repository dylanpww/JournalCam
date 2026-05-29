//
//  CameraService.swift
//  JournalCam
//
//  Created by student on 29/05/26.
//

import SwiftUI
import AVFoundation
import UIKit

@Observable
class CameraService: NSObject {
    var capturedImage: UIImage?
    var error: String?

    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?

    func start() async {
        guard await checkPermission() else {
            error = "Camera access denied"
            return
        }
        session.beginConfiguration()
        session.sessionPreset = .photo

        // Front camera for selfies
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                    for: .video,
                                                    position: .front),
              let input = try? AVCaptureDeviceInput(device: device)
        else { return }

        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        session.commitConfiguration()

        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill

        Task.detached { await self.session.startRunning() }
    }

    func capture() {
        let settings = AVCapturePhotoSettings()
        output.capturePhoto(with: settings, delegate: self)
    }

    private func checkPermission() async -> Bool {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: return true
        case .notDetermined: return await AVCaptureDevice.requestAccess(for: .video)
        default: return false
        }
    }
}

extension CameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        Task { @MainActor in self.capturedImage = image }
    }
}


