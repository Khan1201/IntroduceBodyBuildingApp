//
//  RoutineTableViewCell.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/10/05.
//

import Foundation
import UIKit

class RoutineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var divisionLabel: UILabel!
    @IBOutlet weak var divisionImageView: UIImageView!{
        didSet{
            divisionImageView.layer.masksToBounds = true
            divisionImageView.layer.cornerRadius = 7
        }
    }
    
    @IBOutlet weak var mondayLabel: UILabel!
    @IBOutlet weak var tuesdayLabel: UILabel!
    @IBOutlet weak var wednesdayLabel: UILabel!
    @IBOutlet weak var thursdayLabel: UILabel!
    @IBOutlet weak var fridayLabel: UILabel!
    
    @IBOutlet weak var alarmSwitch: UISwitch!

    var mondayBool: Bool?
    var tuesdayBool: Bool?
    var wednesdayBool: Bool?
    var thursdayBool: Bool?
    var fridayBool: Bool?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        initializeDayLabel()
        bindAllLabel()
    }
}
//MARK: - Day Label 초기화, dayBool: true -> Label 색 변경

extension RoutineTableViewCell {
    
    func initializeDayLabel() {
        mondayLabel.backgroundColor = .systemGray5
        mondayLabel.textColor = .systemGray2

        tuesdayLabel.backgroundColor = .systemGray5
        tuesdayLabel.textColor = .systemGray2

        wednesdayLabel.backgroundColor = .systemGray5
        wednesdayLabel.textColor = .systemGray2

        thursdayLabel.backgroundColor = .systemGray5
        thursdayLabel.textColor = .systemGray2

        fridayLabel.backgroundColor = .systemGray5
        fridayLabel.textColor = .systemGray2
    }
    
    func bindAllLabel() {
        bindLabel(to: mondayLabel, newValue: mondayBool)
        bindLabel(to: tuesdayLabel, newValue: tuesdayBool)
        bindLabel(to: wednesdayLabel, newValue: wednesdayBool)
        bindLabel(to: thursdayLabel, newValue: thursdayBool)
        bindLabel(to: fridayLabel, newValue: fridayBool)
    }
    
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
