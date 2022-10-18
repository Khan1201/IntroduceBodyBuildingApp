//
//  RoutineViewModel.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/10/05.
//

import Foundation
import UIKit
import CoreData
import RxSwift

class RoutineViewModel{
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var routineObservable = BehaviorSubject<[Routine]>(value: [])
    
    func readCoreData() { //coreData에서 데이터 read
        let fetchRequest: NSFetchRequest<Routine> = Routine.fetchRequest()
        let context = appdelegate.persistentContainer.viewContext
        do{
            routineObservable.onNext(try context.fetch(fetchRequest))
        }catch{
            print(error)
        }
    }
    
    func deleteCoreData(deleteCondition: String) -> [Routine]{
                
        let context = appdelegate.persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        var result: [Routine] = []
        // coreData context 선언
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Routine")
        fetchRequest.predicate = NSPredicate(format: "title = %@", deleteCondition) //데이터 조건 검색
        
        do { //coreData 데이터 삭제
            let test = try context.fetch(fetchRequest)
            let objectToDelete = test[0] as! NSManagedObject
            context.delete(objectToDelete)
            do {
                let tempFetchRequest: NSFetchRequest<Routine> = Routine.fetchRequest()
                result = try context.fetch(tempFetchRequest)
                try context.save()
//                let tempFetchRequest: NSFetchRequest<Routine> = Routine.fetchRequest()
//                print("삭제 후 값은 : \(try context.fetch(tempFetchRequest))")
                
            } catch {
                print("save error: \(error)")
            }
        } catch {
            print("fetch error: \(error)")
        }
        return result
    }
    
    init(){
        readCoreData()
    }
}

