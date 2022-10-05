
import UIKit
import CoreData
import RxSwift
import RxCocoa
import SnapKit
import DropDown

class MainViewController: UIViewController{
    
    @IBOutlet weak var mainTableView: UITableView!
    
    let disposeBag = DisposeBag()
    var mainViewModel = MainTableViewModel()
    var detailViewModel = DetailViewModel()
    
    var isFiltering: Bool{ //검색 활성화 인식 로직
        let searchController = self.navigationItem.searchController
        let isActive = searchController?.isActive ?? false
        let isSearchBarHasText = searchController?.searchBar.text?.isEmpty == false //서치바에 텍스트가 존재 시 true
        return isActive && isSearchBarHasText
    }
    
    func makeSearchBar(){ //서치바 생성
        let searchController = UISearchController(searchResultsController: nil)
        navigationSet(searchController: searchController)
        searchControllerSet(searchController: searchController)
        func navigationSet(searchController: UISearchController){
            self.navigationItem.title = "Health Program"
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.hidesSearchBarWhenScrolling = true //스크롤 내릴 시 검색창 숨김
            self.navigationItem.searchController = searchController
            self.navigationItem.backButtonTitle = "Back"

        }
        
        func searchControllerSet(searchController: UISearchController){
            searchController.obscuresBackgroundDuringPresentation = false //false -> 검색창 활성화 시 주변 화면 흐림 X
            searchController.searchResultsUpdater = self //SearchBar에 데이터 입력 시 실시간으로 결과 반영
        }
    }
    
    func makePlusButton() {
        let plusButton = UIButton()
        setButton()
        addClickEvent()
        
        func setButton(){
            plusButton.backgroundColor = .systemGray4
            let config = UIImage.SymbolConfiguration( //sf symbol 이미지 사이즈 설정
                pointSize: 40, weight: .bold, scale: .default)
            plusButton.setImage(UIImage(systemName: "plus", withConfiguration: config), for: .normal)
            plusButton.tintColor = .black
            plusButton.layer.masksToBounds = true
            plusButton.layer.cornerRadius = 15
            plusButton.alpha = 0.8 //버튼 투명도
            view.addSubview(plusButton) //뷰에 버튼 추가
        
            plusButton.snp.makeConstraints { make in
                make.width.height.equalTo(70)
                make.bottom.equalToSuperview().offset(-40)
                make.trailing.equalToSuperview().offset(-18)
            }
        }
        func addClickEvent(){ // + 버튼 클릭 이벤트
            plusButton.rx.tap.bind { [weak self] in //버튼 액션
                let dropDown = DropDown() //dropDown ui 객체 생성
                setDropDown()
                linkCustomCell()
                addClickEvent()
                dropDown.show()

                func setDropDown(){ // dropDown option set
                    dropDown.anchorView = plusButton
                    dropDown.width = 140
                    dropDown.cellHeight = 70
                    dropDown.cornerRadius = 15
                    dropDown.dataSource = ["루틴등록","보관함"]
                    dropDown.topOffset = CGPoint(x: -60, y:-(dropDown.anchorView?.plainView.bounds.height)!)
                }
                func linkCustomCell(){ // dropDown list -> custom cell
                    dropDown.cellNib = UINib(nibName: "DropCell", bundle: nil) //customCell 적용
                    dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                        guard let cell = cell as? DropCell else { return }
                        if index == 0{
                            cell.dropDownImage.image = UIImage(systemName: "square.and.pencil")
                        }
                        else{
                            cell.dropDownImage.image = UIImage(systemName: "archivebox")
                        }
                    }
                }
                func addClickEvent(){
                    dropDown.selectionAction = { [weak self] (index, item) in
                        if index == 1{
                            _ = MyProgramViewModel() //선언과 동시에 coreData 생성 됨
                            let basetVC = UIStoryboard(name: "MyProgramViewController", bundle: nil)
                                .instantiateViewController(withIdentifier: "MyProgramViewController") as! MyProgramViewController
                            self?.navigationController?.pushViewController(basetVC, animated: true)
                        }
                    }
                }
            }.disposed(by: disposeBag) // 구독해제 (메모리 정리)
        }
    }
    private func bindTableView(isFilterd: Bool) { //테이블 뷰 셀 바인딩, 테이뷸 뷰 옵션 설정
        
        setTableViewOption()
        isFilterd ? bindingCell(data: mainViewModel.filteredObservable) : bindingCell(data: mainViewModel.tableViewObservable)
        
        func setTableViewOption(){ //테이블 뷰 초기설정
            mainTableView.separatorStyle = .none
            mainTableView.showsVerticalScrollIndicator = false
            mainTableView.delegate = nil
            mainTableView.dataSource = nil
        }
        func bindingCell(data: BehaviorSubject<[MainTVCellModel.Fields]>){ // 메인 테이블 뷰에 cell 바인딩
            data.bind(to: self.mainTableView.rx.items(cellIdentifier: "MainTableViewCell", cellType: MainTableViewCell.self)) { (index, element, cell) in
        
                cell.titleLabel.text = element.title
                cell.weekLabel.text = element.week
                cell.descriptionLabel.text = element.description
                cell.recommendLabel.text = element.recommend
                cell.divisionLabel.text = element.division
                cell.healthImageView.image = UIImage(named: element.image )
            }.disposed(by: self.disposeBag)
        }
    }
    
    func addCellCilckEvent(){ // 셀 클릭 이벤트 (한번만 선언위해 바깥으로 빼놓음)
        Observable.zip(mainTableView.rx.itemSelected, mainTableView.rx.modelSelected(MainTVCellModel.Fields.self))
        //itemSelectd -> IndexPath 추출, modelSelected -> .title 추출
            .withLatestFrom(detailViewModel.detailViewObservable){ [weak self] (zipData, detailVCDatas) in
                //zipData -> (indexPath, modelData)
                self?.mainTableView.deselectRow(at: zipData.0, animated: true) //셀 선택시 선택 효과 고정 제거
                let detailVC = UIStoryboard(name: "DetailViewController", bundle: nil)
                    .instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                
                for detailVCData in detailVCDatas{ //Array인 detailViewModel의 Data에 접근
                    if zipData.1.title == detailVCData.title{
                        detailVC.detailVCIndexObservable.onNext(detailVCData)
                    }
                }
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }
            .subscribe(onDisposed:  {
            }).disposed(by: disposeBag)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makeSearchBar()
        bindTableView(isFilterd: false)
        addCellCilckEvent()
        makePlusButton()
    }
}

extension MainViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) { //SearchBar에 입력 시 실시간으로 결과 반영
        guard let text = searchController.searchBar.text?.uppercased() else {return}
        
        mainViewModel.tableViewObservable
            .map({ datas in
                var tempArray: [MainTVCellModel.Fields] = []
                for data in datas{
                    if data.title.uppercased().contains(text) || data.week.uppercased().contains(text) ||
                        data.recommend.uppercased().contains(text) || data.division.uppercased().contains(text) {
                        tempArray.append(data)
                    }
                }
                return tempArray
            })
            .subscribe { [weak self] data in
                if let self = self{
                    self.mainViewModel.filteredObservable.onNext(data)
                    self.bindTableView(isFilterd: self.isFiltering)
                }
            }.disposed(by: disposeBag)
    }
}
