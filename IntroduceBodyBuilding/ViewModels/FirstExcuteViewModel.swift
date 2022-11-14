import Foundation
import RxSwift

class FirstExcuteViewModel {
    
    lazy var detectFirstExecution = true
    lazy var fromExecutionGuide: BehaviorSubject<Bool> = BehaviorSubject(value: false)

    var index = 0
    var title: String {
        var temp: String
        if detectFirstExecution{
            temp = "시작하기"
        }
        else{
            temp = "실행 가이드"
        }
        return temp
    }
    lazy var firstExcuteimageNamesArray: [String] = ["firstExecution1", "firstExecution2", "firstExecution3"]
    lazy var firstExcuteNotice1: String =
    """
    해당 프로그램을
    등록 해보세요.
    """
    
    lazy var firstExcuteNotice2: String =
    """
    자주보는 프로그램을
    등록 해보세요.
    """
    
    lazy var firstExcuteNotice3: String =
    """
    루틴을 등록하여
    알람을 받아보세요.
    """
    
    lazy var executionGuideImageNamesArray: [String] = ["ExecutionGuide1", "ExecutionGuide2", "ExecutionGuide3"]
    lazy var executionGuideNotice1: String =
    """
    '기타'를
    누르세요.
    """
    
    lazy var executionGuideNotice2: String =
    """
    맨 오른쪽의
    '더 보기'를 누르세요.
    """
    
    lazy var executionGuideNotice3: String =
    """
    '스프레드 시트'를
    선택하세요.
    """

}
