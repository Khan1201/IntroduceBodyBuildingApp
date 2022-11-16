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
//MARK: - Label 키워드 폰트 적용

extension UILabel{
    func bold() {
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
