////
////  Layer.swift
////  FAVE
////
////  Created by Nazih Shoura on 29/06/2016.
////  Copyright © 2016 Nazih Shoura. All rights reserved.
////
//
//import Foundation
//import RxSwift
//import LayerKit
//
//extension LYRMessage {
//    func recipientStatusByUserId() -> [String: Int] {
//        let recipientStatuses = self.recipientStatusByUserID as! [String: Int]
//        return recipientStatuses
//    }
//    
//    func recipientStatus(ofUserWithId userId: String) -> LYRRecipientStatus? {
//        let recipientStatuses = self.recipientStatusByUserID as! [String: Int]
//        if let recipientStatus = recipientStatuses[userId] {
//            let status = LYRRecipientStatus.init(rawValue: recipientStatus)!
//            return status
//        }
//        return nil
//    }
//}
//
//extension LYRConversation {
//    func messagesQuery(sortBy sortDescriptors: [NSSortDescriptor], limit: UInt?, offset: UInt?) -> LYRQuery  {
//        
//        let query = LYRQuery(queryableClass: LYRMessage.self)
//        query.predicate = LYRPredicate(property: "conversation", predicateOperator: .IsEqualTo, value: self)
//        query.sortDescriptors = sortDescriptors
//        if let limit = limit { query.limit = limit }
//        if let offset = offset { query.offset = offset }
//        
//        return query
//    }
//}
//
//extension LYRClient {
//    
//    func synchronize(inReactionToRemoteNotificationWithUserInfo userInfo: [NSObject : AnyObject]) -> Observable<Bool> {
//        let result = Observable.create { (observer: AnyObserver<Bool>) -> Disposable in
//            self.synchronizeWithRemoteNotification(userInfo) { (conversation, message, error) in
//                if let error = error {
//                    observer.onError(error)
//                    return
//                }
//                // Data downloaded
//                if conversation != nil || message != nil {
//                    observer.onNext(true)
//                    return
//                }
//                // No data downloaded
//                observer.onNext(false)
//            }
//            return AnonymousDisposable {}
//        }
//        return result
//    }
//    
//    /**
//     Login the client with the passed layer user id
//     
//     - author: Nazih Shoura
//     
//     - parameter layerUserId: The layerUserId to be used to log in
//     
//     - returns: Observable<LYRIdentity>
//     */
//    func login(withLayerUserId layerUserId: String) -> Observable<LYRIdentity> {
//        return connectToLayer()
//            .flatMap { _ in return self.authenticateLayerClient(withLayerUserID: layerUserId) }
//    }
//    
//    /**
//     Connect to layer
//     
//     - author: Nazih Shoura
//     
//     - returns: Observable descriping the result of the operation
//     */
//    private func connectToLayer() -> Observable<Bool> {
//        let result = Observable.create { (observer: AnyObserver<Bool>) -> Disposable in
//            self.connectWithCompletion { (success, error) in
//                if let error = error {
//                    observer.onError(error)
//                } else {
//                    observer.onNext(true)
//                }
//                observer.onCompleted()
//            }
//            return AnonymousDisposable {}
//        }
//        return result
//    }
//    
//    /**
//     Authenticate the messaging client with the passed layer user id. If the user already autenticated, just return the current LYRIdentity object
//     
//     - author: Nazih Shoura
//     
//     - parameter layerUserId: The layerUserId to be used to log in
//     
//     - returns: Observable descriping the result of the operation
//     */
//    private func authenticateLayerClient(withLayerUserID layerUserID: String) -> Observable<LYRIdentity> {
//        
//        // Check to see if the layerClient is already authenticated.
//        if self.authenticatedUser != nil {
//            if self.authenticatedUser?.userID == layerUserID { // If the layerClient is authenticated with the requested userID, complete the authentication process.
//                return Observable.of(self.authenticatedUser!)
//            }
//            //If the authenticated userID is different, then deauthenticate the current client and re-authenticate with the new userID.
//            return self.deauthenticateLayerClient().flatMap { _ in
//                return self.authenticateLayerClient(withLayerUserID: layerUserID)
//            }
//        }
//        
//        return authenticationNonce()
//            .flatMap { return self.authenticationToken(forLayerUserId: layerUserID, nonce: $0) }
//            .flatMap { return self.authenticate(withIdentityToken: $0) }
//    }
//    
//    /**
//     Authenticate the layer client
//     
//     - author: Nazih Shoura
//     
//     - parameter identityToken: The identity token used to authenticate the layer client
//     
//     - returns: An observable having the retult layer identity
//     */
//    private func authenticate(withIdentityToken identityToken: String) -> Observable<LYRIdentity> {
//        let result = Observable.create { (observer: AnyObserver<LYRIdentity>) -> Disposable in
//            self.authenticateWithIdentityToken(identityToken, completion: { (layerIdentity, error) in
//                if let error = error {
//                    observer.onError(error)
//                } else {
//                    observer.onNext(layerIdentity!)
//                }
//            })
//            return AnonymousDisposable {}
//        }
//        return result
//        
//    }
//    
//    /**
//     Get the authentication nonce for the layer client
//     
//     - author: Nazih Shoura
//     
//     - returns: Observable containing nonce
//     */
//    private func authenticationNonce() -> Observable<String> {
//        let result = Observable.create { (observer: AnyObserver<String>) -> Disposable in
//            self.requestAuthenticationNonceWithCompletion { (nonce, error) in
//                if let error = error {
//                    observer.onError(error)
//                } else {
//                    observer.onNext(nonce!)
//                }
//                observer.onCompleted()
//            }
//            return AnonymousDisposable {}
//        }
//        return result
//    }
//    
//    /**
//     Get the authentication token for the layer client
//     
//     - author: Nazih Shoura
//     
//     - parameter layerUserId: The id to be used to obtain the token
//     
//     - returns: Observable descriping the result of the operation
//     */
//    private func authenticationToken(forLayerUserId layerUserId: String, nonce: String) -> Observable<String> {
//        
//        let result = Observable.create { (observer: AnyObserver<String>) -> Disposable in
//            
////            IdentityTokenGenerator.requestIdentityTokenForUserID(layerUserId, appID: self.appID.absoluteString, nonce: nonce, completion: { (identityToken, error) in
////                if let error = error {
////                    observer.onError(error)
////                } else {
////                    observer.onNext(identityToken)
////                }
////                observer.onCompleted()
////            })
//            
//            return AnonymousDisposable {}
//        }
//        return result
//    }
//    
//    /**
//     Logout the layer client.
//     
//     - author: Nazih Shoura
//     
//     - returns: Observable representing the result of the operation
//     */
//    func logoutMessagingServiceUser() -> Observable<Bool> {
//        return deauthenticateLayerClient()
//            .flatMap{ success -> Observable<Bool> in
//                return Observable.of(success)
//        }
//    }
//    
//    /**
//     Deauterize the layer client
//     
//     - author: Nazih Shoura
//     
//     - returns: Observable descriping the result of the operation
//     */
//    private func deauthenticateLayerClient() -> Observable<Bool> {
//        let result = Observable.create { (observer: AnyObserver<Bool>) -> Disposable in
//            self.deauthenticateWithCompletion({ (success, error) in
//                if let error = error {
//                    observer.onError(error)
//                } else {
//                    observer.onNext(true)
//                }
//                observer.onCompleted()
//            })
//            return AnonymousDisposable {}
//        }
//        return result
//    }
//}
