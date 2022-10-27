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
    
    @IBOutlet weak var VCNameLabel: UILabel!{
        didSet{
            VCNameLabel.text = viewControllerName
        }
    }
    @IBOutlet weak var pickerView: UIPickerView!{
        didSet{
            if fromTableCellSelectionBool{ // 루틴 페이지에서 편집 시 크기 줄임
                pickerView.translatesAutoresizingMaskIntoConstraints = false
                pickerView.heightAnchor.constraint(equalToConstant: 120).isActive = true
            }
            
        }
    }
    @IBOutlet weak var embeddedView: UIView!{
        didSet{
            setCornerRadius(embeddedView, radius: 10)
        }
    }
    @IBOutlet weak var programTextField: UITextField!
    @IBOutlet var dayButtons: [UIButton]!{
        didSet{
            for dayButton in dayButtons{
                setCornerRadius(dayButton, radius: 6)
            }
        }
    }
    @IBOutlet weak var divisionTextField: UITextField!
    @IBOutlet weak var targetTextField: UITextField!
    @IBOutlet weak var totalPeriodTextField: UITextField!
    @IBOutlet weak var weekNoticeLabel: UILabel!
    @IBOutlet weak var noticeSwitch: UISwitch!
    
    
    @IBOutlet weak var viewRoutineButton: UIButton!{
        didSet{
            setCornerRadius(viewRoutineButton, radius: 10)
            viewRoutineButton.layer.isHidden = !fromTableCellSelectionBool // 루틴 페이지에서 편집 시 버튼 보임
        }
    }
    
    @IBOutlet weak var routineDeleteButton: UIButton!{
        didSet{
            setCornerRadius(routineDeleteButton, radius: 10)
            routineDeleteButton.layer.isHidden = !fromTableCellSelectionBool // 루틴 페이지에서 편집 시 버튼 보임
        }
    }
    
    //MARK: - 해당 VC의 UI event를 위한 변수
    
    lazy var routineViewModel = RoutineViewModel()
    lazy var detailViewModel = DetailViewModel()
    
    let routineAddviewModel = RoutineAddViewModel()
    let disposeBag = DisposeBag()
    lazy var fromTableCellSelectionBool: Bool = false // 호출한 페이지 확인 bool
    lazy var fromTableCellSelectedDaysIntArray: [String] = []
    lazy var fromTableCellSwitchBool: Bool = false
    lazy var viewControllerName: String = "루틴 추가"
    lazy var selectedDaysBoolArray: [Bool] = [] // 월 ~ 금 버튼 선택 체크 확인 bool
    lazy var selectedDaysStringArray: [String] = [] // 월 ~ 금 선택된 버튼 요일 array (notification의 weekDay 구분 위해)
    lazy var weekDayCount: Int = 0 // 운동 총 기간 중, 주 n회 카운트
    lazy var selectedDayCount: Int = 0 //월 ~ 금 버튼 체크 카운트 (버튼 최대 선택 카운트)
    
    //MARK: - CoreData에 저장할 데이터
    
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
        
        // tableCell의 선택으로 호출 되었을 시
        if fromTableCellSelectionBool{
            
            // coreData 업데이트
            routineAddviewModel.updateData(condition: programTextField.text!, switchBool: coreDataSwitchBool, dayBools: selectedDaysBoolArray, selectedDays: selectedDayCount)
            
            // coreData에 저장된 swtichBool state
            if coreDataSwitchBool{
                routineViewModel.deleteNotification(title: programTextField.text!, days: fromTableCellSelectedDaysIntArray)
                routineViewModel.makeLocalNotification(title: programTextField.text!, days: selectedDaysStringArray)
            }
            else{
                routineViewModel.deleteNotification(title: programTextField.text!, days: fromTableCellSelectedDaysIntArray)
            }
            self.presentingViewController?.dismiss(animated: true)
        }
        
        // 루틴 추가 버튼으로 호출 되었을 시
        else{
            // coredata 접근 후 중복 state bool return. 중복이 아니면, 데이터 저장 함
            let duplicated: Bool = routineAddviewModel.returnDuplicatedBoolAfterSaveData(title: programTextField.text!, imageName: coreDataDivisionIconName, divisionName: divisionTextField.text!, dayBools: selectedDaysBoolArray, recommend: targetTextField.text!, week: totalPeriodTextField.text!, weekCount: String(weekDayCount), switchBool: coreDataSwitchBool, selectedDays: selectedDayCount, viewController: self)
            
            if duplicated{
                makeAlert()
            }
            else{
                // 알림 스위치 on -> 해당 프로그램 notification 등록
                if coreDataSwitchBool{
                    routineViewModel.makeLocalNotification(title: programTextField.text!, days: selectedDaysStringArray)
                }
                self.presentingViewController?.dismiss(animated: true)
            }
        }
    }
    
    @IBAction func addViewAction(_ sender: Any) {
         
        
        if let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            
            detailVC.fromRoutineVC = true
            setDetailVCData(detailVC: detailVC)
            
            self.present(detailVC, animated: true)

        }
        
        // 해당 프로그램 타이틀과 맞는 detailVC 데이터를 observable에 set
        func setDetailVCData(detailVC: DetailViewController){
            lazy var tempData: DetailVCModel.Fields = .init()

            detailViewModel.detailViewObservable
                .filter({ element in
                    element != []
                })
                .subscribe { [unowned self] elements in
                    if let elements = elements.element{
                        for element in elements{
                            if element.title == self.programTextField.text!{
                                detailVC.detailVCIndexObservable // observable set
                                    .onNext(element)
                            }
                        }
                    }
                }.disposed(by: disposeBag)
        }
        
    }
    
    
    @IBAction func addDeleteAction(_ sender: Any) {
        _ = routineViewModel.deleteCoreData(deleteCondition: programTextField.text!)
        if fromTableCellSwitchBool{
            routineViewModel.deleteNotification(title: programTextField.text!, days: fromTableCellSelectedDaysIntArray)
        }
        
        self.presentingViewController?.dismiss(animated: true)
    }
    
    
    //MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindPickerView(fromRoutineVC: fromTableCellSelectionBool)
    }
}

