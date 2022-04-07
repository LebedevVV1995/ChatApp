//
//  CustomViewCellCountry.swift
//  
//
//  Created by Владимир on 04.09.2021.
//

import UIKit

class CustomViewCellCountry: UITableViewCell {
//    let backView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .blue
//        return view
//    }()
    
    let countryName: UILabel = {
        let name = UILabel()
        name.textAlignment = .left
        name.font = UIFont.boldSystemFont(ofSize: 16)
        return name
    }()
    
    let codeNum: UILabel = {
        let code = UILabel()
        code.textAlignment = .right
        code.font = UIFont.boldSystemFont(ofSize: 16)
        return code
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .clear
        backgroundColor = .clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //addSubview(backView)
        addSubview(countryName)
        addSubview(codeNum)
        
//        backView.snp.makeConstraints { make in
//            make.top.bottom.left.right.equalTo(contentView).inset(0)
//        }
        countryName.snp.makeConstraints { make in
            make.left.equalTo(contentView).inset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(140)
        }
        codeNum.snp.makeConstraints { make in
            make.right.equalTo(contentView).inset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(70)
        }
    }
}

