//
//  BarcodeScannerView.swift
//  medicinetime
//
//  Created on 2026-03-10.
//

import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    let onBarcodeScanned: (String) -> Void
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.onBarcodeScanned = onBarcodeScanned
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {
        // No update needed
    }
}

// MARK: - Scanner View Controller
class ScannerViewController: UIViewController {
    var onBarcodeScanned: ((String) -> Void)?
    
    private let captureSession = AVCaptureSession()
    private let videoPreviewLayer = AVCaptureVideoPreviewLayer()
    private let scanLineView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCaptureSession()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureSession.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureSession.stopRunning()
    }
    
    private func setupCaptureSession() {
        captureSession.sessionPreset = .high
        
        guard let camera = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: camera),
              captureSession.canAddInput(input) else {
            return
        }
        
        captureSession.addInput(input)
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        guard captureSession.canAddOutput(metadataOutput) else {
            return
        }
        
        captureSession.addOutput(metadataOutput)
        
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        metadataOutput.metadataObjectTypes = [.ean8, .ean13, .upce, .code128, .code39, .code93, .qr]
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        videoPreviewLayer.session = captureSession
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.frame = view.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        // Scan line
        scanLineView.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.5)
        scanLineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanLineView)
        
        NSLayoutConstraint.activate([
            scanLineView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scanLineView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scanLineView.heightAnchor.constraint(equalToConstant: 2),
            scanLineView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100)
        ])
        
        animateScanLine()
        
        // Close button
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func animateScanLine() {
        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse], animations: {
            self.scanLineView.transform = CGAffineTransform(translationX: 0, y: 200)
        })
    }
    
    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let barcodeValue = readableObject.stringValue else {
            return
        }
        
        // Vibrate
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Play sound
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        
        onBarcodeScanned?(barcodeValue)
        dismiss(animated: true)
    }
}

// MARK: - Preview
struct BarcodeScannerView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeScannerView { barcode in
            print("Scanned: \(barcode)")
        }
    }
}
