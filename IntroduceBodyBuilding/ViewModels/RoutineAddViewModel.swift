import Foundation
import Alamofire
import RxSwift
import CoreData

class RoutineAddViewModel {
    let routineAddObservable: BehaviorSubject<[RoutineVCModel.Fields]> = BehaviorSubject(value: []) //루틴 추가 뷰 data
    lazy var alarmToastObservable = PublishSubject<String>() // 스위치 toggle 상태 감지 (toast 생성 위해)
    lazy var dataFromTableCell = DataFromTableCell()
    lazy var uiData = UIData()
    
    // DataFromTableCell 및 UIData 공동으로 사용
    var datePickerObservable: BehaviorSubject = BehaviorSubject(value: "오전 7:00")
    
    struct DataFromTableCell{
        var fromTableCellSelectionBool = BehaviorSubject<Bool>(value: false)
        var fromTableCellSelectedDaysIntArray: [String] = []
        var fromTableCellSwitchBool: Bool = false
    }
    struct UIData{
        var viewControllerName: String = "루틴 추가"
        var selectedDaysBoolArray: [Bool] = [] // 월 ~ 금 버튼 선택 체크 확인 bool
        var selectedDaysStringArray: [String] = [] // 월 ~ 금 선택된 버튼 요일 array (notification의 weekDay 구분 위해)
        var weekDayCount: Int = 0 // 운동 총 기간 중, 주 n회 카운트
        var selectedDayCount: Int = 0 //월 ~ 금 버튼 체크 카운트 (버튼 최대 선택 카운트)
    }
    init() {
        makeData()
    }
}

//MARK: - routineAddVC 전체 데이터 생성

extension RoutineAddViewModel{
    func makeData() {
        let url = "https://firestore.googleapis.com/v1/projects/bodybuildingapp-3e7db/databases/(default)/documents/Program"
        AF.request(url,
                   method: .get,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: RoutineVCModel.self) { response in // decoding
            switch response.result {
            case .success :
                if let value = response.value?.documents{
                    self.routineAddObservable.onNext(value)
                }
                
            case .failure(let error):
                print("AF error: \(error)")
            }
        }
    }
}

//MARK: - tableCell 선택으로 VC호출 -> 저장 시, 해당 메소드 실행 (데이터 추가가 아닌 업데이트)

extension RoutineAddViewModel{
    func updateData(condition: String, switchBool: Bool, dayBools: [Bool], selectedDays: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Routine")
        fetchRequest.predicate = NSPredicate(format: "title = %@", condition)
        
        do {
            let test = try managedContext.fetch(fetchRequest)
            let objectUpdate = test[0] as! NSManagedObject
            objectUpdate.setValue(dayBools[0], forKey: "monday")
            objectUpdate.setValue(dayBools[1], forKey: "tuesday")
            objectUpdate.setValue(dayBools[2], forKey: "wednesday")
            objectUpdate.setValue(dayBools[3], forKey: "thursday")
            objectUpdate.setValue(dayBools[4], forKey: "friday")
            objectUpdate.setValue(switchBool, forKey: "alarmSwitch")
            objectUpdate.setValue(Int16(selectedDays), forKey: "selectedDays")
            
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
}

//MARK: - 루틴 추가 버튼으로 VC호출 -> 저장 시 해당 메소드 실행(CoreData에 데이터 추가)

extension RoutineAddViewModel{
    
    // 저장 후 중복체크 bool return 함. true -> 데이터 삽입 X, false -> CoreData 삽입 (루틴 페이지에 등록)
    func returnDuplicatedBoolAfterSaveData(title: String, imageName: String, divisionName: String, dayBools: [Bool], recommend: String, week: String, weekCount: String, switchBool: Bool, selectedDays: Int) -> Bool{
        
        var duplicated: Bool = false // 중복 체크 bool
        duplicated = checkDuplicated()
        
        if duplicated == false{
            approachCoreData()
        }
        return duplicated
        
        // 중복 체크
        func checkDuplicated() -> Bool{
            let coreDatas = readCoreData()
            for coreData in coreDatas{
                if coreData.title == title{
                    return true
                }
            }
            return false
            
            // 전체 coreData 불러옴
            func readCoreData() -> [Routine] { //coreData에서 데이터 read
                let fetchRequest: NSFetchRequest<Routine> = Routine.fetchRequest()
                let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                var data: [Routine] = []
                do{
                    data = try context.fetch(fetchRequest)
                }catch{
                    print(error)
                }
                return data
            }
        }
        
        // coreData 접근 -> 해당 값 insert
        func approachCoreData(){
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
                routine.title = title
                routine.divisionImage = imageName
                routine.divisionString = divisionName
                routine.recommend = recommend
                routine.week = week
                routine.weekCount = weekCount
                routine.monday = dayBools[0]
                routine.tuesday = dayBools[1]
                routine.wednesday = dayBools[2]
                routine.thursday = dayBools[3]
                routine.friday = dayBools[4]
                routine.alarmSwitch = switchBool
                routine.selectedDays = Int16(selectedDays)
                do{
                    try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save() //insert 적용
                }
                catch{
                    print("save error: \(error)")
                }
            }
            
            // 에러 정의
            enum setDataError: Error{
                case EntityNotExist
            }
        }
    }
}

//MARK: - CoreData안의 데이터 형식으로 return

extension RoutineAddViewModel{
    func getDivisionIconName(_ textFieldOfText: String) -> String{
        switch textFieldOfText{
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
}
