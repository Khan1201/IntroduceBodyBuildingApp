//
//  RoutineTableViewCell.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/10/05.
//

import Foundation
import UIKit

class RoutineTableViewCell: UITableViewCell {
    
    var darkModeBool: Bool?{
        willSet{
            
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divisionLabel: UILabel!
    @IBOutlet weak var divisionImageView: UIImageView!{
        didSet{
            divisionImageView.layer.masksToBounds = true
            divisionImageView.layer.cornerRadius = 7
        }
    }
    
    var mondayBool: Bool?{
        willSet{
            bindLabel(to: mondayLabel, newValue: newValue)
        }
    }
    var tuesdayBool: Bool?{
        willSet{
            bindLabel(to: tuesdayLabel, newValue: newValue)
        }
    }
    var wednesdayBool: Bool?{
        willSet{
            bindLabel(to: wednesdayLabel, newValue: newValue)
        }
    }
    var thursdayBool: Bool?{
        willSet{
            bindLabel(to: thursdayLabel, newValue: newValue)
        }
    }
    var fridayBool: Bool?{
        willSet{
            bindLabel(to: fridayLabel, newValue: newValue)
        }
    }
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    
    @IBOutlet weak var alarmSwitch: UISwitch!
    
}
//MARK: - dayBool -> Label 바인딩, Label 테두리 set

extension RoutineTableViewCell {
    func bindLabel(to label: UILabel, newValue: Bool?){
        if let newValue = newValue{
            if newValue{
                label.backgroundColor = .darkGray
                label.textColor = .systemOrange
            }
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 7
        }
    }
}
