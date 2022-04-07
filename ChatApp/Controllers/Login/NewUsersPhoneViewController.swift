//
//  ViewController.swift
//  ChatApp
//
//  Created by Владимир on 20.07.2021.
//  Copyright © 2021 Владимир. All rights reserved.
//

import UIKit
import SnapKit
import FirebaseAuth
import Firebase
import JGProgressHUD

class NewUsersPhoneViewController: UIViewController, SharedCountry, SharedNumCode, UITextFieldDelegate {
    func protocolNumberCode(nummber: String!) {
        numbCodeTxtField.text = "+\(nummber ?? "+")"
    }
    func protocolCountry(country: String!) {
        countryButton.setTitle(country ?? "Country", for: .normal)
    }
// MARK: Button Actions
    @objc func countryOpen() {
        let CountryVC = CountryViewController()
        navigationController?.pushViewController(CountryVC, animated: true)
        CountryVC.delegateCountry = self
        CountryVC.delegateCode = self
    }

    @objc func Cancel(){
        let ChatsVC = ConversationsViewController()
        navigationController?.pushViewController(ChatsVC, animated: true)
//        numbTxtField.text = nil
//        numbCodeTxtField.text = "+"
//        countryButton.titleLabel?.text = "Country" //????????
    }
    
    @objc func SendPhone() {
        if numbTxtField.text!.isEmpty{
            let alert = UIAlertController(title: "Uncorrect number",
                                          message: "Wright your phone number",
                                          preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok",
                                          style: UIAlertAction.Style.cancel,
                                          handler: { _ in
                
            }))
            self.present(alert, animated: true, completion: nil)
        }else {
            sendPhone()
            PhoneAuthProvider.provider().verifyPhoneNumber("\(numbCodeTxtField)\(numbTxtField)", uiDelegate: nil)
        }
    }
    func sendPhone() {
        numbCodeTxtField.resignFirstResponder()
        numbTxtField.resignFirstResponder()
        //let txtFld = ("\(numbCodeTxtField.text)\(numbTxtField.text)")
        if var text = numbTxtField.text, !text.isEmpty {
            text = numbCodeTxtField.text! + numbTxtField.text!
            let number = "\(text)"
            AuthManager.shared.startAuth(phoneNumber: number) { [weak self] succes in
                guard succes else {return}
                DispatchQueue.main.async {
                    let vc = SMSCodeViewController()
                    vc.title = "Enter code"
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialized()
        numbCodeTxtField.text = "+"
        initializeHideKeyboard()
        numbTxtField.delegate = self
        numbCodeTxtField.delegate = self
        navigationController?.navigationBar.barTintColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .done, target: self, action: #selector(SendPhone))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(Cancel))
    }
    
// MARK: UI
    let spinner = JGProgressHUD(style: .dark)
    
    let titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Your Phone"
        label.font = UIFont.init(name: "HelveticaNeue-Thin", size: 30)
        label.textColor = .placeholderText
        label.textAlignment = .center
        return label
    }()
    let subTitleLabel: UILabel = {
        var label = UILabel()
        label.text = "Please confirm your country code and enter your phone number."
        label.font = UIFont.init(name: "HelveticaNeue-Thin", size: 16)
        label.textColor = .placeholderText
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    let separator: UIView = {
        var view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    let countryButton: UIButton = {
        var button = UIButton()
        button.setTitle("Country", for: .normal)
        button.setTitleColor(.systemGray, for: .normal)
        button.setTitleColor(.systemGray3, for: .highlighted)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(countryOpen), for: .touchUpInside)
        return button
    }()
    let separator2: UIView = {
        var view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    let numbCodeTxtField: UITextField = {
        var txtField = UITextField()
        txtField.keyboardType = .phonePad
        txtField.textColor = .label
        txtField.font = UIFont.init(name: "HelveticaNeue", size: 18)
        
        //txtField.backgroundColor = .secondarySystemBackground
        return txtField
    }()
    let numbTxtField: UITextField = {
        var txtField = UITextField()
        txtField.keyboardType = .phonePad
        txtField.textColor = .label
        txtField.font = UIFont.init(name: "HelveticaNeue", size: 18)
        txtField.placeholder = "Your phone number"
        txtField.clearButtonMode = .always
        txtField.returnKeyType = .continue
        //txtField.backgroundColor = .secondarySystemBackground
        //ооооочеееень тусклый интерфейс почему?
        return txtField
    }()
    let vertSeparator: UIView = {
        var view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    let separator3: UIView = {
        var view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    let syncLabel: UILabel = {
        var label = UILabel()
        label.text = "Sync Contacts"
        label.font = UIFont.init(name: "HelveticaNeue-Thin", size: 16)
        label.textColor = .label
        label.textAlignment = .left
        return label
    }()
    let switchCont: UISwitch = {
        var swich = UISwitch()
        return swich
    }()
    
// MARK: Constraints
    private func initialized(){
        view.backgroundColor = .systemBackground
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(separator)
        view.addSubview(countryButton)
        view.addSubview(separator2)
        view.addSubview(numbCodeTxtField)
        view.addSubview(numbTxtField)
        view.addSubview(vertSeparator)
        view.addSubview(separator3)
        view.addSubview(syncLabel)
        view.addSubview(switchCont)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(100)
            make.centerX.equalToSuperview()
            make.width.equalTo(145)
            make.height.equalTo(38)
        }
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel).inset(50)
            make.width.equalTo(250)
            make.height.equalTo(38)
        }
        
        installSeparatorConstraint(separ: separator, equalTo: subTitleLabel.snp.top, inset: 100)
        
        countryButton.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalTo(separator).inset(16)
            make.width.equalTo(340)
            make.height.equalTo(25)
        }
        installSeparatorConstraint(separ: separator2, equalTo: countryButton.snp.bottom, inset: -16)
        
        numbCodeTxtField.snp.makeConstraints{ make in
            make.left.equalToSuperview().inset(30)
            make.top.equalTo(separator2).inset(16)
            make.width.equalTo(58)
            make.height.equalTo(25)
        }
        numbTxtField.snp.makeConstraints{ make in
            make.left.equalTo(vertSeparator).inset(8)
            make.top.equalTo(separator2).inset(16)
            make.bottom.equalTo(separator3).inset(16)
            make.width.equalTo(263)
            make.height.equalTo(25)
        }
        vertSeparator.snp.makeConstraints{ make in
            make.left.equalTo(numbCodeTxtField.snp.right).inset(0)
            make.top.equalTo(separator2).inset(0)
            make.width.equalTo(1)
            make.height.equalTo(58)
        }
        installSeparatorConstraint(separ: separator3, equalTo: vertSeparator.snp.bottom, inset: 0)
        
        syncLabel.snp.makeConstraints{ make in
            make.left.equalToSuperview().inset(20)
            make.top.equalTo(separator3).inset(25)
            make.width.equalTo(112)
            make.height.equalTo(22)
        }
        switchCont.snp.makeConstraints{ make in
            make.right.equalToSuperview().inset(20)
            make.top.equalTo(separator3).inset(25)
        }
    }
    
    func installSeparatorConstraint (separ: UIView, equalTo: ConstraintItem, inset: Int){
        separ.snp.makeConstraints{ make in
            make.left.equalToSuperview().inset(20)
            make.right.equalToSuperview().inset(0)
            make.top.equalTo(equalTo).inset(inset)
            make.width.equalTo(360)
            make.height.equalTo(1)
        }
    }
}

// MARK: Dismiss Keboard
extension NewUsersPhoneViewController {
    func initializeHideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
        action: #selector(dismissMyKeyboard))
        view.addGestureRecognizer(tap)
    }

    @objc func dismissMyKeyboard(){
        view.endEditing(true)
        if (numbCodeTxtField.text?.isEmpty == true){
            numbCodeTxtField.text = "+"
        }
    }
 }
