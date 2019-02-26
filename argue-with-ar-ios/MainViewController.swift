import ARKit
import SceneKit
import UIKit
import AVFoundation

class MainViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var detectionImages: [PersistentARReferenceImage]!
    var fullPath: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("arimgdb")
    }
    
    @IBAction func didTapAdd() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    var timestamp: DispatchTime?
    
    @IBAction func didTapRecord() {
        classify(image: sceneView.snapshot())
    }

    // MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        loadARResources()
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
        
		UIApplication.shared.isIdleTimerDisabled = true
        resetTracking()
        print("Started new session!")
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
        sceneView.session.pause()
        print("Pausing session...")
    }
    
    // MARK: Helper Methods
    
    // Source: Stackoverflow https://stackoverflow.com/questions/27207278/how-to-turn-flashlight-on-and-off-in-swift
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                } catch {
                    print(error)
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    func resetTracking() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = Set(detectionImages)
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func classify(image: UIImage) {
        let storyboard = UIStoryboard(name: "Classification", bundle: nil)
        let classificationVC = storyboard.instantiateViewController(withIdentifier: "ClassificationVC") as! ClassificationViewController
        classificationVC.modalTransitionStyle = .flipHorizontal
        classificationVC.image = image
        classificationVC.mainViewController = self
        self.present(classificationVC, animated: true)
    }
}

// MARK: AR Delegate

extension MainViewController: ARSCNViewDelegate, ARSessionDelegate {
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .limited(ARCamera.TrackingState.Reason.initializing):
//            Uncomment for additional light simulation
//            toggleFlash()
            break
        case .normal:
            print("STATE: \(camera.trackingState)")
            if timestamp == nil {
                timestamp = DispatchTime.now()
                DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
                    print("XXXXXXX: ")
                    self.doSafeExit()
                }
            }
        default:
            print("STATE: \(camera.trackingState)")
        }
    }
    
    func doSafeExit() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            exit(0)
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        print("SESSION-ERROR: \(error)")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARImageAnchor else { return }
        print("XXXXXXX: \((DispatchTime.now().uptimeNanoseconds - timestamp!.uptimeNanoseconds) / 1000000 )")
        doSafeExit()
    }
    
    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
}

// MARK: Persistent Storage

extension MainViewController {
    func loadARResources() {
        detectionImages = []
        do {
            let data = try Data(contentsOf: fullPath)
            if let loadedResources = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [PersistentARReferenceImage] {
                detectionImages = loadedResources
            }
        } catch {
            print("Couldn't read set of ar resources")
            print(error)
        }
    }
    
    func saveARResources() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: detectionImages, requiringSecureCoding: false)
            try data.write(to: fullPath)
        } catch {
            print("Couldn't write set of ar resources")
            print(error)
        }
    }
}

// MARK: Image Picker Delegate

extension MainViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            picker.dismiss(animated: true) {
                self.classify(image: pickedImage)
            }
        }
    }
}
