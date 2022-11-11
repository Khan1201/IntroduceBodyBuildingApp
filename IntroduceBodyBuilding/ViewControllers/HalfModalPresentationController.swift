//
//  HalfModalPresentationController.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/11/09.
//

import UIKit

class HalfModalPresentationController: UIPresentationController {
    
    let blurEffectView: UIVisualEffectView!
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    var check: Bool = false
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        let blurEffect = UIBlurEffect(style: .dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(presentedViewController: presentedViewController, presenting: presentedViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.blurEffectView.isUserInteractionEnabled = true
        self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
    }
    @objc func dismissController() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }

    
    override var frameOfPresentedViewInContainerView: CGRect {
        CGRect(origin: CGPoint(x: 0,
                               y: self.containerView!.frame.height - self.containerView!.frame.height / 1.5),
               size: CGSize(width: self.containerView!.frame.width,
                            height: (self.presentedView?.frame.height)!))
//        CGRect(origin: CGPoint(x: 0,
//                               y: self.containerView!.frame.height / 4 * 2),
//               size: CGSize(width: self.containerView!.frame.width,
//                            height: (self.presentedView?.frame.height)!))
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
