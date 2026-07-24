import SwiftUI
import AVFoundation

@MainActor
@Observable
final class CameraPreviewService: NSObject {
    enum CameraState {
        case idle, configuring, running, unauthorized, unavailable
    }

    let session = AVCaptureSession()
    private(set) var state: CameraState = .idle
    private let sessionQueue = DispatchQueue(label: "com.yonigolfor.Stoic.cameraSessionQueue")

    func start() {
        guard state == .idle else { return }
        state = .configuring

        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndStart()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                Task { @MainActor in
                    guard let self else { return }
                    granted ? self.configureAndStart() : (self.state = .unauthorized)
                }
            }
        default:
            state = .unauthorized
        }
    }

    func stop() {
        sessionQueue.async { [session] in
            if session.isRunning { session.stopRunning() }
        }
        state = .idle
    }

    private func configureAndStart() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let input = try? AVCaptureDeviceInput(device: device) else {
            state = .unavailable
            return
        }

        sessionQueue.async { [session] in
            session.beginConfiguration()
            session.sessionPreset = .high
            if session.canAddInput(input) { session.addInput(input) }
            session.commitConfiguration()
            session.startRunning()

            Task { @MainActor [weak self] in
                self?.state = .running
            }
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewUIView, context: Context) {}

    final class PreviewUIView: UIView {
        override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
        var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
    }
}
