import Foundation
import UIKit

class DetailTableViewCell: UITableViewCell{
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var numberImageView: UIImageView!{
        didSet{
            numberImageView.layer.masksToBounds = true
            numberImageView.layer.cornerRadius = 5
        }
    }
    
    @IBOutlet weak var routinLabel: UILabel!{
        didSet{
            let attrString = NSMutableAttributedString(string: routinLabel.text!)
            let paragraphStyle = NSMutableParagraphStyle()
            
            routinLabel.lineBreakMode = .byWordWrapping
            routinLabel.numberOfLines = 0
            paragraphStyle.lineSpacing = 10
            attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            routinLabel.attributedText = attrString
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .systemGray5
    }
    
}
//MARK: - Label 키워드 폰트 적용, 밑줄 폰트 적용

extension UILabel{
    func bold() {
        let highlightedWords = ["벤치프레스", "클로즈그립 벤치프레스","스피드 벤치프레스", "정지 벤치프레스", "와이드그립 벤치프레스","펙덱 플라이", "덤벨 숄더 프레스", "와이드그립 시티드 로우", "와이드그립 풀업", "덤벨 오버헤드프레스", "해머컬", "스쿼트", "스피드 스쿼트", "정지 스쿼트", "데드리프트",  "컨벤셔널 데드리프트", "스모 데드리프트","싸이클", "중량 친업", "케이블 플라이", "프론트 스쿼트", "스피드 데드리프트", "바벨로우", "오버헤드프레스"]
        
        let fontSize = self.font.pointSize
        let font = UIFont.boldSystemFont(ofSize: fontSize)
        
        let fullText = self.text ?? ""
        
        let attributedString = NSMutableAttributedString(string: fullText)
        for highlightedWord in highlightedWords {
            let textRange = (fullText as NSString).range(of: highlightedWord)
            attributedString.addAttribute(.foregroundColor, value: UIColor.systemIndigo, range: textRange)
            attributedString.addAttribute(.font, value: font, range: textRange)
        }
        self.attributedText = attributedString
    }
    func lineColorAndLineSpacing(spacing: CGFloat) {
        //        let font = UIFont.boldSystemFont(ofSize: fontSize)
        let line = "-----------------------------------"
        let fullText = self.text ?? ""
        
        let attributedString = NSMutableAttributedString(string: fullText) // fulltext 기준
        var textAfterLine = fullText // line 이후의 또 다른 line에 접근 위해
        var index = 0 // 각 line의 start index
        
        let paragraphStyle = NSMutableParagraphStyle() // 라인 spacing 위해
        paragraphStyle.lineSpacing = spacing
        
        // fullText에서의 모든 line 글꼴 적용 (range(of:)는 첫번째 만족하는 것만 반환하고 나머지 중복된 것은 반환하지 않으므로)
        while true{
            if textAfterLine.contains(line){
                
                guard let lineRange = textAfterLine.range(of: line) else {return}
                let onlyText = textAfterLine[textAfterLine.startIndex..<lineRange.lowerBound]
                index += onlyText.count
                let fulltextOfLineRange = NSRange(location: index, length: 35)
                index += 35
                
                attributedString.addAttribute(.foregroundColor, value: UIColor.systemGray3, range: fulltextOfLineRange)
                textAfterLine = String(textAfterLine[lineRange.upperBound...])
                
            }
            else{
                attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
                break
            }
        }
        self.attributedText = attributedString
    }
}

//MARK: - TableViewCell의 % 무게 -> 자신의 무게로 대치

extension DetailViewController{
    
