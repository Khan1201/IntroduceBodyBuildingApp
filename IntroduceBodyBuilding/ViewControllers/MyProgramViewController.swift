import UIKit
import CoreData
import RxSwift

class MyProgramViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    let myProgramViewModel = MyProgramViewModel()
    let detailViewModel = DetailViewModel()
    
    @IBOutlet weak var BBCollectionView: UICollectionView!
    @IBOutlet weak var PBCollectionView: UICollectionView!
    @IBOutlet weak var PLCollectionView: UICollectionView!
    
    //MARK: - viewDidLoad(), viewWillAppear()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSet()
        bindCollectionView()
        fromDetailAddButton()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

//MARK: - 네비게이션 바 속성

extension MyProgramViewController {
    private func navigationSet(){
        self.navigationItem.title = "보관함"
        self.navigationItem.largeTitleDisplayMode = .never
        
        // 홈 버튼 활성화
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "house"), style: .plain, target: nil, action: nil)
        self.navigationItem.setRightBarButton(navigationItem.rightBarButtonItem, animated: true)
        
        // 홈 버튼 클릭 이벤트
        self.navigationItem.rightBarButtonItem?.rx.tap
            .bind { _ in
                self.navigationController?.popToRootViewController(animated: true)
                
            }.disposed(by: disposeBag)
    }
}

//MARK: - 컬렉션 뷰에 데이터 바인딩

extension MyProgramViewController {
    func bindCollectionView(){
        setCollectionViewOption()
        bindDivisedCollectionView()
        
        addCilckEvent(targetView: BBCollectionView, sendObservable: myProgramViewModel.bodyBuildingObservable)
        addCilckEvent(targetView: PBCollectionView, sendObservable: myProgramViewModel.powerBuildingObservable)
        addCilckEvent(targetView: PLCollectionView, sendObservable: myProgramViewModel.powerLiftingObservable)
        
        //콜렉션 뷰 초기설정
        func setCollectionViewOption(){
            self.BBCollectionView.delegate = nil
            self.BBCollectionView.dataSource = nil
            
            self.PBCollectionView.delegate = nil
            self.PBCollectionView.dataSource = nil
            
            self.PLCollectionView.delegate = nil
            self.PLCollectionView.dataSource = nil
        }
        
        //divisionModel -> 각 종목에 맞는 collectionview에 바인딩
        func bindDivisedCollectionView(){
            myProgramViewModel.bodyBuildingObservable
                .bind(to: BBCollectionView.rx.items(cellIdentifier: "BBCollectionViewCell",cellType: BBCollectionViewCell.self)) { (index, element, cell) in
                    cell.BBTitleLabel.text = element.title
                    cell.BBimageView.image = UIImage(named: element.image ?? "")
                    self.makeDeleteButton(in: cell, deleteCondition: element.title ?? "", target: self.myProgramViewModel.bodyBuildingObservable, division: "bodybuilding")
                }.disposed(by: disposeBag)
            
            myProgramViewModel.powerBuildingObservable
                .bind(to: PBCollectionView.rx.items(cellIdentifier: "PBCollectionViewCell",cellType: PBCollectionViewCell.self)) { (index, element, cell) in
                    cell.PBTitleLabel.text = element.title
                    cell.PBimageView.image = UIImage(named: element.image ?? "")
                    self.makeDeleteButton(in: cell, deleteCondition: element.title ?? "", target: self.myProgramViewModel.powerBuildingObservable, division: "powerbuilding")
                }.disposed(by: disposeBag)
            
            myProgramViewModel.powerLiftingObservable
                .bind(to: PLCollectionView.rx.items(cellIdentifier: "PLCollectionViewCell",cellType: PLCollectionViewCell.self)) { (index, element, cell) in
                    cell.PLTitleLabel.text = element.title
                    cell.PLimageView.image = UIImage(named: element.image ?? "")
                    self.makeDeleteButton(in: cell, deleteCondition: element.title ?? "", target: self.myProgramViewModel.powerLiftingObservable, division: "powerlifting")
                }.disposed(by: disposeBag)
        }
        
        //  컬렉션 뷰 클릭 이벤트 (상세 페이지 호출)
        func addCilckEvent(targetView: UICollectionView, sendObservable: BehaviorSubject<[MyProgram]>){
            
            guard let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
            targetView.rx.itemSelected
                .withLatestFrom(sendObservable, resultSelector: { indexPath, data in
                    
                    // detailVC 데이터 받아옴
                    self.detailViewModel.detailViewObservable
                        .filter {
                            $0 != []
                        }
                        .subscribe { elements in
                            if let elements = elements.element{
                                for element in elements{
                                    if element.title == data[indexPath.row].title{ //detail VC 접근
                                        bindDetailVC(detailVC, data: element)
                                    }
                                }
                            }
                        }.dispose()
                })
                .subscribe { _ in
                    self.present(detailVC, animated: true)
                }.disposed(by: disposeBag)
            
            //detailVC에 데이터 바인딩
            func bindDetailVC(_ detailVC: DetailViewController, data: DetailVCModel.Fields){
                detailVC.viewModel.detailVCIndexObservable
                    .onNext(data) // 해당 셀 데이터와 일치하는 detailVC 데이터 보냄
                detailVC.viewModel.fromMyProgramVC.onNext(true) // myProgramVC에서 호출 했다는 것을 알림
                
                // myProgramVC -> detailVC의 루틴 등록 버튼 클릭 구독
                detailVC.viewModel.fromDetailVCRoutineAddButton = PublishSubject()
                detailVC.viewModel.fromDetailVCRoutineAddButton
                    .subscribe { [weak self] bool in
                        if let bool = bool.element{
                            self?.myProgramViewModel.fromDetailVCRoutineAddButton
                                .onNext(bool)
                        }
                    }.disposed(by: disposeBag)
            }
        }
    }
}

