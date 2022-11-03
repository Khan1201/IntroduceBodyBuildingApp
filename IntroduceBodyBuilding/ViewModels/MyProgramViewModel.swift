import Foundation
import CoreData
import UIKit
import RxSwift

class MyProgramViewModel {
    static var coreData = [MyProgram]()
    
    let bodyBuildingObservable = BehaviorSubject<[MyProgram]>(value: [MyProgram()])
    let powerBuildingObservable = BehaviorSubject<[MyProgram]>(value: [])
    let powerLiftingObservable = BehaviorSubject<[MyProgram]>(value: [])
    let fromDetailVCRoutineAddButton = PublishSubject<Bool>()
    
    init(){
        readCoreData()
        bindingCoreData(to: bodyBuildingObservable, division: "bodybuilding")
        bindingCoreData(to: powerBuildingObservable, division: "powerbuilding")
        bindingCoreData(to: powerLiftingObservable, division: "powerlifting")
    }
}

//MARK: - CoreData 전체 읽어옴

extension MyProgramViewModel{
    func readCoreData() { //coreData에서 데이터 read
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<MyProgram> = MyProgram.fetchRequest()
        
        do{
            MyProgramViewModel.coreData = try context.fetch(fetchRequest)
        }catch{
            print(error)
        }
    }
}

//MARK: - coreData -> 해당 collection view에 바인딩

extension MyProgramViewModel{
    func bindingCoreData(to observable: BehaviorSubject<[MyProgram]>, division: String) {
        var divisionModel: [MyProgram] = []
        
        for coreData in MyProgramViewModel.coreData{
            if coreData.division == division{ // 컬렉션 뷰에 맞는 데이터 구분 위해
                
                if divisionModel.isEmpty { //첫 데이터 삽입
                    divisionModel.append(coreData)
                }
                else{
                    var titleCount = 0 //중복 체크 로직 (중복되지 않을시 카운트 +1)
                    for divisionData in divisionModel{
                        if divisionData.title != coreData.title{
                            titleCount += 1
                        }
                    }
                    if titleCount == divisionModel.count{ //카운트가 해당 모델 개수와 같을 시 (중복이 없을때) 데이터 삽입
                        divisionModel.append(coreData)          
                    }
                }
            }
        }
        observable.onNext(divisionModel)
    }
}

//MARK: - CoreData 삭제

extension MyProgramViewModel{
    func deleteCoreData(to divisonModel: BehaviorSubject<[MyProgram]>, deleteCondition: String, division: String) {
        
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        // coreData context 선언
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "MyProgram")
        fetchRequest.predicate = NSPredicate(format: "title = %@", deleteCondition) //데이터 조건 검색
        
        do { //coreData 데이터 삭제
            let test = try context.fetch(fetchRequest)
            let objectToDelete = test[0] as! NSManagedObject
            context.delete(objectToDelete)
            do {
                try context.save()
            } catch {
                print("save error: \(error)")
            }
        } catch {
            print("fetch error: \(error)")
        }
        bindingCoreData(to: divisonModel, division: division) //삭제 후 데이터 리바인딩
    }
}
