
import UIKit
import CoreData
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {
    
    var addButtonBool: Bool?
    
    let disposeBag = DisposeBag()
    let detailVCIndexObservable = BehaviorSubject<DetailVCModel.Fields>(value: DetailVCModel.Fields())
    var url: String?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!{
        didSet{
            let attrString = NSMutableAttributedString(string: descriptionLabel.text!)
            let paragraphStyle = NSMutableParagraphStyle()
            
            descriptionLabel.lineBreakMode = .byWordWrapping
            descriptionLabel.numberOfLines = 0
            paragraphStyle.lineSpacing = 10
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            descriptionLabel.attributedText = attrString
        }
    }
    @IBOutlet weak var addRoutineButton: UIButton!{
        didSet{
            addRoutineButton.setTitle("See More...", for: .normal)
        }
    }
    @IBOutlet weak var addButton: UIButton!{
        didSet{
            if addButtonBool == false{ //장바구니에서 접근할시 버튼
                addButton.isEnabled = false
            }
        }
    }
    @IBAction func addRoutineButtonAction(_ sender: UIButton) {

    }
    @IBAction func basketButtonAction(_ sender: UIButton) { //CoreData에 데이터 삽입
        do{
            let myProgramObject = try getObject() //CoreData Entity인 MyProgram 정의
            MyProgramViewModel.coreData.isEmpty ? //CoreData에 데이터가 없을 시, 데이터 삽입
            insertData(in: myProgramObject) : insertDataAfterDuplicatedCheck(in: myProgramObject)
        }
        catch{
            print(error)
        }
        
        func getObject() throws -> NSManagedObject{
            let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            guard let myProgramEntity = NSEntityDescription.entity(forEntityName: "MyProgram", in: viewContext) else{
                throw setDataError.EntityNotExist } //CoreData entity 정의
            let myProgramObject = NSManagedObject(entity: myProgramEntity, insertInto: viewContext)
            return myProgramObject
        }
        
        func insertData(in object: NSManagedObject) {
            let myProgram = object as! MyProgram
            //MyProgram entity 존재 시, unwrapping 후 coreData에 데이터 insert
            detailVCIndexObservable
                .subscribe { data in
                    myProgram.title = data.element?.title //
                    myProgram.image = data.element?.image
                    myProgram.description_ = data.element?.description
                    myProgram.division = data.element?.image //bodybuilding, powerbuilding, powerlifting 의 구분자 역활
                }.disposed(by: disposeBag)
            
            divideAlert(duplicated: false) //보관함으로 이동 alert
            do{
                try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save() //insert 적용
            }
            catch{
                print("save error: \(error)")
            }
        }
        func insertDataAfterDuplicatedCheck(in myProgramObject: NSManagedObject){
            _ = MyProgramViewModel() //선언과 동시에 MyProgramViewModel.coreData 최신화
            var count = 0
            for data in MyProgramViewModel.coreData{
                if (data.title == titleLabel.text){ //중복시 중복 다이얼로그 생성
                    divideAlert(duplicated: true)
                }
                else{
                    count += 1
                    if count == MyProgramViewModel.coreData.count{ //전체 순회하였을 시(중복이 없을 시) coreData에 데이터 삽입
                        insertData(in: myProgramObject)
                    }
                }
            }
        }
        enum setDataError: Error{ //오류 정의
            case EntityNotExist
        }
    }
    
    func viewBinding() { //인덱스에 맞는 detailViewModel 데이터 바인딩
        detailVCIndexObservable.subscribe({[weak self] data in
            self?.titleLabel.text = data.element?.title ?? "sorry"
            self?.descriptionLabel.text = data.element?.description ?? "sorry"
            self?.imageView.image = UIImage(named: data.element?.image ?? "sorry")
        }).disposed(by: disposeBag)
    }
    
    func divideAlert(duplicated: Bool) -> Void { //true -> basket duplicated(중복) 다이얼로그, false -> basket add 다이얼로그
        return duplicated ?
        makeAlertDialog(title: "안내", message: "보관함에 이미 존재하는 프로그램입니다.", duplicatedBool: true) :
        makeAlertDialog(title: "안내", message: "보관함에 프로그램을 담았습니다.   보관함으로 이동하시겠습니까 ?", duplicatedBool: false)
        
        // Alert Dialog 생성
        func makeAlertDialog(title: String, message: String, duplicatedBool: Bool){
            let alert =  UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            if(duplicatedBool == true) { // Dialog에 버튼 추가
                alert.addAction(CancelButton())
            }
            else {
                alert.addAction(OKButton())
                alert.addAction(CancelButton())
            }
            self.present(alert, animated: true, completion: nil) // 화면에 출력
            
            func OKButton() -> UIAlertAction {
                let alertSuccessBtn = UIAlertAction(title: "OK", style: .default) { _ in
                    let myProgramVC = UIStoryboard(name: "MyProgramViewController", bundle:  nil).instantiateViewController(withIdentifier: "MyProgramViewController") as! MyProgramViewController
                    self.navigationController?.pushViewController(myProgramVC, animated: true)
                }
                return alertSuccessBtn
            }
            func CancelButton() -> UIAlertAction {
                let alertDeleteBtn = UIAlertAction(title: "Cancel", style: .destructive) { _ in } //.destructive -> 글씨 빨갛게
                return alertDeleteBtn
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewBinding()
    }
}


