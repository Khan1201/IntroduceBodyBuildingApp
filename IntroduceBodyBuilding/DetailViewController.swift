//
//  DetailViewController.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/08/19.
//

import UIKit
import SafariServices


class DetailViewController: UIViewController {
    
    var titleName: String?
    var imageName: String?
    var descrip: String?
    var url: String?
    
    @IBOutlet weak var titleLabel: UILabel!{
        didSet{
            titleLabel.text = titleName ?? "sorry"
        }
    }
    @IBOutlet weak var imageView: UIImageView!{
        didSet{
            imageView.image = UIImage(named: imageName ?? "")
        }
    }
    @IBOutlet weak var descriptionLabel: UILabel!{
        didSet{
            
            descriptionLabel.text = descrip ?? "sorry"
            
            let attrString = NSMutableAttributedString(string: descriptionLabel.text!)
            let paragraphStyle = NSMutableParagraphStyle()
            
            descriptionLabel.lineBreakMode = .byWordWrapping
            descriptionLabel.numberOfLines = 0
            paragraphStyle.lineSpacing = 10
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            descriptionLabel.attributedText = attrString
        }
    }
    
    @IBOutlet weak var urlButton: UIButton!{
        didSet{
            urlButton.setTitle("See More...", for: .normal)
        }
    }
    
    
    
   
    
   
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        
        // Do any additional setup after loading the view.
    }
    @IBAction func urlButtonAction(_ sender: UIButton) {
        let setUrl = NSURL(string: url!)
        let moveUrl: SFSafariViewController = SFSafariViewController(url: setUrl! as URL)
        self.present(moveUrl, animated: true)
        
        
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
