import Foundation
import RxSwift

class KeywordViewModel {
    let colorDataObservable: BehaviorSubject<[Keyword]> = BehaviorSubject(value: [])
    
    struct Keyword{
        let colorName: String
        let colorCode: UIColor
    }

    let colorName: [String] = ["Indigo","Blue", "Brown", "Gray", "Green", "Orange", "Pink", "Purple", "Red",
                               "Teal", "Yellow"]
    
    let colorCode: [UIColor] = [.systemIndigo, .systemBlue, .systemBrown, .systemGray, .systemGreen,.systemOrange,
                                .systemPink, .systemPurple, .systemRed, .systemTeal, .systemYellow]
    
    init(){
        var keywordArray: [Keyword] = []
        
        for (index, _) in colorName.enumerated(){
            let element = Keyword(colorName: colorName[index], colorCode: colorCode[index])
            keywordArray.append(element)
        }
        
        colorDataObservable.onNext(keywordArray)
    }
    
}
