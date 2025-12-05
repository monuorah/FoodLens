//
//  BarcodeScannerService.swift
//  FoodLens
//
//  Created by Melanie & Muna on 12/4/24.
//

import AVFoundation
import Vision
import UIKit

protocol BarcodeScannerDelegate: AnyObject {
    func didDetectBarcode(_ barcode: String)
    func didFailWithError(_ error: Error)
}

class BarcodeScannerService: NSObject {
    weak var delegate: BarcodeScannerDelegate?

    private let captureSession = AVCaptureSession()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "barcodeScannerQueue")
    private var isScanning = false
    private var isConfigured = false

    // Debounce to avoid multiple detections of same barcode
    private var lastScannedBarcode: String?
    private var lastScanTime: Date?
    private let scanDebounceInterval: TimeInterval = 2.0

    var isAuthorized: Bool {
        AVCaptureDevice.authorizationStatus(for: .video) == .authorized
    }

    // MARK: - Setup

    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        @unknown default:
            completion(false)
        }
    }

    func setupCamera(in view: UIView) {
        sessionQueue.async { [weak self] in
            self?.configureSession(in: view)
        }
    }

    private func configureSession(in view: UIView) {
        guard !isConfigured else { return }

        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high

        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            captureSession.commitConfiguration()
            DispatchQueue.main.async {
                self.delegate?.didFailWithError(ScannerError.cameraUnavailable)
            }
            return
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        // Add video output for Vision framework
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        videoOutput.alwaysDiscardsLateVideoFrames = true

        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        captureSession.commitConfiguration()
        isConfigured = true

        // Setup preview layer on main thread and then start scanning
        DispatchQueue.main.async {
            self.setupPreviewLayer(in: view)
        }

        // Start running after configuration is complete
        isScanning = true
        captureSession.startRunning()
    }

    private func setupPreviewLayer(in view: UIView) {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.insertSublayer(previewLayer, at: 0)
        self.previewLayer = previewLayer
    }

    // MARK: - Scanning Control

    func startScanning() {
        sessionQueue.async { [weak self] in
            guard let self = self, self.isConfigured, !self.captureSession.isRunning else { return }
            self.isScanning = true
            self.captureSession.startRunning()
        }
    }

    func stopScanning() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            self.isScanning = false
            if self.captureSession.isRunning {
                self.captureSession.stopRunning()
            }
        }
    }

    func updatePreviewFrame(_ frame: CGRect) {
        DispatchQueue.main.async {
            self.previewLayer?.frame = frame
        }
    }

    // MARK: - Barcode Detection

    private func detectBarcode(in sampleBuffer: CMSampleBuffer) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNDetectBarcodesRequest { [weak self] request, error in
            if let error = error {
                DispatchQueue.main.async {
                    self?.delegate?.didFailWithError(error)
                }
                return
            }

            self?.handleBarcodeResults(request.results as? [VNBarcodeObservation])
        }

        // Support common food barcode formats
        request.symbologies = [.ean13, .ean8, .upce, .code128, .code39]

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        try? handler.perform([request])
    }

    private func handleBarcodeResults(_ results: [VNBarcodeObservation]?) {
        guard let results = results, let firstResult = results.first,
              let barcodeValue = firstResult.payloadStringValue else { return }

        // Debounce - don't report same barcode within interval
        let now = Date()
        if let lastBarcode = lastScannedBarcode,
           let lastTime = lastScanTime,
           lastBarcode == barcodeValue,
           now.timeIntervalSince(lastTime) < scanDebounceInterval {
            return
        }

        lastScannedBarcode = barcodeValue
        lastScanTime = now

        DispatchQueue.main.async {
            self.delegate?.didDetectBarcode(barcodeValue)
        }
    }

    // MARK: - Errors

    enum ScannerError: LocalizedError {
        case cameraUnavailable
        case permissionDenied

        var errorDescription: String? {
            switch self {
            case .cameraUnavailable:
                return "Camera is not available on this device."
            case .permissionDenied:
                return "Camera permission was denied. Please enable it in Settings."
            }
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension BarcodeScannerService: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard isScanning else { return }
        detectBarcode(in: sampleBuffer)
    }
}
