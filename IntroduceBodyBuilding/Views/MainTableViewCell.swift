//
//  HealthCell.swift
//  BodyBuildingProgram
//
//  Created by 윤형석 on 2022/08/16.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var weekLabel: UILabel!{
        didSet{
            //underline 생성
            let attributedString = NSMutableAttributedString.init(string: weekLabel.text ?? "")
            attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range:
                NSRange.init(location: 0, length: attributedString.length));
            weekLabel.attributedText = attributedString
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var recommendLabel: UILabel!
    @IBOutlet weak var divisionLabel: UILabel!
    @IBOutlet weak var healthImageView: UIImageView!{
        didSet{
            healthImageView.layer.masksToBounds = true
            healthImageView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var allComponentEmbeddedView: UIView!{
        didSet{
            allComponentEmbeddedView.layer.cornerRadius = 30
        }
    }
    
    
}
