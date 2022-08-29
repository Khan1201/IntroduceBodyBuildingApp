
import UIKit
import SafariServices
import CoreData


class DetailViewController: UIViewController {
    
    // 이전 뷰에서 받을 데이터
    var titleName: String?
    var imageName: String?
    var descrip: String?
    var url: String?
    
    var alertBool: Bool? // true -> basket add 다이얼로그, false -> basket duplicated(중복) 다이얼로그
    
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
    @IBOutlet weak var addButton: UIButton!
    
    // Alert Dialog 생성
    func makeAlertDialog(title: String, message: String, _ isAlert : Bool = true) throws  {
        
        // alert : 가운데에서 출력되는 Dialog. 취소/동의 같이 2개 이하를 선택할 경우 사용. 간단명료 해야함.
        let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
        // destructive : title 글씨가 빨갛게 변함
        // cancel : 글자 진하게
        // defaule : X
        let alertSuccessBtn = UIAlertAction(title: "OK", style: .default) { (action) in
            print("[SUCCESS] Dialog Success Button Click!")
            
            
            //해당 뷰 컨트롤러로 이동
            let myProgramVC = UIStoryboard(name: "MyProgramViewController", bundle: nil).instantiateViewController(withIdentifier: "MyProgramViewController") as! MyProgramViewController
            self.present(myProgramVC, animated: true)
        }
        let alertDeleteBtn = UIAlertAction(title: "Cancel", style: .destructive) { (action) in
            print("[SUCCESS] Dialog Cancel Button Click!")
        }
        
        // Dialog에 버튼 추가
        if(isAlert && self.alertBool == true) {
            alert.addAction(alertDeleteBtn)
            alert.addAction(alertSuccessBtn)
            
        }
        else {
            alert.addAction(alertDeleteBtn)
        }
        // 화면에 출력
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
    }
    
    @IBAction func urlButtonAction(_ sender: UIButton) {
        let setUrl = NSURL(string: url!)
        let moveUrl: SFSafariViewController = SFSafariViewController(url: setUrl! as URL)
        self.present(moveUrl, animated: true)
        
        
    }
    @IBAction func basketButtonAction(_ sender: UIButton) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext // coreData context 선언
        
        guard let entityDescription = NSEntityDescription.entity(forEntityName: "MyProgram", in: context) else {return} //coreData entity 정의
        
        
        do{
            let ls = MyProgramViewController.MakeBasketData()
            ls.makeBasketData() //장바구니 전체 데이터 read
            
            if MyProgramViewController.basketModel.isEmpty{ // 장바구니 데이터가 없을 시, coreData에 데이터 삽입
                guard let object = NSManagedObject(entity: entityDescription, insertInto: context) as? MyProgram else {return} // coreData에 데이터 삽입
                object.title = titleName
                object.image = imageName
                object.description_ = descrip
                object.url = url
                object.division = imageName //bodybuilding, powerbuilding, powerlifting 의 구분자 역활
                
                try context.save()
                try makeAlertDialog(title: "Notice", message: "Added to basket.                               Move to basket page ?") //다이얼로그 생성
                
            }
            
            else{
                var count = 0
                for data in MyProgramViewController.basketModel{
                    
                    if (data.title == self.titleName){ //중복시 중복 다이얼로그 생성
                        self.alertBool = false
                        try makeAlertDialog(title: "Notice", message: "Duplicated Data")
                    }
                    
                    else{
                        count += 1
                        if count == MyProgramViewController.basketModel.count{ //전체 순회하였을 시(중복이 없을 시) coreData에 데이터 삽입
                            guard let object = NSManagedObject(entity: entityDescription, insertInto: context) as? MyProgram else {return} // coreData에 데이터 삽입
                            
                            object.title = titleName
                            object.image = imageName
                            object.description_ = descrip
                            object.url = url
                            object.division = imageName //bodybuilding, powerbuilding, powerlifting 의 구분자 역활
                            
                            try context.save()
                            self.alertBool = true
                            try makeAlertDialog(title: "Notice", message: "Added to basket.                               Move to basket page ?")
                        }
                    }
                }
            }
        }
        catch{
            print(error)
        }
    }
    
    ////        delete
    //        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "MyProgram")
    //        fetchRequest.predicate = NSPredicate(format: "division = %@", "bodybuilding")
    //
    //        do {
    //                let test = try context.fetch(fetchRequest)
    //                print("테스트는 \(test)")
    //                let objectToDelete = test[0] as! NSManagedObject
    //                context.delete(objectToDelete)
    //                do {
    //                    try context.save()
    //                } catch {
    //                    print("오류는 \(error)")
    //                }
    //            } catch {
    //                print("오류는 \(error)")
    //            }
    //
    //        //해당 뷰 컨트롤러로 이동
    //        let myProgramVC = UIStoryboard(name: "MyProgramViewController", bundle: nil).instantiateViewController(withIdentifier: "MyProgramViewController") as! MyProgramViewController
    //
    //        self.present(myProgramVC, animated: true)
}

//}
