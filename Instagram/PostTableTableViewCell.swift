//
//  PostTableTableViewCell.swift
//  Instagram
//
//  Created by 青木亮祐 on 2020/01/20.
//  Copyright © 2020 ryosuke.aoki. All rights reserved.
//

import UIKit
import FirebaseUI

class PostTableTableViewCell: UITableViewCell {

    @IBOutlet weak var postImageView: UIImageView!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var likeLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var captionLabel: UILabel!
    
    @IBOutlet weak var commentButton: UIButton!  // 課題で追加
    
    @IBOutlet weak var commentContents: UILabel! // 課題で追加
    
    
    // 自動で作成
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    // 自動で作成
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // PostDataクラスのプロパティ内容をセルに表示
    func setPostData(_ postData: PostData) {
        // 画像の表示
        // FirebaseUIに統合されたSDWebImageフレームワークの定義するプロパティ
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePathe).child(postData.id + ".jpg")
        // これもSDWebImageフレームワークの定義するメソッド
        postImageView.sd_setImage(with: imageRef)

        // キャプションの表示
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"

        // 日時の表示
        self.dateLabel.text = ""
        // オプショナルバインディング
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
        }

        // いいね数の表示 countは、配列の要素数を示すプロパティ
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"

        // いいねボタンの表示
        if postData.isLiked { // islikedがBool型のためこういう記載
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        } else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
        
        // コメントの表示
        // 配列として入っているコメントを１つずつ取り出してラベルに貼る
        let array = postData.comments
        // 以下は、スナップショットで無用に繰り返される場合に備えて、いったんラベルtextをリセットしてからコメント配列の全要素を+=で代入
        self.commentContents.text? = ""
        for comment in array {
            self.commentContents.text? += "\(comment)\n"
        }
    }
    
}
