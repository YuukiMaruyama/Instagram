//
//  HomeViewController.swift
//  Instagram
//
//  Created by まるやまゆうき on 2019/03/28.
//  Copyright © 2019 yuuki.maruyama. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var postArray: [PostData] = []
    
    // DatabaseのobserveEventの登録状態を表す
    var observing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        // テーブルセルのタップを無効にする
        tableView.allowsSelection = false
        
        let nib = UINib(nibName: "PostTableViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // テーブル行の高さをAutoLayoutで自動調整する
        tableView.rowHeight = UITableView.automaticDimension
        // テーブル行の高さの概算値を背呈しておく
        // 高さ概算値 = 「縦横比1:1のUIImageViewの高さ(=画面幅)」+「いいねボタン、キャプションラベル、その他余白の高さの合計概算(=100pt)」
        tableView.estimatedRowHeight = UIScreen.main.bounds.width + 100
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        if Auth.auth().currentUser != nil {
            if self.observing == false {
                // 要素が追加されたらpostA rraに追加してTableViewを再表示する
                let postsRef = Database.database().reference().child(Const.PostPath)
                postsRef.observe(.childAdded, with: { snapshot in
                    print("DEBUG_PRINT: .childAddedイベントが発生しました。")
                    
                    // PostDataクラスを生成して受け取ったデータを設定する
                    if let uid = Auth.auth().currentUser?.uid {
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        self.postArray.insert(postData, at: 0)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                // 要素が変更されたら該当のデータをpostArrayから一度削除した後に新しいデータを追加してTableViewを再表示する
                postsRef.observe(.childChanged, with: { snapshot in
                    print("DEBUG_PRINT: .childChangedイベントが発生しました。")
                    
                    if let uid = Auth.auth().currentUser?.uid {
                        // PostDataクラスを生成して受け取ったデータを設定する
                        let postData = PostData(snapshot: snapshot, myId: uid)
                        
                        // 保持している配列からidが同じものを探す
                        var index: Int = 0
                        for post in self.postArray {
                            if post.id == postData.id {
                                index = self.postArray.index(of: post)!
                                break
                            }
                        }
                        
                        // 差し替えるため一度削除する
                        self.postArray.remove(at: index)
                        
                        // 削除したところに更新済みのデータを追加する
                        self.postArray.insert(postData, at: index)
                        
                        // TableViewを再表示する
                        self.tableView.reloadData()
                    }
                })
                
                // DatabaseのobserveEventが上記コードにより登録されたため
                // trueとする
                observing = true
            }
        } else {
            if observing == true {
                // ログアウトを検出したら、一旦テーブルをクリアしてオブザーバーを削除する
                // テーブルをクリアする
                postArray = []
                tableView.reloadData()
                // オブザーバーを削除する
                Database.database().reference().removeAllObservers()
                
                // DatabaseのobserveEventが上記コードにより解除されたため
                // falseとする
                observing = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableViewCell
        cell.setPostData(postArray[indexPath.row])
        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        
        // 追加機能　コメントを表示する
        // セル内のボタンのアクションをソースコードで設定する
        cell.postCommentButton.addTarget(self, action:#selector(handleCommentButton(_:forEvent:)), for: .touchUpInside)
        cell.commentViewButton.addTarget(self, action:#selector(handleCommentViewButton(_:forEvent:)), for: .touchUpInside)
        
        return cell
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // Firebaseに保存するデータの準備
        if let uid = Auth.auth().currentUser?.uid {
            if postData.isLiked {
                // すでにいいねをしていた場合はいいねを解除するためIDを取り除く
                var index = -1
                for likeId in postData.likes {
                    if likeId == uid {
                        // 削除するためにインデックスを保持しておく
                        index = postData.likes.index(of: likeId)!
                        break
                    }
                }
                postData.likes.remove(at: index)
            } else {
                postData.likes.append(uid)
            }
            
            // 増えたlikesをFirebaseに保存する
            let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
            let likes = ["likes": postData.likes]
            postRef.updateChildValues(likes)
        }
    }
    
    // コメント機能の追加
    // セル内のコメントボタンがタップされた時に呼ばれるメソッド
    @objc func handleCommentButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: コメント登録ボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]

        // TODO
        // 画面遷移
print("TODO:コメント登録の画面に遷移する処理を書くよ")
        // コメント表示の画面を表示する
        let postCommentViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostComment")
        self.present(postCommentViewController!, animated: true, completion: nil)
        
        
        print("ICHIFUJI---")
        // 遷移先のPostCommentViewControllerで宣言している変数に値を代入して渡す
//        postCommentViewController.data1 = "1"
        
        // TODO
//        // Firebaseに保存するデータの準備
//        var comment: [String:String] = [:]
//        postData.comments.append(comment)
//
//        // commentをFirebaseに保存する
//        let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
//        let comments = ["comments": postData.comments]
//        postRef.updateChildValues(comments)

    }
    // コメントを表示する
    // セル内のコメントボタンがタップされた時に呼ばれるメソッド
    @objc func handleCommentViewButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: コメント表示ボタンがタップされました。")
        
        // タップされたセルのインデックスを求める
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]
        
        // TODO
        // 画面遷移
        print("TODO:コメント表示の画面に遷移する処理を書くよ")
        // コメント表示の画面を表示する
        let commentViewController = self.storyboard?.instantiateViewController(withIdentifier: "CommentView")
        self.present(commentViewController!, animated: true, completion: nil)
        


        // TODO
        //        // Firebaseに保存するデータの準備
        //        var comment: [String:String] = [:]
        //        postData.comments.append(comment)
        //
        //        // commentをFirebaseに保存する
        //        let postRef = Database.database().reference().child(Const.PostPath).child(postData.id!)
        //        let comments = ["comments": postData.comments]
        //        postRef.updateChildValues(comments)
        
    }
    
    // コメント機能の追加
    // コメントを登録するときに必要な情報を渡す
    // segueを使ってないから、このメソッド、呼ばれないんみたいなんだけど。ボタンを押したときに呼ばれるメソッドを使うのが正解では？
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // segueから遷移先のPostCommentViewControllerを取得する
        let postCommentViewController:PostCommentViewController = segue.destination as! PostCommentViewController
        // 遷移先のPostCommentViewControllerで宣言している変数に値を代入して渡す
        postCommentViewController.data1 = "1"
        
        print("KAWASAKI")
    }
    // 遷移した画面から戻ってくるとき
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
}
