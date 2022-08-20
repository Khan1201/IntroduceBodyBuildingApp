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
    @IBOutlet weak var searchBar: UISearchBar!
    
    struct cellData{ // 셀 데이터 및 뷰 컨트롤러 데이터 저장 구조체
        static var cellModel = [[CellModel]]()
        static var vcModel = [VCModel]()
    }
   

    
    func makeData(){ //내부데이터 생성

        
        cellData.vcModel.append(
            VCModel(title: "nSuns 5/3/1 Complete", image: "bodybuilding", description: "nSuns 5/3/1 is a linear progression powerlifting program that was inspired by Jim Wendler’s 5/3/1 strength program. It progresses on a weekly basis, making it well suited for late stage novice and early intermediate lifters. It is known for its challenging amount of volume. Those who stick with it tend to find great results from the additional work capacity.", url: "https://liftvault.com/programs/powerlifting/n-suns-lifting-spreadsheets/")
        )
        cellData.vcModel.append(
            VCModel(title: "1111", image: "bbbb", description: "cccc", url: "dddd")
        )
        cellData.vcModel.append(
            VCModel(title: "2222", image: "bbbb", description: "cccc", url: "dddd")
        )
        cellData.vcModel.append(
            VCModel(title: "3333", image: "bbbb", description: "cccc", url: "dddd")
        )
        cellData.vcModel.append(
            VCModel(title: "4444", image: "bbbb", description: "cccc", url: "dddd")
        )
        
        
        cellData.cellModel.append(
        [CellModel(title: "nSuns 5/3/1 Complete", author: "Jim Wendler", description: "nSuns 5/3/1 is a linear progression powerlifting program that was inspired by Jim Wendler’s 5/3/1 strength program", recommend: "★★★★☆", division: "PowerLifting", image: "bodybuilding")]
        )

        cellData.cellModel.append(
        [CellModel(title: "StrongLift 5x5", author: "Bigmike", description: "Need to increase Strength and Hypertrophy", recommend: "★★★★★", division: "4분할", image: "paperplane")]
        )
        cellData.cellModel.append(
        [CellModel(title: "StrongLift 5x5", author: "Bigmike", description: "Need to increase Strength and Hypertrophy", recommend: "★★★★★", division: "4분할", image: "paperplane")]
        )
        cellData.cellModel.append(
        [CellModel(title: "StrongLift 5x5", author: "Bigmike", description: "Need to increase Strength and Hypertrophy", recommend: "★★★★★", division: "4분할", image: "paperplane")]
        )
        cellData.cellModel.append(
        [CellModel(title: "StrongLift 5x5", author: "Bigmike", description: "Need to increase Strength and Hypertrophy", recommend: "★★★★★", division: "4분할", image: "paperplane")]
        )
        cellData.cellModel.append(
        [CellModel(title: "StrongLift 5x5", author: "Bigmike", description: "Need to increase Strength and Hypertrophy", recommend: "★★★★★", division: "4분할", image: "paperplane")]
        )
        cellData.cellModel.append(
        [CellModel(title: "StrongLift 5x5", author: "Bigmike", description: "Need to increase Strength and Hypertrophy", recommend: "★★★★★", division: "4분할", image: "paperplane")]
        )
        cellData.cellModel.append(
        [CellModel(title: "StrongLift 5x5", author: "Bigmike", description: "Need to increase Strength and Hypertrophy", recommend: "★★★★★", division: "4분할", image: "paperplane")]
        )
        

    }
    // (firebase 데이터 로딩, 오류가 발생하여 임시데이터로 작업 후 나중에 서버 데이터 연결 예정)
////    func makeData2(){
//
//            let db = Firestore.firestore()
//
//            let docRef = db.collection("Program").document("dittk1")
//            docRef.getDocument { (document, error) in
//                if let document = document, document.exists {
//                    let dataDescription = document.data()
//                    guard let data = try? JSONSerialization.data(withJSONObject: Array(arrayLiteral: dataDescription), options: []) else{return} //Json 데이터로 변환
//                    let decode = try? JSONDecoder().decode([CellModel].self, from: data)
//                    print(decode ?? "sorry")
//                    cellData.cellModel.append(decode!) //document 1개당 cellModel.append
//                    print(cellData.cellModel[2])
//                    print(data)
//                } else {
//                    print("Document does not exist")
//                }
//            }
//    }
    
//    func makeData3(){
//        var count = 0
//        let db = Firestore.firestore()
//        db.collection("Program").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//
//                    guard let data = try? JSONSerialization.data(withJSONObject: Array(arrayLiteral: document.data()), options: []) else{return} //Json 데이터로 변환
//                    let decode = try? JSONDecoder().decode([CellModel].self, from: data)
//                    cellData.cellModel.append(decode!) //document 1개당 cellModel.append
//                    print(cellData.cellModel.count)
//                    print(cellData.cellModel[count])
//                    count += 1
//
//                }
//            }
//        }
//    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
  
        makeData()
        
        
        self.title = "프로그램 소개"
        healthTableView.delegate = self
        healthTableView.dataSource = self
        searchBar.delegate = self

    }
    

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.cellModel[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellData.cellModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = healthTableView.dequeueReusableCell(withIdentifier: "HealthCell", for: indexPath)
                    as! HealthCell
        
        
        cell.layer.cornerRadius = cell.bounds.height / 6
        cell.titleLabel.text = cellData.cellModel[indexPath.section][indexPath.row].title
        cell.authorLabel.text = cellData.cellModel[indexPath.section][indexPath.row].author
        cell.descriptionLabel.text = cellData.cellModel[indexPath.section][indexPath.row].description
        cell.recommendLabel.text = cellData.cellModel[indexPath.section][indexPath.row].recommend
        cell.divisionLabel.text = cellData.cellModel[indexPath.section][indexPath.row].division
        cell.healthImageView.image = UIImage(named: cellData.cellModel[indexPath.section][indexPath.row].image)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // storyboard 인스턴스화 -> 데이터 전송 -> 뷰 전환
            if let moveVC = UIStoryboard(name: "DetailViewController", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController{
                moveVC.titleName = cellData.vcModel[indexPath.section].title
                moveVC.imageName = cellData.vcModel[indexPath.section].image
                moveVC.descrip = cellData.vcModel[indexPath.section].description
                moveVC.url = cellData.vcModel[indexPath.section].url
                self.navigationController?.pushViewController(moveVC, animated: true)
            }
   
            
        
    }
    
}

extension ViewController: UISearchBarDelegate{
    
}

