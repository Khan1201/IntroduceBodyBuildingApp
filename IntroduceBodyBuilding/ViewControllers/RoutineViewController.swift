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
    
    
    func getData() {
        
        do{
            let routineObject = try getObject() //CoreData Entity인 MyProgram 정의
            insertData(in: routineObject)
        }
        catch{
            print("coreData error: \(error)")
        }
        
        func getObject() throws -> NSManagedObject{
            let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            guard let routineEntity = NSEntityDescription.entity(forEntityName: "Routine", in: viewContext) else{
                throw setDataError.EntityNotExist } //CoreData entity 정의
            let routineObject = NSManagedObject(entity: routineEntity, insertInto: viewContext)
            return routineObject
        }
        
        // CoreData에 데이터 삽입
        func insertData(in object: NSManagedObject) {
            let routine = object as! Routine
            //MyProgram entity 존재 시, unwrapping 후 coreData에 데이터 insert
            routine.title = "Brogains 10 Week Powerbuilding"
            routine.divisionImage = "PBIcon"
            routine.divisionString = "PowerBuilding"
            routine.monday = true
            routine.tuesday = false
            routine.wednesday = true
            routine.thursday = true
            routine.friday = true
            routine.alarmSwitch = true
            do{
                try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save() //insert 적용
            }
            catch{
                print("save error: \(error)")
            }
            viewModel = RoutineViewModel()
        }
    }
    enum setDataError: Error{
        case EntityNotExist
    }
    
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
