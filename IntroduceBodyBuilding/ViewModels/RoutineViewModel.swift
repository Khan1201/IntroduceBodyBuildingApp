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
    static var coreData: [Routine] = []
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var routineObservable = BehaviorSubject<[Routine]>(value: [])
    
    
    
    func makeCoreData() { //coreData에서 데이터 read
        let fetchRequest: NSFetchRequest<Routine> = Routine.fetchRequest()
        let context = appdelegate.persistentContainer.viewContext
        
        do{
            RoutineViewModel.coreData = try context.fetch(fetchRequest)
        }catch{
            print(error)
        }
    }
    
    func bindingCoreData(to observable: BehaviorSubject<[Routine]>) { // coreData -> 해당 collection view에 바인딩
        var divisionModel: [Routine] = []
        
        for coreData in RoutineViewModel.coreData{
            divisionModel.append(coreData)
        }
        observable.onNext(divisionModel)
    }
    
    init(){
        makeCoreData()
        bindingCoreData(to: routineObservable)
    }
}

