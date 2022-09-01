
import UIKit
import CoreData
import CoreAudio

class BBCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var BBimageView: UIImageView!{
        didSet{
            MyProgramViewController().setviewImage(imageView: BBimageView, imageName: "bodybuilding")
        }
    }
    
    @IBOutlet weak var BBTitleLabel: UILabel!
    
}

class PBCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var PBimageView: UIImageView!{
        didSet{
            MyProgramViewController().setviewImage(imageView: PBimageView, imageName: "powerbuilding")
        }
    }
    @IBOutlet weak var PBTitleLabel: UILabel!
}

class PLCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var PLimageView: UIImageView!{
        didSet{
            MyProgramViewController().setviewImage(imageView: PLimageView, imageName: "powerlifting")
        }
    }
    @IBOutlet weak var PLTitleLabel: UILabel!
} // <- storyboard ui


class MyProgramViewController: UIViewController {
    
    var basketTitle: String?
    var basketImageNmae: String?
    var basketDescription: String?
    var basketUrl: String?
    
    static let appdelegate = UIApplication.shared.delegate as! AppDelegate
    static var basketModel = [MyProgram]()
    
    static var rowCount = 0
    
    static var bodybuildingModel : [MyProgram] = []
    static var powerbuildingModel : [MyProgram] = []
    static var powerLiftingModel : [MyProgram] = []
    
    @IBOutlet weak var BBCollectionView: UICollectionView!{
        didSet{
            BBCollectionView.reloadData()
        }
    }
    @IBOutlet weak var PBCollectionView: UICollectionView!{
        didSet{
            PBCollectionView.reloadData()
        }
    }
    @IBOutlet weak var PLCollectionView: UICollectionView!{
        didSet{
            PLCollectionView.reloadData()
        }
    }
    
    class MakeBasketData {
        
        func makeBasketData() { //coreData에서 데이터 read
            let fetchRequest: NSFetchRequest<MyProgram> = MyProgram.fetchRequest()
            let context = appdelegate.persistentContainer.viewContext
            
            do{
                basketModel = try context.fetch(fetchRequest)
            }catch{
                print(error)
            }
        }
        
        func CheckDuplicated(division: String, divisionModel: inout [MyProgram]) -> [MyProgram] { //중복체크 로직, 중복되지 않은 배열을 return
            
            MyProgramViewController.rowCount = 0 //해당되는 데이터 개수만큼 콜렉션 뷰 셀 개수 반환
            divisionModel = []
            
            for data in MyProgramViewController.basketModel{
                if data.division == division{ // 데이터 구분 위해
                    
                    if divisionModel.isEmpty { //첫 데이터 삽입
                        divisionModel.append(data)
                        MyProgramViewController.rowCount += 1
                    }
                    else{
                        var titleCount = 0 //중복 체크 로직 (중복되지 않을시 카운트 +1)
                        for temp in divisionModel{
                            if temp.title != data.title{
                                titleCount += 1
                            }
                        }
                        if titleCount == divisionModel.count{ //카운트가 해당 모델 개수와 같을 시 (중복이 없을때) 데이터 삽입
                            divisionModel.append(data)
                            MyProgramViewController.rowCount += 1
                        }
                    }
                    
                }
            }
            return divisionModel
        }
    }
    
    class closeData: UIButton { //(selector에 파라미터 전달 위해 클래스 생성)
        var title: String?
        var view: UICollectionView?
        
        convenience init(title: String, view: UICollectionView){
            self.init() //버튼 활성화 위해 필수 uibutton()
            self.title = title
            self.view = view
        }
    }
    
    func moveDetailVC(model: [MyProgram],indexPath: IndexPath) {
        
        if let moveVC = UIStoryboard(name: "DetailViewController", bundle: nil).instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController{
            moveVC.titleName = model[indexPath.row].title
            moveVC.imageName = model[indexPath.row].image
            moveVC.descrip = model[indexPath.row].description_
            moveVC.url = model[indexPath.row].url
            moveVC.buttonBool = false
            self.present(moveVC, animated: true)
        }
    }
    
    
    
