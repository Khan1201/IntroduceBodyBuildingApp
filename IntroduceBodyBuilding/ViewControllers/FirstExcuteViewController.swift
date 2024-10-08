import UIKit

import RxSwift
import SnapKit
import Then

class FirstExcuteViewController: UIViewController {
    let viewModel = FirstExcuteViewModel()
    var disposeBag = DisposeBag()

    lazy var lastPageAllEmbeddedView = UIView()
    lazy var benchPressTextField = UITextField().then {
        setInitialTextFieldUI($0, placeHolder: "ex) 80")
    }
    
    lazy var deadLiftTextField = UITextField().then {
        setInitialTextFieldUI($0, placeHolder: "ex) 160")
    }
    lazy var squatTextField = UITextField().then {
        setInitialTextFieldUI($0, placeHolder: "ex) 150")
    }
   
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var goBackButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.text = viewModel.initialTitle
        }
    }
    @IBOutlet weak var imageViewNoticeViewEmbeddedView: UIView!
    
    @IBOutlet var gestureStart: UISwipeGestureRecognizer!
    @IBOutlet weak var imageViewEmbeddedView: UIView!{
        didSet{
            imageViewEmbeddedView.layer.cornerRadius = 10
        }
    }
    @IBOutlet weak var imageView: UIImageView!{
        didSet{
            imageView.image = UIImage(named: viewModel.initialImageName)
        }
    }
    
    @IBOutlet weak var noticeLabelImage: UIImageView!
    @IBOutlet weak var noticeLabelEmbeddedView: UIView!{
        didSet{
            noticeLabelEmbeddedView.layer.cornerRadius = 10
            
            noticeLabel.text = viewModel.detectFirstExecution ? viewModel.firstExcuteNotice1 :                                                                        viewModel.executionGuideNotice1
        }
    }
    
    @IBOutlet weak var noticeLabel: UILabel!{
        didSet{
            let attrString = NSMutableAttributedString(string: noticeLabel.text!)
            let paragraphStyle = NSMutableParagraphStyle()
            
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = 20
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            noticeLabel.attributedText = attrString
        }
    }
    @IBOutlet weak var pageControl: UIPageControl!{
        didSet{
            if viewModel.detectFirstExecution{ // 앱 최초 실행으로 호출 시
                pageControl.numberOfPages = viewModel.firstExcuteimageNamesArray.count + 1
                
                if viewModel.fromSettingVC{ // 세팅의 '이용방법'으로 호출 시 (1RM 입력 페이지 제외하고 나머지 재사용)
                    pageControl.numberOfPages = viewModel.firstExcuteimageNamesArray.count
                }
            }
            
            else{ // '루틴 전체보기'로 호출 시
                pageControl.numberOfPages = viewModel.executionGuideImageNamesArray.count
            }
        }
    }
    @IBOutlet weak var okButton: UIButton!{
        didSet{
            okButton.layer.cornerRadius = 10
        }
    }
    
    //MARK: - IBAction
    
    @IBAction func okButtonAction(_ sender: Any) {
        if viewModel.detectFirstExecution{
            
            if viewModel.currentIndex <= viewModel.firstExcuteMaxIndex - 1{ // 마지막 페이지 전까진 '다음'으로 이동
                setGestureDirectionEvent("left")
            }
            else{
                // 설정에서 '이용방법'으로 호출 시 1RM 페이지가 없음.
                if viewModel.fromSettingVC{
                    self.dismiss(animated: true)
                }
                viewModel.isValid
                    .filter { $0 == true}
                    .bind { _ in
                        UserDefaults.standard.set(Int(self.benchPressTextField.text!)!, forKey: "benchPress")
                        UserDefaults.standard.set(Int(self.deadLiftTextField.text!)!, forKey: "deadLift")
                        UserDefaults.standard.set(Int(self.squatTextField.text!)!, forKey: "squat")
                        UserDefaults.standard.set("Indigo", forKey: "color") // 초기 키워드 색깔 저장
                        
                        // 현재 버전 저장 (1RM 받지 못하면 항상 최초실행 VC 띄움)
                        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                        UserDefaults.standard.set(currentVersion, forKey: "VersionOfLastRun")

                        self.presentingViewController?.dismiss(animated: true)
                        self.dismiss(animated: true) {
                            self.viewModel.completionObservable.onNext(true)
                        }
                    }.dispose()
            }
        }
        
        else{
            if viewModel.currentIndex <= viewModel.executionGuideMaxIndex - 1{ 
                setGestureDirectionEvent("left")
            }
            else{
                self.dismiss(animated: true) {
                    self.viewModel.fromExecutionGuide.onNext(true)
                }
            }
        }
    }
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        addGestureEvent(sender: sender)
    }
    //MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reactDevice()
        if viewModel.detectFirstExecution{
            drawInputUI()
            bindTextFieldData()
        }
        else{
            activateGoBackButton()
        }
        addGestureAfterSetDirection()
        self.hideKeyboard()
    }
}

