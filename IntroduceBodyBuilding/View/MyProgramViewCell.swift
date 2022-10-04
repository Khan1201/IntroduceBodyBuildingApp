//
//  MyProgramViewCell.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/09/29.
//

import Foundation
import UIKit

    class BBCollectionViewCell: UICollectionViewCell {
        
        
        @IBOutlet weak var BBAllComponentEmbeddedView: UIView!
        
        @IBOutlet weak var BBimageView: UIImageView!
        {
            didSet{
                BBimageView.layer.cornerRadius = 10
                BBimageView.layer.borderColor = UIColor.systemGray.cgColor
                BBimageView.layer.borderWidth = 0.5
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
                PBimageView.layer.borderColor = UIColor.systemGray.cgColor
                PBimageView.layer.borderWidth = 0.5
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
                PLimageView.layer.borderColor = UIColor.systemGray.cgColor
                PLimageView.layer.borderWidth = 0.5
            }
        }
        
        @IBOutlet weak var PLTitleLabel: UILabel!
        
    }

