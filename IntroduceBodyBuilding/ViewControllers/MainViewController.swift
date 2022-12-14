import UIKit
import Network

import CoreData
import RxSwift
import RxCocoa
import SnapKit
import DropDown
import Then
import DeviceKit






struct NetWorkUI{
    
    let wifiImage: UIImageView = UIImageView().then {
        $0.image = UIImage(systemName: "wifi.slash")
        $0.tintColor = .systemBlue
        $0.contentMode = .scaleAspectFit
    }
    let networkLabelOne: UILabel = UILabel().then {
        $0.text =
                """
                네트워크 문제로 연결이
                지연되고 있습니다.
                """
        $0.numberOfLines = 0
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: 17, weight: .semibold)
    }
    let networkLabelTwo: UILabel = UILabel().then {
        $0.text = "네트워크 연결을 확인한 후, ↑ 스와이프 해주세요"
        $0.textColor = .systemGray
        $0.font = .systemFont(ofSize: 13, weight: .regular)
    }
}



class MainViewController: UIViewController{
    
    let disposeBag = DisposeBag()
    var clickEventDisposeBag = DisposeBag() // 셀 클릭 이벤트 DisposeBag
    
    var mainViewModel = MainTableViewModel()
    var detailViewModel = DetailViewModel()
    
    private var refreshControl: UIRefreshControl = UIRefreshControl()
    
    var monitor = NWPathMonitor()
    let networkFalseUI = NetWorkUI()
    
    @IBOutlet weak var mainTableView: UITableView!{
        didSet{
            mainTableView.layer.cornerRadius = 20
        }
    }

    //MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestNotificationAuthorization() // 알림 접근권한 요청 Alert 제공
        detectFirstExecution()
        makeNavigationBar()
        makePlusButton()
        self.hideKeyboard()
        self.makeNetworkUIConstraint() // 미리 네트워크 연결 X UI 생성 후, 네트워크 상태에 따라 Hidden 설정
        
        monitor.start(queue: .global()) // 네트워크 상태 감지 시작
        
        monitor.pathUpdateHandler = { path in
            
            // 네트워크 연결 O
            if path.status == .satisfied{
                DispatchQueue.main.async{
                    self.hideNetworkUI()
                }
            }
            
            // 네트워크 연결 X
            else {
                DispatchQueue.main.async{
                    self.exposeNetworkUI()
                }
            }
        }
        monitor.cancel()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            self.bindTableView(isFilterd: false)
            self.addCellCilckEvent()
            self.addTableViewRefresh()
        }
    }
}

//MARK: - 네트워크 연결상태 X UI

extension MainViewController {
    
    // 네트워크 연결상태 X UI 숨김 (네트워크가 연결되어 있을때)
    func hideNetworkUI(){
        networkFalseUI.wifiImage.isHidden = true
        networkFalseUI.networkLabelOne.isHidden = true
        networkFalseUI.networkLabelTwo.isHidden = true
    }
    
    // 네트워크 연결상태 X UI 보이게 (네트워크가 연결되어 있지 않을때)
    func exposeNetworkUI(){
        networkFalseUI.wifiImage.isHidden = false
        networkFalseUI.networkLabelOne.isHidden = false
        networkFalseUI.networkLabelTwo.isHidden = false
    }
    
