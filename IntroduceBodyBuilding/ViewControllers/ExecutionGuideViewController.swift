import UIKit
import RxSwift

class ExecutionGuideViewController: UIViewController {
    
    let viewModel = ExecutionGuideViewModel()
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var imageViewNoticeViewEmbeddedView: UIView!

    @IBOutlet var gestureStart: UISwipeGestureRecognizer!
    @IBOutlet weak var imageViewEmbeddedView: UIView!{
        didSet{
            imageViewEmbeddedView.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var noticeLabelEmbeddedView: UIView!{
        didSet{
            noticeLabelEmbeddedView.layer.cornerRadius = 10
            noticeLabel.text = viewModel.notice1
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
        self.dismiss(animated: true)
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
                imageView.image = UIImage(named: viewModel.imageNames[viewModel.index])
                
                if viewModel.index == 0{
                    noticeLabel.text = viewModel.notice1
                }
                else if viewModel.index == 1{
                    noticeLabel.text = viewModel.notice2
                }
                else{
                    noticeLabel.text = viewModel.notice3
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

extension ExecutionGuideViewController{
    func addGestureAfterSetDirection(){
        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
        rightGesture.direction = .right
        self.imageViewNoticeViewEmbeddedView.addGestureRecognizer(rightGesture)
        
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
        leftGesture.direction = .left
        self.imageViewNoticeViewEmbeddedView.addGestureRecognizer(leftGesture)
    }
}
