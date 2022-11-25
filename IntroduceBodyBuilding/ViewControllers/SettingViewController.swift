
import UIKit
import MessageUI

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
    @IBOutlet weak var darkModeSwitch: UISwitch!{
        didSet{
            // 기존 시스템 다크모드 감지, 다크모드 -> 스위치 on
            if self.traitCollection.userInterfaceStyle == .dark{
                darkModeSwitch.isOn = true
            }
            else{
                darkModeSwitch.isOn = false
            }
        }
    }
    
    
    @IBOutlet weak var keywordChangeView: UIView!
    @IBOutlet weak var requestView: UIView!
    @IBOutlet weak var guideView: UIView!
    
    @IBOutlet weak var currentVersionLabel: UILabel!{
        didSet{
            currentVersionLabel.text = "현재 버전 : \(getCurrentVersion())"
        }
    }
    @IBOutlet weak var latestVersionLabel: UILabel!{
        didSet{
            latestVersionLabel.text = "최신 버전 :"
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
    
    @IBAction func darkModeSwitchAction(_ sender: Any) {
        
        if let window = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            
            if #available(iOS 15.0, *) {
                let windows = window.windows.first
                
                // off -> on (눌렀을때 on)
                if darkModeSwitch.isOn{
                    windows?.overrideUserInterfaceStyle = .dark
                }
                
                // on -> off (눌렀을때 off)
                else{
                    windows?.overrideUserInterfaceStyle = .light
                }
            }
        }
        else if let window = UIApplication.shared.windows.first {
            
            if #available(iOS 13.0, *) {
                
                if darkModeSwitch.isOn{
                    window.overrideUserInterfaceStyle = .dark
                }
                else{
                    window.overrideUserInterfaceStyle = .light
                }
                
            }
        }
    }
    
    func addViewsAction(){
        keywordChangeViewAction()
        requestViewAction()
        guideViewAction()
        
        func keywordChangeViewAction(){
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeKeywords))
            keywordChangeView.addGestureRecognizer(tapGestureRecognizer)
        }
        
        func requestViewAction(){
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(requestImprovements))
            requestView.addGestureRecognizer(tapGestureRecognizer)
        }
        
        func guideViewAction(){
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(offerGuide))
            guideView.addGestureRecognizer(tapGestureRecognizer)
        }
        
        
    }
    
    @objc func changeKeywords(){
        print("키워드 체인지 VC 호출")
    }
    @objc func requestImprovements(){
        if MFMailComposeViewController.canSendMail() {
                let composeViewController = MFMailComposeViewController()
                composeViewController.mailComposeDelegate = self
                
                let bodyString = """
                                 [안내]
                                 서비스에 대한 문의사항이나 오류사항은 메일로 받고 있습니다.
                                 
                                 [피드백 정보]
                                 문의사항 해결을 위해 디바이스와 어플리케이션 정보를 수집합니다.
                                 
                                 [문의 내용]
                                 
                                 
                                 
                                 
                                 -------------------
                                 
                                 Device Model : \(self.getDeviceIdentifier())
                                 Device OS : \(UIDevice.current.systemVersion)
                                 App Version : \(self.getCurrentVersion())
                                 
                                 -------------------
                                 """
                composeViewController.setToRecipients(["qjrtm1245@gmail.com"])
                composeViewController.setSubject("<루틴모아> 문의 및 의견")
                composeViewController.setMessageBody(bodyString, isHTML: false)
                
                self.present(composeViewController, animated: true, completion: nil)
            
            } else {
                MakeFailMailAcessAlert()
            }
    }
    @objc func offerGuide(){
        guard let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FirstExcuteViewController") as? FirstExcuteViewController else {return}
        firstVC.modalPresentationStyle = .custom
        firstVC.transitioningDelegate = self
        firstVC.viewModel.fromSettingVC = true
        HalfModalPresentationController.dismissGestureFlag = true
        self.present(firstVC, animated: true)
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
        
        addViewsAction()
        
    }
    
}
//MARK: - Custom presentationController

extension SettingViewController: UIViewControllerTransitioningDelegate{
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

//MARK: - Mail 작성창 dismiss

extension SettingViewController: MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true)
    }
}

//MARK: - Mail 관련 함수들 (현재 버전, Device Identifier, Mail 앱 실행불가 Alert)

extension SettingViewController {
    
    // 현재 버전 가져오기
    func getCurrentVersion() -> String {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String else { return "" }
        return version
    }
    
    // Device Identifier 찾기
    func getDeviceIdentifier() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    // Mail 앱 실행할 수 없을 경우 Alert 생성
    func MakeFailMailAcessAlert(){
        let sendMailErrorAlert = UIAlertController(title: "메일 전송 실패", message: "메일을 보내려면 'Mail' 앱이 필요합니다. App Store에서 해당 앱을 복원하거나 이메일 설정을 확인하고 다시 시도해주세요.", preferredStyle: .alert)
        
        let goAppStoreAction = UIAlertAction(title: "App Store로 이동하기", style: .default) { _ in
           
            // 앱스토어로 이동하기(Mail)
            if let url = URL(string: "https://apps.apple.com/kr/app/mail/id1108187098"), UIApplication.shared.canOpenURL(url) {
                
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
                else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        let cancleAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        
        sendMailErrorAlert.addAction(goAppStoreAction)
        sendMailErrorAlert.addAction(cancleAction)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
}


