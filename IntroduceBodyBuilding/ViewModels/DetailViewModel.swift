import Foundation
import CoreData
import Alamofire
import RxSwift

class DetailViewModel {
    let detailViewObservable: BehaviorSubject<[DetailVCModel.Fields]> = BehaviorSubject(value: [])
    lazy var detailVCIndexObservable = BehaviorSubject<DetailVCModel.Fields>(value: DetailVCModel.Fields())
    
    // 위 Index Observable의 값 튜플화한 Observable
    lazy var tableViewObservable = BehaviorSubject<[(String ,String)]>(value: [("","")])
    
    // 호출한 VC 판별
    lazy var fromRoutineVC = BehaviorSubject<Bool>(value: false)
    lazy var fromMyProgramVC = BehaviorSubject<Bool>(value: false)
    lazy var fromDetailVCRoutineAddButton = PublishSubject<Bool>()
    
    // webViewVC에 전달할 string
    lazy var url = ""
    
    init() {
        makeDetailVCData()
    }
}

//MARK: - detailVC의 전체 데이터 생성

extension DetailViewModel{
    func makeDetailVCData() {
        let url = "https://firestore.googleapis.com/v1/projects/bodybuildingapp-3e7db/databases/(default)/documents/Detail"
        AF.request(url,
                   method: .get,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: DetailVCModel.self) { response in // decoding
            switch response.result {
            case .success :
                if let value = response.value?.documents {
                    self.detailViewObservable.onNext(value)
                }
            case .failure(let error):
                print("AF error: \(error)")
            }
        }
    }
}

//MARK: - CoreData에 접근

extension DetailViewModel{
    
   func returnDuplicatedBoolAfterSaveData(data: DetailVCModel.Fields) -> Bool{
       var duplicated: Bool = false
       do{
            let myProgramObject = try getObject() //CoreData Entity인 MyProgram 정의

            //CoreData에 데이터가 없을 시 -> 데이터 삽입, 데이터가 있을 시 -> 중복체크 후 데이터 삽입
            if MyProgramViewModel.coreData.isEmpty{
                insertData(in: myProgramObject, data: data)
            }
            else{
                duplicated = insertDataAfterDuplicatedCheck(in: myProgramObject, data: data)
            }
        }
        catch{
            print("coreData Error: \(error)")
        }
       return duplicated
        
        //CoreData 오브젝트 get
        func getObject() throws -> NSManagedObject{
            let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            guard let myProgramEntity = NSEntityDescription.entity(forEntityName: "MyProgram", in: viewContext) else{
                throw setDataError.EntityNotExist } //CoreData entity 정의
            let myProgramObject = NSManagedObject(entity: myProgramEntity, insertInto: viewContext)
            return myProgramObject
        }
        
        // CoreData에 데이터 삽입
        func insertData(in object: NSManagedObject, data: DetailVCModel.Fields) {
            let myProgram = object as! MyProgram
            myProgram.title = data.title
            myProgram.image = data.image
            myProgram.description_ = data.description
            myProgram.division = data.image //bodybuilding, powerbuilding, powerlifting 의 구분자 역활
            
            do{
                try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save() //insert 적용
            }
            catch{
                print("save error: \(error)")
            }
        }
        
        // 데이터 중복체크 후 CoreData에 데이터 삽입
       func insertDataAfterDuplicatedCheck(in myProgramObject: NSManagedObject, data: DetailVCModel.Fields) -> Bool{
            _ = MyProgramViewModel() //선언과 동시에 MyProgramViewModel.coreData 최신화
            var count = 0
            for coreData in MyProgramViewModel.coreData{
                if (coreData.title == data.title){ //중복시 중복 다이얼로그 생성
                    return true
                }
                else{
                    count += 1
                    if count == MyProgramViewModel.coreData.count{ //전체 순회하였을 시(중복이 없을 시) coreData에 데이터 삽입
                        insertData(in: myProgramObject, data: data)
                    }
                }
            }
           return false
        }
        
        //오류 정의
        enum setDataError: Error{
            case EntityNotExist
        }
    }
}
