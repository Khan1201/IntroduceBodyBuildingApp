//
//  DetailViewController.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/08/19.
//

import UIKit


class DetailViewController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var urlView: UILabel!
   
    
   var titleName: String?
   var imageName: String?
   var descrip: String?
   var url: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = titleName ?? "sorry"

        
        // Do any additional setup after loading the view.
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
