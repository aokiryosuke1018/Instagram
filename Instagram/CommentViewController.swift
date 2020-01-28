//
//  CommentViewController.swift
//  Instagram
//
//  Created by 青木亮祐 on 2020/01/26.
//  Copyright © 2020 ryosuke.aoki. All rights reserved.
//

import UIKit
import Firebase

class CommentViewController: UIViewController {

    var documentID:String?
    
    @IBOutlet weak var textView: UITextView!
    
    // コメントをfirebaseに保存する。
    // 遷移元から取得したdocumentIDのフィールドにcommentキーとその値を格納する。nilであれば格納。そうでなければ上書き。どうやる？
    // その上でHomeViewに戻る。
    @IBAction func ok(_ sender: UIButton) {
        let postRef = Firestore.firestore().collection(Const.PostPath).document(documentID!)
        
        let user = Auth.auth().currentUser?.displayName
        let text = self.textView.text!
        
        // document内のフィールドにcommentsがあるかどうかで場合分け
        // フィールドへの参照は、ドキュメントを取得する方法しかなさそう
        postRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if document.get("comments") != nil {
                    postRef.updateData([
                    "comments" : FieldValue.arrayUnion(["\(user!)" + " : " + text])
                    ])
                } else {
                    postRef.setData([
                        "comments":[]
                    ], merge: true)
                    postRef.updateData([
                        "comments" : FieldValue.arrayUnion(["\(user!)" + " : " + text])
                    ])
                }
            } else {
                print("ドキュメントは存在しません")
        }
        

        self.dismiss(animated: true, completion: nil)
        }
    }
    // モーダルビューを閉じる
    
    @IBAction func cancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        textView.layer.borderWidth = 0.5
        
        
        
    }
    

    /* commentの流れ
     （表層的）
    HomeViewControllerに表示されているPostTableTableViewCell内のcommentボタンをタップ
    すると、モーダルビューでCommentViewControllerが登場
    そこでテキストを入れてOKボタンでコメント内容がFirebaseに記録
　　　HomeViewControllerに戻る際にFirebaseに記録されたコメントが呼び出されPostTableTableViewCell内のTextViewに表示される
     （内部的）
     コメントについてもPostData（データが実際に表示される時のもの）の項目に挙げる。
　　　HomeViewControllerでsetPostDataが実行されるが、そのメソッドはPostTableTableViewCellで宣言されているので、その宣言内でCommentについても実装。
     
     */
    
    // 遷移元のデータのdocumentidを取得する。
    // その上で、当該idを持つdocumentのフィールドに、commentキーに値を追加していく
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

 }

