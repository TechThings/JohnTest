//
//  Request.swift
//
//  Created by Nazih Shoura on 18/03/2016.
//  Copyright © 2016 Nazih Shoura. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

extension Request {

    /**
     Serilize the json rescived from the network to the object represented by the function genaric type.
     The genaric type must comfirm to Serializable Protocol
     
     - author: Nazih Shoura
     
     - parameter keyPath: The path insde the json the object to be serialized should be found at. Send nil to start the serialization from the top of the rescived json.
     
     - returns: The serialized object if the serialization was successful. Otherwise, returns an NSError.
     */
    static func ObjectMapperSerializer<T: Serializable>(keyPath: String?) -> ResponseSerializer<T, NSError> {
        return ResponseSerializer { request, response, data, error in

            guard error == nil else {
                loggerDefault.log(error!.toDescribableError(), logingTags: [])
                return .Failure(error!)
            }

            guard let _ = data else {
                let error = ResponseError.noDataReceived(request: request)
                loggerDefault.log(error, logingTags: [])
                return .Failure(error.toNSError())
            }

            let JSONResponseSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

            if let statusCode = response?.statusCode where statusCode >= 400 {
                loggerDefault.log(ResponseError.backEndError(request: request, statusCode: statusCode, errorResponse: result.value), logingTags: [])
                if let apiError = APIErrorModel.serialize(result.value) {
                    let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey: apiError.userVisibleErrorMessage, Error.UserInfoKeys.StatusCode: response!.statusCode]
                    let error = NSError(domain: Error.Domain, code: Error.Code.StatusCodeValidationFailed.rawValue, userInfo: userInfo)
                    return .Failure(error)
                } else {
                    let userInfo: [NSObject : AnyObject] = [NSLocalizedDescriptionKey: NSLocalizedString("msg_something_wrong", comment: ""), Error.UserInfoKeys.StatusCode: response!.statusCode]
                    let error = NSError(domain: Error.Domain, code: Error.Code.StatusCodeValidationFailed.rawValue, userInfo: userInfo)
                    return .Failure(error)
                }
            }

            let JSONToSerialize: AnyObject?
            if let keyPath = keyPath where keyPath.isEmpty == false {
                JSONToSerialize = result.value?.valueForKeyPath(keyPath)
            } else {
                JSONToSerialize = result.value
            }

            if let parsedObject = T.serialize(JSONToSerialize) {
                return .Success(parsedObject as! T)
            }

            let serializationError = ResponseError.couldNotSerializeResponse(request: request)
            loggerDefault.log(serializationError, logingTags: [])
            return .Failure(serializationError.toNSError())
        }
    }

    /**
     Adds a handler to be called once the request has finished.
     
     - parameter keyPath:           The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
     */
    public func responseObject<T: Serializable>(keyPath: String? = nil, completionHandler: Response<T, NSError> -> Void) -> Self {
        return responseObject(nil, keyPath: keyPath, completionHandler: completionHandler)
    }

    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue:             The queue on which the completion handler is dispatched.
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
     */
    public func responseObject<T: Serializable>(queue: dispatch_queue_t?, completionHandler: Response<T, NSError> -> Void) -> Self {
        return responseObject(queue, keyPath: nil, completionHandler: completionHandler)
    }

    /**
     Adds a handler to be called once the request has finished.
     
     - parameter queue:             The queue on which the completion handler is dispatched.
     - parameter keyPath:           The key path where object mapping should be performed
     - parameter completionHandler: A closure to be executed once the request has finished and the data has been mapped by ObjectMapper.
     
     - returns: The request.
     */
    public func responseObject<T: Serializable>(queue: dispatch_queue_t?, keyPath: String?, completionHandler: Response<T, NSError> -> Void) -> Self {
        return response(queue: queue, responseSerializer: Request.ObjectMapperSerializer(keyPath), completionHandler: completionHandler)
    }

    // MARK: Request - Upload and download progress

    /**
     Returns an `Observable` for the current progress status.
     
     Parameters on observed tuple:
     
     1. bytes written
     1. total bytes written
     1. total bytes expected to write.
     
     - returns: An instance of `Observable<(Int64, Int64, Int64)>`
     */
    public func rx_progress() -> Observable<RxProgress> {
        return Observable.create { observer in
            self.progress() { bytesWritten, totalBytesWritten, totalBytesExpectedToWrite in

                observer.onNext(RxProgress(bytesWritten: bytesWritten, totalBytesWritten: totalBytesWritten, totalBytesExpectedToWrite: totalBytesExpectedToWrite))

                if totalBytesWritten >= totalBytesExpectedToWrite {
                    observer.onCompleted()
                }

            }

            return NopDisposable.instance
            }
            .startWith(RxProgress(bytesWritten: 0, totalBytesWritten: 0, totalBytesExpectedToWrite: 0))
    }
}

// MARK: RxProgress
public struct RxProgress {
    let bytesWritten: Int64
    let totalBytesWritten: Int64
    let totalBytesExpectedToWrite: Int64
    var progress: Int64 {
        return ( totalBytesExpectedToWrite * 100 ) / totalBytesWritten
    }

    public init(bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.bytesWritten = bytesWritten
        self.totalBytesWritten = totalBytesWritten
        self.totalBytesExpectedToWrite = totalBytesExpectedToWrite
    }

    public func floatValue() -> Float {
        if totalBytesExpectedToWrite > 0 {
            return Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        } else {
            return 0
        }
    }
}

enum ResponseError: DescribableError {
    case noDataReceived(request: NSURLRequest?)
    case backEndError(request: NSURLRequest?, statusCode: Int, errorResponse: AnyObject?)
    case couldNotSerializeResponse(request: NSURLRequest?)

    var description: String {
        switch self {
        case let .noDataReceived(request): return "Request: \(request?.description)\nNo data received"
        case let .backEndError(request, statusCode, errorResponse): return "Request: \(request?.description)\nBackend error\nStatus code: \(statusCode)\nError response: \(errorResponse)"
        case let .couldNotSerializeResponse(request): return "Request: \(request?.description)\nCould not serialize response"
        }
    }

    var userVisibleDescription: String {
        switch self {
        case .noDataReceived: return NSLocalizedString("msg_something_wrong", comment: "")
        case .backEndError: return NSLocalizedString("msg_something_wrong", comment: "")
        case .couldNotSerializeResponse: return NSLocalizedString("msg_something_wrong", comment: "")
        }
    }

}
