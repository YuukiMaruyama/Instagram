//
//  PostCommentViewController.swift
//  Instagram
//
//  Created by まるやまゆうき on 2019/04/18.
//  Copyright © 2019 yuuki.maruyama. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class PostCommentViewController: UIViewController {

    // コメントを登録するデータ
    var postData: PostData?
    
    @IBOutlet weak var commentText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func postComment(_ sender: Any) {
        
        let user = Auth.auth().currentUser
        
        // Firebaseに保存するデータの準備
        let comment: String = "【" + String(user!.displayName!) + "】" + commentText.text!
        postData!.comments.append(comment)

        // commentをFirebaseに保存する
        let postRef = Database.database().reference().child(Const.PostPath).child(postData!.id!)
        let comments = ["comments": postData!.comments]
        postRef.updateChildValues(comments)
    }
}
