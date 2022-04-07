//
//  CustomViewCellChatList.swift
//  
//
//  Created by Владимир on 07.09.2021.
//

import UIKit
//import SnapKit

class CustomViewCellChatList: UITableViewCell {
//    let backView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .blue
//        return view
//    }()
    let chatImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 30
        image.backgroundColor = .blue
        return image
    }()
    let chatName: UILabel = {
        let name = UILabel()
        //name.text = "CHat NAME"
        name.textAlignment = .left
        name.font = UIFont.boldSystemFont(ofSize: 16)

        return name
    }()
    let lastMessage: UILabel = {
        let lastMess = UILabel()
        //lastMess.numberOfLines = 2
        lastMess.textAlignment = .left
        lastMess.font = UIFont.boldSystemFont(ofSize: 16)
        return lastMess
    }()
    let dateSendMessage: UILabel = {
        let date = UILabel()
        //date.text = "21.03.4444"
        date.textAlignment = .left
        date.font = UIFont.boldSystemFont(ofSize: 16)
        return date
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
        addSubview(chatImage)
        addSubview(chatName)
        addSubview(lastMessage)
        addSubview(dateSendMessage)
        
//        backView.snp.makeConstraints { make in
//            make.top.bottom.left.right.equalTo(contentView).inset(0)
//        }
        chatImage.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(8)
            //.centerX.equalToSuperview()
            make.height.equalTo(64)
            make.width.equalTo(64)
        }
        chatName.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.equalTo(chatImage.snp.right).inset(-16)
            make.right.equalTo(dateSendMessage.snp.left).inset(-8)
            make.height.equalTo(16)
        }
        lastMessage.snp.makeConstraints { make in
            make.top.equalTo(chatName.snp.bottom).inset(8)
            make.bottom.equalToSuperview().inset(8)
            make.left.equalTo(chatImage.snp.right).inset(-16)
            make.right.equalToSuperview().inset(8)
        }
        dateSendMessage.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(8)
            make.right.equalTo(contentView).inset(16)
            make.height.equalTo(16)
            make.width.equalTo(80)
        }
    }
}