//MARK: - pickerView 바인딩

extension RoutineAddViewController {
    private func bindPickerView(fromRoutineVC: Bool){
        pickerView.delegate = nil
        pickerView.dataSource = nil
        
        // 루틴 페이지에서 호출하면 routineViewModel의 observable로 바인딩
        fromRoutineVC ? bindPickerViewData(data: routineViewModel.routineAddObservable) : bindPickerViewData(data: routineAddviewModel.routineAddObservable)
        
        func bindPickerViewData(data: BehaviorSubject<[RoutineVCModel.Fields]>){
            data
                .bind(to: pickerView.rx.itemTitles) { (_, element) in
                    return element.title
                }.disposed(by: disposeBag)
            
            addSelectEvent(data: data)
        }
        
        // 피커뷰 선택 이벤트, 초기 선택 값 세팅위해 (호출 페이지 구분)data 인자로 받아옴
        func addSelectEvent(data: BehaviorSubject<[RoutineVCModel.Fields]>){
            
            setInitialSelected()
            
            // 선택 시 바인드
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
            
            // 피커뷰 UI 및 UI 데이터 초기화
            func resetInitialState(){
                self.selectedDayCount = 0
                self.selectedDaysBoolArray = [false, false, false, false, false]
                self.noticeSwitch.isOn = false
                self.selectedDaysStringArray = []
                for dayButton in self.dayButtons{
                    dayButton.backgroundColor = .systemGray5
                    dayButton.tintColor = .systemGray2
                }
            }
            
            // 초기 선택값 설정
            func setInitialSelected(){
                data
                    .filter({ element in //observable 초기값은 []이므로, 필터로 거르고 다음 값 얻음
                        element != []
                    })
                    .take(1)
                    .bind { [unowned self] element in
                        
                        // 셀 선택으로 호출 되었을 시 -> 현재 셀의 요일 값 적용, 루틴 추가 버튼으로 호출 되었을 시 -> 요일 변수 모두 초기화
                        fromTableCellSelectionBool ? setSelectedDaysFromTableCell() : resetInitialState()
                        
                        self.noticeSwitch.isOn = self.fromTableCellSwitchBool
                        self.programTextField.text = element[0].title
                        self.divisionTextField.text = element[0].division
                        self.targetTextField.text = element[0].recommend
                        self.totalPeriodTextField.text = element[0].week
                        self.weekNoticeLabel.text = "최대 \(element[0].weekCount)회 선택하세요 ! "
                        self.weekDayCount = Int(element[0].weekCount) ?? 0
                    }.disposed(by: disposeBag)
                
                // 셀 선택으로 호출 시 바인딩 했던 데이터로 등록한 버튼 요일 불러옴
                func setSelectedDaysFromTableCell(){
                    for dayButton in dayButtons {
                        for selectedDay in selectedDaysStringArray{
                            if dayButton.currentTitle! == selectedDay{
                                dayButton.backgroundColor = .darkGray
                                dayButton.tintColor = .systemOrange
                            }
                        }
                    }
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
                        if (selectedDaysBoolArray[index] == false) {
                            setSelectedButton(index: index) // 선택시, 현재 버튼 카운트 +1 및 해당 요일 true
                        }
                        else{ // 해당 요일 선택 bool -> true 이면, 요일 선택해제 가능
                            setReleasedButton(index: index)
                            
                        }
                    }
                    
                    // 현재 선택한 요일 카운트 = 최대 요일 카운트 시, 버튼선택 해제만 가능하도록
                    else{
                        if selectedDaysBoolArray[index] == true { // 해당 요일 선택 bool -> true, 요일 해제 가능
                            setReleasedButton(index: index)
                        }
                    }
                }
            }
            
            // 버튼 선택 시, UI event
            func setSelectedButton(index: Int){
                sender.backgroundColor = .darkGray
                sender.tintColor = .systemOrange
                selectedDaysBoolArray[index] = true // 해당 요일 bool 값 true 활성화 (선택 됨)
                selectedDayCount += 1 // 현재 요일 카운트 + 1
                selectedDaysStringArray.append(sender.currentTitle!) // 선택된 요일 배열에 삽입
            }
            
            // 버튼 해제 시, UI event
            func setReleasedButton(index: Int){
                sender.backgroundColor = .systemGray5
                sender.tintColor = .systemGray2
                selectedDaysBoolArray[index] = false
                selectedDayCount -= 1
                if let index = selectedDaysStringArray.firstIndex(of: sender.currentTitle!){ // 해제된 요일 배열에서 삭제
                    selectedDaysStringArray.remove(at: index)
                }
            }
        }
    }
}
//MARK: - 저장 버튼 클릭 후 데이터 중복 시, alert

extension RoutineAddViewController{
    func makeAlert(){
        let alert =  UIAlertController(title: "안내", message: "루틴에 이미 존재합니다 !", preferredStyle: .alert)
        let alertDeleteBtn = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
        alert.addAction(alertDeleteBtn)
        self.present(alert, animated: true)
    }
}

//MARK: - view object corner 적용

extension RoutineAddViewController{
    func  setCornerRadius(_ object: AnyObject, radius: CGFloat){
        object.layer?.masksToBounds = true
        object.layer?.cornerRadius = radius
    }
}