    func makeCloseButton(cell: UICollectionViewCell, title: String, view: UICollectionView){ //셀에 삭제 버튼 추가 함수
        let closeButton = closeData(title: title, view: view)
        closeButton.setImage(UIImage(systemName: "x.circle.fill"), for: .normal)
        closeButton.imageView?.tintColor = .systemRed
        closeButton.translatesAutoresizingMaskIntoConstraints = false //autolayout 사용 위해 false 필수
        
        closeButton.addTarget(self, action: #selector(ClickCloseButton(_:)), for: .touchUpInside)
        
        cell.addSubview(closeButton)
        
        closeButton.topAnchor.constraint(equalTo: cell.topAnchor, constant: 0).isActive = true
        closeButton.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 140).isActive = true
        closeButton.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -125).isActive = true
        closeButton.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 0).isActive = true
    }
    
    @objc func ClickCloseButton(_ sender: Any) {
        
        let title = (sender as! closeData).title //sender -> Any 선언 후 데이터가 담긴 클래스로 타입 캐스팅 후 접근
        let view = (sender as! closeData).view!
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        // coreData context 선언
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "MyProgram")
        fetchRequest.predicate = NSPredicate(format: "title = %@", title!) //데이터 조건 검색
        
        do { //coreData 데이터 삭제
            let test = try context.fetch(fetchRequest)
            print("테스트는 \(test)")
            let objectToDelete = test[0] as! NSManagedObject
            context.delete(objectToDelete)
            do {
                try context.save()
            } catch {
                print("오류는 \(error)")
            }
        } catch {
            print("오류는 \(error)")
        }
        
        view.reloadData()
    }
    
    func setviewImage(imageView: UIImageView, imageName: String){
        imageView.image = UIImage(named: imageName)
        imageView.layer.cornerRadius = imageView.bounds.width / 10
    }
    
    
    func setDelegateDataSource(collectionView: UICollectionView){
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MakeBasketData().makeBasketData()
        
        setDelegateDataSource(collectionView: BBCollectionView)
        setDelegateDataSource(collectionView: PBCollectionView)
        setDelegateDataSource(collectionView: PLCollectionView)
        
    }
    
}

extension MyProgramViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == BBCollectionView {
            
            MyProgramViewController.bodybuildingModel = MakeBasketData().CheckDuplicated(division: "bodybuilding", divisionModel: &MyProgramViewController.bodybuildingModel)
            
            return MyProgramViewController.rowCount
        }
        else if collectionView == PBCollectionView {
            
            MyProgramViewController.powerbuildingModel = MakeBasketData().CheckDuplicated(division: "powerbuilding", divisionModel: &MyProgramViewController.powerbuildingModel)
            
            return MyProgramViewController.rowCount
        }
        
        else {
            MyProgramViewController.powerLiftingModel = MakeBasketData().CheckDuplicated(division: "powerlifting", divisionModel: &MyProgramViewController.powerLiftingModel)
            
            return MyProgramViewController.rowCount
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == BBCollectionView {
            let cell = BBCollectionView.dequeueReusableCell(withReuseIdentifier: "BBCollectionViewCell", for: indexPath) as! BBCollectionViewCell
            
            makeCloseButton(cell: cell, title: MyProgramViewController.bodybuildingModel[indexPath.row].title!, view: collectionView)
            cell.BBTitleLabel.text = MyProgramViewController.bodybuildingModel[indexPath.row].title
            
            return cell
        }
        
        else if collectionView == PBCollectionView {
            let cell = PBCollectionView.dequeueReusableCell(withReuseIdentifier: "PBCollectionViewCell", for: indexPath) as! PBCollectionViewCell
            
            makeCloseButton(cell: cell, title: MyProgramViewController.powerbuildingModel[indexPath.row].title!, view: collectionView)
            cell.PBTitleLabel.text = MyProgramViewController.powerbuildingModel[indexPath.row].title
            
            return cell
        }
        
        else {
            let cell = PLCollectionView.dequeueReusableCell(withReuseIdentifier: "PLCollectionViewCell", for: indexPath) as! PLCollectionViewCell
            
            makeCloseButton(cell: cell, title: MyProgramViewController.powerLiftingModel[indexPath.row].title!, view: collectionView)
            cell.PLTitleLabel.text = MyProgramViewController.powerLiftingModel[indexPath.row].title
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == BBCollectionView {
            
            moveDetailVC(model: MyProgramViewController.bodybuildingModel, indexPath: indexPath)
        }
        
        else if collectionView == PBCollectionView {
            
            moveDetailVC(model: MyProgramViewController.powerbuildingModel, indexPath: indexPath)
        }
        else {
            moveDetailVC(model: MyProgramViewController.powerLiftingModel, indexPath: indexPath)
            
        }
    }
}

