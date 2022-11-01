import Foundation
import UIKit
import UserNotifications

class RoutineTableViewCell: UITableViewCell {
    lazy var viewModel = RoutineViewModel()
    
    
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

    @IBAction func switchAction(_ sender: Any) {
        if alarmSwitch.isOn{
            viewModel.updateSwitchBool(condition: titleLabel.text!, switchBool: alarmSwitch.isOn)
            viewModel.makeLocalNotification(title: titleLabel.text!, days: notificationDays)
        }
        else{
            viewModel.updateSwitchBool(condition: titleLabel.text!, switchBool: alarmSwitch.isOn)
            viewModel.deleteNotification(title: titleLabel.text!, days: notificationDays)
        }
    }
    var mondayBool: Bool?
    var tuesdayBool: Bool?
    var wednesdayBool: Bool?
    var thursdayBool: Bool?
    var fridayBool: Bool?
    
    var notificationDays: [String] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        initializeDayLabel()
        notificationDays = []
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
        bindLabel(to: mondayLabel, dayBool: mondayBool)
        bindLabel(to: tuesdayLabel, dayBool: tuesdayBool)
        bindLabel(to: wednesdayLabel, dayBool: wednesdayBool)
        bindLabel(to: thursdayLabel, dayBool: thursdayBool)
        bindLabel(to: fridayLabel, dayBool: fridayBool)
    }
    
    func bindLabel(to label: UILabel, dayBool: Bool?){
        if let dayBool = dayBool{
            if dayBool{
                label.backgroundColor = .darkGray
                label.textColor = .systemOrange
                notificationDays.append(label.text!) // 해당 요일 활성화 -> notification 배열에 저장
            }
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 7
        }
    }
    func getNotificationDays() -> [String]{
        return notificationDays
    }
    
}
