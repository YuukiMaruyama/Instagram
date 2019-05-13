//
//  PostCommentViewController.swift
//  Instagram
//
//  Created by まるやまゆうき on 2019/04/18.
//  Copyright © 2019 yuuki.maruyama. All rights reserved.
//

import UIKit

class PostCommentViewController: UIViewController {

    // 入力された名前を入れる変数
    var data1:String = "0"
    
    @IBOutlet weak var comment: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func postComment(_ sender: Any) {
        print("TOTSUKA")
        print(comment.text!)
        print(data1)
    }
    
    
    
}