    // 네트워크 연결상태 X UI의 constraint 조정
    func makeNetworkUIConstraint(){
        view.addSubview(networkFalseUI.wifiImage)
        view.addSubview(networkFalseUI.networkLabelOne)
        view.addSubview(networkFalseUI.networkLabelTwo)
        
        networkFalseUI.wifiImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-60)
            make.width.height.equalTo(100)
        }
        networkFalseUI.networkLabelOne.snp.makeConstraints { make in
            make.top.equalTo(networkFalseUI.wifiImage.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        networkFalseUI.networkLabelTwo.snp.makeConstraints { make in
            make.top.equalTo(networkFalseUI.networkLabelOne.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
    }
}

//MARK: - 테이블 뷰 셀 바인딩, 테이뷸 뷰 옵션 설정

extension MainViewController {
    private func bindTableView(isFilterd: Bool) { //isFiltered -> true : 검색 활성화 시, false: 검색 비활성화 시
        
        setTableViewOption()
        isFilterd ? bindCell(data: mainViewModel.filteredObservable) : bindCell(data: mainViewModel.tableViewObservable)
        
        //테이블 뷰 초기설정
        func setTableViewOption(){
            mainTableView.separatorStyle = .none
            mainTableView.showsVerticalScrollIndicator = false
            mainTableView.delegate = nil
            mainTableView.dataSource = nil
        }
        
        // 메인 테이블 뷰에 cell 바인딩
        func bindCell(data: BehaviorSubject<[MainTVCellModel.Fields]>){
            
            data.bind(to: self.mainTableView.rx.items(cellIdentifier: "MainTableViewCell", cellType: MainTableViewCell.self)) { (index, element, cell) in
                
                cell.titleLabel.text = element.title
                cell.weekLabel.text = element.week
                cell.descriptionLabel.text = element.description
                cell.recommendLabel.text = element.recommend
                cell.divisionLabel.text = element.division
                cell.healthImageView.image = UIImage(named: element.title )
            }.disposed(by: self.disposeBag)
        }
    }
}

//MARK: - 셀 클릭 이벤트 (한번만 선언위해 바깥으로 빼놓음)

extension MainViewController {
    private func addCellCilckEvent(){
        
        //itemSelectd -> IndexPath 추출, modelSelected -> .title 추출
        Observable.zip(mainTableView.rx.itemSelected, mainTableView.rx.modelSelected(MainTVCellModel.Fields.self))
            .observe(on: MainScheduler.instance)
            .withLatestFrom(detailViewModel.detailViewObservable){ [weak self] (zipData, detailVCDatas) in
                //zipData -> (indexPath, modelData)
                                
                self?.mainTableView.deselectRow(at: zipData.0, animated: true) //셀 선택시 선택 효과 고정 제거
                guard let detailVC = self?.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
                
                for detailVCData in detailVCDatas{ //Array인 detailViewModel의 Data에 접근
                    if zipData.1.title == detailVCData.title{
                        detailVC.viewModel.detailVCIndexObservable
                            .onNext(detailVCData)
                        detailVC.test = detailVCData.notice
                    }
                }
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }
            .subscribe(onDisposed:  {
            }).disposed(by: clickEventDisposeBag)
    }
}

//MARK: - 네비게이션 바 및 서치바 생성

extension MainViewController {
    private func makeNavigationBar(){ //네비게이션 바 생성
        let searchController = UISearchController(searchResultsController: nil) //서치바 컨트롤러 생성
        searchControllerSet(searchController: searchController)
        navigationSet(searchController: searchController)
        
        func navigationSet(searchController: UISearchController){
            self.navigationItem.title = "운동 프로그램"
            self.navigationController?.navigationBar.prefersLargeTitles = true
            self.navigationItem.hidesSearchBarWhenScrolling = true //스크롤 내릴 시 검색창 숨김
            self.navigationItem.searchController = searchController //서치바 활성화
            self.navigationItem.backButtonTitle = "Back"
            
        }
        func searchControllerSet(searchController: UISearchController){
            searchController.obscuresBackgroundDuringPresentation = false //false -> 검색창 활성화 시 주변 화면 흐림 X
            searchController.searchResultsUpdater = self //SearchBar에 데이터 입력 시 실시간으로 결과 반영
        }
    }
}

//MARK: - 서치바 활성화 후 필러링된 TableView 제공

extension MainViewController: UISearchResultsUpdating{
    
    //SearchBar에 입력 시 실시간으로 결과 반영
    func updateSearchResults(for searchController: UISearchController) {
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
                    self.bindTableView(isFilterd: self.mainViewModel.getIsFiltering(self))
                }
            }.disposed(by: disposeBag)
    }
}

//MARK: - 테이블뷰 Refresh 기능{

extension MainViewController{
    
    func addTableViewRefresh(){
       mainTableView.refreshControl = refreshControl
       refreshControl.addTarget(self, action: #selector(self.pullToRefresh), for: .valueChanged)
    }
    
    // Refresh 동작 시
    @objc func pullToRefresh(_ sender: Any) {
        
        monitor = NWPathMonitor()
        monitor.start(queue: .global())
        monitor.pathUpdateHandler = {path in
            if path.status == .satisfied{
                DispatchQueue.main.async {
                    self.hideNetworkUI()
                    self.mainViewModel = MainTableViewModel()
                    self.detailViewModel = DetailViewModel()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.bindTableView(isFilterd: false)
                    
                    self.clickEventDisposeBag = DisposeBag() // 클릭 이벤트 구독 해제 (중첩 막기위해)
                    self.addCellCilckEvent()
                    self.refreshControl.endRefreshing()
                }
            }
            else{
                DispatchQueue.main.async {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0){
                        self.showToast(message: "네트워크 상태를 확인해주세요. ")
                        self.refreshControl.endRefreshing()
                    }
                    
                }
            }
        }
        monitor.cancel()
    }
}

//MARK: - (+) 버튼 생성

