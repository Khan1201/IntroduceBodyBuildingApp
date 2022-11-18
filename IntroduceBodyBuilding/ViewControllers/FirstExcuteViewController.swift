import UIKit

import RxSwift
import SnapKit
import Then

class FirstExcuteViewController: UIViewController {
    let viewModel = FirstExcuteViewModel()
    var disposeBag = DisposeBag()
    
    lazy var lastPageAllEmbeddedView = UIView()
    lazy var benchPressTextField = UITextField().then {
        $0.layer.cornerRadius = 5
        $0.layer.borderColor = UIColor.label.cgColor
        $0.layer.borderWidth = 1.5
        $0.font = .systemFont(ofSize: 11)
        $0.textAlignment = .center
        $0.placeholder = "ex) 100"
        $0.keyboardType = .numberPad
        $0.returnKeyType = .done
    }
    lazy var deadLiftTextField = UITextField().then {
        $0.layer.cornerRadius = 5
        $0.layer.borderColor = UIColor.label.cgColor
        $0.layer.borderWidth = 1.5
        $0.font = .systemFont(ofSize: 11)
        $0.textAlignment = .center
        $0.placeholder = "ex) 160"
        $0.keyboardType = .numberPad
        $0.returnKeyType = .done
    }
    lazy var squatTextField = UITextField().then {
        $0.layer.cornerRadius = 5
        $0.layer.borderColor = UIColor.label.cgColor
        $0.layer.borderWidth = 1.5
        $0.font = .systemFont(ofSize: 11)
        $0.textAlignment = .center
        $0.placeholder = "ex) 150"
        $0.keyboardType = .numberPad
        $0.returnKeyType = .done
    }
    
    //MARK: - IBOutlet
    
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
            if viewModel.detectFirstExecution{
                noticeLabel.text = viewModel.firstExcuteNotice1
            }
            else{
                noticeLabel.text = viewModel.executionGuideNotice1
            }
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
            if viewModel.detectFirstExecution{
                pageControl.numberOfPages = 4
            }
            else{
                pageControl.numberOfPages = 3
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
            if viewModel.currentIndex <= viewModel.firstExcuteMaxIndex - 1{ // 해당 VC의 pageControl 최대 currentIndex = 3
                setGestureDirectionEvent("left")
            }
            else{
                viewModel.isValid
                    .filter { $0 == true}
                    .bind { _ in
                        UserDefaults.standard.set(Int(self.benchPressTextField.text!)!, forKey: "benchPress")
                        UserDefaults.standard.set(Int(self.deadLiftTextField.text!)!, forKey: "deadLift")
                        UserDefaults.standard.set(Int(self.squatTextField.text!)!, forKey: "squat")
                        self.presentingViewController?.dismiss(animated: true)
                        self.dismiss(animated: true) {
                            self.viewModel.completionObservable.onNext(true)
                        }
                    }.dispose()
            }
        }
        
        else{
            if viewModel.currentIndex <= viewModel.executionGuideMaxIndex - 1{ // 해당 VC의 pageControl 최대 currentIndex = 2
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
        if viewModel.detectFirstExecution{
            drawInputUI()
            bindTextFieldData()
        }
        addGestureAfterSetDirection()
        self.hideKeyboard()
    }
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
                if viewModel.currentIndex == 3{
                    return
                }
            }
            else{
                if viewModel.currentIndex == 2{
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
        
        // 최초실행 VC의 총 페이지 = 4 (currentIndex = 0 ~ 3), 전체루틴 VC의 총 페이지 = 3 (currentIndex = 0 ~ 2)
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
        func insertDivisionData(imageArray: [String], notice1: String, notice2: String, notice3: String){
            
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
            else{
                return
            }
            
            //currentIndex 0 ~ 2 (마지막이 아닐때) 기존 뷰 수정
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
                
                if viewModel.detectFirstExecution{
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
