//
//  APIClient.swift
//  Stratus
//
//  Created by Rudy Bermudez on 6/21/16.
//

import Foundation

public let TRENetworkingErrorDomain = "co.rudybermudez.Stormy.NetworkingError"
public let MissingHTTPResponseError: Int = 10
public let UnexpectedResponseError:Int = 20

typealias JSON = [String: AnyObject]
typealias JSONTaskCompletion = (JSON?, HTTPURLResponse?, NSError?) -> Void
typealias JSONTask = URLSessionDataTask

enum  APIResult<T> {
	case success(T)
	case failure(Error)
}

protocol JSONDecodable {
	init?(JSON: [String : AnyObject])
}

protocol Endpoint {
	var baseURL: URL { get }
	var path: String { get }
	var request: URLRequest { get }
}

protocol APIClient {
	var configuration: URLSessionConfiguration { get }
	var session: URLSession { get }
	
	func JSONTaskWithRequest(request: URLRequest, completion:  @escaping JSONTaskCompletion) -> JSONTask
	func fetch<T: JSONDecodable>(request: URLRequest, parse: @escaping(JSON) -> T?, completion: @escaping (APIResult<T>) -> Void)
}

extension APIClient {
	func JSONTaskWithRequest(request: URLRequest, completion: @escaping JSONTaskCompletion) -> JSONTask {
		let task = session.dataTask(with: request, completionHandler: { data, response, error in
			guard let HTTPResponse = response as? HTTPURLResponse else {
				let userInfo = [
					NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")
				]
				let error = NSError(domain: TRENetworkingErrorDomain, code: MissingHTTPResponseError, userInfo: userInfo)
				completion(nil, nil, error)
				return
			}
			
			if data == nil {
				if let error = error {
					completion(nil, HTTPResponse, error as NSError?)
				}
			} else {
				switch HTTPResponse.statusCode {
				case 200:
					do {
						let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
						completion(json, HTTPResponse, nil)
					} catch let error as NSError{
						completion(nil, HTTPResponse, error)
					}
				default:
					print("Received HTTP Response: \(HTTPResponse.statusCode) not handled")
				}
			}
		}) 
		return task
	}
	
	func fetch<T>(request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void){
		let task = JSONTaskWithRequest(request: request) { json, response, error in
			guard let json = json else {
				if let error = error {
					completion(.failure(error))
				} else {
					// TODO: Implement Error Handling
				}
				return
			}
			if let value = parse(json) {
				completion(.success(value))
			} else {
				let error = NSError(domain: TRENetworkingErrorDomain, code: UnexpectedResponseError, userInfo: nil)
				completion(.failure(error))
			}
		}
		task.resume()
	}
}

