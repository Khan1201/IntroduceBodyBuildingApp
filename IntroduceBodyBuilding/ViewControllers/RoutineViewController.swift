import UIKit
import CoreData
import RxSwift

class RoutineViewController: UIViewController {
    
    var viewModel = RoutineViewModel()
    var disposeBag = DisposeBag()
    
    var emptyImageVIew: UIImageView {
        let emptyImageView = UIImageView()
        emptyImageView.image = UIImage(named: "box")
        emptyImageView.alpha = 0.5
        emptyImageView.contentMode = .scaleToFill
        return emptyImageView
    }
    var emptyLabel: UILabel{
        let emptyLabel = UILabel()
        emptyLabel.text = "루틴을 추가 해보세요"
        emptyLabel.textColor = .systemGray2
        emptyLabel.font = .systemFont(ofSize: 15)
        return emptyLabel
    }
    
    @IBOutlet weak var routineTableView: UITableView!{
        didSet{
            routineTableView.rowHeight = 120
            routineTableView.layer.masksToBounds = true
            routineTableView.layer.cornerRadius = 15
            routineTableView.separatorColor = .black
        }
    }
    
    //MARK: - viewDidLoad(), viewWillAppear()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkMove()
        bindTableView()
        navigationSet()
        reactUIFromEmptyData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 테이블 뷰 리로드
        do{
            viewModel.routineObservable.onNext(try RoutineViewModel().routineObservable.value())
        }
        catch{
            print("Reload error: \(error)")
        }
    }
}
//MARK: - Navigation 세팅

extension RoutineViewController {
    private func navigationSet(){
        self.navigationItem.title = "루틴"
        self.navigationItem.largeTitleDisplayMode = .always //큰 제목 활성화
        
        //네비게이션바에 + 버튼, 홈 버튼 활성화
        let plusButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: nil, action: nil)
        let homeButton = UIBarButtonItem(image: UIImage(systemName: "house"), style: .plain, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItems = [plusButton, homeButton]
        self.navigationItem.setRightBarButtonItems(navigationItem.rightBarButtonItems, animated: true)
        
        // + 버튼 클릭 이벤트
        self.navigationItem.rightBarButtonItems?[0].rx.tap
            .bind { [weak self] _ in
                guard let self = self else {return}
                guard let routineAddVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoutineAddViewController") as? RoutineAddViewController else {return}
                // 테이블 셀이 아닌, +버튼 클릭임으로
                routineAddVC.viewModel.dataFromTableCell.fromTableCellSelectionBool.onNext(false)
                
                //RoutineAddVC로부터 알림 상태 on으로 dismiss 시, 시간 알림 toast 출력
                routineAddVC.viewModel.switchStatefromRoutineAddVC.subscribe { _ in
                    self.showToast(message: "AM 07:00에 알림이 발생합니다.")
                }.disposed(by: self.disposeBag)
                routineAddVC.modalPresentationStyle = .fullScreen //현재 VC의 viewWillAppear 호출 위해 .fullsceen으로 설정
                self.present(routineAddVC, animated: true)
            }.disposed(by: disposeBag)
        
        // 홈 버튼 클릭 이벤트
        self.navigationItem.rightBarButtonItems?[1].rx.tap
            .bind { [weak self] _ in
                self?.navigationController?.popToRootViewController(animated: true)
            }.disposed(by: disposeBag)
    }
}

//MARK: - 테이블 뷰에 셀 바인딩

