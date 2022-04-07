//
//  SMSCodeViewController.swift
//  ChatApp
//
//  Created by Владимир on 22.09.2021.
//  Copyright © 2021 Владимир. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

class SMSCodeViewController: UIViewController, UITextFieldDelegate {
    let codeField: UITextField = {
        var txtField = UITextField()
        txtField.keyboardType = .phonePad
        txtField.textColor = .systemFill
        txtField.font = UIFont.init(name: "HelveticaNeue", size: 18)
        txtField.placeholder = "Enter Code"
        txtField.clearButtonMode = .always
        return txtField
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(codeField)
        codeField.frame = CGRect(x: 0, y: 0, width: 220, height: 50)
        codeField.center = view.center
        codeField.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(nextButton))
    }
    
    @objc func nextButton() -> Bool {
        codeField.resignFirstResponder()
        if let text = codeField.text, !text.isEmpty{
            let code = text
            
            AuthManager.shared.verifyCode(smsCode: code) { [weak self] succes in
                guard succes else {return}
                DispatchQueue.main.async {
                    UserDefaults.standard.set(FirebaseAuth.Auth.auth().currentUser?.phoneNumber, forKey: "phone")
                    let vc = UserInfoController()
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
        return true
    }    
}