//MARK: - 텍스트 필드 UI 초기 설정

func setInitialTextFieldUI(_ textField: UITextField, placeHolder: String){
    textField.layer.cornerRadius = 5
    textField.layer.borderColor = UIColor.systemGray.cgColor
    textField.layer.borderWidth = 1.5
    textField.font = .systemFont(ofSize: 11)
    textField.textAlignment = .center
    textField.placeholder = placeHolder
    textField.keyboardType = .numberPad
}

//MARK: - 제스처 생성 및 View에 제스처 추가

extension FirstExcuteViewController{
    func addGestureAfterSetDirection(){
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
        rightGesture.direction = .right
        self.imageViewNoticeViewEmbeddedView.addGestureRecognizer(rightGesture)
        
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
        leftGesture.direction = .left
        self.imageViewNoticeViewEmbeddedView.addGestureRecognizer(leftGesture)
    }
}

//MARK: - 제스처 방향 이벤트 설정

extension FirstExcuteViewController{
    //제스처 추가
    func addGestureEvent(sender: UISwipeGestureRecognizer){
        if sender.direction == .right{
            
            if viewModel.currentIndex == 0{
                return
            }
            setGestureDirectionEvent("right")
        }
        else if sender.direction == .left{
            
            if viewModel.detectFirstExecution{
                
                if viewModel.currentIndex == viewModel.firstExcuteMaxIndex{
                    return
                }
            }
            else{
                
                if viewModel.currentIndex == viewModel.executionGuideMaxIndex{
                    return
                }
            }
            setGestureDirectionEvent("left")
        }
    }
}
//MARK: - // 제스처 방향 이벤트에 따른 UI 수정

