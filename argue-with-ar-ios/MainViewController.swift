import ARKit
import SceneKit
import UIKit

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

// MARK: ARSCNView Delegate

extension MainViewController: ARSCNViewDelegate, ARSessionDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        DispatchQueue.main.async {
            let imageName = imageAnchor.referenceImage.name ?? ""
            let alert = UIAlertController(title: "Detected", message: "Image: \(imageName)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            if let existingAlert = self.presentedViewController {
                existingAlert.dismiss(animated: false)
            }
            self.sceneView.session.remove(anchor: anchor)
            self.present(alert, animated: true)
            print("Detected \(imageName)!!!")
        }
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