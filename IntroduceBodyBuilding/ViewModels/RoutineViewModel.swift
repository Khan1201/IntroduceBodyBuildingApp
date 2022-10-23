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
import UserNotifications

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
                
            } catch {
                print("save error: \(error)")
            }
        } catch {
            print("fetch error: \(error)")
        }
        return result
    }
    
    func updateSwitchBool(condition: String, switchBool: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Routine")
        fetchRequest.predicate = NSPredicate(format: "title = %@", condition)
        
        do {
            let test = try managedContext.fetch(fetchRequest)
            let objectUpdate = test[0] as! NSManagedObject
            objectUpdate.setValue(switchBool, forKey: "alarmSwitch")
            do {
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    func makeLocalNotification(title: String, days: [String]) {
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = "오늘은 운동하는 날 !"
        notificationContent.body = "프로그램명: \(title)"
        loopUntilDays()
        
        // 월 ~ 금 알림이 선택된 날짜 배열을 받음 -> 해당 날짜 수 만큼 알림 등록
        func loopUntilDays(){
            for (index, day) in days.enumerated(){
                
                //배열 접근  -> weeDay 값 get
                let weekDay: Int = {
                    switch day{
                    case "월": return 2
                    case "화": return 3
                    case "수": return 4
                    case "목": return 5
                    case "금": return 6
                    case "토": return 7
                    case "일": return 8
                    default: print("잘못된 Notification Days")
                        return 0
                    }
                }()
                addRequest(weekDay, index)
            }
            
            // 해당 날짜의 로컬 알림 등록
            func addRequest(_ weekDay: Int, _ identifier: Int){
                if weekDay != 0 {
                    var dateComponents = DateComponents()
                    dateComponents.calendar = Calendar.current
                    dateComponents.weekday = 1
                    dateComponents.hour = 21
                    dateComponents.minute = 19
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                    let request = UNNotificationRequest(identifier: "\(title): \(identifier)",
                                                        content: notificationContent,
                                                        trigger: trigger)
                    UNUserNotificationCenter.current().add(request) { error in
                        if let error = error {
                            print("Notification Error: ", error)
                        }
                    }
                }
                else {
                    return
                }
            }
        }
    }
    
    func deleteNotification(title: String, days: [String]){
        var identifiers: [String] = []
        for (index, _) in days.enumerated(){
            //배열 접근  -> weeDay 값 get
            identifiers.append("\(title): \(index)")
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    init(){
        readCoreData()
    }
}

