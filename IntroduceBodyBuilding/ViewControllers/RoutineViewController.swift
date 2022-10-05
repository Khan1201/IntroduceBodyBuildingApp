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

    @IBOutlet weak var routineTableView: UITableView!
    
    var viewModel = RoutineViewModel()
    var routineObservable: BehaviorSubject<[Routine]> = BehaviorSubject(value: RoutineViewModel.coreData)
    var disposeBag = DisposeBag()
    
    func bindTableView(data: BehaviorSubject<[Routine]>){
        
        data.bind(to: self.routineTableView.rx.items(cellIdentifier: "RoutineTableViewCell", cellType: RoutineTableViewCell.self)) { (index, element, cell) in
    
            cell.titleLabel.text = element.title
            cell.divisionLabel.text = element.divisionString
            cell.divisionImageView.image = UIImage(named: element.divisionImage ?? "")
            cell.mondayButton.isEnabled = element.monday
            cell.tuesdayButton.isEnabled = element.tuesday
            cell.wednesdayButton.isEnabled = element.wednesday
            cell.thursdayButton.isEnabled = element.thursday
            cell.fridayButtoon.isEnabled = element.friday
            cell.alarmSwitch.isEnabled = element.alarmSwitch
        }.disposed(by: self.disposeBag)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
