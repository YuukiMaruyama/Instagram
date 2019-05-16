//
//  PostTableViewCell.swift
//  Instagram
//
//  Created by まるやまゆうき on 2019/04/03.
//  Copyright © 2019 yuuki.maruyama. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    // 追加機能　コメントを表示する
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentViewButton: UIButton!
    @IBOutlet weak var postCommentButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setPostData(_ postData: PostData) {
        self.postImageView.image = postData.image
        
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateString = formatter.string(from: postData.date!)
        self.dateLabel.text = dateString
        
        if postData.isLiked {
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        // 追加機能　コメントを表示する
        if (postData.comments.count == 0){
            commentViewButton.setTitle("", for:.normal)
            commentViewButton.isEnabled = false
            commentLabel.text = ("コメントはありません")
        } else {
            commentViewButton.setTitle(String(postData.comments.count) + "件のコメントを見る", for:.normal)
            commentViewButton.isEnabled = true
            commentLabel.text = ("コメント" + postData.comments[0])
        }
    }
}