extension FirstExcuteViewController{
    func setGestureDirectionEvent(_ direction: String){
        
        // 제스처 방향에 따른 UI 수정
        if direction == "left"{
            viewModel.currentIndex += 1
        }
        else if direction == "right"{
            viewModel.currentIndex -= 1
        }
        pageControl.currentPage = viewModel.currentIndex
        
        // 최초실행 VC의 총 페이지 = 5 (currentIndex = 0 ~ 4), 전체루틴 VC의 총 페이지 = 3 (currentIndex = 0 ~ 2)
        if viewModel.detectFirstExecution{
            insertDivisionData(imageArray: viewModel.firstExcuteimageNamesArray,
                               notice1: viewModel.firstExcuteNotice1,
                               notice2: viewModel.firstExcuteNotice2,
                               notice3: viewModel.firstExcuteNotice3)
            modifyUIHidden()
            setButtonTitleAndAlpha(maxIndex: viewModel.firstExcuteMaxIndex) // 마지막 page에 새로운 UI 생성
        }
        else{
            insertDivisionData(imageArray: viewModel.executionGuideImageNamesArray,
                               notice1: viewModel.executionGuideNotice1,
                               notice2: viewModel.executionGuideNotice2,
                               notice3: viewModel.executionGuideNotice3)
            setButtonTitleAndAlpha(maxIndex: viewModel.executionGuideMaxIndex)
        }
        
        // viewModel.detectFirstExecution의 결과에 따른 데이터 삽입 (최초 실행 VC or 전체 루틴보기 가이드 VC)
        func insertDivisionData(imageArray: [String], notice1: String, notice2: String, notice3: String
                                ,notice4: String = viewModel.firstExcuteNotice4){
            
            // viewModel.index에 따른 UI 수정 (notice1, 2, 3 변수들이 Array에 들어가질 않아서 이렇게 로직 작성)
            if viewModel.currentIndex == 0{
                modifyUIData(imageArray[0], notice1)
            }
            else if viewModel.currentIndex == 1{
                modifyUIData(imageArray[1], notice2)
            }
            else if viewModel.currentIndex == 2{
                modifyUIData(imageArray[2], notice3)
            }
            else if viewModel.currentIndex == 3{
                modifyUIData(imageArray[3], notice4)
            }
            else{
                return
            }
            
            //currentIndex 마지막이 아닐때 기존 뷰 수정
            func modifyUIData(_ imageString: String, _ notice: String){
                imageView.image = UIImage(named: imageString)
                noticeLabel.text = notice
            }
        }
        func modifyUIHidden(){
            if viewModel.currentIndex <= (viewModel.firstExcuteMaxIndex) - 1 {
                lastPageAllEmbeddedView.isHidden = true
                makeVisibleExistingUI()
            }
            else{
                lastPageAllEmbeddedView.isHidden = false
                hideExistingUI()
                if viewModel.fromSettingVC{
                    lastPageAllEmbeddedView.isHidden = true
                    makeVisibleExistingUI()
                }
            }
            
            func makeVisibleExistingUI(){
                self.imageViewEmbeddedView.isHidden = false
                self.noticeLabelImage.isHidden = false
                self.noticeLabelEmbeddedView.isHidden = false
            }
            func hideExistingUI(){
                self.imageViewEmbeddedView.isHidden = true
                self.noticeLabelImage.isHidden = true
                self.noticeLabelEmbeddedView.isHidden = true
            }
        }
        func setButtonTitleAndAlpha(maxIndex: Int){
            if viewModel.currentIndex <= maxIndex - 1 {
                okButton.setTitle("다음", for: .normal)
                okButton.alpha = 1
            }
            else{
                okButton.setTitle("확인", for: .normal)
                
                // 최초실행시에만 1RM 페이지 제공 -> 1RM 텍스트필드 valid 체크 필요
                if viewModel.detectFirstExecution && viewModel.fromSettingVC == false {
                    viewModel.isValid
                        .map { $0 ? 1 : 0.3}
                        .bind(to: okButton.rx.alpha)
                        .disposed(by: disposeBag)
                }
            }
        }
    }
}

//MARK: - 최초실행 VC -> 1RM(최대무게) 입력 UI 그리기 (선언과 동시에 isHidden = true)