//-----------------второй вариант функции instal separator через refactoring-------
//
//    fileprivate func installSeparator2(_ sep: UIView, _ eq: ConstraintItem, _ ins: Int) {
//        sep.snp.makeConstraints{ maker in
//            maker.left.equalToSuperview().inset(20)
//            maker.right.equalToSuperview().inset(0)
//            maker.top.equalTo(eq).inset(ins)
//            maker.width.equalTo(360)
//            maker.height.equalTo(1)
//        }
//    }

//        let sep = separator2
//        let eq = countryButton.snp.bottom
//        let ins = -16
//        installSeparator2(sep, eq, ins)
//---------------------------------------------------------------------------------
//--------------------Аттрибуты кнопок в Навигейшн баре----------------------------
//let navItem = UINavigationItem(title: "guuuhuihiuhuihiuhi")
//navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
//navBar.tintColor = .black //button color
//navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Дане", style: .plain, target: self, action: #selector(pressed))
//let doneItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.camera, target: self, action: #selector(pressed))
//----------------------------------------------------------------------------------
//--------------------Функция регистрации номера телефона в firebase нажимая return-
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        numbCodeTxtField.resignFirstResponder()
//        numbTxtField.resignFirstResponder()
//        if var text = textField.text, !text.isEmpty{
//            text = numbCodeTxtField.text! + numbTxtField.text!
//            let number = "\(text)"
//            AuthManager.shared.startAuth(phoneNumber: number) { [weak self] succes in
//                guard succes else {return}
//                DispatchQueue.main.async {
//                    let vc = SMSCodeViewController()
//                    vc.title = "Enter code"
//                    self?.navigationController?.pushViewController(vc, animated: true)
//                }
//            }
//        }
//        return true
//    }

