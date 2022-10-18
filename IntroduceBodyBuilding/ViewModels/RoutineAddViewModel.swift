//
//  MainVM.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/09/22.
//

import Foundation
import Alamofire
import RxSwift
import CoreData

class RoutineAddViewModel {
    
    let routineAddObservable: BehaviorSubject<[RoutineVCModel.Fields]> = BehaviorSubject(value: []) //루틴 추가 뷰 data
    
    init() {
        makeData()
    }
    
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
    
    func saveData(title: String, imageName: String, divisionName: String, dayBools: [Bool], switchBool: Bool){
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
            print(dayBools)
            routine.monday = dayBools[0]
            routine.tuesday = dayBools[1]
            routine.wednesday = dayBools[2]
            routine.thursday = dayBools[3]
            routine.friday = dayBools[4]
            routine.alarmSwitch = switchBool
            do{
                try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save() //insert 적용
            }
            catch{
                print("save error: \(error)")
            }
        }
        enum setDataError: Error{
            case EntityNotExist
        }
    }
    
    
    
}