    func convertPercent(text: String) -> String{
        var textAfterBackSlash = text // 라인(\n)이후 텍스트에 접근 (초기값은 전체 text)
        var lineText: Substring // 라인(\n)별로 접근
        var resultText = "" // 라인(\n)별로 접근 했으므로, 라인별로 더하여 무게 적용한 결과로 전체 replace
        
        while true{
            if textAfterBackSlash.contains("\\n"){
                let lineRange = textAfterBackSlash.range(of: "\\n") //줄 바꿈(\n)의 index range
                lineText = textAfterBackSlash[textAfterBackSlash.startIndex..<lineRange!.upperBound] // ~ 줄 바꿈(\n)까지의 문자열
                
                if lineText.contains("벤치프레스") && lineText.contains("%"){
                    skipNextLineAfterApplyOwnWeight(type: "benchPress", lineText: &lineText)
                    continue
                }
                else if lineText.contains("데드리프트") && lineText.contains("%"){
                    skipNextLineAfterApplyOwnWeight(type: "deadLift", lineText: &lineText)
                    continue
                }
                else if lineText.contains("스쿼트") && lineText.contains("%"){
                    skipNextLineAfterApplyOwnWeight(type: "squat", lineText: &lineText)
                    continue
                }
                else{
                    resultText += lineText
                    textAfterBackSlash = String(textAfterBackSlash[lineText.endIndex...]) // 다음 라인(\n)으로 접근
                    continue
                }
            }
            
            // 마지막 문장에 접근
            else{
                if textAfterBackSlash.contains("벤치프레스") && textAfterBackSlash.contains("%"){
                    applyOwnWeightAtLastLine(type: "benchPress", lastLineText: &textAfterBackSlash)
                    break
                }
                else if textAfterBackSlash.contains("데드리프트") && textAfterBackSlash.contains("%"){
                    applyOwnWeightAtLastLine(type: "deadLift", lastLineText: &textAfterBackSlash)
                    break
                }
                else if textAfterBackSlash.contains("스쿼트") && textAfterBackSlash.contains("%"){
                    applyOwnWeightAtLastLine(type: "squat", lastLineText: &textAfterBackSlash)
                    break
                }
                else{
                    resultText += textAfterBackSlash
                    break
                }
            }
            
            // %kg -> 자신 무게로 적용 후 다음 라인(\n)에 접근
            func skipNextLineAfterApplyOwnWeight(type: String, lineText: inout Substring) {
                guard let percentIndex = lineText.firstIndex(of: "%") else {return} // % 문자 index
                
                let numberIndex = lineText.index(percentIndex, offsetBy: -2) // % 앞의 숫자 index
                let number = lineText[numberIndex..<(percentIndex)] // 두 개의 index -> % 앞의 숫자 (숫자만 해당)
                let replaceNumber = lineText[numberIndex...percentIndex] // 숫자 + % -> 무게로 대치위해 (숫자 + % 해당)
                
                guard let convertedFloat = Float(number) else {return}
                let convertedPercent = convertedFloat / 100 // % -> 백분율
                
                // 저장된 무게에 % 적용
                let appliedMaxWeight = Float(UserDefaults.standard.integer(forKey: type)) * convertedPercent
                
                let finalMaxWeight = roundInteger(Int(appliedMaxWeight)) // % 적용후의 무게 -> 반올림 적용
                
                // OO% -> OO로 변환
                lineText = Substring(lineText.replacingOccurrences(of: replaceNumber, with: " " + String(finalMaxWeight)))
                
                resultText += lineText // 라인(\n)별로 접근 했으므로, + 하여 무게 적용한 결과로 대치
                textAfterBackSlash = String(textAfterBackSlash[lineText.endIndex...]) // 다음 라인(\n)으로 접근
            }
            
            // 마지막 라인의 %kg -> 자신 무게로 적용
            func applyOwnWeightAtLastLine(type: String, lastLineText: inout String) {
                guard let percentIndex = lastLineText.firstIndex(of: "%") else {return}
                
                let numberIndex = lastLineText.index(percentIndex, offsetBy: -2)
                let number = lastLineText[numberIndex..<(percentIndex)]
                let replaceNumber = lastLineText[numberIndex...percentIndex]
                
                guard let convertedFloat = Float(number) else {return}
                let convertedPercent = convertedFloat / 100
                
                let appliedMaxWeight = Float(UserDefaults.standard.integer(forKey: type)) * convertedPercent
                let finalMaxWeight = roundInteger(Int(appliedMaxWeight)) // % 적용후의 무게 -> 반올림 적용
                lastLineText = lastLineText.replacingOccurrences(of: replaceNumber, with: " " + String(finalMaxWeight))
                resultText += lastLineText
            }
        }
        return resultText
    }
    
    func roundInteger(_ number: Int) -> Int{
        if number % 10 >= 5{
            return number - (number % 10) + 10
        }
        else{
            return number - (number % 10)
        }
    }
}
