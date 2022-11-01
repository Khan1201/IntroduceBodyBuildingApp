import Foundation
import Alamofire
import RxSwift

class MainTableViewModel {
    
    let tableViewObservable: BehaviorSubject<[MainTVCellModel.Fields]> = BehaviorSubject(value: [])//메인 테이블 뷰
    lazy var filteredObservable: BehaviorSubject<[MainTVCellModel.Fields]> = BehaviorSubject(value: [])// 검색 활성화 시 출력되는 테이블 뷰
    
    init() {
        makeCellData()
    }
}

//MARK: - 검색 활성화 인식 로직

extension MainTableViewModel{
    func getIsFiltering(_ vc: MainViewController) -> Bool{
        let searchController = vc.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false //서치바에 텍스트가 존재 시 true
        return isActive && isSearchBarHasText
    }
}

//MARK: - TableView Data 생성

extension MainTableViewModel{
    func makeCellData() {
        let url = "https://firestore.googleapis.com/v1/projects/bodybuildingapp-3e7db/databases/(default)/documents/Program"
        AF.request(url,
                   method: .get,
                   parameters: nil,
                   encoding: URLEncoding.default,
                   headers: ["Content-Type":"application/json", "Accept":"application/json"])
        .validate(statusCode: 200..<300)
        .responseDecodable(of: MainTVCellModel.self) { response in // decoding
            switch response.result {
            case .success :
                if let value = response.value?.documents{
                    self.tableViewObservable.onNext(value)
                }
                
            case .failure(let error):
                print("AF error: \(error)")
            }
        }
    }
}
