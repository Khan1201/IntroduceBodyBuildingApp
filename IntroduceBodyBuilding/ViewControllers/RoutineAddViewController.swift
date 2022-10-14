//
//  RoutineAddViewController.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/10/13.
//

import UIKit
import RxSwift

class RoutineAddViewController: UIViewController {
    
    var selectedDayBool: [Bool] = [] //월 ~ 금 버튼 선택 체크 flag
    var coreDataDayBools: [Bool] = [] // CoreData 월 ~ 금 각 bool형 변수에 보낼 array

    var weekDayCount: Int = 0 //주 n회 카운트
    var selectedDayCount: Int = 0 //월 ~ 금 버튼 체크 카운트
    
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
            print("값이 존재하지 않음")
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
                        sender.backgroundColor = .black
                        selectedDayBool[index] = true
                        selectedDayCount += 1
                    }
                    else{
                        sender.backgroundColor = .systemGray5
                        selectedDayBool[index] = false
                        selectedDayCount -= 1
                    }
                }
                                
                else{ //요일 선택 해제
                    if selectedDayBool[index] == true {
                        sender.backgroundColor = .systemGray5
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
        print(coreDataDayBools)
    }
    
    let viewModel = RoutineAddViewModel()
    let disposeBag = DisposeBag()
    
    func setDayButton(to label: UIButton) {
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickerView.delegate = nil
        pickerView.dataSource = nil
        
        viewModel.routineAddObservable
            .bind(to: pickerView.rx.itemTitles) { [weak self](row, element) in
                if let self = self{
                    self.programTextField.text = element.title
                    self.divisionTextField.text = element.division
                    self.targetTextField.text = element.recommend
                    self.totalPeriodTextField.text = element.week
                    self.weekNoticeLabel.text = "\(element.weekCount)회 선택하세요 ! "
                    
                    self.weekDayCount = Int(element.weekCount) ?? 0
                    
                    self.selectedDayCount = 0
                    self.selectedDayBool = [false, false, false, false, false]
                    self.coreDataDayBools = [false, false, false, false, false]
                    for dayButton in self.dayButtons{
                        dayButton.backgroundColor = .systemGray5
                    }
                    
                }
                return element.title
            }.disposed(by: disposeBag)
        
    }
}
