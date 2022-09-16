
import UIKit
import FirebaseFirestore
import CoreData
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController{
    let disposeBag = DisposeBag()
 
    @IBOutlet weak var mainTableView: UITableView!
    
    struct cellData{ // 셀 데이터 및 뷰 컨트롤러 데이터 저장 구조체 (메인 cell, detail 페이지 -> 2개의 컬렉션으로 구성)
        static var mainVCModel = [MainVCModel]() //테이블 셀 데이터
        static var detailVCModel = [DetailVCModel]() //datail 페이지 데이터
        static var filteredModel = [MainVCModel]() //search filter
    }
    
    func MainTVSet(){
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.separatorStyle = .none
        mainTableView.showsVerticalScrollIndicator = false
    }
    
    func makeFireStoreData(){
        readData(collection: "Program", model: cellData.mainVCModel)
        readData(collection: "Detail", model: cellData.detailVCModel)
    }
    
    func readData<T: Decodable>(collection: String, model: [T]) {
        Firestore.firestore().collection(collection).getDocuments() { (querySnapshot, err) in //메인페이지 데이터 Read
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents { //data -> json 변환
                    guard let data = try? JSONSerialization.data(withJSONObject: document.data(), options: []) else{ return }
                    if let decode = try? JSONDecoder().decode(T.self, from: data){ //json 데이터를 struct에.set
                        applyModel(data: decode)
                    }
                }
                self.mainTableView.reloadData()
            }
        }
        
        func applyModel<T>(data: T) { //firestore 데이터 -> 내부 모델(배열)에 저장
            if data is MainVCModel{
                cellData.mainVCModel.append(data as! MainVCModel)
            }
            else if data is DetailVCModel{
                cellData.detailVCModel.append(data as! DetailVCModel)
            }
        }
    }
    
    var isFiltering: Bool {
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false //서치바에 텍스트가 존재 시 true
        return isActive && isSearchBarHasText
    }
    
    func makeSearchBar(){
        let searchController = UISearchController(searchResultsController: nil)
        navigationSet(searchController: searchController)
        searchBarSet(searchController: searchController)
        
        func navigationSet(searchController: UISearchController){
            self.navigationItem.title = "Health Program"
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.hidesSearchBarWhenScrolling = true //스크롤 내릴 시 검색창 숨김
            self.navigationItem.searchController = searchController
        }
        
        func searchBarSet(searchController: UISearchController){
            searchController.obscuresBackgroundDuringPresentation = false //false -> 검색창 활성화 시 주변 화면 흐림 X
            searchController.searchResultsUpdater = self //SearchBar에 데이터 입력 시 실시간으로 결과 반영
        }
    }
    
    func moveVC <T>(name: String, VC: T, indexPath: IndexPath?) {
        
        if VC is DetailViewController{
            let storyboard = UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: name) as! DetailViewController
            storyboard.titleName = cellData.detailVCModel[indexPath!.row].title
            storyboard.imageName = cellData.detailVCModel[indexPath!.row].image
            storyboard.descrip = cellData.detailVCModel[indexPath!.row].description
            storyboard.url = cellData.detailVCModel[indexPath!.row].url
            self.navigationController?.pushViewController(storyboard, animated: true)
        }
        
        else if VC is MyProgramViewController{
            let storyboard = UIStoryboard(name: name, bundle: nil).instantiateViewController(withIdentifier: name) as! MyProgramViewController
            self.present(storyboard, animated: true)
        }
        
    }
    
    func makeButton() {
        basketButton()
        
        func basketButton() {
            let basketButton = UIButton()
            setButton()
            selectAction()

            func selectAction(){
                basketButton.rx.tap.bind { _ in
                    self.moveVC(name: "MyProgramViewController", VC: MyProgramViewController(), indexPath: nil)
                }.disposed(by: disposeBag) // 구독해제 (메모리 정리)
            }
            
            func setButton(){
                basketButton.backgroundColor = .systemGray3
                basketButton.translatesAutoresizingMaskIntoConstraints = false //autolayout 사용 위해 false 필수
                basketButton.setImage(UIImage(named: "basket"), for: .normal)
                
                basketButton.layer.masksToBounds = true
                basketButton.layer.cornerRadius = 20
                basketButton.alpha = 0.9 //버튼 투명도
                
                view.addSubview(basketButton) //뷰에 버튼 추가
                
                basketButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 730).isActive = true //constraint 설정
                basketButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 300).isActive = true
                basketButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -40).isActive = true
                basketButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18).isActive = true
            }
        }

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeFireStoreData()
        makeSearchBar()
        MainTVSet()
        makeButton()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if isFiltering { //검색 활성화 -> 검색 데이터 적용, 검색 비활성화 -> 기존 데이터 사용
            return cellData.filteredModel.count
        }
        else{
            return cellData.mainVCModel.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = mainTableView.dequeueReusableCell(withIdentifier: "MainVCCell", for: indexPath)
        as! MainVCCell

        if isFiltering { //검색 활성화 -> 검색 데이터 적용, 검색 비활성화 -> 기존 데이터 사용
            bindingCell(cell: cell, model: cellData.filteredModel , indexPath: indexPath)
        }
        else{
            bindingCell(cell: cell, model: cellData.mainVCModel, indexPath: indexPath)
        }
        
        return cell
        
        func bindingCell(cell: MainVCCell, model: [MainVCModel], indexPath: IndexPath) {
                        
            cell.titleLabel.text = model[indexPath.row].title
            cell.authorLabel.text = model[indexPath.row].author
            cell.descriptionLabel.text = model[indexPath.row].description
            cell.recommendLabel.text = model[indexPath.row].recommend
            cell.divisionLabel.text = model[indexPath.row].division
            cell.healthImageView.image = UIImage(named: model[indexPath.row].image)
        }
    }
    

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        self.moveVC(name: "DetailViewController", VC: DetailViewController(), indexPath: indexPath)
    }
}

extension ViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) { //SearchBar에 입력 시 실시간으로 결과 반영
        guard let text = searchController.searchBar.text else {return}
        cellData.filteredModel  = cellData.mainVCModel.filter({ MainVCModel in
            MainVCModel.title.contains(text) || MainVCModel.author.contains(text) ||
            MainVCModel.description.contains(text) || MainVCModel.division.contains(text)
        })
        mainTableView.reloadData()
        }
    }



