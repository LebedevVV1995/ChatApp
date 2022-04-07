//
//  UserInfoController.swift
//  
//
//  Created by Владимир on 04.10.2021.
//

import UIKit
import SnapKit
import FirebaseAuth
import JGProgressHUD

class UserInfoController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    public var switcher = false
    let numbPhone = FirebaseAuth.Auth.auth().currentUser?.phoneNumber
    
    @objc private func didTapChangeProfilePic() {
        presentPhotoActionSheet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userName.delegate = self
        userLastname.delegate = self
        userImage.isUserInteractionEnabled = true
        view.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(didTapChangeProfilePic))
        userImage.addGestureRecognizer(gesture)
        initializeHideKeyboard()
        initialized()
        view.backgroundColor = .systemBackground
    }
//MARK: UI
    let spinner = JGProgressHUD(style: .dark)
    
    let Title: UILabel = {
        let label = UILabel()
        label.text = "Your Information"
        label.font = UIFont.init(name: "HelveticaNeue-Medium", size: 30)
        label.textColor = .label
        label.textAlignment = .center
        return label
    }()
    let userImage: UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 64
        image.tintColor = .systemFill
        image.image = UIImage(systemName: "camera.circle")
        image.preferredSymbolConfiguration = .init(pointSize: 0, weight: .thin)
        image.contentMode = .scaleAspectFit
        image.layer.masksToBounds = true
        return image
    }()
    let userName: UITextField = {
        let field = UITextField()
        field.textColor = .systemFill
        field.font = UIFont.init(name: "HelveticaNeue", size: 18)
        field.placeholder = "Name"
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.clearButtonMode = .always

        return field
    }()
    let separator: UIView = {
        var view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    let userLastname: UITextField = {
        let field = UITextField()
        field.textColor = .systemFill
        field.font = UIFont.init(name: "HelveticaNeue", size: 18)
        field.placeholder = "Lastname"
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.clearButtonMode = .always
        return field
    }()
    let separator2: UIView = {
        var view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    let allertTitle: UILabel = {
        let label = UILabel()
        label.text = "Please add name and photo"
        label.font = UIFont.init(name: "HelveticaNeue-Thin", size: 20)
        label.textColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        label.textAlignment = .center
        return label
    }()
// MARK: Register new User
    
    @objc private func didTapRegister() {
        userName.resignFirstResponder()
        userLastname.resignFirstResponder()
        
        switcher = true
        
        guard let name = userName.text,
            let lastname = userLastname.text,
            !name.isEmpty,
            !lastname.isEmpty else{
                alertUserLoginError()
                return
        }
        spinner.show(in: view)
        //-----
        DatabaseManager.shared.userExists(with: numbPhone!, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            //----
            let safePhone = DatabaseManager.safePhone(phoneNumber: (self?.numbPhone!)!)
            DatabaseManager.shared.getDataFor(path: safePhone, completion: { result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                        let firstName = userData["first_name"] as? String,
                        let lastName = userData["last_name"] as? String else {
                            return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")

                case .failure(let error):
                    print("Failed to read data with error \(error)")
                }
            })
            //----
            guard !exists else{
                strongSelf.alertUserLoginError(message: "Looks like a user account for that phone already exists.")
                return
            }
            let chatUser = ChatAppUser(phoneNumber: (self?.numbPhone!)!,
                                                     firstName: name,
                                                     lastName: lastname)
            DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                if success {
                    //upload image
                    guard let image = strongSelf.userImage.image,
                        let data = image.pngData() else {
                        return
                    }
                    let filename = chatUser.profilePictureFileName
                    StorageManager.shared.uploadProfilePicture(with: data, fileName: filename,completion: { result in
                        switch result {
                        case .success(let downloadUrl):
                            UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                            print(downloadUrl)
                        case .failure(let error):
                            print("Storage manager error: \(error)")
                        }
                    })
                }
            })
            //----------
            DispatchQueue.main.async {
                let vc = TabBarController()
                vc.modalPresentationStyle = .fullScreen
                self?.present(vc, animated: true)
            }
            //-----
        })
    }
    
    func alertUserLoginError(message: String = "Please enter all information to create new account") {
        let alert = UIAlertController(title: "Woops",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true)
    }
//MARK: Constraints
    private func initialized(){
        view.addSubview(Title)
        view.addSubview(userImage)
        view.addSubview(userName)
        view.addSubview(userLastname)
        view.addSubview(separator)
        view.addSubview(separator2)
        view.addSubview(allertTitle)
        
        Title.snp.makeConstraints{ make in
            make.left.right.equalToSuperview().inset(30)
            make.top.equalToSuperview().inset(100)
            make.height.equalTo(38)
        }
        userImage.snp.makeConstraints{ make in
            make.left.equalToSuperview().inset(16)
            make.top.equalTo(Title.snp.bottom).inset(-16)
            make.width.equalTo(128)
            make.height.equalTo(128)
        }
        userName.snp.makeConstraints{ make in
            make.left.equalTo(userImage.snp.right).inset(-16)
            make.right.equalToSuperview().inset(0)
            make.top.equalTo(Title.snp.bottom).inset(-32)
            make.height.equalTo(25)
        }
        
        installSeparatorConstraint(separ: separator, equalTo: userName.snp.bottom, inset: -8)
        
        userLastname.snp.makeConstraints{ make in
            make.left.equalTo(userImage.snp.right).inset(-16)
            make.right.equalToSuperview().inset(0)
            make.top.equalTo(separator).inset(8)
            make.height.equalTo(25)
        }
        installSeparatorConstraint(separ: separator2, equalTo: userLastname.snp.bottom, inset: -8)
        
        allertTitle.snp.makeConstraints{ make in
            make.left.right.equalToSuperview().inset(-16)
            make.top.equalTo(userImage.snp.bottom).inset(-25)
            make.height.equalTo(25)
        }
    }
    
    
    func installSeparatorConstraint (separ: UIView, equalTo: ConstraintItem, inset: Int){
        separ.snp.makeConstraints{ make in
            make.left.equalTo(userImage.snp.right).inset(-16)
            make.right.equalToSuperview().inset(0)
            make.top.equalTo(equalTo).inset(inset)
            make.height.equalTo(1)
        }
    }
    
}
// MARK: Take and Choose photo

extension UserInfoController: UIImagePickerControllerDelegate{
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { _ in
           
                                                self.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Choose Photo",
                                            style: .default,
                                            handler: { _ in
           
                                                self.presentPhotoPicker()
        }))
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated:  true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated:  true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.userImage.image = selectedImage
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
// MARK: Hide keyboard

extension UserInfoController {
   func initializeHideKeyboard(){
       let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                action: #selector(dismissMyKeyboard))
       view.addGestureRecognizer(tap)
   }

   @objc func dismissMyKeyboard(){
       view.endEditing(true)
   }
}
