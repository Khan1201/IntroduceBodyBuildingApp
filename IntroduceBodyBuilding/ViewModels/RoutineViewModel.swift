//
//  RoutineViewModel.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/10/05.
//

import Foundation
import UIKit
import CoreData

class RoutineViewModel{
    static var coreData: [Routine] = []

    let appdelegate = UIApplication.shared.delegate as! AppDelegate

    func makeCoreData() { //coreData에서 데이터 read
        let fetchRequest: NSFetchRequest<Routine> = Routine.fetchRequest()
        let context = appdelegate.persistentContainer.viewContext
        
        do{
            RoutineViewModel.coreData = try context.fetch(fetchRequest)
        }catch{
            print(error)
        }
    }
    
    init(){
        makeCoreData()
    }
}

