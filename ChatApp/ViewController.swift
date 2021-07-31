//
//  ViewController.swift
//  ChatApp
//
//  Created by Владимир on 20.07.2021.
//  Copyright © 2021 Владимир. All rights reserved.
//

import UIKit
import SnapKit
//import SwiftUI

class ViewController: UIViewController {
    var selectCount = "Country"

    @objc func pressed() {
        let CountryVC = CountryViewController()
        CountryVC.modalPresentationStyle = UIModalPresentationStyle.popover
        present(CountryVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialized()
    }
    
    let titleLabel: UILabel = {
        var label = UILabel()
        label.text = "Your Phone"
        label.font = UIFont.init(name: "HelveticaNeue-Thin", size: 30)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label.textAlignment = .center
        return label
    }()
    
    let subTitleLabel: UILabel = {
        var label = UILabel()
        label.text = "Please confirm your country code and enter your phone number."
        label.font = UIFont.init(name: "HelveticaNeue-Thin", size: 16)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    let separator: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(red: 199/255, green: 199/255, blue: 200/255, alpha: 1)
        return view
    }()
    
    let countryButton: UIButton = {
        var button = UIButton()
        button.setTitle("Country", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.contentHorizontalAlignment = .left
        button.addTarget(self, action: #selector(pressed), for: .touchUpInside)
        return button
    }()
    
    
    private func initialized(){
        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(separator)
        view.addSubview(countryButton)
        
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
        separator.snp.makeConstraints{ maker in
            maker.left.equalToSuperview().inset(20)
            maker.right.equalToSuperview().inset(0)
            maker.top.equalTo(subTitleLabel.snp.top).inset(100)
            maker.width.equalTo(360)
            maker.height.equalTo(1)
        }
        countryButton.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalTo(separator).inset(20)
            make.width.equalTo(340)
            make.height.equalTo(25)
        }
    }
}



//--------------
//import UIKit
//import SnapKit
//
//class ViewController: UIViewController {
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        initialized()
//    }
//
//    private func initialized(){
//        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//
//        let titleLabel = UILabel()
//        titleLabel.text = "Your Phone"
//        titleLabel.font = UIFont.init(name: "HelveticaNeue-Thin", size: 30)
//        titleLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
//        titleLabel.textAlignment = .center
//        view.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints { maker in
//            maker.top.equalToSuperview().inset(100)
//            maker.centerX.equalToSuperview()
//            maker.width.equalTo(145)
//            maker.height.equalTo(38)
//        }
//
//        let subTitleLabel = UILabel()
//        subTitleLabel.text = "Please confirm your country code and enter your phone number."
//        subTitleLabel.font = UIFont.init(name: "HelveticaNeue-Thin", size: 16)
//        subTitleLabel.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
//        subTitleLabel.textAlignment = .center
//        subTitleLabel.numberOfLines = 0
//        view.addSubview(subTitleLabel)
//        subTitleLabel.snp.makeConstraints{ maker in
//            maker.centerX.equalToSuperview()
//            maker.top.equalTo(titleLabel).inset(50) //при значении 16 почти налипает
//            maker.width.equalTo(250)
//            maker.height.equalTo(38)
//        }
//
//        separator(topEqualTo: subTitleLabel)
//
//    }
//    private func separator(topEqualTo: UILabel ) {
//        let separator = UIView()
//        separator.backgroundColor = UIColor(red: 199/255, green: 199/255, blue: 200/255, alpha: 1)
//        view.addSubview(separator)
//        separator.snp.makeConstraints{ maker in
//            maker.left.equalToSuperview().inset(20)
//            maker.right.equalToSuperview().inset(0)
//            maker.top.equalTo(topEqualTo).inset(100)
//            maker.width.equalTo(360)
//            maker.height.equalTo(1)
//        }
//    }
//}
