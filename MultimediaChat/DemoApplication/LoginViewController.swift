//
//  LoginViewController.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 23/10/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//
import BRYXBanner
import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        SocketIOManager.shared.connectSocket()
        
        if let name = UserDefaults.standard.string(forKey: "userName") {
            let banner = Banner(title: "Last Login with \(name)", subtitle: "Change if you want", backgroundColor: .blue)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
            self.userNameTextField.text = name
            
        }
        // Do any additional setup after loading the view.
    }
    

    @IBAction func tapLogin(_ sender: Any) {
        
        guard let userName = self.userNameTextField.text, userName != "" else {
            return
        }
        
        
       let ack = SocketIOManager.shared.checkUserName(nickname: userName)
        
        ack?.timingOut(after: 5, callback: { (response) -> Void in
            if let ackString = response.first as? String {
                if ackString == "true" {
                    UserDefaults.standard.set(userName, forKey: "userName")
                    
                    SocketIOManager.shared.connectToServerWithUserName(nickname: userName)
                    
                    
                    if let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
                        if let navigator = self.navigationController {
                            viewController.userName = self.userNameTextField.text
                            navigator.pushViewController(viewController, animated: true)
                        }
                    }
                } else {
                    let banner = Banner(title: "\(userName) is taken", subtitle: "Try another name", backgroundColor: .red)
                    banner.dismissesOnTap = true
                    banner.show(duration: 3.0)
                }
            }
            
          
        })
        
        
       
    }
    

}
