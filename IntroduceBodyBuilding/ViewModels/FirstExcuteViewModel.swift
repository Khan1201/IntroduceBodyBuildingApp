import Foundation
import RxSwift
import RxCocoa

class FirstExcuteViewModel {
    
    // 전체루틴보기 VC에 사용
    lazy var fromExecutionGuide: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    // 최초실행 VC에 사용
    lazy var benchPressObservable: BehaviorRelay<String> = BehaviorRelay(value: "")
    lazy var deadLiftObservable: BehaviorRelay<String> = BehaviorRelay(value: "")
    lazy var squatObservable: BehaviorRelay<String> = BehaviorRelay(value: "")
    lazy var completionObservable: BehaviorSubject<Bool> = BehaviorSubject(value: false)

    lazy var isValid: Observable<Bool> = {
        return Observable.combineLatest(benchPressObservable, deadLiftObservable, squatObservable)
            .map { benchPress, deadLift, squat in
                return !benchPress.isEmpty && !deadLift.isEmpty && !squat.isEmpty
            }
    }()
    
    // 둘 다 공통으로 사용
    lazy var detectFirstExecution = true
    var currentIndex = 0
    var firstExcuteMaxIndex: Int{
        return firstExcuteimageNamesArray.count - 1 + 1 // index화 -> 새로운 UI를 위해 +1 적용
    }
    var executionGuideMaxIndex: Int{
        return executionGuideImageNamesArray.count - 1
    }
    
    var initialTitle: String {
        var temp: String
        if detectFirstExecution{
            temp = "시작하기"
        }
        else{
            temp = "실행 가이드"
        }
        return temp
    }
    var initialImageName: String{
        var temp: String
        if detectFirstExecution{
            temp = firstExcuteimageNamesArray[0]
        }
        else{
            temp = executionGuideImageNamesArray[0]
        }
        return temp
    }
    
    lazy var firstExcuteimageNamesArray: [String] =
    ["firstExecution1", "firstExecution2", "firstExecution3", "firstExecution4"]
    
    lazy var firstExcuteNotice1: String =
    """
    다양한 프로그램을
    즐겨 보세요.
    """
    
    lazy var firstExcuteNotice2: String =
    """
    자신의 1RM을
    적용하고
    메모 해보세요.
    """
    
    lazy var firstExcuteNotice3: String =
    """
    자주보는 프로그램을
    등록 해보세요.
    """
    
    lazy var firstExcuteNotice4: String =
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