extension RoutineViewController{
    private func bindTableView(){
        routineTableView.delegate = nil
        routineTableView.dataSource = nil
        bindCell(data: viewModel.routineObservable)
        addDeleteEvent()
        addClickEvent()
        
        func bindCell(data: BehaviorSubject<[Routine]>){
            data.bind(to: self.routineTableView.rx.items(cellIdentifier: "RoutineTableViewCell", cellType: RoutineTableViewCell.self)) { (index, element, cell)  in
                
                cell.titleLabel.text = element.title
                cell.divisionLabel.text = element.divisionString
                cell.divisionImageView.image = UIImage(named: element.divisionImage ?? "")
                
                cell.mondayBool = element.monday
                cell.tuesdayBool = element.tuesday
                cell.wednesdayBool = element.wednesday
                cell.thursdayBool = element.thursday
                cell.fridayBool = element.friday
                cell.alarmSwitch.isOn = element.alarmSwitch
                
                cell.alarmSwitch.rx.controlEvent(.valueChanged)
                    .subscribe { [weak self] _ in
                        if cell.alarmSwitch.isOn{
                            self?.modifyNotificationAndCoreDataAfterCheckAuthorizaiton(cell: cell, switchState: true)
                        }
                        else{
                            self?.modifyNotificationAndCoreDataAfterCheckAuthorizaiton(cell: cell, switchState: false)
                        }
                    }.disposed(by: self.disposeBag)
            }.disposed(by: disposeBag)
        }
        
        func addDeleteEvent(){
            self.routineTableView.rx.itemDeleted
                .bind { [weak self] indexPath in
                    var result:[Routine] = [] // 데이터 삭제 후 패치된 데이터를 받을 변수
                    self?.viewModel.routineObservable // 테이블 뷰에 바인딩 된 데이터를 얻어옴
                        .subscribe {[weak self] element in
                            if let title = element[indexPath.row].title{ // 삭제할 셀 title = coredata 해당 index의 title
                                if element[indexPath.row].alarmSwitch { // 알림 switch -> on일 시, notification 삭제
                                    let selectedDaysArray =
                                    self?.convertSelectedDaysIntToStringArray(selectedDaysInt: Int(element[indexPath.row].selectedDays))
                                    
                                    self?.viewModel.deleteNotification(title: element[indexPath.row].title ?? "", days: selectedDaysArray ?? []) // [notificationCenter identifier] 생성 위해 해당 인자 넘겨줌
                                }
                                result = self?.viewModel.deleteCoreData(deleteCondition: title) ?? [] //해당 함수는 삭제 후 시점의 데이터 반환
                            }
                        } onDisposed: {
                            self?.viewModel.routineObservable.onNext(result) //강제 dispose 후 테이블 뷰 리로딩
                        }.dispose()
                }.disposed(by: disposeBag)
        }
        func addClickEvent(){
            self.routineTableView.rx.itemSelected
                .bind { [weak self] indexPath in
                    
                    // 루틴 편집 페이지에 보낼 현재 데이터
                    lazy var tableCellData: [RoutineVCModel.Fields] = []
                    lazy var selectedDaysIntArray: [String] = []
                    lazy var selectedDayCountInt: Int = 0
                    lazy var currentSwitchBool: Bool = false
                    lazy var selectedDaysStringArray: [String] = []
                    lazy var selectedDaysBoolArray: [Bool] = [false, false, false, false, false]
                    guard let routineVC = self else {return}
                    
                    //해당 셀의 index 데이터 가져오기 위해
                    self?.viewModel.routineObservable
                        .subscribe { [weak self] element in
                            
                            // 헤당 형태에 맞춰서 setting
                            tableCellData = [RoutineVCModel.Fields(title: element[indexPath.row].title!, week: element[indexPath.row].week!, recommend: element[indexPath.row].recommend!, division: element[indexPath.row].divisionString!, weekCount: element[indexPath.row].weekCount!)]
                            
                            // notification update 위해 현재 데이터 binding
                            selectedDaysIntArray = self?.convertSelectedDaysIntToStringArray(selectedDaysInt:Int(element[indexPath.row].selectedDays)) ?? []
                            currentSwitchBool = element[indexPath.row].alarmSwitch
                            selectedDayCountInt = Int(element[indexPath.row].selectedDays)
                            setSelectedDaysStringAndBoolArray()
                            
                            func setSelectedDaysStringAndBoolArray(){
                                let selectedDayBoolsInCell: [Bool] = [element[indexPath.row].monday, element[indexPath.row].tuesday, element[indexPath.row].wednesday, element[indexPath.row].thursday, element[indexPath.row].friday]
                                
                                for (selectedDayBoolIndex, _) in selectedDaysBoolArray.enumerated(){
                                    for (selectedDayBoolInCellIndex, selectedDayBoolInCell) in selectedDayBoolsInCell.enumerated(){
                                        if selectedDayBoolIndex == selectedDayBoolInCellIndex{
                                            selectedDaysBoolArray[selectedDayBoolIndex] = selectedDayBoolInCell
                                            
                                            if selectedDayBoolInCell{
                                                switch selectedDayBoolIndex{
                                                case 0: selectedDaysStringArray.append("월")
                                                case 1: selectedDaysStringArray.append("화")
                                                case 2: selectedDaysStringArray.append("수")
                                                case 3: selectedDaysStringArray.append("목")
                                                case 4: selectedDaysStringArray.append("금")
                                                default:
                                                    return
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } onDisposed: {
                            
                            // RoutineAddViewController 재사용, 호출 장소 구분
                            guard let routineAddVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoutineAddViewController") as? RoutineAddViewController else {return}
                            guard let self = self else {return}
                            
                            //셀 선택으로 호출 되었다는 bool 넘겨줌
                            routineAddVC.viewModel.dataFromTableCell.fromTableCellSelectionBool.onNext(true)
                            routineAddVC.routineViewModel.routineAddObservable.onNext(tableCellData) // 현재 셀 데이터 넣어줌
                            routineAddVC.viewModel.dataFromTableCell.fromTableCellSelectedDaysIntArray  = selectedDaysIntArray
                            routineAddVC.viewModel.dataFromTableCell.fromTableCellSwitchBool = currentSwitchBool
                            routineAddVC.viewModel.uiData.viewControllerName = "루틴 편집"
                            routineAddVC.viewModel.uiData.selectedDayCount = selectedDayCountInt // 선택 된 요일 정수
                            routineAddVC.viewModel.uiData.selectedDaysBoolArray = selectedDaysBoolArray
                            routineAddVC.viewModel.uiData.selectedDaysStringArray = selectedDaysStringArray
                            
                            // RoutineAddVC로부터 알림 상태 on으로 dismiss 시, 시간 알림 toast 출력
                            routineAddVC.viewModel.switchStatefromRoutineAddVC.subscribe { _ in
                                self.showToast(message: "AM 07:00에 알림이 발생합니다.")
                            }.disposed(by: self.disposeBag)
                            
                            routineAddVC.modalPresentationStyle = .fullScreen
                            routineVC.present(routineAddVC, animated: true)
                        }.dispose()
                }.disposed(by: disposeBag)
        }
    }
}

//MARK: - selectedDays: Int -> selectedDays: [String] (선택된 요일 갯수인 n의 정수형태 -> n개가 포함된 String 배열 형태로,                                                                                             notification identifier 구분 위해)
extension RoutineViewController {
    func convertSelectedDaysIntToStringArray(selectedDaysInt: Int) -> [String]{
        var selectedDaysArray: [String] = [] // selectedDays -> [SelectedDays]
        
        if selectedDaysInt != 0{
            for index in 1...selectedDaysInt{
                selectedDaysArray.append("\(index)") // Sequence의 index만 추출하면 됨, index의 String 값은 상관 x
            }
            return selectedDaysArray
        }
        else {
            return selectedDaysArray
        }
    }
}

//MARK: - DetailVC에서 온 것인지 체크

extension RoutineViewController {
    func checkMove(){
        
        viewModel.fromAddRoutineInDetailVC
            .filter({
                $0 != false
            })
            .subscribe { [weak self]_ in
                guard let self = self else {return}
                guard let routineAddVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoutineAddViewController") as? RoutineAddViewController else {return}
                routineAddVC.viewModel.switchStatefromRoutineAddVC
                    .subscribe { _ in
                        self.showToast(message: "AM 07:00에 알림이 발생합니다.")
                    }.disposed(by: self.disposeBag)
                routineAddVC.modalPresentationStyle = .fullScreen //현재 VC의 viewWillAppear 호출 위해 .fullsceen으로 설정
                self.present(routineAddVC, animated: true)
            }.disposed(by: disposeBag)
    }
}

//MARK: - routineAddVC -> routineVC으로 dismiss 시, toast 메세지 출력

extension RoutineViewController{
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 11.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 84, y: self.view.frame.size.height-100, width: 170, height: 30))
        toastLabel.backgroundColor = .systemGray
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 8, delay: 0.3, options: .curveLinear, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}

//MARK: - 알림 스위치 상태 변화 -> 권한 체크 or CoreData 및 Nofitication 접근

extension RoutineViewController{
    func modifyNotificationAndCoreDataAfterCheckAuthorizaiton(cell: RoutineTableViewCell, switchState: Bool){
        
        switchState ? offToOn() : onToOff()
        
        // 스위치 상태 off -> on으로 변경 시
        func offToOn(){
            UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
                guard let self = self else {return}
                
                // 권한 허용 시
                if settings.authorizationStatus  == .authorized || settings.authorizationStatus == .provisional{
                    DispatchQueue.main.async {
                        self.viewModel.updateSwitchBool(condition: cell.titleLabel.text!, switchBool: cell.alarmSwitch.isOn)
                        self.viewModel.makeLocalNotification(title: cell.titleLabel.text!, days:                 cell.getSelectedDaysStringArray())
                        self.showToast(message: "AM 07:00에 알림이 발생합니다.")
                    }
                }
                
                //권한 없을 시
                else{
                    DispatchQueue.main.async {
                        makeAlertAboutAuthorization()
                        cell.alarmSwitch.isOn = false
                    }
                }
            }
        }
        
        // 스위치 상태 on -> off로 변경 시 (스위치가 on이므로 권한이 있음, 따라서 권한을 확인 하지않아도 됨)
        func onToOff(){
            DispatchQueue.main.async {
                self.viewModel.updateSwitchBool(condition: cell.titleLabel.text!, switchBool: cell.alarmSwitch.isOn)
                self.viewModel.deleteNotification(title: cell.titleLabel.text!, days:                 cell.getSelectedDaysStringArray())
            }
        }
        
        // 권한 알림 alert 생성
        func makeAlertAboutAuthorization(){
            let message = """
            알림 권한이 필요합니다.
            (설정 -> 알림 -> 어플 알림 허용)
            """
            let alert =  UIAlertController(title: "안내", message: message, preferredStyle: .alert)
            let alertDeleteBtn = UIAlertAction(title: "Cancel", style: .destructive) { _ in }
            alert.addAction(alertDeleteBtn)
            self.present(alert, animated: true)
        }
    }
}
//MARK: - 해당 VC의 데이터가 Empty -> UI 변경

extension RoutineViewController{
    func reactUIFromEmptyData(){
        
        var imageView = self.emptyImageVIew
        var label = self.emptyLabel
        
        setUIAfterCheckData()
        
        // 종류별 운동 데이터에 데이터가 존재하지 않을 시, UI 변경
        func setUIAfterCheckData(){
            viewModel.routineObservable
                .subscribe { [weak self] data in
                    guard let data = data.element else {return}
                    
                    // 데이터 없을 시
                    if data == []{
                        setUIInsteadOfTableView()
                    }
                    
                    //데이터 존재 시
                    else{
                        imageView.isHidden = true
                        label.isHidden = true
                        self?.routineTableView.isHidden = false
                    }
                }.disposed(by: disposeBag)
            
        }
        
        // TableView 대신 UI 생성
        func setUIInsteadOfTableView(){
            self.routineTableView.isHidden = true
            makeConstraint(imageView, label)
        }
        
        // UI Constraint 조정
        func makeConstraint(_ imageView: UIImageView, _ label: UILabel) {
            imageView.isHidden = false
            label.isHidden = false
            view.addSubview(imageView)
            view.addSubview(label)
            
            imageView.snp.makeConstraints { make in
                make.width.equalTo(130)
                make.centerX.equalToSuperview()
                make.centerY.equalToSuperview()
            }
            label.snp.makeConstraints { make in
                make.top.equalTo(imageView.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
            }
        }
    }
}
