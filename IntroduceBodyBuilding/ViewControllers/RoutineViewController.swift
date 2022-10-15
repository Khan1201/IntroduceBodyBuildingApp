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
    
    var viewModel = RoutineViewModel()
    var disposeBag = DisposeBag()
    
    func bindTableView(data: BehaviorSubject<[Routine]>){
        
        data.bind(to: self.routineTableView.rx.items(cellIdentifier: "RoutineTableViewCell", cellType: RoutineTableViewCell.self)) { (index, element, cell) in
            
            cell.selectionStyle = .none
            
            cell.titleLabel.text = element.title
            cell.divisionLabel.text = element.divisionString
            cell.divisionImageView.image = UIImage(named: element.divisionImage ?? "")
            cell.mondayBool = element.monday
            cell.tuesdayBool = element.tuesday
            cell.wednesdayBool = element.wednesday
            cell.thursdayBool = element.thursday
            cell.fridayBool = element.friday
            cell.alarmSwitch.isSelected = element.alarmSwitch
        }.disposed(by: self.disposeBag)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        getData()
        bindTableView(data: viewModel.routineObservable)
        navigationSet()
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: nil, action: nil)
        
        self.navigationItem.setRightBarButton(navigationItem.rightBarButtonItem, animated: true)
        
        self.navigationItem.rightBarButtonItem?.rx.tap
            .bind { _ in
                guard let routineAddVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoutineAddViewController") as? RoutineAddViewController else {return}
                self.present(routineAddVC, animated: true)
            }.disposed(by: disposeBag)
        
        
    }
    
}
extension RoutineViewController {
    private func navigationSet(){
        self.navigationItem.title = "루틴"
        self.navigationItem.largeTitleDisplayMode = .always
    }
}
