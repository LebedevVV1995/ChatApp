//
//  DatabaseManager.swift
//  ChatApp
//
//  Created by Владимир on 06.10.2021.
//  Copyright © 2021 Владимир. All rights reserved.
//

import Foundation
import FirebaseDatabase
import MessageKit

final class DatabaseManager{
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    static func safePhone(phoneNumber: String) -> String {
        let safePhone = phoneNumber.replacingOccurrences(of: "+", with: "")
        return safePhone
    }
}

extension DatabaseManager {
    /// Returns dictionary node at child path
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        database.child("\(path)").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}

// MARK: - Account Management
extension DatabaseManager{
    public func userExists(with phone: String, completion: @escaping((Bool) -> Void)) {
        let safePhone = DatabaseManager.safePhone(phoneNumber: phone)
        //let safePhone = phone.replacingOccurrences(of: "+", with: "")
        database.child(safePhone).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? [String: Any] != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    /// Inserts new user to Database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void){
        database.child(user.safePhone).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName
            ], withCompletionBlock: { [weak self] error, _ in
                guard let strongSelf = self else {
                    return
                }
                guard error == nil else{
                    print("failed to write to database")
                    completion(false)
                    return
                }
                strongSelf.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                    if var usersCollection = snapshot.value as? [[String: String]] {
                        // append to user dictionary
                        let newElement = [
                                "name": user.firstName + " " + user.lastName,
                                "phone": user.safePhone
                        ]
                        
                        usersCollection.append(newElement)

                        strongSelf.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                    } else {
                        //create that array
                        let newCllection: [[String: String]] = [
                            [
                                "name": user.firstName + " " + user.lastName,
                                "phone": user.safePhone
                            ]
                        ]
                        strongSelf.database.child("users").setValue(newCllection, withCompletionBlock: { error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                    }
                })
        })
    }
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    public enum DatabaseError: Error {
        case failedToFetch
    }
}

// MARK: - Sending messages/conversation

extension DatabaseManager {
    /// Creates a new conversation with target user phone and first message sent
    public func createNewConversation(with otherUserPhone: String, name:String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentPhone = UserDefaults.standard.value(forKey: "phone") as? String,
            let currentNamme = UserDefaults.standard.value(forKey: "name") as? String else {
            return
        }
        let safePhone = DatabaseManager.safePhone(phoneNumber: currentPhone)
        let ref = database.child("\(safePhone)")
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("user not found")
                return
            }
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewControler.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            case .linkPreview(_):
                break
            }
            
            
            let conversationId = "conversation_\(firstMessage.messageId)"
            let newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_phone": otherUserPhone,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationId,
                "other_user_phone": safePhone,
                "name": currentNamme,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            print(currentNamme)
            // Update recipient conversaiton entry
        self?.database.child("\(otherUserPhone)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    // append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserPhone)/conversations").setValue(conversations)
                }
                else {
                    // create
                    self?.database.child("\(otherUserPhone)/conversations").setValue([recipient_newConversationData])
                }
            })

            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                //converation array exists for current user
                //you should append
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConverstion(name: name,
                                                    conversationID: conversationId,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                })
            } else {
                //conversation array NOT exist
                //create it
                userNode["conversations"] = [
                    newConversationData
                ]
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConverstion(name: name,
                                                    conversationID: conversationId,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                })
            }
        })
    }
    
    private func finishCreatingConverstion(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewControler.dateFormatter.string(from: messageDate)
        
        var message = ""
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        case .linkPreview(_):
            break
        }
        
        guard let myPhone = UserDefaults.standard.value(forKey: "phone") as? String else {
            completion(false)
            return
        }
        
        let currentUserPhone = DatabaseManager.safePhone(phoneNumber: myPhone)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_phone": currentUserPhone,
            "is_read": false,
            "name": name
        ]
        let value: [String:Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        print("addind convo \(conversationID)")
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    /// Fetches and returns all conversations for the user with passed in phone
    public func getAllConversations(for phone: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        
        database.child("\(phone)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap({ dictionary in
                guard let conversationId = dictionary["id"] as? String,
                    let name = dictionary["name"] as? String,
                    let otherUserPhone = dictionary["other_user_phone"] as? String,
                    let latestMessage = dictionary["latest_message"] as? [String: Any],
                    let date = latestMessage["date"] as? String,
                    let message = latestMessage["message"] as? String,
                    let isRead = latestMessage["is_read"] as? Bool else {
                        return nil
                }
                let latestMessageObject = LatestMessage(date: date,
                                                        text: message,
                                                        isRead: isRead)
                return Conversation(id: conversationId,
                                    name: name,
                                    otherUserPhone: otherUserPhone,
                                    latestMessage: latestMessageObject)
            })
            completion(.success(conversations))
        })
    }
    /// Gets all messages for a given conversation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else{
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                    let isRead = dictionary["is_read"] as? Bool,
                    let messageID = dictionary["id"] as? String,
                    let content = dictionary["content"] as? String,
                    let senderPhone = dictionary["sender_phone"] as? String,
                    let type = dictionary["type"] as? String,
                    let dateString = dictionary["date"] as? String,
                    let date = ChatViewControler.dateFormatter.date(from: dateString) else {
                        return nil
                }
                
                var kind: MessageKind?
                if type == "photo" {
                    //photo
                    guard let imageUrl = URL(string: content),
                    let placeHolder = UIImage(systemName: "plus") else {
                        return nil
                    }
                    let media = Media(url: imageUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                } else if type == "video" {
                    //video
                    guard let videoUrl = URL(string: content),
                    let placeHolder = UIImage(systemName: "play.rectangle.fill") else {
                        return nil
                    }
                    let media = Media(url: videoUrl,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                } else {
                    kind = .text(content)
                }
                
                guard let finalKind = kind else {
                    return nil
                }
                let sender = Sender(photoURL: "",
                                    senderId: senderPhone,
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: finalKind)
            })
            completion(.success(messages))
        })
    }
