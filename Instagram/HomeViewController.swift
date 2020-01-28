//
//  HomeViewController.swift
//  Instagram
//
//  Created by 青木亮祐 on 2020/01/08.
//  Copyright © 2020 ryosuke.aoki. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    // 投稿データを格納する配列
    // PostDataは、PostData.swiftで宣言したもの
    // 配列変数の中に、クラスのインスタンスが複数生成される場所
    var postArray: [PostData] = []

    // Firestoreのリスナー
    // 投稿データを取得できるかの判定に使われる
    // データを取得できれば、postArrayに中身を入れることになる
    // 後の、addSnapshotListener()が、具体的にその判定を行う
    var listener: ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        // カスタムセルを登録する
        // nibはnibファイルのこと。nibは、Nextstep Interface Builderの略。
        // UINib()内でUINibクラスのイニシャライザの引数を指定している。
        let nib = UINib(nibName: "PostTableTableViewCell", bundle: nil)
        // Registers a nib object containing a cell with the table view under a specified identifier.
        tableView.register(nib, forCellReuseIdentifier: "Cell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")

        if Auth.auth().currentUser != nil {
            // ログイン済み
            if listener == nil {
                // listener未登録なら、登録してスナップショットを受信する
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
                // 投稿データの取得をできるかの判定に使われる
                listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    // ここでpostArrayに値が入る！！
                //それにより下のcell.setPostData(postArray[indexPath.row])が具体化する！
                    // map()は、Arrayメソッドで、配列の要素を変換して新しい配列を作成する。
                    self.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        // PostDataクラスのインスタンス化
                        let postData = PostData(document: document)
                        return postData
                    }
                    // TableViewの表示を更新する
                    self.tableView.reloadData()
                }
            }
        } else { // すなわちcurrentUserがnilであるということ
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                postArray = []
                tableView.reloadData()
            }
        }
    }
    
    
    // 必須のデリゲートメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArray.count
    }

    // 必須のデリゲートメソッド
    // IndexPathとは、データの位置情報を示す構造体
    // ここでのindexPathは、セル側の位置情報（どのセクションの何番めのrowか）を司る
    // セルの数だけ何度も呼び出されるメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得してデータを設定する
        // dequeue（デキュー）とは、キュー（先に入れたものが先に出る構造になっている何か）からデータを取り出すこと
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostTableTableViewCell
        // PostTableTableViewCellの型であるため、そのクラスで定義されたsetPostDataメソッドが利用できる
        // setPostDataは、PostDataクラスのプロパティと画像をセルに表示するメソッドだよ
        // 引数の値がpostArrayという、PostDataクラスを型にする配列
        // postArrayに値を入れるのは、上のviewWillAppear()にて。
        // indexPath.rowは、何番目のrowか示す。1回目の呼び出し時は0、2回目は1、3回目は2、4回目は、、、
        cell.setPostData(postArray[indexPath.row])

        
        // セル内のボタンのアクションをソースコードで設定する
        cell.likeButton.addTarget(self, action:#selector(handleButton(_:forEvent:)), for: .touchUpInside)
        
        // セル内のボタン(comment)のアクションをソースコードで設定する(課題追加）
        cell.commentButton.addTarget(self, action:#selector(commentMethod(_:forEvent:)), for: .touchUpInside)

        return cell
    }
    
    // セル内のボタンがタップされた時に呼ばれるメソッド
    @objc func handleButton(_ sender: UIButton, forEvent event: UIEvent) {
        print("DEBUG_PRINT: likeボタンがタップされました。")

        // タップされたセルのインデックスを求める
        // allTouchesはSetオブジェクト(集合体）であり、Set構造体にfirstプロパティがある
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)

        // 配列からタップされたインデックスのデータを取り出す
        let postData = postArray[indexPath!.row]

        // likesを更新する
        if let myid = Auth.auth().currentUser?.uid {
            // 更新データを作成する
            var updateValue: FieldValue
            if postData.isLiked {
                // すでにいいねをしている場合は、いいね解除のためmyidを取り除く更新データを作成
                updateValue = FieldValue.arrayRemove([myid])
            } else {
                // 今回新たにいいねを押した場合は、myidを追加する更新データを作成
                updateValue = FieldValue.arrayUnion([myid])
            }
            // likesに更新データを書き込む
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes": updateValue])
        }
    }
    
    // commentボタンがタップされた時のメソッド(課題追加）
    @objc func commentMethod(_ sender:UIButton, forEvent event:UIEvent){
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "comment") as! CommentViewController
        self.present(nextView, animated: true, completion: nil)
        
        // 当該セルを構成するデータのidを取得する
        // 先ずはタップされたセルのインデックスを取得
        let touch = event.allTouches?.first
        let point = touch!.location(in: self.tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        
        // 配列からタップされたインデックスのデータのIDを取得
        let postDataID = postArray[indexPath!.row].id
        // CommentViewControllerのdocumentIDプロパティに上記IDを格納
        nextView.documentID = postDataID
    }
    
}

/*
・データの投稿と取得と表示
（投稿）
PostViewControllerクラスで取り決め。
投稿場所を決め、setData()メソッドを利用。その引数は辞書。それぞれのキーに対する値は他の変数を参照して利用。
（取得）
HomeViewControllerクラスで取り決め。
もらう先の場所を決め、addSnapshotListenerメソッドで呼ばれたQuerySnapshotクラスたる引数として取得。
（表示）
PostData（表示される項目を列挙）クラスを型とする配列を宣言。
その配列に、取得したQuerySnapshot型のデータを、PostData型に変換して格納。
その配列は、同じくHomeViewController内のセルの内容を決めるメソッド内にある、setPostDataメソッド（これ自体はPostTableTableViewCellにて宣言）の実行によりセルの内容として表示される！
*/
