import UIKit
import RxSwift

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
            imageViewEmbeddedView.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var imageView: UIImageView!{
        didSet{
            imageView.image = UIImage(named: viewModel.initialImageName)
        }
    }
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
                if viewModel.index == 0{
                    return
                }
                setDirection("right")
            }
            else if sender.direction == .left{
                if viewModel.index == 2{
                    return
                }
                setDirection("left")
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
                    imageView.image = UIImage(named: imageArray[viewModel.index])
                    
                    if viewModel.index == 0{
                        noticeLabel.text = notice1
                    }
                    else if viewModel.index == 1{
                        noticeLabel.text = notice2
                    }
                    else{
                        noticeLabel.text = notice3
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
