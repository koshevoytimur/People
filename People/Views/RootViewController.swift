//
//  RootViewController.swift
//  People
//
//  Created by Тимур Кошевой on 27.10.2019.
//  Copyright © 2019 Тимур Кошевой. All rights reserved.
//

import UIKit

class RootViewController: UIViewController {

    var vSpinner = UIView.init(frame: .zero)
    var activityIndicator : UIActivityIndicatorView?
    var spinnerBack = UIView.init(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSpiner()
    }

    func createSpiner() {
        let radius : CGFloat = 24.0
        self.vSpinner = UIView.init(frame: self.view.bounds)
        self.vSpinner.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
        self.spinnerBack = GradientView.init(frame: CGRect(x: 0, y: 0, width: (radius*2), height: (radius*2)))
        self.spinnerBack.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.3)
        self.spinnerBack.layer.cornerRadius = radius
        self.spinnerBack.layer.borderColor = UIColor(white: 1.0, alpha: 0.8).cgColor
        self.spinnerBack.layer.borderWidth = 2.0
        self.spinnerBack.layer.masksToBounds = true
        activityIndicator = UIActivityIndicatorView.init(style: .large)
        self.spinnerBack.addSubview(activityIndicator!)
        self.vSpinner.addSubview(spinnerBack)
        activityIndicator?.center = self.spinnerBack.center
        spinnerBack.center = self.vSpinner.center
    }
    
    func showSpinner() {
        activityIndicator?.startAnimating()
        DispatchQueue.main.async {
            self.view.addSubview(self.vSpinner)
        }
    }
    
    func removeSpinner() {
        DispatchQueue.main.async {
            self.vSpinner.removeFromSuperview()
        }
    }
}

class GradientView: UIView {
    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

}
