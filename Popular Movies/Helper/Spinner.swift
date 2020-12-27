//
//  SpinnerViewController.swift
//  Popular Movies
//
//  Created by Ramazan Öz on 26.12.2020.
//

import Foundation
import UIKit

class Spinner {
    static var spinner = UIActivityIndicatorView(style: .large)
    static var backgroundView: UIView!

    class func initSpinner() {
        backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(white: 0, alpha: 0.2)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        backgroundView.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
    }
    
    class func show() {
        DispatchQueue.main.async {
            initSpinner()
            let window = UIApplication.shared.windows.first!
            backgroundView.frame = window.bounds
            window.addSubview(backgroundView)
        }
    }
    
    class func dismiss() {
        DispatchQueue.main.async {
            let window = UIApplication.shared.windows.first!
            if self.backgroundView.isDescendant(of: window) {
                self.backgroundView.removeFromSuperview()
            }
        }
    }
}
