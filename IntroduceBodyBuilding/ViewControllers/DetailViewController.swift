import UIKit
import CoreData
import RxSwift
import RxCocoa
import QuickLook

class DetailViewController: UIViewController {
    
    let viewModel = DetailViewModel()
    let disposeBag = DisposeBag()
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!{
        didSet{
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var routineTableView: UITableView!{
        didSet{
            routineTableView.rowHeight = UITableView.automaticDimension
            routineTableView.estimatedRowHeight = 150
            routineTableView.layer.masksToBounds = true
            routineTableView.layer.cornerRadius = 15
            routineTableView.separatorColor = .black
        }
    }
    @IBOutlet weak var allRoutineButton: UIButton!{
        didSet{
            allRoutineButton.layer.masksToBounds = true
            allRoutineButton.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel!{
        didSet{
            //줄 간격 설정
            let attrString = NSMutableAttributedString(string: descriptionLabel.text!)
            let paragraphStyle = NSMutableParagraphStyle()
            
            descriptionLabel.lineBreakMode = .byWordWrapping
            descriptionLabel.numberOfLines = 0
            paragraphStyle.lineSpacing = 10
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            descriptionLabel.attributedText = attrString
        }
    }
    @IBOutlet weak var authorEmbeddedView: UIView!{
        didSet{
            authorEmbeddedView.layer.masksToBounds = true
            authorEmbeddedView.layer.cornerRadius = 7
        }
    }
    @IBOutlet weak var authorLabel: UILabel!
    
    
    @IBOutlet weak var addRoutineButton: UIButton!{
        didSet{
            addRoutineButton.setTitle("루틴등록", for: .normal)
            addRoutineButton.layer.masksToBounds = true
            addRoutineButton.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var addButton: UIButton!{
        didSet{
            addButton.layer.masksToBounds = true
            addButton.layer.cornerRadius = 15
        }
    }
    
    //MARK: - @IBAction
    
    @IBAction func goBackButtonAction(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    @IBAction func allRoutineButtonAction(_ sender: UIButton) {
        guard let webVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "WebViewController") as? WebViewController else {return}
        webVC.routineTitle = titleLabel.text ?? "not exist"
        viewModel.url
            .filter({
                $0 != ""
            })
            .subscribe { url in
                webVC.url = url.element ?? "not exist"
            }.dispose()
        self.navigationController?.pushViewController(webVC, animated: true)
    }
    @IBAction func addRoutineButtonAction(_ sender: UIButton) {
        viewModel.fromMyProgramVC // myProgramVC 호출한지 구독,
            .subscribe { [weak self] bool in
                if let bool = bool.element{
                    
                    if bool{ //dismiss 후 routineVC -> routineAddVC
                        self?.presentingViewController?.dismiss(animated: true, completion: {
                            self?.viewModel.fromDetailVCRoutineAddButton.onNext(true)
                            self?.viewModel.fromDetailVCRoutineAddButton.dispose()
                        })
                    }
                    else{ // 바로 routineAddVC로 이동
                        guard let routineVC = UIStoryboard(name: "Main", bundle: nil)
                            .instantiateViewController(withIdentifier: "RoutineViewController") as? RoutineViewController else {return}
                        routineVC.viewModel.fromAddRoutineInDetailVC
                            .onNext(true)
                        self?.navigationController?.pushViewController(routineVC, animated: true)
                    }
                }
            }.dispose()
    }
    @IBAction func basketButtonAction(_ sender: UIButton) {
        approachCoreData() //CoreData에 접근
    }
    //MARK: - viewDidLoad(), viewDidAppear()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fromVC()
        bindView()
        bindTableViewInView()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // 루틴 or 루틴 추가 페이지에서 호출 시
        if !addButton.isEnabled && !addRoutineButton.isEnabled{
            self.scrollView.setContentOffset(CGPoint(x: 0, y: (self.scrollView.contentSize.height) - (self.scrollView.bounds.height)), animated: true)
        }
    }
}
//MARK: - 이전 뷰 인덱스에 맞는 detailViewModel 데이터 바인딩

extension DetailViewController {
    private func bindView() {
        viewModel.detailVCIndexObservable
            .subscribe({[weak self] data in
                
                self?.titleLabel.text = data.element?.title ?? "not exist"
                self?.descriptionLabel.text = data.element?.description ?? "not exist"
                self?.imageView.image = UIImage(named: data.element?.image ?? "not exist")
                self?.viewModel.url.onNext(data.element?.url ?? "not exist")
                self?.authorLabel.text = data.element?.author ?? "not exist"
                
                var tempArray:[(String, String)] = []
                guard let days = data.element?.day else {return}
                guard let routines = data.element?.routineAtDay else {return}
                
                for (dayIndex, day) in days.enumerated(){ //(day, routine)의 튜플 배열 반환 -> [(day, routine)]
                    for (routinIndex, routine) in routines.enumerated(){
                        if dayIndex == routinIndex{
                            let tuple = (day, routine)
                            tempArray.append(tuple)
                        }
                    }
                }
                self?.viewModel.tableViewObservable.onNext(tempArray)
            }).disposed(by: disposeBag)
    }
}
//MARK: - View안의 TableView에 데이터 바인딩

extension DetailViewController {
    private func bindTableViewInView(){
        
        viewModel.tableViewObservable
            .bind(to: self.routineTableView.rx.items(cellIdentifier: "DetailTableViewCell", cellType: DetailTableViewCell.self)){ (index, element, cell) in
                
                cell.backgroundColor = .systemGray6
                cell.selectionStyle = .none
                
                cell.dayLabel.text = "Day \(element.0)"
                cell.routinLabel.text = element.1.replacingOccurrences(of: "\\n", with: "\n") //FireStroe Json 데이터 줄 바꿈
                cell.numberImageView.image = UIImage(systemName: "\(element.0).square")
            }.disposed(by: disposeBag)
    }
}
//MARK: - Alert Dialog 생성

extension DetailViewController {
    
    // duplicated : true -> 중복 안내 다이얼로그, false -> 추가완료 안내 다이얼로그
    private func makeAlertDialog(duplicated: Bool) -> Void {
        return duplicated ?
        divideAlert(title: "안내", message: "보관함에 이미 존재하는 프로그램입니다.", duplicatedBool: true) :
        divideAlert(title: "안내", message: "보관함에 프로그램을 담았습니다.   보관함으로 이동하시겠습니까 ?", duplicatedBool: false)
        
        // Alert Dialog 생성
        func divideAlert(title: String, message: String, duplicatedBool: Bool){
            let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            if(duplicatedBool == true) { // Dialog에 버튼 추가
                alert.addAction(CancelButton())
            }
            else {
                alert.addAction(OKButton())
                alert.addAction(CancelButton())
            }
            self.present(alert, animated: true, completion: nil) // 화면에 출력
            
            func OKButton() -> UIAlertAction { //OKButton Click -> 보관함 이동
                let alertSuccessBtn = UIAlertAction(title: "OK", style: .default) { _ in
                    guard let myProgramVC = UIStoryboard(name: "Main", bundle:  nil).instantiateViewController(withIdentifier: "MyProgramViewController") as? MyProgramViewController else {return}
                    self.navigationController?.pushViewController(myProgramVC, animated: true)
                }
                return alertSuccessBtn
            }
            func CancelButton() -> UIAlertAction {
                let alertDeleteBtn = UIAlertAction(title: "Cancel", style: .destructive) { _ in } //.destructive -> 글씨 빨갛게
                return alertDeleteBtn
            }
        }
    }
}
//MARK: - CoreData에 접근

extension DetailViewController {
    
    private func approachCoreData(){
        do{
            let myProgramObject = try getObject() //CoreData Entity인 MyProgram 정의
            MyProgramViewModel.coreData.isEmpty ? //CoreData에 데이터가 없을 시 -> 데이터 삽입, 데이터가 있을 시 -> 중복체크 후 데이터 삽입
            insertData(in: myProgramObject) : insertDataAfterDuplicatedCheck(in: myProgramObject)
        }
        catch{
            print("coreData Error: \(error)")
        }
        
        //CoreData 오브젝트 get
        func getObject() throws -> NSManagedObject{
            let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            guard let myProgramEntity = NSEntityDescription.entity(forEntityName: "MyProgram", in: viewContext) else{
                throw setDataError.EntityNotExist } //CoreData entity 정의
            let myProgramObject = NSManagedObject(entity: myProgramEntity, insertInto: viewContext)
            return myProgramObject
        }
        
        // CoreData에 데이터 삽입
        func insertData(in object: NSManagedObject) {
            let myProgram = object as! MyProgram
            //MyProgram entity 존재 시, unwrapping 후 coreData에 데이터 insert
            viewModel.detailVCIndexObservable
                .subscribe { data in
                    myProgram.title = data.element?.title //
                    myProgram.image = data.element?.image
                    myProgram.description_ = data.element?.description
                    myProgram.division = data.element?.image //bodybuilding, powerbuilding, powerlifting 의 구분자 역활
                }.disposed(by: disposeBag)
            
            makeAlertDialog(duplicated: false) //보관함으로 이동 alert
            do{
                try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save() //insert 적용
            }
            catch{
                print("save error: \(error)")
            }
        }
        
        // 데이터 중복체크 후 CoreData에 데이터 삽입
        func insertDataAfterDuplicatedCheck(in myProgramObject: NSManagedObject){
            _ = MyProgramViewModel() //선언과 동시에 MyProgramViewModel.coreData 최신화
            var count = 0
            for data in MyProgramViewModel.coreData{
                if (data.title == titleLabel.text){ //중복시 중복 다이얼로그 생성
                    makeAlertDialog(duplicated: true)
                }
                else{
                    count += 1
                    if count == MyProgramViewModel.coreData.count{ //전체 순회하였을 시(중복이 없을 시) coreData에 데이터 삽입
                        insertData(in: myProgramObject)
                    }
                }
            }
        }
        
        //오류 정의
        enum setDataError: Error{
            case EntityNotExist
        }
    }
}

//MARK: - 호출한 VC에 따른 UI 바인딩

extension DetailViewController{
    func fromVC(){
        
        viewModel.fromRoutineVC
            .filter({
                $0 != false
            })
            .subscribe { [weak self] trueBool in
                if let trueBool = trueBool.element{
                    self?.goBackButton.isHidden = !trueBool
                    self?.addButton.isEnabled = !trueBool
                    self?.addRoutineButton.isEnabled = !trueBool
                }
            }.disposed(by: disposeBag)
        
        viewModel.fromMyProgramVC
            .filter {
                $0 != false
            }
            .subscribe { [weak self] trueBool in
                self?.goBackButton.isHidden = !trueBool
                self?.addButton.isEnabled = !trueBool
                self?.addRoutineButton.isEnabled = trueBool
            }.disposed(by: disposeBag)
    }
}