// MARK: - Sends a message with target conversation and message
    public func sendMessage(to conversation: String, otherUserPhone: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
        //add new message to messages
        //update sender latest message
        //update recipient latest message
        
        guard let myPhone = UserDefaults.standard.value(forKey: "phone") as? String else {
            completion(false)
            return
        }
        let currentPhone = DatabaseManager.safePhone(phoneNumber: myPhone)
        self.database.child("\(conversation)/messages").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewControler.dateFormatter.string(from: messageDate)
            
            var message = ""
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    message = targetUrlString
                }
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            case .linkPreview(_):
                break
            }
            
            guard let myPhone = UserDefaults.standard.value(forKey: "phone") as? String else {
                completion(false)
                return
            }
            
            let currentUserPhone = DatabaseManager.safePhone(phoneNumber: myPhone)
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.messageKindString,
                "content": message,
                "date": dateString,
                "sender_phone": currentUserPhone,
                "is_read": false,
                "name": name
            ]
            currentMessages.append(newMessageEntry)
            strongSelf.database.child("\(conversation)/messages").setValue(currentMessages) { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currentPhone)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                    var databaseEntryConversations = [[String: Any]]()
                    let updateValue: [String: Any] = [
                        "date": dateString,
                        "is_read": false,
                        "message": message
                    ]
                    
                    if var currentUserConversations = snapshot.value as? [[String: Any]] {
                        var targetConversation: [String: Any]?
                        var position = 0
                        for conversationDictionary in currentUserConversations {
                            if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                targetConversation = conversationDictionary
                                break
                            }
                            position += 1
                        }
                        
                        if var targetConversation = targetConversation {
                            targetConversation["latest_message"] = updateValue
                            currentUserConversations[position] = targetConversation
                            databaseEntryConversations = currentUserConversations
                        } else {
                            let newConversationData: [String: Any] = [
                                "id": conversation,
                                "other_user_phone": DatabaseManager.safePhone(phoneNumber: otherUserPhone),
                                "name": name,
                                "latest_message": updateValue
                            ]
                            currentUserConversations.append(newConversationData)
                            databaseEntryConversations = currentUserConversations
                        }
                    } else {
                        let newConversationData: [String: Any] = [
                            "id": conversation,
                            "other_user_phone": DatabaseManager.safePhone(phoneNumber: otherUserPhone),
                            "name": name,
                            "latest_message": updateValue
                        ]
                        databaseEntryConversations = [
                            newConversationData
                        ]
                    }
                    
                    strongSelf.database.child("\(currentPhone)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        //Update latest message for recipient user
                        strongSelf.database.child("\(otherUserPhone)/conversations").observeSingleEvent(of: .value, with: { snapshot in
                            let updateValue: [String: Any] = [
                                "date": dateString,
                                "is_read": false,
                                "message": message
                            ]
                            var databaseEntryConversations = [[String: Any]]()
                            
                            guard let currentName = UserDefaults.standard.value(forKey: "name") as? String else {
                                return
                            }
                            
                            if var otherUserConversations = snapshot.value as? [[String: Any]] {
                                var targetConversation: [String: Any]?
                                var position = 0
                                for conversationDictionary in otherUserConversations {
                                    if let currentId = conversationDictionary["id"] as? String, currentId == conversation {
                                        targetConversation = conversationDictionary
                                        break
                                    }
                                    position += 1
                                }
                                
                                if var targetConversation = targetConversation {
                                    targetConversation["latest_message"] = updateValue
                                    otherUserConversations[position] = targetConversation
                                    databaseEntryConversations = otherUserConversations
                                } else {
                                    //failed to find in current collection
                                    let newConversationData: [String: Any] = [
                                        "id": conversation,
                                        "other_user_phone": DatabaseManager.safePhone(phoneNumber: currentPhone),
                                        "name": currentName,
                                        "latest_message": updateValue
                                    ]
                                    otherUserConversations.append(newConversationData)
                                    databaseEntryConversations = otherUserConversations
                                }
                            } else {
                                //current collection does not exist
                                let newConversationData: [String: Any] = [
                                    "id": conversation,
                                    "other_user_phone": DatabaseManager.safePhone(phoneNumber: currentPhone),
                                    "name": currentName,
                                    "latest_message": updateValue
                                ]
                                databaseEntryConversations = [
                                    newConversationData
                                ]
                            }
                        strongSelf.database.child("\(otherUserPhone)/conversations").setValue(databaseEntryConversations, withCompletionBlock: { error, _ in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                
                                completion(true)
                            })
                        })
                    })
                })
            }
        })
    }
    
    public func deleteConversation(conversationId: String, completion: @escaping (Bool) -> Void) {
        
        guard let phone = UserDefaults.standard.value(forKey: "phone") as? String else {
            return
        }
        let safePhone = DatabaseManager.safePhone(phoneNumber: phone)
        print("Deleting conversation with id: \(conversationId)")
        
        // Get all conversations for current user
        // delete conversation in collection with target id
        // reset those conversations for the user in database
        
        let ref = database.child("\(safePhone)/conversations")
        ref.observeSingleEvent(of: .value) { snapshot in
            if var conversations = snapshot.value as? [[String:Any]] {
                var positionToRemove = 0
                for conversation in conversations {
                    if let id = conversation["id"] as? String,
                        id == conversationId {
                        print("found conversation to delete")
                        break
                    }
                    positionToRemove += 1
                }
                conversations.remove(at: positionToRemove)
                ref.setValue(conversations, withCompletionBlock: { error, _ in
                    guard error == nil else {
                        completion(false)
                        print("failed to write new conversation array")
                        return
                    }
                    print("deleted conversation")
                    completion(true)
                })
            }
        }
    }
    
    public func conversationExists(with targetResipientPhone: String, completion: @escaping(Result<String, Error>) -> Void){
        let safeRecipientPhone = DatabaseManager.safePhone(phoneNumber: targetResipientPhone)
        
        guard let senderPhone = UserDefaults.standard.value(forKey: "phone") as? String else {
            return
        }
        
        let safeSenderPhone = DatabaseManager.safePhone(phoneNumber: senderPhone)
        
        database.child("\(safeRecipientPhone)/conversations").observeSingleEvent(of: .value, with: { snapshot in
            guard let collection = snapshot.value as? [[String:Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            // iterate and find conversation with target sender
            if let conversation = collection.first(where: {
                guard let targetSenderPhone = $0["other_user_phone"] as? String else {
                    return false
                }
                return safeSenderPhone == targetSenderPhone
            }) {
                //get id
                guard let id = conversation["id"] as? String else {
                    completion(.failure(DatabaseError.failedToFetch))
                    return
                }
                completion(.success(id))
                return
            }
            completion(.failure(DatabaseError.failedToFetch))
            return
        })
    }
}

struct ChatAppUser {
    let phoneNumber: String
    let firstName: String
    let lastName: String
    
    var safePhone: String {
        let safePhone = phoneNumber.replacingOccurrences(of: "+", with: "")
        return safePhone
    }
    var profilePictureFileName: String {
        return "\(safePhone)_profile_picture.png"
    }
}
