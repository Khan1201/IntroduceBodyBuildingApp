//
//  MyProgramViewModel.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/09/29.
//

import Foundation
import CoreData
import UIKit
import RxSwift

class MyProgramViewModel {
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    
    static var coreData = [MyProgram]()
    var bodyBuildingObservable = BehaviorSubject<[MyProgram]>(value: [])
    var powerBuildingObservable = BehaviorSubject<[MyProgram]>(value: [])
    var powerLiftingObservable = BehaviorSubject<[MyProgram]>(value: [])

    init(){
        readCoreData()
        bindingCoreData(to: bodyBuildingObservable, division: "bodybuilding")
        bindingCoreData(to: powerBuildingObservable, division: "powerbuilding")
        bindingCoreData(to: powerLiftingObservable, division: "powerlifting")
    }
    
    func readCoreData() { //coreData에서 데이터 read
        let fetchRequest: NSFetchRequest<MyProgram> = MyProgram.fetchRequest()
        let context = appdelegate.persistentContainer.viewContext
        
        do{
            MyProgramViewModel.coreData = try context.fetch(fetchRequest)
        }catch{
            print(error)
        }
    }
    
    func bindingCoreData(to observable: BehaviorSubject<[MyProgram]>, division: String) { // coreData -> 해당 collection view에 바인딩
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
    
    func deleteCoreData(to divisonModel: BehaviorSubject<[MyProgram]>, deleteCondition: String, division: String) {
                
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

