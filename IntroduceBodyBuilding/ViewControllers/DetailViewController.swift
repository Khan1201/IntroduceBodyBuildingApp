import UIKit
import CoreData
import RxSwift
import RxCocoa
import QuickLook
import SafariServices


class DetailViewController: UIViewController {
    
    let viewModel = DetailViewModel()
    let disposeBag = DisposeBag()
    
    //MARK: - @IBOutlet
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!{
        didSet{
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 10
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
    
    @IBOutlet weak var weightApplyButton: UIButton!{
        didSet{
            weightApplyButton.layer.masksToBounds = true
            weightApplyButton.layer.cornerRadius = 10
        }
    }
    
    
    @IBOutlet weak var noticeAllEmbeddedView: UIView!{
        didSet{
            noticeAllEmbeddedView.layer.cornerRadius = 10
            noticeAllEmbeddedView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.6).cgColor
            noticeAllEmbeddedView.layer.borderWidth = 2.0
            self.contentView.sendSubviewToBack(noticeAllEmbeddedView)
        }
    }
    @IBOutlet weak var noticeLabel: UILabel!{
        didSet{
            noticeLabel.text =
            """
            모든 루틴은 세트 x 횟수입니다.
            -----------------------------------
            무게가 없는 것은 해당 반복횟수를
            수행 할 수 있는 개인의 무게입니다.
            -----------------------------------
            AMRAP = 최대 수행 가능한 반복 횟수
            -----------------------------------
            메모는 모든 프로그램에 공유됩니다.
            """
            
            noticeLabel.lineColorAndLineSpacing(spacing: 5)
        }
    }
    @IBOutlet weak var noticeMemoTextView: UITextView!{
        didSet{
            noticeMemoTextView.layer.cornerRadius = 10
            noticeMemoTextView.layer.borderWidth = 1.5
            noticeMemoTextView.layer.borderColor = UIColor.systemGray5.cgColor
            noticeMemoTextView.text = UserDefaults.standard.string(forKey: "memo")
            noticeMemoTextView.rx.didEndEditing
                .subscribe { [weak self] _ in
                    UserDefaults.standard.set(self?.noticeMemoTextView.text, forKey: "memo")
                }
                .disposed(by: disposeBag)
        }
    }
    
    
    @IBOutlet weak var routineTableView: UITableView!{
        didSet{
            routineTableView.rowHeight = UITableView.automaticDimension
            routineTableView.estimatedRowHeight = 150
            routineTableView.layer.masksToBounds = true
            routineTableView.layer.cornerRadius = 15
            routineTableView.separatorColor = .label
        }
    }
    @IBOutlet weak var allRoutineButton: UIButton!{
        didSet{
            allRoutineButton.layer.masksToBounds = true
            allRoutineButton.layer.cornerRadius = 10
        }
    }
    
    // '루틴 등록' 버튼
    @IBOutlet weak var addRoutineButton: UIButton!{
        didSet{
//            addRoutineButton.setTitle("루틴등록", for: .normal)
            addRoutineButton.layer.masksToBounds = true
            addRoutineButton.layer.cornerRadius = 12
        }
    }
    // '보관함 추가' 버튼
    @IBOutlet weak var addButton: UIButton!{
        didSet{
            addButton.layer.masksToBounds = true
            addButton.layer.cornerRadius = 12
        }
    }
    
    //MARK: - @IBAction

    // 'X' 버튼 액션 (RoutineVC or RoutineAddVC에서 호출 시 버튼 활성화)
    @IBAction func goBackButtonAction(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true)
    }
    
