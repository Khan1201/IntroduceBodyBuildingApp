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
            if viewModel.detectFirstExecution{ // ??? ?????? ???????????? ?????? ???
                pageControl.numberOfPages = viewModel.firstExcuteimageNamesArray.count + 1
                
                if viewModel.fromSettingVC{ // ????????? '????????????'?????? ?????? ??? (1RM ?????? ????????? ???????????? ????????? ?????????)
                    pageControl.numberOfPages = viewModel.firstExcuteimageNamesArray.count
                }
            }
            
            else{ // '?????? ????????????'??? ?????? ???
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
            
            if viewModel.currentIndex <= viewModel.firstExcuteMaxIndex - 1{ // ????????? ????????? ????????? '??????'?????? ??????
                setGestureDirectionEvent("left")
            }
            else{
                // ???????????? '????????????'?????? ?????? ??? 1RM ???????????? ??????.
                if viewModel.fromSettingVC{
                    self.dismiss(animated: true)
                }
                viewModel.isValid
                    .filter { $0 == true}
                    .bind { _ in
                        UserDefaults.standard.set(Int(self.benchPressTextField.text!)!, forKey: "benchPress")
                        UserDefaults.standard.set(Int(self.deadLiftTextField.text!)!, forKey: "deadLift")
                        UserDefaults.standard.set(Int(self.squatTextField.text!)!, forKey: "squat")
                        UserDefaults.standard.set("Indigo", forKey: "color") // ?????? ????????? ?????? ??????
                        
                        // ?????? ?????? ?????? (1RM ?????? ????????? ?????? ???????????? VC ??????)
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

//MARK: - ????????? ?????? UI ?????? ??????

func setInitialTextFieldUI(_ textField: UITextField, placeHolder: String){
    textField.layer.cornerRadius = 5
    textField.layer.borderColor = UIColor.systemGray.cgColor
    textField.layer.borderWidth = 1.5
    textField.font = .systemFont(ofSize: 11)
    textField.textAlignment = .center
    textField.placeholder = placeHolder
    textField.keyboardType = .numberPad
}

//MARK: - ????????? ?????? ??? View??? ????????? ??????

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

//MARK: - ????????? ?????? ????????? ??????

extension FirstExcuteViewController{
    //????????? ??????
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
//MARK: - // ????????? ?????? ???????????? ?????? UI ??????

extension FirstExcuteViewController{
    func setGestureDirectionEvent(_ direction: String){
        
        // ????????? ????????? ?????? UI ??????
        if direction == "left"{
            viewModel.currentIndex += 1
        }
        else if direction == "right"{
            viewModel.currentIndex -= 1
        }
        pageControl.currentPage = viewModel.currentIndex
        
        // ???????????? VC??? ??? ????????? = 5 (currentIndex = 0 ~ 4), ???????????? VC??? ??? ????????? = 3 (currentIndex = 0 ~ 2)
        if viewModel.detectFirstExecution{
            insertDivisionData(imageArray: viewModel.firstExcuteimageNamesArray,
                               notice1: viewModel.firstExcuteNotice1,
                               notice2: viewModel.firstExcuteNotice2,
                               notice3: viewModel.firstExcuteNotice3)
            modifyUIHidden()
            setButtonTitleAndAlpha(maxIndex: viewModel.firstExcuteMaxIndex) // ????????? page??? ????????? UI ??????
        }
        else{
            insertDivisionData(imageArray: viewModel.executionGuideImageNamesArray,
                               notice1: viewModel.executionGuideNotice1,
                               notice2: viewModel.executionGuideNotice2,
                               notice3: viewModel.executionGuideNotice3)
            setButtonTitleAndAlpha(maxIndex: viewModel.executionGuideMaxIndex)
        }
        
        // viewModel.detectFirstExecution??? ????????? ?????? ????????? ?????? (?????? ?????? VC or ?????? ???????????? ????????? VC)
        func insertDivisionData(imageArray: [String], notice1: String, notice2: String, notice3: String
                                ,notice4: String = viewModel.firstExcuteNotice4){
            
            // viewModel.index??? ?????? UI ?????? (notice1, 2, 3 ???????????? Array??? ???????????? ????????? ????????? ?????? ??????)
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
            
            //currentIndex ???????????? ????????? ?????? ??? ??????
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
                okButton.setTitle("??????", for: .normal)
                okButton.alpha = 1
            }
            else{
                okButton.setTitle("??????", for: .normal)
                
                // ????????????????????? 1RM ????????? ?????? -> 1RM ??????????????? valid ?????? ??????
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

//MARK: - ???????????? VC -> 1RM(????????????) ?????? UI ????????? (????????? ????????? isHidden = true)

extension FirstExcuteViewController{
    func drawInputUI(){
        // UI Component ??????
        let inputTitleLabel = UILabel().then {
            $0.text = "1RM ??????"
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
        let benchPressLabel = makeDivisionLabel(text: "?????? ????????? :")
        let deadLiftLabel = makeDivisionLabel(text: "?????? ????????? :")
        let sqautLabel = makeDivisionLabel(text: "????????? :")
        
        // ??????????????? maxWeightInputView??? ?????? (index??? ?????? ????????? or ????????? ?????? ??????????????? ??????)
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

//MARK: - 1RM ?????? ??????????????? ????????? -> observable ?????????

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

//MARK: - ?????? 'X' ?????? ?????????

extension FirstExcuteViewController{
    func activateGoBackButton(){
        goBackButton.isHidden = false
        goBackButton.rx.tap
            .bind { _ in
                self.dismiss(animated: true)
            }.disposed(by: disposeBag)
    }
}
