//
//  RoutineViewController.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/10/05.
//

import UIKit
import CoreData
import RxSwift

class RoutineViewController: UIViewController {
    
    @IBOutlet weak var routineTableView: UITableView!{
        didSet{
            routineTableView.rowHeight = 120
            routineTableView.layer.masksToBounds = true
            routineTableView.layer.cornerRadius = 15
            routineTableView.separatorColor = .black
        }
    }
    
    lazy var moveBool: Bool = false // detailVC에서 접근 시 true, true -> routineAddVC 호출
    lazy var switchBool: Bool = false
    lazy var indexArray: [String] = [] // selectedDays -> [SelectedDays]
    var viewModel = RoutineViewModel()
    var disposeBag = DisposeBag()
    //MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkMove()
        bindTableView()
        navigationSet()
        
    }
    //MARK: - viewWillAppear()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
            .bind { _ in
                guard let routineAddVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoutineAddViewController") as? RoutineAddViewController else {return}
                routineAddVC.modalPresentationStyle = .fullScreen //현재 VC의 viewWillAppear 호출 위해 .fullsceen으로 설정
                self.present(routineAddVC, animated: true)
            }.disposed(by: disposeBag)
        
        // 홈 버튼 클릭 이벤트
        self.navigationItem.rightBarButtonItems?[1].rx.tap
            .bind { _ in
                self.navigationController?.popToRootViewController(animated: true)
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
                
            }.disposed(by: disposeBag)
        }
        
        func addDeleteEvent(){
            self.routineTableView.rx.itemDeleted
                .bind { [unowned self] indexPath in
                    var result:[Routine] = [] // 데이터 삭제 후 패치된 데이터를 받을 변수
                    self.viewModel.routineObservable // 테이블 뷰에 바인딩 된 데이터를 얻어옴
                        .subscribe {[unowned self] element in
                            if let title = element[indexPath.row].title{ // 삭제할 셀 title = coredata 해당 index의 title
                                if element[indexPath.row].alarmSwitch { // 알림 switch -> on
                                    let selectedDaysArray =
                                    getSelectedDaysIntArray(selectedDays: Int(element[indexPath.row].selectedDays))
                                    
                                    self.viewModel.deleteNotification(title: element[indexPath.row].title ?? "", days: selectedDaysArray) // [notificationCenter identifier] 생성 위해 해당 인자 넘겨줌
                                }
                                result = self.viewModel.deleteCoreData(deleteCondition: title) //해당 함수는 삭제 후 시점의 데이터 반환
                            }
                        } onDisposed: {
                            self.viewModel.routineObservable.onNext(result) //강제 dispose 후 테이블 뷰 리로딩
                        }.dispose()
                }.disposed(by: disposeBag)
        }
        func addClickEvent(){
            self.routineTableView.rx.itemSelected
                .bind { [unowned self] indexPath in
                    
                    // 루틴 편집 페이지에 보낼 현재 데이터
                    lazy var tableCellData: [RoutineVCModel.Fields] = []
                    lazy var selectedDaysIntArray: [String] = []
                    lazy var selectedDayCount: Int = 0
                    lazy var currentSwitchBool: Bool = false
                    
                    lazy var selectedDaysStringArray: [String] = []
                    lazy var selectedDaysBoolArray: [Bool] = [false, false, false, false, false]
                    lazy var routineVC: RoutineViewController = self
                    
                    //해당 셀의 index 데이터 가져오기 위해
                    self.viewModel.routineObservable
                        .subscribe { [unowned self] element in
                            
                            // 헤당 형태에 맞춰서 setting
                            tableCellData = [RoutineVCModel.Fields(title: element[indexPath.row].title!, week: element[indexPath.row].week!, recommend: element[indexPath.row].recommend!, division: element[indexPath.row].divisionString!, weekCount: element[indexPath.row].weekCount!)]
                            
//                             notification update 위해 selectedDaysArray setting
                            selectedDaysIntArray = getSelectedDaysIntArray(selectedDays:Int(element[indexPath.row].selectedDays))
                            currentSwitchBool = element[indexPath.row].alarmSwitch
                            selectedDayCount = Int(element[indexPath.row].selectedDays)
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
                            if let routineAddVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoutineAddViewController") as? RoutineAddViewController{
                                routineAddVC.fromTableCellSelectionBool = true // 셀 선택으로 호출 되었다는 bool -> true
                                routineAddVC.routineViewModel.routineAddObservable // 현재 셀 데이터 넣어줌
                                    .onNext(tableCellData)
                                routineAddVC.viewControllerName = "루틴 편집"
                                routineAddVC.fromTableCellSelectedDaysIntArray  = selectedDaysIntArray
                                routineAddVC.fromTableCellSwitchBool = currentSwitchBool
                            
                                routineAddVC.selectedDayCount = selectedDayCount // 선택 된 요일 정수
                                routineAddVC.selectedDaysBoolArray = selectedDaysBoolArray
                                routineAddVC.selectedDaysStringArray = selectedDaysStringArray
                                
                                routineAddVC.modalPresentationStyle = .fullScreen
                                routineVC.present(routineAddVC, animated: true)
                            }
                        }.dispose()
                }.disposed(by: disposeBag)
        }
        
        
    }
}
//MARK: - DetailVC에서 온 것인지 체크

extension RoutineViewController {
    func checkMove(){
        if moveBool{
            moveBool = false
            let routineAddVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoutineAddViewController")
            routineAddVC.modalPresentationStyle = .fullScreen //현재 VC의 viewWillAppear 호출 위해 .fullsceen으로 설정
            self.present(routineAddVC, animated: true)
        }
    }
}
//MARK: - selectedDays: Int -> selectedDays: [String] (선택된 요일 갯수인 n의 정수형태 -> n개가 포함된 String 배열 형태로,                                                                                             notification identifier 구분 위해)

extension RoutineViewController {
    func getSelectedDaysIntArray(selectedDays: Int) -> [String]{
        var selectedDaysArray: [String] = [] // selectedDays -> [SelectedDays]
        
        if selectedDays != 0{
            for index in 1...selectedDays{
                selectedDaysArray.append("\(index)") // Sequence의 index만 추출하면 됨, index의 String 값은 상관 x
            }
            return selectedDaysArray
        }
        else {
            return selectedDaysArray
        }
    }
}
