import Foundation
import UIKit
import CoreData
import RxSwift
import UserNotifications

class RoutineViewModel{
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    let routineObservable = BehaviorSubject<[Routine]>(value: [])
    
    // 셀 인덱스에 맞는 routineAddVC 데이터 바인딩 위해
    lazy var routineAddObservable = BehaviorSubject<[RoutineVCModel.Fields]>(value: [])
    lazy var fromAddRoutineInDetailVC = BehaviorSubject<Bool>(value: false)  // detailVC의 루틴 등록 버튼으로 접근 확인
    lazy var checkAuthorization = PublishSubject<Bool>()
    
    init(){
        readCoreData()
    }
}

//MARK: - coreData에서 데이터 read

extension RoutineViewModel{
    func readCoreData() {
        let fetchRequest: NSFetchRequest<Routine> = Routine.fetchRequest()
        let context = appdelegate.persistentContainer.viewContext
        do{
            routineObservable.onNext(try context.fetch(fetchRequest))
        }catch{
            print(error)
        }
    }
    
}

//MARK: - coreData에서 데이터 delete

extension RoutineViewModel{
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
}

//MARK: - switch toggle on -> coredata switch bool 업데이트

extension RoutineViewModel{
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
}

//MARK: - 로컬 notification 생성

extension RoutineViewModel{
    func makeLocalNotification(title: String, days: [String], time: String = "오전 7:00") {
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
                    dateComponents.weekday = weekDay
                    dateComponents.hour = convertHour(time: time)
                    dateComponents.minute = convertMinute(time: time)
                    
                    // minute: '0' or '5' -> '00' or '05'로 변환
                    let modifiedMinuteDigit = changeMinuteDigit(minute: String(convertMinute(time: time)))
                    
                    // '오후 7:00' -> '19:00' 형태로 변환 후 userDefaults에 영구적으로 저장
                    let timeToString = String(convertHour(time: time)) + ":" + modifiedMinuteDigit
                    setTimeToUserDefaults(timeToString: timeToString, title: title) // title == identier
                    
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
                
                // 오전 7:00 -> '7' 가져옴
                func convertHour(time: String) -> Int {
                    var timeSubstring: Substring
                    var hour: Int = 0
                    
                    // ":" 가 있으면 convert 진행
                    if let colonIndex = time.range(of: ":"){
                        
                        // '13:00'의 형태일 시 count == 8
                        if time.count == 8 {
                            let hourStartIndex = time.index(colonIndex.lowerBound, offsetBy: -2)
                            let minuteEndIndex = time.index(colonIndex.upperBound, offsetBy: 1)
                            timeSubstring = time[hourStartIndex...minuteEndIndex]
                            hour = Int(timeSubstring.prefix(2)) ?? 0
                            
                            if time.contains("오후"){
                                hour += 12
                                
                                if hour == 24{ // 오후 12시 -> 24시 X, 12시 O
                                    hour = 12
                                }
                            }
                            else{
                                if hour == 12{ // 오전 12시 -> 0시
                                    hour = 0
                                }
                            }
                        }
                        
                        // '5:00'의 형태일 시 count == 7
                        else if time.count == 7 {
                            let hourStartIndex = time.index(colonIndex.lowerBound, offsetBy: -1)
                            let minuteEndIndex = time.index(colonIndex.upperBound, offsetBy: 1)
                            timeSubstring = time[hourStartIndex...minuteEndIndex]
                            hour = Int(timeSubstring.prefix(1)) ?? 0
                            
                            if time.contains("오후") {
                                hour += 12
                            }
                        }
                    }
                    return hour
                }
                
                // 오전 7:30 -> '30' 가져옴
                func convertMinute(time: String) -> Int{
                    var minuteSubstring:Substring = ""
                    if let colonIndex = time.range(of: ":"){
                        
                        let minuteEndIndex = time.index(colonIndex.upperBound, offsetBy: 1)
                        minuteSubstring = time[colonIndex.upperBound...minuteEndIndex]
                    }
                    return Int(minuteSubstring) ?? 0
                }
                
                // minute '0' or '5' -> '00' or '05'로 변환
                func changeMinuteDigit(minute: String) -> String{
                    var modifiedMinute = minute
                    
                    // minute 자릿수 변환
                    if minute == "0" && minute.count == 1{
                        modifiedMinute = "00"
                    }
                    else if minute == "5" && minute.count == 1{
                        modifiedMinute = "05"
                    }
                    return modifiedMinute
                }
                
                // 기존에 저장된 시간 있는지 확인 (nil이면 -> 첫 알림을 받는 것, nil이 아니면 -> 알림을 수정 하는 것)
                // 저장 시 21:00 / 4:00 형태로 저장
                func setTimeToUserDefaults(timeToString: String, title: String){
                    if let _ = UserDefaults.standard.string(forKey: "Time" + title) {
                        UserDefaults.standard.removeObject(forKey: "Time" + title)
                        UserDefaults.standard.set(timeToString, forKey: "Time" + title)
                    }
                    else{
                        UserDefaults.standard.set(timeToString, forKey: "Time" + title)
                    }
                }
            }
        }
    }
}
//MARK: - 로컬 notification 삭제

extension RoutineViewModel{
    func deleteNotification(title: String, days: [String]){
        var identifiers: [String] = []
        for (index, _) in days.enumerated(){
            //배열 접근  -> 배열 index 값 get
            identifiers.append("\(title): \(index)")
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        UserDefaults.standard.removeObject(forKey: "Time" + title)
    }
}
