//
//  TestViewController.swift
//  MultimediaChat
//
//  Created by Tobias Frantsen on 12/11/2018.
//  Copyright © 2018 Tobias Frantsen. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, GifPickerDelegate {
    func getLink(_ url: String?) {
        debugPrint("TOBIASGIF\(url)")
    }
    

    @IBOutlet weak var test: ChatView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let test  = self.navigationController
        debugPrint(test)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
