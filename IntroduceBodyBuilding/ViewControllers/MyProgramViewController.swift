
import UIKit
import CoreData
import CoreAudio
import RxSwift

class MyProgramViewController: UIViewController {
    
    @IBOutlet weak var BBCollectionView: UICollectionView!
    @IBOutlet weak var PBCollectionView: UICollectionView!
    @IBOutlet weak var PLCollectionView: UICollectionView!
    
    let myProgramViewModel = MyProgramViewModel()
    let disposeBag = DisposeBag()
    
    func makeCloseButton(in cell: UICollectionViewCell, condition: String, target: BehaviorSubject<[MyProgram]>, division: String){ //셀에 삭제 버튼 추가 함수
        
        let closeButton = UIButton()
        setButton()
        addCilckEvent()
        
        func setButton() { //버튼 속성 set
            closeButton.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
            closeButton.imageView?.tintColor = .systemRed
            closeButton.translatesAutoresizingMaskIntoConstraints = false //autolayout 사용 위해 false 필수
            
            cell.addSubview(closeButton)
            
            closeButton.topAnchor.constraint(equalTo: cell.topAnchor, constant: 0).isActive = true
            closeButton.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 140).isActive = true
            closeButton.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -125).isActive = true
            closeButton.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 0).isActive = true
        }
        
        func addCilckEvent(){ //데이터 삭제 이벤트, division은 삭제 후 데이터 리바인딩 위해
            closeButton.rx.tap.bind { [weak self] in
                if let self = self{
                    self.myProgramViewModel.deleteCoreData(to: target, condition: condition, division: division)
                }
            }.disposed(by: disposeBag)
        }
    }
    
    func bindCollectionView(){
        setCollectionViewOption()
        bindDivisionView()
        
        addCilckEvent(targetView: BBCollectionView, sendObservable: myProgramViewModel.bodyBuildingObservable)
        addCilckEvent(targetView: PBCollectionView, sendObservable: myProgramViewModel.powerBuildingObservable)
        addCilckEvent(targetView: PLCollectionView, sendObservable: myProgramViewModel.powerLiftingObservable)
        
        func setCollectionViewOption(){ //콜렉션 뷰 초기설정
            self.BBCollectionView.delegate = nil
            self.BBCollectionView.dataSource = nil
            
            self.PBCollectionView.delegate = nil
            self.PBCollectionView.dataSource = nil
            
            self.PLCollectionView.delegate = nil
            self.PLCollectionView.dataSource = nil
        }
        func bindDivisionView(){ //divisionModel -> divisionView 각 바인딩
            myProgramViewModel.bodyBuildingObservable //구분 데이터 -> 콜렉션뷰 바인딩
                .bind(to: BBCollectionView.rx.items(cellIdentifier: "BBCollectionViewCell",cellType: BBCollectionViewCell.self)) { (index, element, cell) in
                    cell.BBTitleLabel.text = element.title
                    cell.BBimageView.image = UIImage(named: element.image ?? "")
                    self.makeCloseButton(in: cell, condition: element.title ?? "", target: self.myProgramViewModel.bodyBuildingObservable, division: "bodybuilding")
                }.disposed(by: disposeBag)
            
            myProgramViewModel.powerBuildingObservable
                .bind(to: PBCollectionView.rx.items(cellIdentifier: "PBCollectionViewCell",cellType: PBCollectionViewCell.self)) { (index, element, cell) in
                    cell.PBTitleLabel.text = element.title
                    cell.PBimageView.image = UIImage(named: element.image ?? "")
                    self.makeCloseButton(in: cell, condition: element.title ?? "", target: self.myProgramViewModel.powerBuildingObservable, division: "powerbuilding")
                }.disposed(by: disposeBag)
            
            myProgramViewModel.powerLiftingObservable
                .bind(to: PLCollectionView.rx.items(cellIdentifier: "PLCollectionViewCell",cellType: PLCollectionViewCell.self)) { (index, element, cell) in
                    cell.PLTitleLabel.text = element.title
                    cell.PLimageView.image = UIImage(named: element.image ?? "")
                    self.makeCloseButton(in: cell, condition: element.title ?? "", target: self.myProgramViewModel.powerLiftingObservable, division: "powerlifting")
                }.disposed(by: disposeBag)
        }
        func addCilckEvent(targetView: UICollectionView, sendObservable: BehaviorSubject<[MyProgram]> ){
            // 각 divisionView에 이벤트 추가
            targetView.rx.itemSelected
                .withLatestFrom(sendObservable) { [weak self] indexPath, data in
                    let convertObservable: BehaviorSubject<DetailVCModel.Fields> = BehaviorSubject(value: DetailVCModel.Fields(title: data[indexPath.row].title ?? "", image: data[indexPath.row].image ?? "", description: data[indexPath.row].description_ ?? ""))
                    
                    let detailVC = UIStoryboard(name: "DetailViewController", bundle: nil)
                        .instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
                    
                    convertObservable.subscribe { data in
                        detailVC.detailVCIndexObservable.onNext(data)
                        detailVC.addButtonBool = false
                        self?.present(detailVC, animated: true)
                    }.disposed(by:self?.disposeBag ?? DisposeBag())
                }
                .subscribe(onDisposed:  {
                }).disposed(by: disposeBag)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindCollectionView()
        self.navigationItem.title = "보관함"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil

    }    
}
