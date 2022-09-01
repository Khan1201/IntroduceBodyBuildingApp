
import UIKit
import FirebaseFirestore
import CoreData

class ViewController: UIViewController{
    
    @IBOutlet weak var mainTableView: UITableView!
    
    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false //서치바에 텍스트가 존재 시 true
        return isActive && isSearchBarHasText
    }
    
    struct cellData{ // 셀 데이터 및 뷰 컨트롤러 데이터 저장 구조체
        static var cellModel = [[MainTableViewCellModel]]()
        static var detailVCModel = [[DetailVCModel]]()
        static var filteredModel = [[MainTableViewCellModel]]()
    }
    
    //    func makeFireStoreData(){ //내부데이터 생성
    //
    //
    //        cellData.detailVCModel.append(
    //            [DetailVCModel(title: "nSuns 5/3/1 Complete", image: "powerlifting", description: "nSuns 5/3/1 is a linear progression powerlifting program that was inspired by Jim Wendler’s 5/3/1 strength program. It progresses on a weekly basis, making it well suited for late stage novice and early intermediate lifters. It is known for its challenging amount of volume. Those who stick with it tend to find great results from the additional work capacity", url: "https://liftvault.com/programs/powerlifting/n-suns-lifting-spreadsheets/")]
    //
    //        cellData.cellModel.append(
    //        [MainTableViewCellModel(title: "nSuns 5/3/1 Complete", author: "nSuns", description: "nSuns 5/3/1 is a linear progression powerlifting program that was inspired by Jim Wendler’s 5/3/1 strength program", recommend: "★★★★☆", division: "PowerLifting", image: "powerlifting")]
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
    
    func makeFireStoreData(){
        let db = Firestore.firestore()
        db.collection("Program").getDocuments() { (querySnapshot, err) in //메인페이지 데이터 Read
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    var count = 0
                    guard let data = try? JSONSerialization.data(withJSONObject: Array(arrayLiteral: document.data()), options: []) else{return} //Json 데이터로 변환
                    let decode = try? JSONDecoder().decode([MainTableViewCellModel].self, from: data)
                    cellData.cellModel.append(decode!) //document 1개당 cellModel.append
                    count += 1
                    
                }
                self.mainTableView.reloadData()
            }
        }
        
        db.collection("Detail").getDocuments() { (querySnapshot, err) in //상세페이지 데이터 Read
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    var count = 0
                    guard let data = try? JSONSerialization.data(withJSONObject: Array(arrayLiteral: document.data()), options: []) else{return} //Json 데이터로 변환
                    let decode = try? JSONDecoder().decode([DetailVCModel].self, from: data)
                    cellData.detailVCModel.append(decode!) //document 1개당 cellModel.append
                    count += 1
                    
                }
                
            }
        }
    }
    
    func makeBasketButton() {
        let basketButton = UIButton()
        
        basketButton.backgroundColor = .systemGray3
        basketButton.translatesAutoresizingMaskIntoConstraints = false
        basketButton.setImage(UIImage(named: "basket"), for: .normal)
        basketButton.imageView?.contentMode = .scaleToFill
        
        basketButton.layer.masksToBounds = true
        basketButton.layer.cornerRadius = 20
        basketButton.alpha = 0.9
        
        basketButton.addTarget(self, action: #selector(moveBasketVC), for: .touchUpInside)
        
        view.addSubview(basketButton)
        
        basketButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 730).isActive = true
        basketButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 300).isActive = true
        basketButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
        basketButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18).isActive = true
    }
    
    @objc func moveBasketVC() {
        let storyboard = UIStoryboard(name: "MyProgramViewController", bundle: nil).instantiateViewController(withIdentifier: "MyProgramViewController") as! MyProgramViewController
        self.present(storyboard, animated: true)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        makeFireStoreData()
        makeSearchBar()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        makeBasketButton()
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
        
        let cell = mainTableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath)
        as! MainTableViewCell
        
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
            moveVC.titleName = cellData.detailVCModel[indexPath.section][indexPath.row].title
            moveVC.imageName = cellData.detailVCModel[indexPath.section][indexPath.row].image
            moveVC.descrip = cellData.detailVCModel[indexPath.section][indexPath.row].description
            moveVC.url = cellData.detailVCModel[indexPath.section][indexPath.row].url
            self.navigationController?.pushViewController(moveVC, animated: true)
        }
    }
}

extension ViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) { //SearchBar에 입력 시 실시간으로 결과 반영
        guard let text = searchController.searchBar.text else {return}
        cellData.filteredModel  = cellData.cellModel.filter{ $0.contains { MainTableViewCellModel in //기존의 데이터 모델과 같은 형태의 filteredModel 선언, .filter를 통해 필터링된 데이터 저장 -> 테이블 뷰 리로드
            if MainTableViewCellModel.title.contains(text) || MainTableViewCellModel.author.contains(text) || MainTableViewCellModel.description.contains(text) {
                return true
            }
            else{
                return false
            }
        }
        }
        mainTableView.reloadData()
    }
}



