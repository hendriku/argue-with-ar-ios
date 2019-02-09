import UIKit
import ARKit

class PersistentARReferenceImage: ARReferenceImage, NSCoding {
    
    let image: UIImage
    
    init(image: UIImage, physicalWidth: CGFloat, name: String) {
        self.image = image
        super.init(image.cgImage!, orientation: CGImagePropertyOrientation.up, physicalWidth: physicalWidth)
        super.name = name
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(image, forKey: "image")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(physicalSize.width, forKey: "physicalWidth")
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(image: aDecoder.decodeObject(forKey: "image") as! UIImage, physicalWidth: aDecoder.decodeObject(forKey: "physicalWidth") as! CGFloat, name: aDecoder.decodeObject(forKey: "name") as! String)
    }
}
