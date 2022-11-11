import Foundation
import UIKit

class DetailTableViewCell: UITableViewCell{
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var numberImageView: UIImageView!{
        didSet{
            numberImageView.layer.masksToBounds = true
            numberImageView.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var routinLabel: UILabel!{
        didSet{
            let attrString = NSMutableAttributedString(string: routinLabel.text!)
            let paragraphStyle = NSMutableParagraphStyle()
            
            routinLabel.lineBreakMode = .byWordWrapping
            routinLabel.numberOfLines = 0
            paragraphStyle.lineSpacing = 10
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            routinLabel.attributedText = attrString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .systemGray6
    }
    
}
