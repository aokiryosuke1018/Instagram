//
//  LoginViewController.swift
//  Instagram
//
//  Created by 青木亮祐 on 2020/01/08.
//  Copyright © 2020 ryosuke.aoki. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController{
    
    @IBOutlet weak var mailAdressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    // ログインボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleLoginButton(_ sender: Any) {
        if let address = mailAdressTextField.text, let password = passwordTextField.text{
            // アドレスとパスワード名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty {
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            Auth.auth().signIn(withEmail: address, password: password){ authResult, error in
                if let error = error {
                    print("DEBUG_PRINT:" + error.localizedDescription)
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")
                
                // HUDを消す
                SVProgressHUD.dismiss()
                
                // 画面を閉じてタブ画面に戻る
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // アカウント作成ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCreateAccountButton(_ sender: Any) {
        if let address = mailAdressTextField.text, let password = passwordTextField.text, let displayName = displayNameTextField.text{
            
            // アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                return
            }
            
            // HUDで処理中を表示
            SVProgressHUD.show()
            
            // アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする
            Auth.auth().createUser(withEmail: address, password: password)
            { authResult, error in
                // オプショナルバインディング
                if let error = error{
            //authResult, errorの部分は、クロージャを呼び出す時に渡す引数で、どのような引数が渡されるかは、createUserメソッドの仕様で決められています。 createUserメソッドのクロージャの場合、第一引数(authResult)に認証結果情報が渡され、第二引数(error)には、エラー発生時のエラー情報が渡されます。
            //エラーがあったら原因をprintして、returnすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT:" + error.localizedDescription)
                    return
            }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                // 表示名を設定する
                let user = Auth.auth().currentUser
                  // オプショナルバインディング
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges{ error in
                        if let error = error {
                            // プロフィールの更新でエラーが発生
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            return
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                        
                        // HUDを消す
                        SVProgressHUD.dismiss()
                        
                        // 画面を閉じてタブ画面に戻る
                            self.dismiss(animated:true, completion: nil)
                    }
                }
                    
                    
                    
                }
            }
        
            
        }
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
        
    }
    
    
    
    
    


