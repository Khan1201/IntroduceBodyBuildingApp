//
//  SceneDelegate.swift
//  IntroduceBodyBuilding
//
//  Created by 윤형석 on 2022/08/16.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var sendOnlyScene: UIScene? // notification didReceive에서 사용할 Scene
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
//        checkAppFirstrunOrUpdateStatus(scene: scene)
        guard let _ = (scene as? UIWindowScene) else { return }
        sendOnlyScene = scene
        UNUserNotificationCenter.current().delegate = self
        checkAppFirstrunOrUpdateStatus(scene: scene)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}
//MARK: - 앱 최초 설치 감지, 최초 설치 -> 최초 설치 VC present

extension SceneDelegate{
    func checkAppFirstrunOrUpdateStatus(scene: UIScene) {
        
        let currentVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let versionOfLastRun = UserDefaults.standard.object(forKey: "VersionOfLastRun") as? String
        if versionOfLastRun == nil {
            setRootVC(scene)
        } else if versionOfLastRun != currentVersion {
        }
//        UserDefaults.standard.synchronize()
    }
    func setRootVC(_ scene: UIScene){
        if let windowScene = scene as? UIWindowScene{
            let window = UIWindow(windowScene: windowScene)
            guard let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else {return}
            firstVC.mainViewModel.firstExecution.onNext(true)
            let nav = UINavigationController(rootViewController: firstVC)
            window.rootViewController = nav
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}
//MARK: - 알림 수신 후 클릭 시 해당 VC로 바로 이동

extension SceneDelegate: UNUserNotificationCenterDelegate{

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // 알림 내용의 프로그램명 가져오기
        var body = response.notification.request.content.body
        let startIndex: String.Index = body.index(body.startIndex, offsetBy: 7)
        body = String(body[startIndex...])
        
        if let windowScene = sendOnlyScene as? UIWindowScene{
            let window = UIWindow(windowScene: windowScene)
            guard let firstVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController else {return}
            firstVC.mainViewModel.receivedNotification.onNext(body)
            let nav = UINavigationController(rootViewController: firstVC)
            window.rootViewController = nav
            self.window = window
            window.makeKeyAndVisible()
        }
        completionHandler()
    }
}
