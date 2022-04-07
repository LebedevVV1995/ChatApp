//
//  ConversationTableViewCell.swift
//  ChatApp
//
//  Created by Владимир on 05.11.2021.
//  Copyright © 2021 Владимир. All rights reserved.
//

import UIKit
import SnapKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    static let identifire = "ConversationTableViewCell"
    
    let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 32
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .thin)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(8)
            make.height.equalTo(64)
            make.width.equalTo(64)
        }
        userNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8)
            make.left.equalTo(userImageView.snp.right).inset(-8)
            make.right.equalToSuperview().inset(8)
            make.height.equalTo(16)
        }
        userMessageLabel.snp.makeConstraints { make in
            make.top.equalTo(userNameLabel.snp.bottom).inset(-8)
            make.bottom.equalToSuperview().inset(8)
            make.left.equalTo(userImageView.snp.right).inset(-8)
            make.right.equalToSuperview().inset(8)
            make.height.equalTo(16)
        }
    }
    
    public func configure(with model: Conversation) {
        self.userNameLabel.text = model.name
        self.userMessageLabel.text = model.latestMessage.text
        
        let path = "images/\(model.otherUserPhone)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("failed to get image url:\(error)")
            }
        })
    }
}
