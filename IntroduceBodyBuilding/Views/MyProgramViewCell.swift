import Foundation
import UIKit

    class BBCollectionViewCell: UICollectionViewCell {
        @IBOutlet weak var BBAllComponentEmbeddedView: UIView!
        @IBOutlet weak var BBimageView: UIImageView!
        {
            didSet{
                BBimageView.layer.cornerRadius = 10
            }
        }
        @IBOutlet weak var BBTitleLabel: UILabel!
    }
    
    class PBCollectionViewCell: UICollectionViewCell {
        @IBOutlet weak var PBAllComponentEmbeddedView: UIView!
        @IBOutlet weak var PBimageView: UIImageView!
        {
            didSet{
                PBimageView.layer.cornerRadius = 10
            }
        }
        @IBOutlet weak var PBTitleLabel: UILabel!
    }
    
    class PLCollectionViewCell: UICollectionViewCell {
        
        @IBOutlet weak var PLAllComponentEmbeddedView: UIView!
        @IBOutlet weak var PLimageView: UIImageView!
        {
            didSet{
                PLimageView.layer.cornerRadius = 10
            }
        }
        @IBOutlet weak var PLTitleLabel: UILabel!
    }

