//
//  CommentViewController.swift
//  Instagram
//
//  Created by まるやまゆうき on 2019/04/17.
//  Copyright © 2019 yuuki.maruyama. All rights reserved.
//

import UIKit

class CommentViewController: UIViewController {

    // コメントを表示するデータ
    var postData: PostData?
    
    @IBOutlet weak var commentTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var commentText = ""
        
        for i in 0..<postData!.comments.count {
            commentText = commentText + postData!.comments[i] + "\n"
        }
        
        commentTextView.text = commentText
    }
}
