
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
    

    
    func makeFireStoreData(){
        readData(collection: "Program", model: cellData.mainVCModel) // Program -> 메인 셀 데이터
        readData(collection: "Detail", model: cellData.detailVCModel) // Detail -> 상세 뷰 데이터
        
        func readData<T: Decodable>(collection: String, model: [T]) {
            Firestore.firestore().collection(collection).getDocuments() { (querySnapshot, err) in //메인페이지 데이터 Read
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents { //data -> json 변환
                        guard let data = try? JSONSerialization.data(withJSONObject: document.data(), options: []) else{ return }
                        if let decode = try? JSONDecoder().decode(T.self, from: data){ //json 데이터를 struct에 set
                            applyModel(data: decode)
                        }
                    }
                    tableViewBinding(collection: collection) // 메인 테이블 뷰 바인딩 (상세 뷰는 메인 Cell 데이터를 가져오기 때문)
                }
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
        
        func tableViewBinding(collection: String){
            if collection == "Program" { // Program -> 메인 테이블 뷰 데이터
                self.bindTableView(isFilterd: false)
                setupTableViewDelegate()
            }
        }
        
        
    }
    
    var isFiltering: Bool{
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
    
    func makeButton() {
        basketButton()
        
        func basketButton() {
            let basketButton = UIButton()
            setButton()
            selectAction()
            
            func selectAction(){
                basketButton.rx.tap.bind { _ in
                    self.moveVC(VC: MyProgramViewController(), data: nil, indexPath: nil)
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
    
    func moveVC <T>(VC: T, data: ControlEvent<MainVCModel>.Element?, indexPath: IndexPath?) {
        
        if VC is DetailViewController{ // 상세 뷰 컨트롤러
            let storyboard = UIStoryboard(name: "DetailViewController", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
            var indexModel: Int = 0 // 메인 뷰 - 상세 뷰 데이터 바인딩 위한 index
            for (index, model) in cellData.mainVCModel.enumerated(){
                if model.title == data!.title  {
                    indexModel = index
                }
            }
            self.mainTableView.deselectRow(at: indexPath!, animated: true)
            
            storyboard.titleName = cellData.detailVCModel[indexModel].title //위에서 구한 index로 상세 뷰 데이터 배열에서 해당 데이터 가져옴
            storyboard.descrip = cellData.detailVCModel[indexModel].description
            storyboard.imageName = cellData.detailVCModel[indexModel].image
            storyboard.url = cellData.detailVCModel[indexModel].url
            self.navigationController?.pushViewController(storyboard, animated: true)
        }
        
        else if VC is MyProgramViewController{ //장바구니 뷰 컨트롤러
            let storyboard = UIStoryboard(name: "MyProgramViewController", bundle: nil).instantiateViewController(withIdentifier: "MyProgramViewController") as! MyProgramViewController
            self.present(storyboard, animated: true)
        }
    }
    
    private func bindTableView(isFilterd: Bool) {

        setupTableViewOption()
        let mainOb: Observable<[MainVCModel]> = Observable.of(cellData.mainVCModel) //메인 테이블 뷰
        let filteredOb: Observable<[MainVCModel]> = Observable.of(cellData.filteredModel) // 검색 활성화 시 출력되는 테이블 뷰
        
        isFilterd ? bindingCell(observable: filteredOb) : bindingCell(observable: mainOb) //필터링(검색 활성화 시)
        
        func bindingCell(observable: Observable<[MainVCModel]>){ // 메인 테이블 뷰에 cell 바인딩
            observable.bind(to: self.mainTableView.rx.items(cellIdentifier: "MainVCCell", cellType: MainVCCell.self)) { (index: Int, element: MainVCModel, cell: MainVCCell) in
                
                cell.titleLabel.text = element.title
                cell.authorLabel.text = element.author
                cell.descriptionLabel.text = element.description
                cell.recommendLabel.text = element.recommend
                cell.divisionLabel.text = element.division
                cell.healthImageView.image = UIImage(named: element.image)
            }.disposed(by: self.disposeBag)
        }
        
        func setupTableViewOption(){
            mainTableView.separatorStyle = .none
            mainTableView.showsVerticalScrollIndicator = false
            mainTableView.delegate = nil
            mainTableView.dataSource = nil
        }
    }
        
    func setupTableViewDelegate(){ //selected action
        Observable.zip(mainTableView.rx.modelSelected(MainVCModel.self), mainTableView.rx.itemSelected)
            .bind { (data, indexPath) in //data: 상세 뷰에 데이터 바인딩 위해, indexPath: deselectRow 위해
                self.moveVC(VC: DetailViewController(), data: data, indexPath: indexPath)
            }.disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeFireStoreData()
        makeSearchBar()
        makeButton()
    }
}

extension ViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) { //SearchBar에 입력 시 실시간으로 결과 반영
        guard let text = searchController.searchBar.text?.uppercased() else {return}
        cellData.filteredModel  = cellData.mainVCModel.filter({ MainVCModel in
            MainVCModel.title.uppercased().contains(text) || MainVCModel.author.uppercased().contains(text) ||
            MainVCModel.description.uppercased().contains(text) || MainVCModel.division.uppercased().contains(text)
        })
        isFiltering ? bindTableView(isFilterd: true) : bindTableView(isFilterd: false)
    }
}
