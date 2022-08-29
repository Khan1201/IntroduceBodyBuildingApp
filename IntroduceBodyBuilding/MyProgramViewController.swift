
import UIKit
import CoreData
import CoreAudio

class MyProgramViewController: UIViewController {
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MakeBasketData().makeBasketData()
        BBCollectionView.dataSource = self
        BBCollectionView.delegate = self
        
        PBCollectionView.dataSource = self
        PBCollectionView.delegate = self
        
        PLCollectionView.dataSource = self
        PLCollectionView.delegate = self
        
    }
    
}

class BBCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var BBimageView: UIImageView!{
        didSet{
            BBimageView.image = UIImage(named: "bodybuilding")
            BBimageView.layer.cornerRadius = BBimageView.bounds.width / 10
        }
    }
    
    @IBOutlet weak var BBTitleLabel: UILabel!
    
}

class PBCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var PBimageView: UIImageView!{
        didSet{
            PBimageView.image = UIImage(named: "powerbuilding")
            PBimageView.layer.cornerRadius = PBimageView.bounds.width / 10
        }
    }
    @IBOutlet weak var PBTitleLabel: UILabel!
}

class PLCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var PLimageView: UIImageView!{
        didSet{
            PLimageView.image = UIImage(named: "powerlifting")
            PLimageView.layer.cornerRadius = PLimageView.bounds.width / 10
        }
    }
    @IBOutlet weak var PLTitleLabel: UILabel!
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
            
            
            cell.BBTitleLabel.text = MyProgramViewController.bodybuildingModel[indexPath.row].title
            
            
            return cell
        }
        
        else if collectionView == PBCollectionView {
            let cell = PBCollectionView.dequeueReusableCell(withReuseIdentifier: "PBCollectionViewCell", for: indexPath) as! PBCollectionViewCell
            
            cell.PBTitleLabel.text = MyProgramViewController.powerbuildingModel[indexPath.row].title
            
            
            return cell
        }
        
        else {
            let cell = PLCollectionView.dequeueReusableCell(withReuseIdentifier: "PLCollectionViewCell", for: indexPath) as! PLCollectionViewCell
            
            cell.PLTitleLabel.text = MyProgramViewController.powerLiftingModel[indexPath.row].title
            
            
            return cell
        }
        
    }
}


