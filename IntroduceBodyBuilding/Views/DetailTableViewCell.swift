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
        let highlightedWords: Set<String> = ["벤치프레스", "클로즈그립 벤치프레스","스피드 벤치프레스", "정지 벤치프레스", "와이드그립 벤치프레스","펙덱 플라이", "덤벨 숄더 프레스", "와이드그립 시티드 로우", "와이드그립 풀업", "덤벨 오버헤드프레스", "해머컬", "스쿼트", "스피드 스쿼트", "정지 스쿼트", "데드리프트",  "컨벤셔널 데드리프트", "스모 데드리프트","싸이클", "중량 친업", "친업", "케이블 플라이", "프론트 스쿼트", "스피드 데드리프트", "바벨로우", "오버헤드프레스","비하인드 넥 프레스", "바벨컬", "무릎 굽히고 윗몸일으키기", "중량 풀업", "인버티드 로우", "중량 딥스", "펜들레이 로우", "덤벨 숄더프레스", "캠버드 바 컬", "라잉 트라이셉스 익스텐션", "핵 스쿼트", "레그 익스텐션", "스티프 레그 데드리프트", "레그컬", "시티드 레그컬", "스탠딩 카프레이즈", "시티드 카프레이즈", "시티드 케이블 로우", "덤벨 로우", "클로즈그립 풀 다운", "덤벨 벤치프레스", "업라이트 로우", "사이드 레터럴 레이즈", "돈키 카프레이즈", "시티드 카프레이즈", "덤벨 프레스", "인클라인 덤벨프레스", "인클라인 체스트프레스", "인클라인 케이블 플라이", "프리처 컬", "컨센트레이션 컬", "스파이더 컬", "캠버드 바 익스텐션", "케이블 프레스다운 로프", "케이블 킥백", "레그 프레스", "루마니안 데드리프트", "켐버드 바 익스텐션", "원암 덤벨로우", "디클라인 벤치프레스", "인클라인 이너 바이셉스 컬", "덤벨 컨센트레이션 컬", "덤벨 쓰로우백", "트라이셉스 풀 다운", "머신 체스트 플라이", "스탠딩 바벨 카프레이즈", "힙 어덕션", "렛풀다운", "암풀다운", "와이드그립 케이블로우", "힙 쓰러스트", "스탠딩 바벨 카프레이즈", "힙 어덕션", "덤벨 프리처컬", "트랩3 레이즈", "덤벨 슈러그", "프론트 레터럴 레이즈", "후면삼각근 머신플라이", "숄더프레스"]
        
        let fontSize = self.font.pointSize
        let font = UIFont.boldSystemFont(ofSize: fontSize)
        let fontColor = getColor()
        let fullText = self.text ?? ""
        
        let attributedString = NSMutableAttributedString(string: fullText)
        for highlightedWord in highlightedWords {
            let textRange = (fullText as NSString).range(of: highlightedWord)
            attributedString.addAttribute(.foregroundColor, value: fontColor, range: textRange)
            attributedString.addAttribute(.font, value: font, range: textRange)
        }
        self.attributedText = attributedString
        
        func getColor() -> UIColor{
            var colorCode: UIColor = .systemIndigo
            
            if let colorName = UserDefaults.standard.string(forKey: "color"){
                switch colorName{
                case "Indigo":
                    colorCode = .systemIndigo
                case "Blue":
                    colorCode = .systemBlue
                case "Brown":
                    colorCode = .systemBrown
                case "Gray":
                    colorCode = .systemGray
                case "Green":
                    colorCode = .systemGreen
                case "Orange":
                    colorCode = .systemOrange
                case "Pink":
                    colorCode = .systemPink
                case "Purple":
                    colorCode = .systemPurple
                case "Red":
                    colorCode = .systemRed
                case "Teal":
                    colorCode = .systemTeal
                case "Yellow":
                    colorCode = .systemYellow
                    
                default:
                    print("color 존재하지 않음")
                }
            }
            
          return colorCode
        }
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