    // '1RM 적용' 버튼
    @IBAction func weightApplyButtonAction(_ sender: Any) {
        
        let rowCount =  routineTableView.numberOfRows(inSection: 0)
        lazy var tableViewData:[(String, String)] = [("","")]

        self.viewModel.tableViewObservable
            .subscribe { data in
                tableViewData = data.element ?? [("","")]
            }.dispose()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            for row in 0..<rowCount{
                tableViewData[row].1 = self.convertPercent(text: tableViewData[row].1)
            }
            self.viewModel.tableViewObservable.onNext(tableViewData)
            self.showToast()
            self.scrollView.setContentOffset(CGPoint(x: 0, y: (self.scrollView.contentSize.height) - (self.scrollView.bounds.height)), animated: true)
        }
    }
    
    // '루틴 전체보기' 버튼 액션
    @IBAction func allRoutineButtonAction(_ sender: UIButton) {
        let googleSheets = "googlesheets://" // 구글 시트에 대한 URL Scheme
        let googleSheetsURL = NSURL(string: googleSheets) //URL 인스턴스를 만들어 주는 단계
        
        //canOpenURL(_:) 메소드를 통해서 URL 체계를 처리하는 데 앱을 사용할 수 있는지 여부를 확인('스프레드 시트'가 설치되어 있을 경우)
        if (UIApplication.shared.canOpenURL(googleSheetsURL! as URL)) {
            
            // FirstVC 재사용 (이미지와 설명만 바꿔 재사용)
            guard let excutionGuideVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirstExcuteViewController") as? FirstExcuteViewController else {return}
            
            // excutionGuideVC로 호출 했다는 flag
            excutionGuideVC.viewModel.detectFirstExecution = false
            
            // excutionGuide dismiss 후 '전체 루틴 보기' 실행 위하여 (excutionGuideVC의 '확인' 버튼 클릭 시 true가 내려옴)
            excutionGuideVC.viewModel.fromExecutionGuide
                .filter { $0 == true}
                .bind { [weak self] _ in
                    let url = URL(string: "https://docs.google.com/uc?export=download&id=19CzZUj_n1mGfHFN82ioH_W8U91IbHtYO")
                    let safariViewController = SFSafariViewController(url: url!)
                    self?.present(safariViewController, animated: true)
                }.disposed(by: disposeBag)
            
            excutionGuideVC.modalPresentationStyle = .custom
            excutionGuideVC.transitioningDelegate = self
            HalfModalPresentationController.dismissGestureFlag = true
            self.present(excutionGuideVC, animated: true)
        }

        // 사용 불가능한 URLScheme일 때('스프레드 시트'가 설치되지 않았을 경우) 앱 스토어 연결
        else {
            let storeId =  "itms-apps://itunes.apple.com/app/id842849113"
            if let storeURL = URL(string: storeId), UIApplication.shared.canOpenURL(storeURL){
                makeAlertAboutAppStore(title: "안내",
                                       message: "전체 루틴을 열기위해 '스프레드시트' 앱이 필요합니다. 앱 스토어로 이동 하시겠습니까 ?",
                                       storeURL: storeURL)
            }
        }
        func makeAlertAboutAppStore(title: String, message: String, storeURL: URL){
            let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(CancelButton())
                alert.addAction(OKButton())
            self.present(alert, animated: true, completion: nil) // 화면에 출력
            
            func OKButton() -> UIAlertAction { //OKButton Click -> 보관함 이동
                let alertSuccessBtn = UIAlertAction(title: "OK", style: .default) { _ in
                    UIApplication.shared.open(storeURL, options: [:], completionHandler: nil)
                }
                return alertSuccessBtn
            }
            func CancelButton() -> UIAlertAction {
                let alertDeleteBtn = UIAlertAction(title: "Cancel", style: .destructive) { _ in } //.destructive -> 글씨 빨갛게
                return alertDeleteBtn
            }
        }
    }
    
    // '루틴 등록' 버튼 액션
    @IBAction func addRoutineButtonAction(_ sender: UIButton) {
        viewModel.fromMyProgramVC // myProgramVC에서 호출한지 구독,
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
    
    // '보관함에 추가' 버튼 액션
    @IBAction func basketButtonAction(_ sender: UIButton) {
        
        //CoreData에 접근
        viewModel.detailVCIndexObservable
            .filter({ data in
                data.title != ""
            })
            .subscribe { [weak self] data in
                var tempData: DetailVCModel.Fields = DetailVCModel.Fields()
                tempData.title = data.element?.title ?? "not exist"
                tempData.image = data.element?.image ?? "not exist"
                tempData.description = data.element?.description ?? "not exist"
                
                // duplicated ON -> 중복에 관한 alert dialog 생성, duplicated OFF ->  중복 X에 관한 alert dialog 생성
                if let duplicated = self?.viewModel.returnDuplicatedBoolAfterSaveData(data: tempData){
                    duplicated ? self?.makeAlertDialog(duplicated: true) : self?.makeAlertDialog(duplicated: false)
                }
            }.disposed(by: disposeBag)
    }
    //MARK: - viewDidLoad(), viewDidAppear()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fromVC()
        bindView()
        bindTableViewInView()
        self.hideKeyboard()
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
                self?.viewModel.url = data.element?.url ?? ""
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
            .bind(to: self.routineTableView.rx.items(cellIdentifier: "DetailTableViewCell", cellType: DetailTableViewCell.self)){(index, element, cell) in
            
                cell.selectionStyle = .none
                
                cell.dayLabel.text = "Day \(element.0)"
                cell.routinLabel.text = element.1.replacingOccurrences(of: "\\n", with: "\n") //FireStroe Json 데이터 줄 바꿈
                cell.numberImageView.image = UIImage(systemName: "\(element.0).square")
                
                cell.routinLabel.bold()
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

//MARK: - TransitioningDelegate 구현

extension DetailViewController: UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?{
        return HalfModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

//MARK: - 1RM 클릭 시 제공 toast

extension DetailViewController{
    func showToast(font: UIFont = UIFont.systemFont(ofSize: 13, weight: .bold)) {
        //        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 84, y: self.view.frame.size.height-100, width: 170, height: 30))
        let toastLabel = UILabel()
        let message = "1RM 적용 완료 !"

        toastLabel.backgroundColor = .systemTeal
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.numberOfLines = 2
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 10, delay: 0.5, options: .transitionCurlDown, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
        
        toastLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(130)
            make.bottom.equalToSuperview().offset(-100)
            make.centerX.equalToSuperview()
        }
    }
}



