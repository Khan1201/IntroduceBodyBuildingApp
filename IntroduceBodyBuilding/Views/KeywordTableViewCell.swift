//
//  KeywordTableViewCell.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/11/26.
//

import UIKit

class KeywordTableViewCell: UITableViewCell {
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorView: UIView!{
        didSet{
            colorView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var checkImage: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
