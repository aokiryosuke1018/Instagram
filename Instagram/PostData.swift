//
//  PostData.swift
//  Instagram
//
//  Created by 青木亮祐 on 2020/01/21.
//  Copyright © 2020 ryosuke.aoki. All rights reserved.
//

import UIKit
import Firebase

// postというより、データが実際に表示される時の項目を列挙。postされたデータを表示。
class PostData: NSObject {
    var id: String
    var name: String?
    var caption: String?
    var date: Date?
    var likes: [String] = [] // 配列ですよ！！！
    var isLiked: Bool = false
    var comments: [String] = [] // 課題で追加

    // Firestoreからデータを取得するとQueryDocumentSnapshotクラスのデータが渡されるとのこと
    init(document: QueryDocumentSnapshot) {
        self.id = document.documentID

        // QueryDocumentSnapshotクラスのメソッド。Dictionary型でデータをもらう。
        let postDic = document.data()

        // dictionaryの値へのアクセスの仕方。つまりキーを指定する。
        self.name = postDic["name"] as? String

        self.caption = postDic["caption"] as? String

        let timestamp = postDic["date"] as? Timestamp
        // dateValue()はtimestampクラスのメソッドで、新しく日時を取得。
        self.date = timestamp?.dateValue()

        // オプショナルバインディング
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        // オプショナルバインディング
        if let myid = Auth.auth().currentUser?.uid {
            // likesの配列の中にmyidが含まれているかチェックすることで、自分がいいねを押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                // myidがあれば、いいねを押していると認識する。
                // 具体的には、currentUserのIDの最初の文字があれば、true
                self.isLiked = true
            }
        }
        // コメント
        // オプショナルバインディング
        if let comments = postDic["comments"] as? [String] {
            self.comments = comments
        }
    }
}

/*
・likes
　まず、PostTableTableViewCellクラスで接続されているlikeLabelがある。
　このlikeLabelには、PostDataクラスの配列likesの要素数を表示すると決められている(上記PostTableTableViewCellクラスで決められている）。
　likesは、QueryDocumentSnapshotクラスのdata()でもらったデータ（辞書型）のうちlikesキーの値が入る(PostDataクラスで決められている）。
　likesをキーとする配列は、HomeViewControllerでクリックされた時に生成されることが決められている。
*/
