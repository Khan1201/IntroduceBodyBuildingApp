import UIKit

class HalfModalPresentationController: UIPresentationController {
    
    let blurEffectView: UIVisualEffectView!
    
    // ExcutionGuideVC로 호출 시 true, true -> tapGesture 추가
    static var dismissGestureFlag: Bool = false

    lazy var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentedViewController)
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        // ExcutionGuideVC로 호출 시 -> 주변 클릭으로 dismiss 가능, 최초실행VC로 호출 시 -> 주변 클릭으로 dismiss 불가
        if HalfModalPresentationController.dismissGestureFlag{
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
            self.blurEffectView.isUserInteractionEnabled = true
            self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
            HalfModalPresentationController.dismissGestureFlag = false
        }
    }
    @objc func dismissController() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }


    
    override var frameOfPresentedViewInContainerView: CGRect {
        CGRect(origin: CGPoint(x: 0,
                               y: self.containerView!.frame.height - self.containerView!.frame.height / 1.5),
               size: CGSize(width: self.containerView!.frame.width,
                            height: self.presentedView!.frame.height))
    }
    
    override func presentationTransitionWillBegin() {
        self.blurEffectView.alpha = 0
        self.containerView!.addSubview(blurEffectView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in self.blurEffectView.alpha = 0.7}, completion: nil)
    }
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in self.blurEffectView.alpha = 0}, completion: { _ in self.blurEffectView.removeFromSuperview()})
    }
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        blurEffectView.frame = containerView!.bounds
        presentedView?.layer.cornerRadius = 15
    }
}
