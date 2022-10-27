
import UIKit
import CoreData
import CoreAudio
import RxSwift

class MyProgramViewController: UIViewController {
    
    @IBOutlet weak var BBCollectionView: UICollectionView!
    @IBOutlet weak var PBCollectionView: UICollectionView!
    @IBOutlet weak var PLCollectionView: UICollectionView!
    
    let disposeBag = DisposeBag()
    let myProgramViewModel = MyProgramViewModel()
    let detailViewModel = DetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationSet()
        bindCollectionView()
    }    
}
//MARK: - 네비게이션 바 속성

extension MyProgramViewController {
    private func navigationSet(){
        self.navigationItem.title = "보관함"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
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
        
        func addCilckEvent(targetView: UICollectionView, sendObservable: BehaviorSubject<[MyProgram]>){
            
            guard let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {return}
            
            Observable.combineLatest(targetView.rx.itemSelected, sendObservable)
                .subscribe { [unowned self] indexPath, data in
                    detailViewModel.detailViewObservable
                        .filter({ element in
                            element != []
                        })
                        .subscribe { elements in
                            print("구독")
                            print(elements)
                            if let elements = elements.element{
                                for element in elements{
                                    if element.title == data[indexPath.row].title{ //detail VC 접근
                                        detailVC.detailVCIndexObservable
                                            .onNext(element)
                                        detailVC.fromMyProgramVC = true
                                        self.present(detailVC, animated: true)
                                    }
                                }
                            }
                        }.dispose()
                }.disposed(by: disposeBag)
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