//MARK: - 삭제 버튼 생성

extension MyProgramViewController{
    
    private func makeDeleteButton(in cell: UICollectionViewCell, deleteCondition: String, target: BehaviorSubject<[MyProgram]>, division: String){
        
        let closeButton = UIButton()
        setButton()
        addCilckEvent()
        
        //버튼 속성 set
        func setButton() {
            closeButton.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
            closeButton.imageView?.tintColor = .systemRed
            closeButton.translatesAutoresizingMaskIntoConstraints = false //autolayout 사용 위해 false 필수
            
            cell.addSubview(closeButton)
            
            closeButton.topAnchor.constraint(equalTo: cell.topAnchor, constant: 0).isActive = true
            closeButton.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 140).isActive = true
            closeButton.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -125).isActive = true
            closeButton.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 0).isActive = true
        }
        
        //데이터 삭제 이벤트, division은 삭제 후 구분된 Observable에 새로운 데이터 next 위해
        func addCilckEvent(){
            closeButton.rx.tap.bind { [weak self] in
                if let self = self{
                    self.myProgramViewModel.deleteCoreData(to: target, deleteCondition: deleteCondition, division: division)
                }
            }.disposed(by: disposeBag)
        }
    }
}

//MARK: - myProgramVC > detailVC의 루틴 등록 버튼 구독

extension MyProgramViewController{
    
    // myProgramVC -> detailVC의 루틴 등록 버튼 클릭 시 -> routinVC로 이동
    func fromDetailAddButton(){
        myProgramViewModel.fromDetailVCRoutineAddButton
            .subscribe { _ in
                guard let routineVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RoutineViewController") as? RoutineViewController else{return}
                routineVC.viewModel.fromAddRoutineInDetailVC
                    .onNext(true)
                self.navigationController?.pushViewController(routineVC, animated: true)
            }.disposed(by: disposeBag)
    }
}
