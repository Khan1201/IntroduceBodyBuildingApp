import UIKit
import RxSwift
import CoreData

class RoutineAddViewController: UIViewController {
    
    let viewModel = RoutineAddViewModel()
    let disposeBag = DisposeBag()
    
    var routineViewModel = RoutineViewModel()
    lazy var detailViewModel = DetailViewModel()
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var VCNameLabel: UILabel!{
        didSet{
            VCNameLabel.text = viewModel.uiData.viewControllerName
        }
    }
    @IBOutlet weak var pickerView: UIPickerView!
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
    @IBOutlet weak var datePicker: UIDatePicker!
    
    // 밑 2개는 루틴 VC 셀에서 호출 시 보임
    @IBOutlet weak var viewRoutineButton: UIButton!{
        didSet{
            setCornerRadius(viewRoutineButton, radius: 10)
        }
    }
    @IBOutlet weak var routineDeleteButton: UIButton!{
        didSet{
            setCornerRadius(routineDeleteButton, radius: 10)
        }
    }
    
    //MARK: - @IBAction
    
    @IBAction func addDayButtonAction(_ sender: UIButton) {
        setDayButtons(sender: sender)
    }
    @IBAction func addCancelAction(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    @IBAction func addSaveAction(_ sender: Any) {
        
        // 호출한 VC check
        viewModel.dataFromTableCell.fromTableCellSelectionBool
            .subscribe { [weak self] bool in
                var alarmTime: String = ""
                self?.viewModel.datePickerObservable
                    .subscribe { data in
                        if let data = data.element{
                            alarmTime = data
                        }
                    }.dispose()
                
                guard let fromTableCellSelectionBool = bool.element else {return} // tableCell에서의 호출 구독
                guard let switchBool = self?.noticeSwitch.isOn else {return}
                guard let title = self?.programTextField.text! else {return}
                guard let selectedDaysBoolArray = self?.viewModel.uiData.selectedDaysBoolArray else {return}
                guard let selectedDaysInt = self?.viewModel.uiData.selectedDayCount else {return}
                guard let selectedDaysIntArray = self?.viewModel.dataFromTableCell.fromTableCellSelectedDaysIntArray else {return}
                guard let selectedDaysStringArray = self?.viewModel.uiData.selectedDaysStringArray else {return}
                
                // tableCell의 선택으로 호출 되었을 시
                if fromTableCellSelectionBool{
                    // coreData 업데이트
                    self?.viewModel.updateData(condition: title, switchBool: switchBool, dayBools: selectedDaysBoolArray, selectedDays: selectedDaysInt)
                    
                    // 스위치 on일 시, notification 추가
                    if switchBool{
                        self?.routineViewModel.deleteNotification(title: title, days: selectedDaysIntArray)
                        self?.routineViewModel.makeLocalNotification(title: title, days: selectedDaysStringArray, time: alarmTime)
                    }
                    else{
                        self?.routineViewModel.deleteNotification(title: title, days: selectedDaysIntArray)
                    }
                    self?.presentingViewController?.dismiss(animated: true){
                        if switchBool{
                            self?.viewModel.switchStatefromRoutineAddVC.onNext(true)
                        }
                    }
                }
                
                // 루틴 추가 버튼으로 호출 되었을 시
                else{
                    
                    
                    guard let title = self?.programTextField.text! else {return}
                    guard let imageName = self?.viewModel.getDivisionIconName(self?.divisionTextField.text! ?? "") else {return}
                    guard let divisionName = self?.divisionTextField.text! else {return}
                    guard let selectedDaysBoolArray = self?.viewModel.uiData.selectedDaysBoolArray else {return}
                    guard let recommend = self?.targetTextField.text! else {return}
                    guard let totalWeek = self?.totalPeriodTextField.text! else {return}
                    guard let oneWeekCount = self?.viewModel.uiData.weekDayCount else {return}
                    guard let switchBool = self?.noticeSwitch.isOn else {return}
                    guard let selectedDaysInt = self?.viewModel.uiData.selectedDayCount else {return}
                    guard let selectedDaysStringArray = self?.viewModel.uiData.selectedDaysStringArray else {return}

                    
                    // coredata 접근 후 중복 state bool return. 중복 O -> 데이터 저장 X, 중복 X -> 데이터 저장
                    guard let duplicated = self?.viewModel.returnDuplicatedBoolAfterSaveData(title: title, imageName: imageName, divisionName: divisionName, dayBools: selectedDaysBoolArray, recommend: recommend, week: totalWeek, weekCount: String(oneWeekCount), switchBool: switchBool, selectedDays: selectedDaysInt) else {return}
                    
                    if duplicated{
                        self?.makeAlert()
                    }
                    else{
                         // 알림 스위치 on -> 해당 프로그램 notification 등록
                        if switchBool{
                            self?.routineViewModel.makeLocalNotification(title: title, days: selectedDaysStringArray, time: alarmTime)
                        }
                        self?.presentingViewController?.dismiss(animated: true){
                            if switchBool{
                                self?.viewModel.switchStatefromRoutineAddVC.onNext(true) // dismiss 후 toast 출력위해
                            }
                        }
                    }
                }
            }.disposed(by: disposeBag)
    }
    
    @IBAction func addViewAction(_ sender: Any) {
        
        if let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController {
            detailVC.viewModel.fromRoutineVC.onNext(true)
            setDetailVCData(detailVC: detailVC)
            
            self.present(detailVC, animated: true)
        }
        
        // 해당 프로그램 타이틀과 맞는 detailVC 데이터를 observable에 set
        func setDetailVCData(detailVC: DetailViewController){
            detailViewModel.detailViewObservable
                .filter({
                    $0 != []
                })
                .subscribe { [weak self] elements in
                    if let elements = elements.element{
                        for element in elements{
                            if element.title == self?.programTextField.text!{
                                detailVC.viewModel.detailVCIndexObservable // observable set
                                    .onNext(element)
                            }
                        }
                    }
                }.disposed(by: disposeBag)
        }
    }
    
    @IBAction func addDeleteAction(_ sender: Any) {
        _ = routineViewModel.deleteCoreData(deleteCondition: programTextField.text!)
        if viewModel.dataFromTableCell.fromTableCellSwitchBool{
            routineViewModel.deleteNotification(title: programTextField.text!, days: viewModel.dataFromTableCell.fromTableCellSelectedDaysIntArray)
        }
        
        self.presentingViewController?.dismiss(animated: true)
    }
    
    //MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindPickerView()
        bindUIFromTableCellSelection()
        checkAuthorization()
        datePicker.rx.value.changed
            .subscribe { time in
                let timeFormatter = DateFormatter()
                timeFormatter.timeStyle = DateFormatter.Style.short

                var strDate = timeFormatter.string(from: self.datePicker.date)
                self.viewModel.datePickerObservable.onNext(strDate)
            }
        
    }
}

