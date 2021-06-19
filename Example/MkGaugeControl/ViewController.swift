//
//  ViewController.swift
//  MkGaugeControl
//
//  Created by manojkarkie@gmail.com on 06/19/2021.
//  Copyright (c) 2021 manojkarkie@gmail.com. All rights reserved.
//

import UIKit
import MkGaugeControl

class ViewController: UIViewController {

    @IBOutlet weak var gaugeView: MKGaugeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        gaugeView.layer.borderWidth = 1.0
//        gaugeView.layer.borderColor = UIColor.orange.cgColor
    }

    @IBAction func animte(_ sender: Any) {
        gaugeView.maxGaugeLimit = 100000
        gaugeView.needleValue = 75000
        gaugeView.animateNeedle()
    }

}