extension FirstExcuteViewController{
    func drawInputUI(){
        // UI Component 선언
        let inputTitleLabel = UILabel().then {
            $0.text = "1RM 입력"
            $0.font = .boldSystemFont(ofSize: 20)
        }
        let divisionLineView = UIView().then {
            $0.backgroundColor = .systemGray4
        }
        let maxWeightInputView = UIView().then {
            $0.layer.masksToBounds = true
            $0.layer.cornerRadius = 10
            $0.backgroundColor = .systemGray5
        }
        let benchPressLabel = makeDivisionLabel(text: "벤치 프레스 :")
        let deadLiftLabel = makeDivisionLabel(text: "데드 리프트 :")
        let sqautLabel = makeDivisionLabel(text: "스쿼트 :")
        
        // 전역변수인 maxWeightInputView에 추가 (index에 따른 숨기기 or 보이기 위해 전역변수로 선언)
        maxWeightInputView.addSubview(benchPressLabel)
        maxWeightInputView.addSubview(deadLiftLabel)
        maxWeightInputView.addSubview(sqautLabel)
        
        maxWeightInputView.addSubview(benchPressTextField)
        maxWeightInputView.addSubview(deadLiftTextField)
        maxWeightInputView.addSubview(squatTextField)
        
        lastPageAllEmbeddedView.addSubview(maxWeightInputView)
        lastPageAllEmbeddedView.addSubview(inputTitleLabel)
        lastPageAllEmbeddedView.addSubview(divisionLineView)
        
        self.view.addSubview(lastPageAllEmbeddedView)
        
        makeConstraint()
        lastPageAllEmbeddedView.isHidden = true
        
        func makeDivisionLabel(text: String) -> UILabel{
            let label = UILabel()
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.text = text
            return label
        }
        
        func makeConstraint(){
            lastPageAllEmbeddedView.snp.makeConstraints { make in
                make.top.equalTo(titleLabel.snp.bottom).offset(105)
                make.centerX.equalToSuperview()
                make.width.equalTo(260)
            }
            
            inputTitleLabel.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.left.equalToSuperview()
            }
            divisionLineView.snp.makeConstraints { make in
                make.top.equalTo(inputTitleLabel.snp.bottom).offset(8)
                make.left.equalToSuperview()
                make.right.equalToSuperview()
                make.height.equalTo(0.5)
            }
            maxWeightInputView.snp.makeConstraints { make in
                make.top.equalTo(divisionLineView.snp.bottom).offset(15)
                make.left.right.bottom.equalToSuperview()
            }
            
            benchPressLabel.snp.makeConstraints { make in
                make.top.left.equalToSuperview().inset(30)
            }
            benchPressTextField.snp.makeConstraints { make in
                make.top.equalTo(benchPressLabel.snp.top).offset(-5)
                make.bottom.equalTo(benchPressLabel.snp.bottom).offset(5)
                make.right.equalToSuperview().inset(30)
                make.width.equalTo(90)
            }
            deadLiftLabel.snp.makeConstraints { make in
                make.top.equalTo(benchPressLabel.snp.bottom).offset(27)
                make.left.equalToSuperview().inset(30)
            }
            deadLiftTextField.snp.makeConstraints { make in
                make.top.equalTo(deadLiftLabel.snp.top).offset(-5)
                make.bottom.equalTo(deadLiftLabel.snp.bottom).offset(5)
                make.right.equalToSuperview().inset(30)
                make.width.equalTo(90)
            }
            sqautLabel.snp.makeConstraints { make in
                make.top.equalTo(deadLiftLabel.snp.bottom).offset(27)
                make.centerX.equalTo(benchPressLabel.snp.centerX)
                make.bottom.equalToSuperview().inset(30)
            }
            squatTextField.snp.makeConstraints { make in
                make.top.equalTo(sqautLabel.snp.top).offset(-5)
                make.bottom.equalTo(sqautLabel.snp.bottom).offset(5)
                make.right.equalToSuperview().inset(30)
                make.width.equalTo(90)
            }
        }
    }
}

//MARK: - 1RM 입력 텍스트필드 데이터 -> observable 바인딩

extension FirstExcuteViewController{
    func bindTextFieldData(){
        benchPressTextField.rx.text
            .orEmpty
            .bind(to: viewModel.benchPressObservable)
            .disposed(by: disposeBag)
        
        deadLiftTextField.rx.text
            .orEmpty
            .bind(to: viewModel.deadLiftObservable)
            .disposed(by: disposeBag)
        
        squatTextField.rx.text
            .orEmpty
            .bind(to: viewModel.squatObservable)
            .disposed(by: disposeBag)
    }
}

//MARK: - 취소 'X' 버튼 활성화

extension FirstExcuteViewController{
    func activateGoBackButton(){
        goBackButton.isHidden = false
        goBackButton.rx.tap
            .bind { _ in
                self.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
}
