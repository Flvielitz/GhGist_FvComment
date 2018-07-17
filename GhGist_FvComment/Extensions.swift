//
//  Extensions.swift
//  GhGist_FvComment
//
//  Created by Philliph on 15/07/18.
//  Copyright © 2018 Philliph. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func CustomDarkOne() -> UIColor {
        return colorFromRGB(red: 37, green: 51, blue: 62)
    }
    static func CustomDarkTwo() -> UIColor {
        return colorFromRGB(red: 67, green: 81, blue: 92)
    }
    
    static func ViewsColor() -> UIColor {
        return colorFromRGB(red: 145, green: 187, blue: 197)
    }
    
    static func CustomLightBlueNav() -> UIColor {
        return UIColor(red: 0.7686, green: 0.8196, blue: 0.8705, alpha: 1.0)
    }
    
    static func colorFromRGB(red: Int, green: Int, blue: Int) -> UIColor {
        return UIColor(red: CGFloat(Float(red) / 255.0),
                       green: CGFloat(Float(green) / 255.0),
                       blue: CGFloat(Float(blue) / 255.0),
                       alpha: CGFloat(1.0))
    }
    
}

extension UIViewController {
    func presentAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    func presentAlertCancelWithCompletion(_ title: String, message: String, completion: ((UIAlertAction)->Void)? ) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: completion ))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: completion ))
        present(alert, animated: true, completion: nil )
        
    }
    
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}

extension UITextView {
    func setPreferences() {
        self.backgroundColor = .ViewsColor()
        self.clipsToBounds = true
        self.layer.cornerRadius = 12.0
    }
}
