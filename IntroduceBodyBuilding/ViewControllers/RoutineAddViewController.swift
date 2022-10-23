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
    //MARK: - UI 변수
    
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
                dayButton.layer.masksToBounds = true
                dayButton.layer.cornerRadius = 6
            }
        }
    }
    @IBOutlet weak var divisionTextField: UITextField!
    @IBOutlet weak var targetTextField: UITextField!
    @IBOutlet weak var totalPeriodTextField: UITextField!
    @IBOutlet weak var weekNoticeLabel: UILabel!
    @IBOutlet weak var noticeSwitch: UISwitch!
    //MARK: - 해당 VC의 UI event를 위한 변수
    
    lazy var routineViewModel = RoutineViewModel()
    let routineAddviewModel = RoutineAddViewModel()
    let disposeBag = DisposeBag()
    lazy var selectedDayBools: [Bool] = [] // 월 ~ 금 버튼 선택 체크 확인 bool
    lazy var selectedDayStrings: [String] = [] // 월 ~ 금 선택된 버튼 요일 array
    lazy var weekDayCount: Int = 0 // 운동 총 기간 중, 주 n회 카운트
    lazy var selectedDayCount: Int = 0 //월 ~ 금 버튼 체크 카운트 (버튼 최대 선택 카운트)
    //MARK: - CoreData에 저장할 데이터
    
    lazy var coreDataDayBools: [Bool] = [] // CoreData의 월 ~ 금 변수에 보낼 array
    var coreDataDivisionIconName: String { // CoreData의 아이콘 구분 변수에 보낼 변수
        switch divisionTextField.text{ // division 데이터로 운동 종류 구분
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
    var coreDataSwitchBool: Bool { //CoreData의 스위치 구분 변수에 보낼 변수
        let resultBool = noticeSwitch.isOn ? true : false
        return resultBool
    }
    //MARK: - @IBAction
    
    @IBAction func addDayButtonAction(_ sender: UIButton) {
        setDayButtons(sender: sender)
    }
    @IBAction func addCancelAction(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    @IBAction func addSaveAction(_ sender: Any) {
       
        // coredata 접근 후 중복 확인. 중복이면 저장 x -> 중복o bool return, 중복아니면 저장 -> 중복x bool return
        let duplicatedBool = routineAddviewModel.returnDuplicatedBoolAfterSaveData(title: programTextField.text!, imageName: coreDataDivisionIconName, divisionName: divisionTextField.text!, dayBools: coreDataDayBools, switchBool: coreDataSwitchBool, notificationIndex: selectedDayCount, viewController: self)
        
        if duplicatedBool == false{
            
            // 알림 스위치 on -> 해당 프로그램 notification 등록
            if coreDataSwitchBool{
                routineViewModel.makeLocalNotification(title: programTextField.text!, days: selectedDayStrings)
            }
            self.presentingViewController?.dismiss(animated: true)
        }
    }
    //MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindPickerView()
    }
}
//MARK: - pickerView 바인딩

extension RoutineAddViewController {
    private func bindPickerView(){
        pickerView.delegate = nil
        pickerView.dataSource = nil
        bindPickerViewData(data: routineAddviewModel.routineAddObservable)
        addSelectEvent()
        
        func bindPickerViewData(data: BehaviorSubject<[RoutineVCModel.Fields]>){
            data
                .bind(to: pickerView.rx.itemTitles) { (_, element) in
                    return element.title
                }.disposed(by: disposeBag)
        }
        
        // 피커뷰 선택 이벤트
        func addSelectEvent(){
            pickerView.rx.modelSelected(RoutineVCModel.Fields.self)
                .subscribe { [weak self] element in
                    if let self = self{
                        resetInitialState()
                        self.programTextField.text = element[0].title
                        self.divisionTextField.text = element[0].division
                        self.targetTextField.text = element[0].recommend
                        self.totalPeriodTextField.text = element[0].week
                        self.weekNoticeLabel.text = "최대 \(element[0].weekCount)회 선택하세요 ! "
                        self.weekDayCount = Int(element[0].weekCount) ?? 0
                    }
                }.disposed(by: disposeBag)
            
            // 피커뷰 UI event 데이터 초기화
            func resetInitialState(){
                self.selectedDayCount = 0
                self.selectedDayBools = [false, false, false, false, false]
                self.coreDataDayBools = [false, false, false, false, false]
                for dayButton in self.dayButtons{
                    dayButton.backgroundColor = .systemGray5
                    dayButton.tintColor = .systemGray2
                }
            }
        }
    }
}
//MARK: - 월 ~ 금 버튼 클릭 이벤트

extension RoutineAddViewController {
    func setDayButtons(sender: UIButton){
        approachEachButton()
 
        // 각 요일 버튼에 접근
        func approachEachButton(){
            for (index, dayButton) in dayButtons.enumerated() { //button array의 해당 값과 index 접근
                if sender.currentTitle == dayButton.currentTitle { // 버튼 array 중 클릭한 버튼에 접근
                    
                    // 요일 최대 선택 가능 횟수
                    if selectedDayCount < weekDayCount {
                        
                        // 해당 요일 선택 bool -> false 이면, 요일 선택 가능
                        if (selectedDayBools[index] == false) {
                            setSelectedButton(index: index)
                            setCoreDataDayBools(condition: sender.currentTitle!) // 선택된 true 값 coreData 변수에 저장
                            selectedDayStrings.append(sender.currentTitle!)
                        }
                        else{ // 해당 요일 선택 bool -> true 이면, 요일 선택해제 가능
                            setReleasedButton(index: index)
                        }
                    }
                    
                    // 현재 선택한 요일 카운트 = 최대 요일 카운트 시, 버튼선택 해제만 가능하도록
                    else{
                        if selectedDayBools[index] == true { // 해당 요일 선택 bool -> true, 요일 해제 가능
                           setReleasedButton(index: index)
                            setCoreDataDayBools(condition: sender.currentTitle!)
                        }
                    }
                }
            }
            
            // 버튼 선택 시, UI event
            func setSelectedButton(index: Int){
                sender.backgroundColor = .darkGray
                sender.tintColor = .systemOrange
                selectedDayBools[index] = true // 해당 요일 bool 값 true 활성화 (선택 됨)
                selectedDayCount += 1 // 현재 요일 카운트 + 1
            }
            
            // 버튼 해제 시, UI event
            func setReleasedButton(index: Int){
                sender.backgroundColor = .systemGray5
                sender.tintColor = .systemGray2
                selectedDayBools[index] = false
                selectedDayCount -= 1
            }
            
            // 해당 요일이 선택되면, CoreData 변수의 해당 요일 true (디폴트는 false)
            func setCoreDataDayBools(condition: String){
                switch condition {
                case "월" :
                    coreDataDayBools[0] = !coreDataDayBools[0]
                case "화" :
                    coreDataDayBools[1] = !coreDataDayBools[1]
                case "수" :
                    coreDataDayBools[2] = !coreDataDayBools[2]
                case "목" :
                    coreDataDayBools[3] = !coreDataDayBools[3]
                case "금" :
                    coreDataDayBools[4] = !coreDataDayBools[4]
                default:
                    print("Day 값 존재하지 않음")
                }
            }
        }
    }
}
