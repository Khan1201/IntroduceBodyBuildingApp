//
//  ViewController.swift
//  BodyBuildingProgram
//
//  Created by 윤형석 on 2022/08/16.
//

import UIKit
import FirebaseFirestore
import FirebaseCore
import Firebase

class ViewController: UIViewController{
   
    
  
    

    @IBOutlet weak var healthTableView: UITableView!
        
    struct cellData{ // 셀 데이터 및 뷰 컨트롤러 데이터 저장 구조체
        static var cellModel = [[CellModel]]()
        static var vcModel = [[VCModel]]()
        static var filteredModel = [[CellModel]]()

    }
   

    
//    func makeData(){ //내부데이터 생성
//
//
//        cellData.vcModel.append(
//            [VCModel(title: "nSuns 5/3/1 Complete", image: "powerlifting", description: "nSuns 5/3/1 is a linear progression powerlifting program that was inspired by Jim Wendler’s 5/3/1 strength program. It progresses on a weekly basis, making it well suited for late stage novice and early intermediate lifters. It is known for its challenging amount of volume. Those who stick with it tend to find great results from the additional work capacity", url: "https://liftvault.com/programs/powerlifting/n-suns-lifting-spreadsheets/")]
//
//        cellData.cellModel.append(
//        [CellModel(title: "nSuns 5/3/1 Complete", author: "nSuns", description: "nSuns 5/3/1 is a linear progression powerlifting program that was inspired by Jim Wendler’s 5/3/1 strength program", recommend: "★★★★☆", division: "PowerLifting", image: "powerlifting")]
//        )
//
//    }
    
    func makeSearchBar(){
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false //false -> 검색창 활성화 시 주변 화면 흐림 X
        searchController.searchResultsUpdater = self //SearchBar에 데이터 입력 시 실시간으로 결과 반영
        
        
        self.navigationItem.title = "Health Program"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.hidesSearchBarWhenScrolling = true //스크롤 내릴 시 검색창 숨김
        self.navigationItem.searchController = searchController
        
    }
    
    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false //서치바에 텍스트가 존재 시 true
        return isActive && isSearchBarHasText
    }
    
    
    func makeData(){
        let db = Firestore.firestore()
        db.collection("Program").getDocuments() { (querySnapshot, err) in //메인페이지 데이터 로딩
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {

                    var count = 0
                    guard let data = try? JSONSerialization.data(withJSONObject: Array(arrayLiteral: document.data()), options: []) else{return} //Json 데이터로 변환
                    let decode = try? JSONDecoder().decode([CellModel].self, from: data)
                    print(decode)
                    cellData.cellModel.append(decode!) //document 1개당 cellModel.append
                    print(cellData.cellModel.count)
                    print(cellData.cellModel[count])
                    count += 1

                }
                self.healthTableView.reloadData()
            }
        }
        
        db.collection("Detail").getDocuments() { (querySnapshot, err) in //상세페이지 데이터 로딩
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {

                    var count = 0
                    guard let data = try? JSONSerialization.data(withJSONObject: Array(arrayLiteral: document.data()), options: []) else{return} //Json 데이터로 변환
                    let decode = try? JSONDecoder().decode([VCModel].self, from: data)
                    print(decode)
                    cellData.vcModel.append(decode!) //document 1개당 cellModel.append
                    print(cellData.vcModel.count)
                    print(cellData.vcModel[count])
                    count += 1

                }
                
            }
        }
        
        
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
  
//        makeData()
        makeData()
        makeSearchBar()
            
        healthTableView.delegate = self
        healthTableView.dataSource = self
    }
    

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering { //검색 활성화 -> 검색 데이터 적용, 검색 비활성화 -> 기존 데이터 사용
            return cellData.filteredModel[section].count
        }
        else{
            return cellData.cellModel[section].count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isFiltering {
            return cellData.filteredModel.count
        }
        else{
            return cellData.cellModel.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = healthTableView.dequeueReusableCell(withIdentifier: "HealthCell", for: indexPath)
                    as! HealthCell
        
        cell.layer.cornerRadius = cell.bounds.height / 6
        
        if isFiltering { //검색 활성화 -> 검색 데이터 적용, 검색 비활성화 -> 기존 데이터 사용
            cell.titleLabel.text = cellData.filteredModel[indexPath.section][indexPath.row].title
            cell.authorLabel.text = cellData.filteredModel[indexPath.section][indexPath.row].author
            cell.descriptionLabel.text = cellData.filteredModel[indexPath.section][indexPath.row].description
            cell.recommendLabel.text = cellData.filteredModel[indexPath.section][indexPath.row].recommend
            cell.divisionLabel.text = cellData.filteredModel[indexPath.section][indexPath.row].division
            cell.healthImageView.image = UIImage(named: cellData.filteredModel[indexPath.section][indexPath.row].image)
        }
        else{
            cell.titleLabel.text = cellData.cellModel[indexPath.section][indexPath.row].title
            cell.authorLabel.text = cellData.cellModel[indexPath.section][indexPath.row].author
            cell.descriptionLabel.text = cellData.cellModel[indexPath.section][indexPath.row].description
            cell.recommendLabel.text = cellData.cellModel[indexPath.section][indexPath.row].recommend
            cell.divisionLabel.text = cellData.cellModel[indexPath.section][indexPath.row].division
            cell.healthImageView.image = UIImage(named: cellData.cellModel[indexPath.section][indexPath.row].image)
        }
 
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // storyboard 인스턴스화 -> 데이터 전송 -> 뷰 전환
            if let moveVC = UIStoryboard(name: "DetailViewController", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController{
                moveVC.titleName = cellData.vcModel[indexPath.section][indexPath.row].title
                moveVC.imageName = cellData.vcModel[indexPath.section][indexPath.row].image
                moveVC.descrip = cellData.vcModel[indexPath.section][indexPath.row].description
                moveVC.url = cellData.vcModel[indexPath.section][indexPath.row].url
                self.navigationController?.pushViewController(moveVC, animated: true)
            }
   
            
        
    }
    
    
    
}

extension ViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) { //SearchBar에 입력 시 실시간으로 결과 반영
        guard let text = searchController.searchBar.text else {return}
        cellData.filteredModel  = cellData.cellModel.filter{ $0.contains { CellModel in //기존의 데이터 모델과 같은 형태의 filteredModel 선언, .filter를 통해 필터링된 데이터 저장 -> 테이블 뷰 리로드
            if CellModel.title.contains(text) || CellModel.author.contains(text) || CellModel.description.contains(text) {
                return true
            }
            else{
                return false
            }
        }
        }
        healthTableView.reloadData()
    }
    
    
    
}



