//
//  HealthCell.swift
//  BodyBuildingProgram
//
//  Created by 윤형석 on 2022/08/16.
//

import UIKit

class MainVCCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var recommendLabel: UILabel!
    @IBOutlet weak var divisionLabel: UILabel!
    @IBOutlet weak var healthImageView: UIImageView!
    @IBOutlet weak var allComponentEmbeddedView: UIView!{
        didSet{
            allComponentEmbeddedView.layer.cornerRadius = 30
        }
    }
    
    
}
