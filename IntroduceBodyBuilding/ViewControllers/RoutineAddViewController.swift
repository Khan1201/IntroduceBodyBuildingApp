//
//  RoutineAddViewController.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/10/13.
//

import UIKit
import RxSwift
import CoreData

class RoutineAddViewController: UIViewController {
    
    let viewModel = RoutineAddViewModel()
    let disposeBag = DisposeBag()
    
    lazy var selectedDayBool: [Bool] = [] //월 ~ 금 버튼 선택 체크 flag

    lazy var weekDayCount: Int = 0 //운동 총 기간 중, 주 n회 카운트
    lazy var selectedDayCount: Int = 0 //월 ~ 금 버튼 체크 카운트
    
    lazy var coreDataDayBools: [Bool] = [] // CoreData의 월 ~ 금 각 bool형 변수에 보낼 array
    var coreDataDivisionIconName: String {
        switch divisionTextField.text{
        case "BodyBuilding":
            return "BBIcon"
        case "PowerBuilding":
            return "PBIcon"
        case "PowerLifting":
            return "PLIcon"
        default:
            print("구분 값을 알 수 없습니다.")
            return ""
        }
    }
    var coreDataSwitchBool: Bool {
        let resultBool = noticeSwitch.isOn ? true : false
        return resultBool
    }
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var embeddedView: UIView!{
        didSet{
            embeddedView.layer.masksToBounds = true
            embeddedView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var programTextField: UITextField!
    

    @IBOutlet var dayButtons: [UIButton]!{
        didSet{
            for dayButton in dayButtons{
                setDayButton(to: dayButton)
            }
        }
    }
    @IBOutlet weak var noticeSwitch: UISwitch!
    
    
    func setCoreDataDayBools(condition: String, selectedBoolIndex index: Int){
        switch condition {
        case "월" :
            setCoreDataDayBool(condition: index, at: 0)
        case "화" :
            setCoreDataDayBool(condition: index, at: 1)
        case "수" :
            setCoreDataDayBool(condition: index, at: 2)
        case "목" :
            setCoreDataDayBool(condition: index, at: 3)
        case "금" :
            setCoreDataDayBool(condition: index, at: 4)
        default:
            print("Day 값 존재하지 않음")
        }
        
        func setCoreDataDayBool(condition selectedBoolIndex: Int, at coreDataBoolIndex: Int){
            if selectedDayBool[selectedBoolIndex] == false {
                coreDataDayBools[coreDataBoolIndex] = true
            }
            else{
                coreDataDayBools[coreDataBoolIndex] = false
            }
        }
    }
    
    
    
    
    @IBAction func addDayButtonAction(_ sender: UIButton) {

        for (index, dayButton) in dayButtons.enumerated() {
            if sender.currentTitle == dayButton.currentTitle {
                
                setCoreDataDayBools(condition: sender.currentTitle!, selectedBoolIndex: index)

                if selectedDayCount < weekDayCount {
                    if (selectedDayBool[index] == false) { //요일 선택
                        sender.backgroundColor = .darkGray
                        sender.tintColor = .systemOrange
                        selectedDayBool[index] = true
                        selectedDayCount += 1
                    }
                    else{
                        sender.backgroundColor = .systemGray5
                        sender.tintColor = .systemGray2
                        selectedDayBool[index] = false
                        selectedDayCount -= 1
                    }
                }
                                
                else{ //요일 선택 해제
                    if selectedDayBool[index] == true {
                        sender.backgroundColor = .systemGray5
                        sender.tintColor = .systemGray2
                        selectedDayBool[index] = false
                        selectedDayCount -= 1
                    }
                }
            }
        }
    }
    

    @IBOutlet weak var divisionTextField: UITextField!
    
    @IBOutlet weak var targetTextField: UITextField!
    
    @IBOutlet weak var totalPeriodTextField: UITextField!
    
    @IBOutlet weak var weekNoticeLabel: UILabel!
        
    @IBAction func addCancelAction(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    @IBAction func addSaveAction(_ sender: Any) {
        viewModel.saveData(title: programTextField.text ?? "", imageName: coreDataDivisionIconName, divisionName: divisionTextField.text ?? "", dayBools: coreDataDayBools, switchBool: coreDataSwitchBool)
        self.presentingViewController?.dismiss(animated: true)
    }
    

    
    func setDayButton(to label: UIButton) {
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
    }
    
    func resetInitialState(){
        self.selectedDayCount = 0
        self.selectedDayBool = [false, false, false, false, false]
        self.coreDataDayBools = [false, false, false, false, false]
        for dayButton in self.dayButtons{
            dayButton.backgroundColor = .systemGray5
            dayButton.tintColor = .systemGray2
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = nil
        pickerView.dataSource = nil
        
        
        
        viewModel.routineAddObservable
            .bind(to: pickerView.rx.itemTitles) { (_, element) in
                return element.title
            }.disposed(by: disposeBag)
        
        
        
        pickerView.rx.modelSelected(RoutineVCModel.Fields.self)
            .subscribe { [weak self] element in
                if let self = self{
                    self.programTextField.text = element[0].title
                    self.divisionTextField.text = element[0].division
                    self.targetTextField.text = element[0].recommend
                    self.totalPeriodTextField.text = element[0].week
                    self.weekNoticeLabel.text = "최대 \(element[0].weekCount)회 선택하세요 ! "

                    self.weekDayCount = Int(element[0].weekCount) ?? 0
                    self.resetInitialState()
                }
            }.disposed(by: disposeBag)
    }
}
