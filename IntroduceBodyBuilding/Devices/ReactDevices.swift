import Foundation

import UIKit

extension FirstExcuteViewController {
    
    func reactDevice(){
        
        if DeviceManager.shared.isFourIncheDevices() || DeviceManager.shared.isFiveIncheDevices() {
            
            imageView.snp.makeConstraints { make in
                make.height.equalTo(250)
            }
            okButton.snp.makeConstraints { make in
                make.height.equalTo(33)
            }
            HalfModalPresentationController.firstExcuteVCHeight = 465 // customModal Height
        }
    }
}


extension MyProgramViewController {
    
    func reactDevice(){
        if DeviceManager.shared.isFourIncheDevices() || DeviceManager.shared.isFiveIncheDevices() {
            
            // Collection View
            adjustCollectionViewHeight(BBCollectionView)
            adjustCollectionViewHeight(PBCollectionView)
            adjustCollectionViewHeight(PLCollectionView)
            
            // Label
            bodyBuildingLabel.font = .systemFont(ofSize: 18, weight: .bold)
            powerBuildingLabel.font = .systemFont(ofSize: 18, weight: .bold)
            powerLiftingLabel.font = .systemFont(ofSize: 18, weight: .bold)
            
            
            func adjustCollectionViewHeight(_ collectionView: UICollectionView){
                collectionView.snp.makeConstraints { make in
                    make.height.equalTo(130)
                }
            }
        }
    }
}
extension BBCollectionViewCell {
    
    func reactDevice(){
        if DeviceManager.shared.isFourIncheDevices() || DeviceManager.shared.isFiveIncheDevices() {
            BBimageView.snp.makeConstraints { make in
                make.height.equalTo(90)
                make.width.equalTo(140)
            }
        }
    }
}
extension PBCollectionViewCell {
    
    func reactDevice(){
        if DeviceManager.shared.isFourIncheDevices() || DeviceManager.shared.isFiveIncheDevices() {
            PBimageView.snp.makeConstraints { make in
                make.height.equalTo(90)
                make.width.equalTo(140)
            }
        }
    }
}
extension PLCollectionViewCell {
    
    func reactDevice(){
        if DeviceManager.shared.isFourIncheDevices() || DeviceManager.shared.isFiveIncheDevices() {
            PLimageView.snp.makeConstraints { make in
                make.height.equalTo(90)
                make.width.equalTo(140)
            }
        }
    }
}
extension RoutineAddViewController {
    
    func reactDevice(fromRoutineVC: Bool = false){
        
        if DeviceManager.shared.isFourIncheDevices() || DeviceManager.shared.isFiveIncheDevices() {
            
            // 루틴 VC의 셀에서 호출 시
            if fromRoutineVC {
                pickerView.snp.makeConstraints { make in
                    make.height.equalTo(60)
                }
            }
            
            else{
                pickerView.snp.makeConstraints { make in
                    make.height.equalTo(100)
                }
            }
            
            // TextField
            adjustTextFieldHeight(programTextField)
            adjustTextFieldHeight(divisionTextField)
            adjustTextFieldHeight(targetTextField)
            adjustTextFieldHeight(totalPeriodTextField)
            
            programTextField.font = .systemFont(ofSize: 13)
            divisionTextField.font = .systemFont(ofSize: 13)
            targetTextField.font = .systemFont(ofSize: 13)
            totalPeriodTextField.font = .systemFont(ofSize: 13)
            
            // Button
            for button in dayButtons {
                button.snp.makeConstraints { make in
                    make.width.equalTo(60)
                    make.height.equalTo(24)
                    
                }
            }
            adjustButtonHeight(viewRoutineButton)
            adjustButtonHeight(routineDeleteButton)
                    
            // Label
            programLabel.font = .systemFont(ofSize: 12, weight: .semibold)
            divisionLabel.font = .systemFont(ofSize: 12, weight: .semibold)
            targetLabel.font = .systemFont(ofSize: 12, weight: .semibold)
            totalPeriodLabel.font = .systemFont(ofSize: 12, weight: .semibold)
            routineLabel.font = .systemFont(ofSize: 12, weight: .semibold)
            alarmLabel.font = .systemFont(ofSize: 12, weight: .semibold)
            
            func adjustButtonHeight(_ button: UIButton) {
                
                button.snp.makeConstraints { make in
                    make.height.equalTo(40)
                }
            }
            
            func adjustTextFieldHeight(_ textField: UITextField) {
               
                textField.snp.makeConstraints { make in
                    make.height.equalTo(22)
                }
            }
        }
    }
}
