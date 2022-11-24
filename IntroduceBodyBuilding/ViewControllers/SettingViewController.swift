
import UIKit
import RxSwift
import RxCocoa

class SettingViewController: UIViewController {

    let firstExcuteViewModel = FirstExcuteViewModel() // 최초실행 VC의 valid 로직 사용
    let disposeBag = DisposeBag()
    
    @IBOutlet weak var benchPressTextField: UITextField!{
        didSet{
            benchPressTextField.layer.masksToBounds = true
            benchPressTextField.layer.cornerRadius = 5
            benchPressTextField.layer.borderColor = UIColor.systemGray.cgColor
            benchPressTextField.layer.borderWidth = 1
            
            
            let existingValue = UserDefaults.standard.string(forKey: "benchPress")
            benchPressTextField.text = existingValue
            firstExcuteViewModel.benchPressObservable.accept(existingValue ?? "")
        }
    }
    
    @IBOutlet weak var deadLiftTextField: UITextField!{
        didSet{
            deadLiftTextField.layer.masksToBounds = true
            deadLiftTextField.layer.cornerRadius = 5
            deadLiftTextField.layer.borderColor = UIColor.systemGray.cgColor
            deadLiftTextField.layer.borderWidth = 1
            
            let existingValue = UserDefaults.standard.string(forKey: "deadLift")
            deadLiftTextField.text = existingValue
            firstExcuteViewModel.deadLiftObservable.accept(existingValue ?? "")
        }
    }
   
    @IBOutlet weak var squatTextField: UITextField!{
        didSet{
            squatTextField.layer.masksToBounds = true
            squatTextField.layer.cornerRadius = 5
            squatTextField.layer.borderColor = UIColor.systemGray.cgColor
            squatTextField.layer.borderWidth = 1
            
            let existingValue = UserDefaults.standard.string(forKey: "squat")
            squatTextField.text = existingValue
            firstExcuteViewModel.squatObservable.accept(existingValue ?? "")
        }
    }
    @IBOutlet weak var saveButton: UIButton!{
        didSet{
            saveButton.layer.masksToBounds = true
            saveButton.layer.cornerRadius = 10
        }
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        let benchPressWeight = benchPressTextField.text ?? ""
        let deadLiftWeight = deadLiftTextField.text ?? ""
        let squatWeight = squatTextField.text ?? ""
        
        UserDefaults.standard.removeObject(forKey: "benchPress")
        UserDefaults.standard.removeObject(forKey: "deadLift")
        UserDefaults.standard.removeObject(forKey: "squat")
        
        UserDefaults.standard.set(Int(benchPressWeight) ?? 0, forKey: "benchPress")
        UserDefaults.standard.set(Int(deadLiftWeight) ?? 0, forKey: "deadLift")
        UserDefaults.standard.set(Int(squatWeight) ?? 0, forKey: "squat")
        
        showToast(message: "저장 되었습니다.")
    }
    
    
    @IBAction func goBackButtonAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
  
    func bindTextFieldData(){
        benchPressTextField.rx.text
            .orEmpty
            .bind(to: firstExcuteViewModel.benchPressObservable)
            .disposed(by: disposeBag)
        
        deadLiftTextField.rx.text
            .orEmpty
            .bind(to: firstExcuteViewModel.deadLiftObservable)
            .disposed(by: disposeBag)
        
        squatTextField.rx.text
            .orEmpty
            .bind(to: firstExcuteViewModel.squatObservable)
            .disposed(by: disposeBag)
    }
    func showToast(font: UIFont = UIFont.systemFont(ofSize: 11, weight: .bold), message: String) {
        let toastLabel = UILabel()
        toastLabel.backgroundColor = .systemGray
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.numberOfLines = 2
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 6, delay: 0.5, options: .transitionCurlDown, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
        
        toastLabel.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.width.equalTo(130)
            make.bottom.equalTo(benchPressTextField.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboard()
        bindTextFieldData()
        
        firstExcuteViewModel.isValid
            .bind { [weak self] bool in
                self?.saveButton.isEnabled = bool
            }.disposed(by: disposeBag)
        
    }
    
    

}

