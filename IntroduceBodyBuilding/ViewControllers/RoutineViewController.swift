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
    var viewModel = RoutineViewModel()
    var disposeBag = DisposeBag()
    lazy var switchBool: Bool = false
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
        
        //네비게이션바에 + 버튼 활성화
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: nil, action: nil)
        self.navigationItem.setRightBarButton(navigationItem.rightBarButtonItem, animated: true)
        
        // + 버튼 클릭 이벤트
        self.navigationItem.rightBarButtonItem?.rx.tap
            .bind { _ in
                guard let routineAddVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoutineAddViewController") as? RoutineAddViewController else {return}
                routineAddVC.modalPresentationStyle = .fullScreen //현재 VC의 viewWillAppear 호출 위해 .fullsceen으로 설정
                self.present(routineAddVC, animated: true)
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
        
        func bindCell(data: BehaviorSubject<[Routine]>){
            data.bind(to: self.routineTableView.rx.items(cellIdentifier: "RoutineTableViewCell", cellType: RoutineTableViewCell.self)) { (index, element, cell)  in
                
                cell.selectionStyle = .none
                
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
                                    let selectedDays: Int = Int(element[indexPath.row].notificationIndex) // 선택된 요일 카운트
                                    var indexArray: [String] = [] // selectedDays -> [SelectedDays]
                                    for index in 0..<selectedDays{
                                        indexArray.append("\(index)") // Sequence의 index만 추출하면 됨, index의 String 값은 상관 x
                                    }
                                    self.viewModel.deleteNotification(title: element[indexPath.row].title ?? "", days: indexArray) // [notificationCenter identifier] 생성 위해 해당 인자 넘겨줌
                                }
                                result = self.viewModel.deleteCoreData(deleteCondition: title) //해당 함수는 삭제 후 시점의 데이터 반환
                            }
                        } onDisposed: {
                            self.viewModel.routineObservable.onNext(result) //강제 dispose 후 테이블 뷰 리로딩
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
