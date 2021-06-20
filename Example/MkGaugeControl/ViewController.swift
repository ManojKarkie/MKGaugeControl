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
    
        gaugeView.leftGradientColor = UIColor.blue
        gaugeView.rightGradientColor = UIColor.red
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func animte(_ sender: Any) {
        gaugeView.maxGaugeLimit = 1000
        gaugeView.needleValue = 750
        gaugeView.animateNeedle()
    }

}

