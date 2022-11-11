//
//  FirstExcuteViewController.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/11/09.
//

import UIKit

class FirstExcuteViewController: UIViewController {
    
    @IBOutlet var allEmbeddedView: UIView!
    @IBAction func swipeGesture(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .right{
            index -= 1
            pageControl.currentPage = index
            imageView.image = UIImage(named: imageNames[index])
//            noticeLabel.text = notice[index]
            
            if index == 0{
                noticeLabel.text = notice1
            }
            else if index == 1{
                noticeLabel.text = notice2
            }
            else{
                noticeLabel.text = notice3
            }
            
            
        }
        if sender.direction == .left{
            index += 1
            pageControl.currentPage = index
            imageView.image = UIImage(named: imageNames[index])
//            noticeLabel.text = notice[index]
            
            if index == 0{
                noticeLabel.text = notice1
            }
            else if index == 1{
                noticeLabel.text = notice2
            }
            else{
                noticeLabel.text = notice3
            }
        }
    }
    
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
        }
    }
    
    @IBOutlet weak var noticeLabel: UILabel!{
        didSet{
            let attrString = NSMutableAttributedString(string: noticeLabel.text!)
            let paragraphStyle = NSMutableParagraphStyle()
            
            noticeLabel.lineBreakMode = .byWordWrapping
            noticeLabel.numberOfLines = 0
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
    var index: Int = 0
    let imageNames: [String] = ["firstExecution1", "firstExecution2", "firstExecution3"]
    let notice: [String] = ["해당 프로그램을 열람 해보세요.", "자주보는 프로그램을 등록해보세요.", "루틴을 등록하여 알람을 받아보세요."]
    
    let notice1: String =
    """
    해당 프로그램을
    등록 해보세요.
    """
    let notice2: String =
    """
    자주보는 프로그램을
    등록 해보세요.
    """
    let notice3: String =
    """
    루틴을 등록하여
    알람을 받아보세요.
    """
 

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        let rr = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
        rr.direction = .right
        self.allEmbeddedView.addGestureRecognizer(rr)
        let ll = UISwipeGestureRecognizer(target: self, action: #selector(swipeGesture(_:)))
        rr.direction = .left
        self.allEmbeddedView.addGestureRecognizer(ll)
    }
}

//extension FirstExcuteViewController {
//    func tapGesture(){
//        imageView.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(<#T##@objc method#>)))
//    }
//    func tap(){
//
//    }
//}

//extension FirstExcuteViewController: UIScrollViewDelegate{
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            pageControl.currentPage = Int(floor(scrollView.contentOffset.x / UIScreen.main.bounds.width))
//        }
//}
