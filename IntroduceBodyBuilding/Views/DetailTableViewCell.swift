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
        self.backgroundColor = .systemGray6
    }
    
}
//extension NSMutableAttributedString{
//    var fontSize: CGFloat {
//        return 14
//    }
//    var boldFont: UIFont {
//        return UIFont(name: "AvenirNext-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
//    }
//    var normalFont: UIFont {
//        return UIFont(name: "AvenirNext-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
//    }
//
//    func bold(string: String, fontSize: CGFloat, cellText: String) -> NSMutableAttributedString {
//
//        if cellText.contains(string){
//            let font = UIFont.boldSystemFont(ofSize: fontSize)
//            let attributes: [NSAttributedString.Key: Any] = [.font: font]
//            self.append(NSAttributedString(string: string, attributes: attributes))
//            return self
//        }
//        else{
//            let font = UIFont.systemFont(ofSize: 15, weight: .regular)
//            let attributes: [NSAttributedString.Key: Any] = [.font: font]
//            self.append(NSAttributedString(string: cellText, attributes: attributes))
//            return self
//        }
//
//    }
//
//    func regular(string: String, fontSize: CGFloat) -> NSMutableAttributedString {
//        let font = UIFont.systemFont(ofSize: fontSize)
//        let attributes: [NSAttributedString.Key: Any] = [.font: font]
//        self.append(NSAttributedString(string: string, attributes: attributes))
//        return self
//    }
//
//    func orangeHighlight(_ value:String) -> NSMutableAttributedString {
//
//        let attributes:[NSAttributedString.Key : Any] = [
//            .font: normalFont,
//            .foregroundColor: UIColor.white,
//            .backgroundColor: UIColor.orange
//        ]
//        self.append(NSAttributedString(string: value, attributes:attributes))
//        return self
//    }
//
//    func blackHighlight(_ value:String) -> NSMutableAttributedString {
//
//        let attributes:[NSAttributedString.Key : Any] = [
//            .font: normalFont,
//            .foregroundColor: UIColor.white,
//            .backgroundColor: UIColor.black
//
//        ]
//
//        self.append(NSAttributedString(string: value, attributes:attributes))
//        return self
//    }
//
//    func underlined(_ value:String) -> NSMutableAttributedString {
//
//        let attributes:[NSAttributedString.Key : Any] = [
//            .font: normalFont,
//            .underlineStyle : NSUnderlineStyle.single.rawValue
//        ]
//        self.append(NSAttributedString(string: value, attributes:attributes))
//        return self
//    }
//
//    func lineSpacing(_ value:String) -> NSMutableAttributedString{
//        let attrString = NSMutableAttributedString(string: value)
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 10
//        self.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
//        return self
//    }
//}
extension UILabel{
    func bold(targetString: String) {
        let highlightedWords = ["벤치프레스", "스피드 벤치프레스", "정지 벤치프레스", "와이드그립 벤치프레스","펙덱 플라이", "덤벨 숄더 프레스", "와이드그립 시티드 로우", "와이드그립 풀업", "덤벨 오버헤드프레스", "해머컬", "스쿼트", "스피드 스쿼트", "정지 스쿼트", "데드리프트", "싸이클", "중량 친업", "케이블 플라이", "프론트 스쿼트", "스피드 데드리프트"]

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
}
