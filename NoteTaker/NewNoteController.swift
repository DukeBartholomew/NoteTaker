//
//  NewNoteController.swift
//  NoteTaker
//
//  Created by Duke Bartholomew on 12/6/23.
//

import UIKit

class NewNoteController: UIViewController {

    @IBOutlet weak var micButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the image content mode to scale aspect fit
        micButton.imageView?.contentMode = .scaleAspectFit
        
        // Get the original image
        if let originalImage = micButton.imageView?.image {
            // Resize the image (change 2.0 to your desired scale factor)
            let resizedImage = originalImage.resized(to: CGSize(width: originalImage.size.width * 5.0, height: originalImage.size.height * 5.0))
            
            // Tint the image with orange color
            let tintedImage = resizedImage.withRenderingMode(.alwaysTemplate)
            
            // Set the tinted image to the button
            micButton.setImage(tintedImage, for: .normal)
            
            // Set the tint color to orange
            micButton.tintColor = UIColor.orange
        }
    }
}

// Extension to resize UIImage
extension UIImage {
    func resized(to newSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
