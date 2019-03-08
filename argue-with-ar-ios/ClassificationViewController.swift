import ARKit
import UIKit

class ClassificationViewController: UIViewController {
    
    @IBOutlet var displayImage: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var widthTextField: UITextField!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    var mainViewController: MainViewController?
    var image: UIImage?

    override func viewDidLoad() {
        displayImage.image = UIImage(cgImage: image!.cgImage!)
        let tapInBackground = UITapGestureRecognizer(target: self, action: #selector(self.hideKeyboard (_:)))
        view.addGestureRecognizer(tapInBackground)
    }
    
    @objc func hideKeyboard (_ sender: UITapGestureRecognizer) {
        nameTextField.resignFirstResponder()
        widthTextField.resignFirstResponder()
    }
    
    @IBAction func didTapCancel() {
        dismiss(animated: true)
    }
    
    @IBAction func didTapSave() {
        if let physicalWidth = Float(widthTextField.text?.replacingOccurrences(of: ",", with: ".") ?? "") {
            mainViewController!.detectionImages.append(PersistentARReferenceImage(image: image!, physicalWidth: CGFloat(physicalWidth), name: nameTextField.text!))
            mainViewController!.saveARResources()
            dismiss(animated: true)
        }
    }
}

