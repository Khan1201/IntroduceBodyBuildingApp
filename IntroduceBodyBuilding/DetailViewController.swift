
import UIKit
import SafariServices
import CoreData


class DetailViewController: UIViewController {
    
    // 이전 뷰에서 받을 데이터
    var titleName: String?
    var imageName: String?
    var descrip: String?
    var url: String?
    
    var addButtonBool: Bool?
    
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
    
    @IBOutlet weak var addButton: UIButton!{
        didSet{
            if addButtonBool == false{
                addButton.isEnabled = false
            }
        }
    }
    
    @IBAction func urlButtonAction(_ sender: UIButton) {
        let setUrl = NSURL(string: url!)
        let moveUrl: SFSafariViewController = SFSafariViewController(url: setUrl! as URL)
        self.present(moveUrl, animated: true)
    }
    
    @IBAction func basketButtonAction(_ sender: UIButton) {
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "MyProgram",
                                                                 in: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext) else {return} //coreData entity 정의
        
        MyProgramViewController.MakeBasketData().makeBasketData() //장바구니 전체 데이터 read
        
        if MyProgramViewController.basketModel.isEmpty { // 장바구니 데이터가 없을 시, coreData에 데이터 삽입
            insertData(object: NSManagedObject(entity: entityDescription,
                                               insertInto: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext))
        }
        else{
            var count = 0
            for data in MyProgramViewController.basketModel{
                
                if (data.title == self.titleName){ //중복시 중복 다이얼로그 생성
                    divideAlert(duplicated: true)
                }
                else{
                    count += 1
                    if count == MyProgramViewController.basketModel.count{ //전체 순회하였을 시(중복이 없을 시) coreData에 데이터 삽입
                        insertData(object: NSManagedObject(entity: entityDescription,
                                                           insertInto: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext))
                    }
                }
            }
        }
    }
    
    // Alert Dialog 생성
    func makeAlertDialog(title: String, message: String, duplicatedBool: Bool){
        
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let alertSuccessBtn = UIAlertAction(title: "OK", style: .default) { (action) in
            let myProgramVC = UIStoryboard(name: "MyProgramViewController", bundle:  nil).instantiateViewController(withIdentifier: "MyProgramViewController") as! MyProgramViewController
            self.present(myProgramVC, animated: true) //이동
        }
        
        let alertDeleteBtn = UIAlertAction(title: "Cancel", style: .destructive) { (action) in //.destructive -> 글씨 빨갛게
        }
        
        if(duplicatedBool == true) { // Dialog에 버튼 추가
            alert.addAction(alertDeleteBtn)
        }
        else {
            alert.addAction(alertDeleteBtn)
            alert.addAction(alertSuccessBtn)
        }
        
        self.present(alert, animated: true, completion: nil) // 화면에 출력
    }
    
    func divideAlert(duplicated: Bool){ //true -> basket duplicated(중복) 다이얼로그, false -> basket add 다이얼로그
        return duplicated ? makeAlertDialog(title: "Notice", message: "Duplicated Data", duplicatedBool: true) : makeAlertDialog(title: "Notice", message: "Added to basket.                               Move to basket page ?", duplicatedBool: false)
    }
    
    func insertData(object: NSManagedObject) {
        if let myProgram = object as? MyProgram { //MyProgram entity 존재 시, unwrapping 후 coreData에 데이터 insert
            myProgram.title = self.titleName //
            myProgram.image = self.imageName
            myProgram.description_ = self.descrip
            myProgram.url = self.url
            myProgram.division = self.imageName //bodybuilding, powerbuilding, powerlifting 의 구분자 역활
            
            divideAlert(duplicated: false)
            do{
                try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save() //insert 적용
            }
            catch{
                print(error)
            }
        }
        else{
            print("Entity not exist ")
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
}
