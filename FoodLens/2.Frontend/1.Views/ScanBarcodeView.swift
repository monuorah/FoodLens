//
//  ScanBarcodeView.swift
//  FoodLens
//
//  Created by Melanie & Muna on 10/29/25.
//

import SwiftUI
import AVFoundation
import Combine

struct ScanBarcodeView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BarcodeScannerViewModel()

    var body: some View {
        ZStack {
            // Camera preview
            if viewModel.cameraPermissionGranted {
                CameraPreviewView(scanner: viewModel.scanner)
                    .ignoresSafeArea()
            } else {
                Color.fblack.ignoresSafeArea()
            }

            // Overlay
            VStack {
                // Top bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundStyle(.fwhite)
                            .padding(12)
                            .background(Circle().fill(Color.fblack.opacity(0.5)))
                    }
                    Spacer()
                }
                .padding()

                Spacer()

                // Scan frame
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.forange, lineWidth: 3)
                    .frame(width: 280, height: 180)
                    .overlay(
                        // Corner accents
                        ZStack {
                            // Top-left
                            CornerShape()
                                .stroke(Color.forange, lineWidth: 4)
                                .frame(width: 40, height: 40)
                                .position(x: 20, y: 20)

                            // Top-right
                            CornerShape()
                                .stroke(Color.forange, lineWidth: 4)
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(90))
                                .position(x: 260, y: 20)

                            // Bottom-left
                            CornerShape()
                                .stroke(Color.forange, lineWidth: 4)
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(-90))
                                .position(x: 20, y: 160)

                            // Bottom-right
                            CornerShape()
                                .stroke(Color.forange, lineWidth: 4)
                                .frame(width: 40, height: 40)
                                .rotationEffect(.degrees(180))
                                .position(x: 260, y: 160)
                        }
                    )

                Spacer()

                // Status message
                VStack(spacing: 12) {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.fwhite)
                        Text("Looking up product...")
                            .foregroundStyle(.fwhite)
                            .font(.system(.body, design: .rounded))
                    } else if let error = viewModel.errorMessage {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title2)
                            .foregroundStyle(.fred)
                        Text(error)
                            .foregroundStyle(.fwhite)
                            .font(.system(.body, design: .rounded))
                            .multilineTextAlignment(.center)
                    } else if !viewModel.cameraPermissionGranted {
                        Image(systemName: "camera.fill")
                            .font(.title2)
                            .foregroundStyle(.forange)
                        Text("Camera access required")
                            .foregroundStyle(.fwhite)
                            .font(.system(.headline, design: .rounded))
                        Button("Open Settings") {
                            if let url = URL(string: UIApplication.openSettingsURLString) {
                                UIApplication.shared.open(url)
                            }
                        }
                        .foregroundStyle(.forange)
                        .font(.system(.body, design: .rounded))
                    } else {
                        Image(systemName: "barcode.viewfinder")
                            .font(.title2)
                            .foregroundStyle(.forange)
                        Text("Position barcode in frame")
                            .foregroundStyle(.fwhite)
                            .font(.system(.body, design: .rounded))
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.fblack.opacity(0.7))
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            viewModel.startScanning()
        }
        .onDisappear {
            viewModel.stopScanning()
        }
        .navigationDestination(item: $viewModel.scannedFood) { food in
            FoodView(foodItem: food)
        }
    }
}

// MARK: - Corner Shape for scan frame

private struct CornerShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}

// MARK: - Camera Preview UIViewRepresentable

struct CameraPreviewView: UIViewRepresentable {
    let scanner: BarcodeScannerService

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        scanner.setupCamera(in: view)
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        scanner.updatePreviewFrame(uiView.bounds)
    }
}

// MARK: - ViewModel

class BarcodeScannerViewModel: NSObject, ObservableObject {
    @Published var cameraPermissionGranted = false
    @Published var scannedFood: FoodItem?
    @Published var isLoading = false
    @Published var errorMessage: String?

    let scanner = BarcodeScannerService()
    private let foodLookupService = OpenFoodFactsService()

    override init() {
        super.init()
        scanner.delegate = self
        checkCameraPermission()
    }

    func checkCameraPermission() {
        scanner.requestCameraPermission { [weak self] granted in
            DispatchQueue.main.async {
                self?.cameraPermissionGranted = granted
            }
        }
    }

    func startScanning() {
        guard cameraPermissionGranted else { return }
        errorMessage = nil
        scanner.startScanning()
    }

    func stopScanning() {
        scanner.stopScanning()
    }

    private func lookupBarcode(_ barcode: String) {
        DispatchQueue.main.async {
            self.isLoading = true
            self.errorMessage = nil
        }

        Task {
            do {
                let food = try await foodLookupService.lookupBarcode(barcode)
                await MainActor.run {
                    self.scannedFood = food
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Product not found.\nTry searching manually."
                }
                // Resume scanning after error
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                await MainActor.run {
                    self.errorMessage = nil
                }
            }
        }
    }
}

extension BarcodeScannerViewModel: BarcodeScannerDelegate {
    func didDetectBarcode(_ barcode: String) {
        lookupBarcode(barcode)
    }

    func didFailWithError(_ error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ScanBarcodeView()
}