extension MainViewController {
    private func makePlusButton() {
        let plusButton = UIButton()
        setButton()
        addClickEvent()
        
        // 버튼 option set
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
        
        // + 버튼 클릭 이벤트
        func addClickEvent(){
            plusButton.rx.tap.bind { [weak self] in // 버튼 액션
                let dropDown = DropDown() //dropDown ui 객체 생성
                setDropDown()
                linkCustomCell()
                addClickEvent()
                dropDown.show()
                
                // DropDown option set
                func setDropDown(){
                    dropDown.anchorView = plusButton
                    dropDown.width = 140
                    dropDown.cellHeight = 70
                    dropDown.cornerRadius = 15
                    dropDown.backgroundColor = UIColor(named: "DropDownColor")!
                    dropDown.textColor = .black
                    dropDown.dataSource = ["설정","루틴","보관함"]
                    dropDown.topOffset = CGPoint(x: -60, y:-(dropDown.anchorView?.plainView.bounds.height)!)
                }
                
                // dropDown list -> custom cell
                func linkCustomCell(){
                    dropDown.cellNib = UINib(nibName: "DropCell", bundle: nil) //customCell 적용
                    dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                        guard let cell = cell as? DropCell else { return }
                        if index == 0{
                            cell.dropDownImage.image = UIImage(systemName: "gearshape")
                        }
                        else if index == 1{
                            cell.dropDownImage.image = UIImage(systemName: "square.and.pencil")
                        }
                        else{
                            cell.dropDownImage.image = UIImage(systemName: "archivebox")
                        }
                    }
                }
                
                //DropDown 클릭 이벤트
                func addClickEvent(){
                    dropDown.selectionAction = { [weak self] (index, item) in
                     
                        if index == 0{
                            guard let settingVC = self?.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") else {return}
                            settingVC.modalPresentationStyle = .popover
                            self?.present(settingVC, animated: true)
                        }
                        else if index == 1 {
                            guard let routineVC = self?.storyboard?.instantiateViewController(withIdentifier: "RoutineViewController") else {return}
                            self?.navigationController?.pushViewController(routineVC, animated: true)
                        }
                        else{
                            _ = MyProgramViewModel() //선언과 동시에 coreData 생성 됨
                            guard let basetVC = self?.storyboard?.instantiateViewController(withIdentifier: "MyProgramViewController") else {return}
                            self?.navigationController?.pushViewController(basetVC, animated: true)
                        }
                    }
                }
            }.disposed(by: disposeBag) // 구독해제 (메모리 정리)
        }
    }
}

//MARK: - 로컬 푸쉬 알림 권한 요청

extension MainViewController {
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions(arrayLiteral: .alert, .sound)
        
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { success, error in
      
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
}
//MARK: - 알림 클릭 시, 해당 알림 내용의 프로그램 title 바인딩 -> detailVC로 이동

extension MainViewController{
    
    func requestdNotificationAuthorization(){
        
        // 알림 클릭 구독
        mainViewModel.receivedNotification
            .filter({ $0 != "" })
            .subscribe { [weak self] receivedTitle in
                
                // detailVC의 전체 데이터 불러옴
                self?.detailViewModel.detailViewObservable
                    .filter({ $0 != [] })
                    .subscribe { [weak self] detailVCDatas in
                        guard let detailVCDatas = detailVCDatas.element else {return}
                        guard let detailVC = self?.storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
                        
                        // 전체 데이터 배열을 순환하여 해당 조건에 맞게 접근 후 이동
                        for detailVCData in detailVCDatas{
                            if receivedTitle == detailVCData.title{
                                detailVC.viewModel.detailVCIndexObservable
                                    .onNext(detailVCData)
                                self?.navigationController?.pushViewController(detailVC, animated: true)
                            }
                        }
                    }.disposed(by: self?.disposeBag ?? DisposeBag())
            }.disposed(by: disposeBag)
    }
}

//MARK: - 최초 실행 감지, 최초 실행 -> 최초 실행 VC 제공

extension MainViewController{
    func detectFirstExecution(){
        
        mainViewModel.firstExecution
            .filter { $0 == true}
            .subscribe { [weak self] _ in
                guard let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirstExcuteViewController") as? FirstExcuteViewController else {return}
                firstVC.modalPresentationStyle = .custom
                firstVC.transitioningDelegate = self
                firstVC.viewModel.completionObservable
                    .filter { $0 == true}
                    .subscribe { [weak self] _ in
                            self?.requestNotificationAuthorization() // 로컬 푸쉬 알림 권한 요청
                        
                            let message =
                            """
                            (+) 버튼 -> 설정 탭에서
                            1RM 재설정 가능합니다.
                            """
                            self?.showToast(message: message)
                    }.disposed(by: self?.disposeBag ?? DisposeBag())
                self?.present(firstVC, animated: true)
            }.dispose()
    }
    
    //최초 실행 Toast 출력
    func showToast(font: UIFont = UIFont.systemFont(ofSize: 13, weight: .bold), message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = .systemBlue
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.numberOfLines = 2
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 12, delay: 0.5, options: .transitionCurlDown, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
        
        toastLabel.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.width.equalTo(200)
            make.bottom.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
        }
    }
}

//MARK: - Modal Transitioning Delegate
extension MainViewController: UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?{
        return HalfModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
