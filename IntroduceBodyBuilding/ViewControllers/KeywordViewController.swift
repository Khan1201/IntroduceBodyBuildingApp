
import UIKit

import RxSwift
import RxCocoa

class KeywordViewController: UIViewController {
    
    let viewModel = KeywordViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        bindTableView()
        addClickEvent()
    }
}

//MARK: - 테이블 뷰 바인딩 및 클릭 이벤트

extension KeywordViewController{
    func bindTableView(){
        
        viewModel.colorDataObservable
            .bind(to: self.tableView.rx.items(cellIdentifier: "KeywordTableViewCell", cellType: KeywordTableViewCell.self)) { (index, element, cell) in
                cell.checkImage.isHidden = true // 초기 체크이미지 히든으로 설정
                
                cell.colorLabel.text = element.colorName
                cell.colorView.backgroundColor = element.colorCode
                
                // UserDefaults의 컬러값과 현재 컬러값이 일치 -> 체크 이미지 hidden 제거
                guard let currentColor = UserDefaults.standard.string(forKey: "color") else {return}
                
                if element.colorName == currentColor{
                    cell.checkImage.isHidden = false
                }
            }.disposed(by: disposeBag)
        
    }
    func addClickEvent(){
        tableView.rx.modelSelected(KeywordViewModel.Keyword.self)
            .bind { [weak self] element in
                UserDefaults.standard.removeObject(forKey: "color")
                UserDefaults.standard.set(element.colorName, forKey: "color")
                
                
                self?.tableView.reloadData()
            }.disposed(by: disposeBag)
    }
}
