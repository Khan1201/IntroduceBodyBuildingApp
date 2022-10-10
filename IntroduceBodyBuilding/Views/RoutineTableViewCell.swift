//
//  RoutineTableViewCell.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/10/05.
//

import Foundation
import UIKit

class RoutineTableViewCell: UITableViewCell {
    
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
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divisionLabel: UILabel!
    @IBOutlet weak var divisionImageView: UIImageView!
    
    @IBOutlet weak var mondayLabel: UILabel!{
        didSet{
            setLabel(to: mondayLabel)
        }
    }
    
    @IBOutlet weak var tuesdayLabel: UILabel!{
        didSet{
            setLabel(to: tuesdayLabel)
        }
    }
    
    @IBOutlet weak var wednesdayLabel: UILabel!{
        didSet{
            setLabel(to: wednesdayLabel)
        }
    }
    
    @IBOutlet weak var thursdayLabel: UILabel!{
        didSet{
            setLabel(to: thursdayLabel)
        }
    }
    
    @IBOutlet weak var fridayLabel: UILabel!{
        didSet{
            setLabel(to: fridayLabel)
        }
    }
    
    @IBOutlet weak var alarmSwitch: UISwitch!
    
}
//MARK: - Label 바인딩

extension RoutineTableViewCell {
    func bindLabel(to label: UILabel, newValue: Bool?){
        if let newValue = newValue{
            if newValue{
                label.backgroundColor = .darkGray
                label.textColor = .systemOrange
            }
        }
    }
}

//MARK: - Label 둥글게 set

extension RoutineTableViewCell {
    func setLabel(to label: UILabel){
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 7
    }
}
