//
//  UIViewController+Extensions.swift
//  LanguageTranslationAR
//
//  Created by Cesare de Cal on 26/12/2018.
//  Copyright © 2018 Cesare de Cal. All rights reserved.
//

import UIKit

extension UIViewController {
    var isModal: Bool {
        let presentingIsModal = presentingViewController != nil
        let presentingIsNavigation = navigationController?.presentingViewController?.presentedViewController == navigationController
        let presentingIsTabBar = tabBarController?.presentingViewController is UITabBarController
        return presentingIsModal || presentingIsNavigation || presentingIsTabBar || false
    }
    
    func presentErrorAlertController() {        
        let message = "The \(APIKeys.GoogleAPIKey.rawValue).txt file at root level either doesn't exist or contains an invalid key. Current contents: \(APIKeys.GoogleAPIKey.value ?? "None")"
        
        let alertController = UIAlertController(title: "Invalid Google API Key", message: message, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(confirmAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