//MARK: - pickerView 바인딩

extension RoutineAddViewController {
    private func bindPickerView(){
        pickerView.delegate = nil
        pickerView.dataSource = nil
        
        
        // routineVC의 cell 선택으로 호출 시
        viewModel.dataFromTableCell.fromTableCellSelectionBool
            .subscribe { [weak self] bool in
                guard let fromTableCellSelectionBool = bool.element else {return}
            
                if fromTableCellSelectionBool{
                    // routineVC 데이터 바인딩
                    bindPickerViewData(data: self?.routineViewModel.routineAddObservable ?? BehaviorSubject(value: []))
                }
                else{
                    // routineAddVC 데이터 바인딩
                    bindPickerViewData(data: self?.viewModel.routineAddObservable ?? BehaviorSubject(value: []))
                }
            }.disposed(by: disposeBag)
        
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
                        self.viewModel.uiData.weekDayCount = Int(element[0].weekCount) ?? 0
                    }
                }.disposed(by: disposeBag)
            
            // 피커뷰 UI 및 UI 데이터 초기화
            func resetInitialState(){
                self.viewModel.uiData.selectedDayCount = 0
                self.viewModel.uiData.selectedDaysBoolArray = [false, false, false, false, false]
                self.noticeSwitch.isOn = false
                self.viewModel.uiData.selectedDaysStringArray = []
                for dayButton in self.dayButtons{
                    dayButton.backgroundColor = .systemGray5
                    dayButton.tintColor = .systemGray2
                }
            }
            
            // 초기 선택값 설정
            func setInitialSelected(){
                data
                    .filter({ //observable 초기값은 []이므로, 필터로 거르고 다음 값 얻음
                        $0 != []
                    })
                    .take(1)
                    .bind { [weak self] element in
                        
                        // 셀 선택으로 호출 되었을 시 -> 현재 셀의 요일 값 적용, 루틴 추가 버튼으로 호출 되었을 시 -> 요일 변수 모두 초기화
                        self?.viewModel.dataFromTableCell.fromTableCellSelectionBool
                            .subscribe({ bool in
                                guard let fromTableCellSelectionBool = bool.element else {return}
                                fromTableCellSelectionBool ? setSelectedDaysFromTableCell() : resetInitialState()
                            }).dispose()
                        
                        self?.noticeSwitch.isOn = self?.viewModel.dataFromTableCell.fromTableCellSwitchBool ?? false
                        self?.programTextField.text = element[0].title
                        self?.divisionTextField.text = element[0].division
                        self?.targetTextField.text = element[0].recommend
                        self?.totalPeriodTextField.text = element[0].week
                        self?.weekNoticeLabel.text = "최대 \(element[0].weekCount)회 선택하세요 ! "
                        self?.viewModel.uiData.weekDayCount = Int(element[0].weekCount) ?? 0
                    }.disposed(by: disposeBag)
                
                // 셀 선택으로 호출 시 바인딩 했던 데이터로 등록한 버튼 요일 불러옴
                func setSelectedDaysFromTableCell(){
                    for dayButton in dayButtons {
                        for selectedDay in viewModel.uiData.selectedDaysStringArray{
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
                    if viewModel.uiData.selectedDayCount < viewModel.uiData.weekDayCount {
                        // 해당 요일 선택 bool -> false 이면, 요일 선택 가능
                        if (viewModel.uiData.selectedDaysBoolArray[index] == false) {
                            setSelectedButton(index: index) // 선택시, 현재 버튼 카운트 +1 및 해당 요일 true
                        }
                        else{ // 해당 요일 선택 bool -> true 이면, 요일 선택해제 가능
                            setReleasedButton(index: index)
                            
                        }
                    }
                    
                    // 현재 선택한 요일 카운트 = 최대 요일 카운트 시, 버튼선택 해제만 가능하도록
                    else{
                        if viewModel.uiData.selectedDaysBoolArray[index] == true { // 해당 요일 선택 bool -> true, 요일 해제 가능
                            setReleasedButton(index: index)
                        }
                    }
                }
            }
            
            // 버튼 선택 시, UI event
            func setSelectedButton(index: Int){
                sender.backgroundColor = .darkGray
                sender.tintColor = .systemOrange
                viewModel.uiData.selectedDaysBoolArray[index] = true // 해당 요일 bool 값 true 활성화 (선택 됨)
                viewModel.uiData.selectedDayCount += 1 // 현재 요일 카운트 + 1
                viewModel.uiData.selectedDaysStringArray.append(sender.currentTitle!) // 선택된 요일 배열에 삽입
            }
            
            // 버튼 해제 시, UI event
            func setReleasedButton(index: Int){
                sender.backgroundColor = .systemGray5
                sender.tintColor = .systemGray2
                viewModel.uiData.selectedDaysBoolArray[index] = false
                viewModel.uiData.selectedDayCount -= 1
                if let index = viewModel.uiData.selectedDaysStringArray.firstIndex(of: sender.currentTitle!){ // 해제된 요일 배열에서 삭제
                    viewModel.uiData.selectedDaysStringArray.remove(at: index)
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

//MARK: - tableCell에서 호출 시 UI 변경

extension RoutineAddViewController{
    func bindUIFromTableCellSelection(){
        viewModel.dataFromTableCell.fromTableCellSelectionBool
            .filter({
                $0 != false
            })
            .bind { [weak self] _ in
                // 루틴 페이지에서 호출 시 크기 조정
                self?.pickerView.translatesAutoresizingMaskIntoConstraints = false
                self?.pickerView.heightAnchor.constraint(equalToConstant: 120).isActive = true
                self?.routineDeleteButton.layer.isHidden = false // 루틴 페이지에서 편집 시 버튼 보임
            }.disposed(by: disposeBag)
    }
}

//MARK: - 알림 스위치 상태 변화 구독.  알림 스위치 off -> on 일 시, 권한 여부 체크

extension RoutineAddViewController{
    
    func checkAuthorization(){
        noticeSwitch.rx.controlEvent(.valueChanged)
            .bind { [weak self] _ in
                guard let self = self else {return}
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    
                    // 권한 없을 시
                    if !(settings.authorizationStatus  == .authorized || settings.authorizationStatus == .provisional){
                        DispatchQueue.main.async {
                            self.noticeSwitch.isOn = false
                            let message = " 알림 권한이 필요합니다.\n (설정 -> 알림 -> 어플 알림 허용)"
                            showToast(message: message)
                        }
                    }
                }
            }.disposed(by: disposeBag)
        
        func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 10.0)) {
            let toastLabel = UILabel()
            toastLabel.backgroundColor = .systemRed
            toastLabel.textColor = UIColor.white
            toastLabel.font = font
            toastLabel.textAlignment = .center;
            toastLabel.text = message
            toastLabel.alpha = 1.0
            toastLabel.numberOfLines = 0
            toastLabel.layer.cornerRadius = 5;
            toastLabel.clipsToBounds  =  true
            self.view.addSubview(toastLabel)
            
            toastLabel.snp.makeConstraints { make in
                
                make.left.equalTo(noticeSwitch.snp.right).offset(35)
                make.top.equalTo(weekNoticeLabel.snp.bottom).offset(10)
                make.bottom.equalTo(embeddedView.snp.bottom).offset(-15)
            }
            UIView.animate(withDuration: 10, delay: 0.3, options: .curveLinear, animations: {
                toastLabel.alpha = 0.0
            }, completion: {(isCompleted) in
                toastLabel.removeFromSuperview()
            })
        }
    }
}
