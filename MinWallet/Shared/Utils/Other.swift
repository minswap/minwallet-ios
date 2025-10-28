import UIKit
import CoreImage


extension Array {
    subscript(safeIndex index: Int) -> Element? {
        get {
            guard 0 <= index && index < count else { return nil }
            return self[index]
        }
        set {
            guard 0 <= index && index < count,
                let value = newValue
            else { return }
            self[index] = value
        }
    }

    public subscript(gk_safeIndex index: Int) -> Element? {
        self[safeIndex: index]
    }
}

extension String {
    var isBlank: Bool {
        trimmingCharacters(in: .whitespacesAndNewlines) == ""
    }

    func generateQRCode(
        centerImage: UIImage?,
        centerImageSize: CGSize = .init(width: 38, height: 38),
        size: CGSize,
        padding: CGFloat = 10,
        centerBackgroundColor: UIColor? = nil
    ) -> UIImage? {
        // Generate QR Code
        guard let data = self.data(using: .ascii),
            let filter = CIFilter(name: "CIQRCodeGenerator")
        else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")  // High error correction

        guard let qrCodeImage = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: size.width / 30, y: size.height / 30)) else {
            return nil
        }

        let qrCodeUIImage = UIImage(ciImage: qrCodeImage)

        // Overlay the center image
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        qrCodeUIImage.draw(in: CGRect(origin: .zero, size: size))

        if let centerImage = centerImage {
            //let centerImageSize = CGSize(width: size.width * 0.3, height: size.height * 0.3)
            let paddedSize = CGSize(
                width: centerImageSize.width + padding * 2,
                height: centerImageSize.height + padding * 2
            )
            let paddedRect = CGRect(
                x: (size.width - paddedSize.width) / 2,
                y: (size.height - paddedSize.height) / 2,
                width: paddedSize.width,
                height: paddedSize.height
            )
            let imageRect = CGRect(
                x: paddedRect.origin.x + padding,
                y: paddedRect.origin.y + padding,
                width: centerImageSize.width,
                height: centerImageSize.height
            )

            if let backgroundColor = centerBackgroundColor {
                // Draw the circular background color
                let circlePath = UIBezierPath(ovalIn: paddedRect)
                backgroundColor.setFill()
                circlePath.fill()
            }

            // Clip the center image to a circle and draw it
            _ = UIBezierPath(ovalIn: imageRect)
            centerImage.draw(in: imageRect)

        }
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return finalImage
    }
}


extension UITapGestureRecognizer {
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)

        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
