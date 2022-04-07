//
//  NewConversationViewCell.swift
//  ChatApp
//
//  Created by Владимир on 19.01.2022.
//  Copyright © 2022 Владимир. All rights reserved.
//

import Foundation
import SnapKit
import SDWebImage

class NewConversationCell: UITableViewCell {
    static let identifire = "NewConversationCell"
    
    let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 25
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview().inset(8)
            make.height.equalTo(50)
            make.width.equalTo(50)
        }
        userNameLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(8)
            make.left.equalTo(userImageView.snp.right).inset(-8)
            make.right.equalToSuperview().inset(8)
            make.height.equalTo(50)
        }
    }
    
    public func configure(with model: SearchResult) {
        self.userNameLabel.text = model.name
        
        let path = "images/\(model.phone)_profile_picture.png"
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
