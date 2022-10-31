//
//  DetailViewModel.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/09/27.
//

import Foundation
import Alamofire
import RxSwift

class DetailViewModel {
    var detailViewObservable: BehaviorSubject<[DetailVCModel.Fields]> = BehaviorSubject(value: [])
    
    // MainVC, MyProgramVC에서 쓰이기 때문에 private 지정 X
    lazy var detailVCIndexObservable = BehaviorSubject<DetailVCModel.Fields>(value: DetailVCModel.Fields())
    
    // 위 Index Observable의 값 튜플화한 Observable
    lazy var tableViewObservable = BehaviorSubject<[(String ,String)]>(value: [("","")])
    
    // 호출한 VC 판별
    lazy var fromRoutineVC = BehaviorSubject<Bool>(value: false)
    lazy var fromMyProgramVC = BehaviorSubject<Bool>(value: false)
    lazy var fromDetailVCRoutineAddButton = PublishSubject<Bool>()
    
    // webViewVC에 전달할 string
    lazy var url = BehaviorSubject<String>(value: "")
    
    init() {
        makeDetailVCData()
    }
    
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
//                    DetailViewModel.detailViewModel = value
                    self.detailViewObservable.onNext(value)
                }
            case .failure(let error):
                print("AF error: \(error)")
            }
        }
    }
}
