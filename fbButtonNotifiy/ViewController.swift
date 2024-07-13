//
//  ViewController.swift
//  fbButtonNotifiy
//
//  Created by Süha Karakaya on 2.07.2024.
//

import UIKit
import SpeedcheckerSDK

class ViewController: UIViewController {
    
    @IBOutlet weak var lbl: UILabel!
    var customPlayer: CustomAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customPlayer = CustomAudioPlayer()
        lbl.text = AppDelegate.response
    }


    @IBAction func stopButtonAction(_ sender: Any) {
        customPlayer?.send(false, completion: { res in
            AppDelegate.response = res
        })
        
    }
    @IBAction func startButtonAction(_ sender: Any) {
        customPlayer?.send(true, completion: { res in
            AppDelegate.response = res
        })
    }
}

