import UIKit

import RxSwift
import SnapKit
import Then

class FirstExcuteViewController: UIViewController {
    let viewModel = FirstExcuteViewModel()
    
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
            paragraphStyle.lineSpacing = 30
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            noticeLabel.attributedText = attrString
        }
    } 
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var okButton: UIButton!{
        didSet{
            okButton.layer.cornerRadius = 10
        }
    }
    
    //MARK: - IBAction

    @IBAction func okButtonAction(_ sender: Any) {
        if viewModel.detectFirstExecution{
            self.dismiss(animated: true)
        }
        else{
            self.dismiss(animated: true) {
                self.viewModel.fromExecutionGuide.onNext(true)
            }
        }
    }
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        addGesture()
        
        //제스처 추가
        func addGesture(){
            if sender.direction == .right{
//                if viewModel.index == 0{
//                    return
//                }
                setDirection("right")
                input1RM()
            }
            else if sender.direction == .left{
//                if viewModel.index == 2{
//                    return
//                }
                setDirection("left")
                input1RM()
            }
            
            // 제스처 방향에 따른 UI 수정
            func setDirection(_ direction: String){
                if direction == "left"{
                    viewModel.index += 1
                }
                else if direction == "right"{
                    viewModel.index -= 1
                }
                pageControl.currentPage = viewModel.index
                if viewModel.detectFirstExecution{
                    insertDivisionData(imageArray: viewModel.firstExcuteimageNamesArray, notice1: viewModel.firstExcuteNotice1, notice2: viewModel.firstExcuteNotice2, notice3: viewModel.firstExcuteNotice3)
                }
                else{
                    insertDivisionData(imageArray: viewModel.executionGuideImageNamesArray, notice1: viewModel.executionGuideNotice1, notice2: viewModel.executionGuideNotice2, notice3: viewModel.executionGuideNotice3)
                }
        
                // viewModel.detectFirstExecution의 결과에 따른 데이터 삽입 (최초 실행 VC or 전체 루틴보기 가이드 VC)
                func insertDivisionData(imageArray: [String], notice1: String, notice2: String, notice3: String){
                    if viewModel.index == 3{
                        return
                    }
                    else{
                        imageView.image = UIImage(named: imageArray[viewModel.index])
                        
                        if viewModel.index == 0{
                            noticeLabel.text = notice1
                        }
                        else if viewModel.index == 1{
                            noticeLabel.text = notice2
                        }
                        else if viewModel.index == 2{
                            noticeLabel.text = notice3
                        }
                    }
                    
                    
                }
            }
            func input1RM(){
                if viewModel.index == 3{
                    self.imageViewEmbeddedView.isHidden = true
                    self.noticeLabelImage.isHidden = true
                    self.noticeLabelEmbeddedView.isHidden = true
                    
                    let inputTitleLabel = UILabel().then {
                        $0.text = "1RM 입력"
                        $0.font = .boldSystemFont(ofSize: 20)
                    }
                    let divisionLineView = UIView().then {
                        $0.backgroundColor = .systemGray4
                    }
                    let allEmbeddedView = UIView().then {
                        $0.layer.masksToBounds = true
                        $0.layer.cornerRadius = 10
                        $0.backgroundColor = .systemGray6
                    }
                    let benchPressLabel = makeDivisionLabel(text: "벤치 프레스 :")
                    let deadLiftLabel = makeDivisionLabel(text: "데드 리프트 :")
                    let sqautLabel = makeDivisionLabel(text: "스쿼트 :")
                    
                    let benchPressInput = makeInputLabel()
                    let deadLiftInput = makeInputLabel()
                    let squatInput = makeInputLabel()
                    
                    allEmbeddedView.addSubview(benchPressLabel)
                    allEmbeddedView.addSubview(deadLiftLabel)
                    allEmbeddedView.addSubview(sqautLabel)

                    allEmbeddedView.addSubview(benchPressInput)
                    allEmbeddedView.addSubview(deadLiftInput)
                    allEmbeddedView.addSubview(squatInput)
                    
                    self.view.addSubview(inputTitleLabel)
                    self.view.addSubview(divisionLineView)
                    self.view.addSubview(allEmbeddedView)
                    
                    inputTitleLabel.snp.makeConstraints { make in
                        make.bottom.equalTo(divisionLineView.snp.top).offset(-10)
                        make.left.equalTo(allEmbeddedView.snp.left).offset(10)
                    }
                    divisionLineView.snp.makeConstraints { make in
                        make.bottom.equalTo(allEmbeddedView.snp.top).offset(-10)
                        make.left.equalTo(allEmbeddedView.snp.left)
                        make.right.equalTo(allEmbeddedView.snp.right)
                        make.height.equalTo(0.5)
                    }
                    
                    allEmbeddedView.snp.makeConstraints { make in
                        make.top.equalTo(titleLabel.snp.bottom).offset(100)
                        make.centerX.equalToSuperview()
                        make.width.equalTo(300)
                    }
                    
                    benchPressLabel.snp.makeConstraints { make in
                        make.top.left.equalToSuperview().inset(30)
                    }
                    benchPressInput.snp.makeConstraints { make in
                        make.top.equalTo(benchPressLabel.snp.top).offset(-5)
                        make.bottom.equalTo(benchPressLabel.snp.bottom).offset(5)
                        make.left.equalTo(benchPressLabel.snp.right).offset(30)
                        make.right.equalToSuperview().inset(30)
                    }
                    deadLiftLabel.snp.makeConstraints { make in
                        make.top.equalTo(benchPressLabel.snp.bottom).offset(27)
                        make.left.equalToSuperview().inset(30)
                    }
                    deadLiftInput.snp.makeConstraints { make in
                        
                        make.top.equalTo(deadLiftLabel.snp.top).offset(-5)
                        make.bottom.equalTo(deadLiftLabel.snp.bottom).offset(5)
                        make.left.equalTo(deadLiftLabel.snp.right).offset(30)
                        make.right.equalToSuperview().inset(30)

                    }
                    sqautLabel.snp.makeConstraints { make in
                        make.top.equalTo(deadLiftLabel.snp.bottom).offset(27)
                        make.left.bottom.equalToSuperview().inset(30)
                    }
                    squatInput.snp.makeConstraints { make in
                        make.top.equalTo(sqautLabel.snp.top).offset(-5)
                        make.bottom.equalTo(sqautLabel.snp.bottom).offset(5)
                        make.left.equalTo(sqautLabel.snp.right).offset(30)
                        make.right.equalToSuperview().inset(30)
                    }
                    
                    func makeDivisionLabel(text: String) -> UILabel{
                        let label = UILabel()
                        label.font = .systemFont(ofSize: 16, weight: .medium)
                        label.text = text
                        return label
                    }
                    func makeInputLabel() -> UITextField{
                        let textField = UITextField()
                        textField.layer.cornerRadius = 5
                        textField.layer.borderColor = UIColor.label.cgColor
                        textField.layer.borderWidth = 1.5
                        textField.font = .systemFont(ofSize: 9)
                        textField.textAlignment = .center
                        textField.placeholder = "무게를 입력하세요"
                        return textField
                    }
                    

                }
            }
            
        }
    }
    
    //MARK: - viewDidLoad()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureAfterSetDirection()
    }
}

//MARK: - 제스처 방향 설정 및 해당 뷰에 추가

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
