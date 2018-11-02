//
//  NewtorkSupport.swift
//  ExpenseEntry
//
//  Created by Scott Champ on 2018-02-02.
//  Copyright © 2018 Touch Sciences. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(T?)
    case failure(Error)
}

enum NetworkHelperError: Error {
    case noURLResponse
    case badStatusCode(code: Int)
    case signinFailed
}

private struct SignInRequestModel: Encodable {
    let userName: String
    let password: String
    
    enum CodingKeys: String, CodingKey { // declaring our keys
        case userName = "user_name"
        case password = "password"
    }
}

private struct SignInResponseModel: Decodable {
    let sessionId: String
    
    enum CodingKeys: String, CodingKey { // declaring our keys
        case sessionId = "session_id"
    }
}

private struct ExpenseRequestModel: Encodable {
    let type: String
    let date: String
    let amount: String
    let companyId: String
    
    enum CodingKeys: String, CodingKey { // declaring our keys
        case type, date, amount
        case companyId = "company_id"
    }
    
    init(type: ExpenseType, date: String, amount: String, companyId: String) {
        self.type = type.rawValue
        self.date = date
        self.amount = amount
        self.companyId = companyId
    }
}

private struct ExpenseResponseModel: Decodable {
    let expenseId: String
    
    enum CodingKeys: String, CodingKey { // declaring our keys
        case expenseId = "expense_id"
    }
}

private struct RecieptResponseModel: Decodable { }

private struct EmptyModel: Decodable {}

private struct SessionInfo {
    let sessionId: String
    let sessionExpiry: Date
}

class NetworkHelper {
    private let signInURL = "https://touchexpenseservice.azurewebsites.net/api/session"
    private let expenseURL = "https://touchexpenseservice.azurewebsites.net/api/expense"
    private let recieptURL = "https://touchexpenseservice.azurewebsites.net/api/reciept"
    private let userName = "user"
    private let password = "uvFwncaZ8vCmAH"
    
    private var sessionInfo: SessionInfo? = nil
    
    func addExpense(type: ExpenseType, date: Date, amount: String, companyId: String, completion: @escaping (Result<String>) -> Void ) {
        signInIfNeeded() { success in
            if success {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yyyy"
                let dateString = dateFormatter.string(from: date)
                let requestModel = ExpenseRequestModel(type: type, date: dateString, amount: amount, companyId: companyId)
                let request = self.createRequest(url: self.expenseURL, model: requestModel)
                
                self.performNetworkTask(with: request, responseType: ExpenseResponseModel.self) { result in
                    switch result {
                    case let .success(responseModel):
                        completion(Result.success(responseModel?.expenseId))
                    case let .failure(error):
                        completion(Result.failure(error))
                    }
                }
            } else {
                completion(Result.failure(NetworkHelperError.signinFailed))
            }
        }
    }
    
    func addReciept(expenseId: String, imageData: Data, completion: @escaping (Bool) -> Void) {
        signInIfNeeded() { success in
            if success {
                var request = URLRequest(url: URL(string: self.recieptURL)!)
                request.httpMethod = "POST"
                request.httpBody = imageData
                request.addValue(expenseId, forHTTPHeaderField: "expense_id")
                request.addValue(self.sessionInfo!.sessionId, forHTTPHeaderField: "session_id")
                request.addValue("image/jpeg", forHTTPHeaderField: "Content-Type")

                self.performNetworkTask(with: request, responseType: RecieptResponseModel.self) { result in
                    switch result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    func getExpenses(companyId: String, completion: @escaping (Result<[ExpenseEntry]>) -> Void) {
        signInIfNeeded() { success in
            if success {
                var request = URLRequest(url: URL(string: self.expenseURL)!)
                request.httpMethod = "GET"
                request.addValue(self.sessionInfo!.sessionId, forHTTPHeaderField: "session_id")
                request.addValue(companyId, forHTTPHeaderField: "company_filter")

                self.performNetworkTask(with: request, responseType: [ExpenseEntry].self) { result in
                    completion(result)
                }
            } else {
                completion(Result.failure(NetworkHelperError.signinFailed))
            }
        }
    }
    
    func deleteExpense(expenseId: String, completion: @escaping (Bool) -> Void) {
        signInIfNeeded() { success in
            if success {
                var request = URLRequest(url: URL(string: self.expenseURL)!)
                request.httpMethod = "DELETE"
                request.addValue(self.sessionInfo!.sessionId, forHTTPHeaderField: "session_id")
                request.addValue(expenseId, forHTTPHeaderField: "expense_id")
                
                self.performNetworkTask(with: request, responseType: EmptyModel.self) { result in
                    switch result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    private func performNetworkTask<T: Decodable>(with request: URLRequest, responseType: T.Type, completion: @escaping (Result<T>) -> Void) {
        let session = createSession()
        let sessionDataTask = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let sessionTaskError = error {
                    completion(Result.failure(sessionTaskError))
                    return
                }
                guard let urlResponse = response as? HTTPURLResponse else {
                    // Should not get here. Just in case...
                    completion(Result.failure(NetworkHelperError.noURLResponse))
                    return
                }

                if urlResponse.statusCode >= 200 && urlResponse.statusCode < 300 {
                    guard let responseData = data, responseData.count > 0 else {
                        completion(Result.success(nil))
                        return
                    }
                    do {
                        let responseModel: T = try self.processResponse(data: responseData)
                        completion(Result.success(responseModel))
                    } catch {
                        completion(Result.failure(error))
                    }
                } else {
                    completion(Result.failure(NetworkHelperError.badStatusCode(code: urlResponse.statusCode)))
                }
            }
        }
        sessionDataTask.resume()
    }
    
    private func createSession() -> URLSession {
        let sessionConfig = URLSessionConfiguration.ephemeral
        return URLSession(configuration: sessionConfig)
    }
    
    private func processResponse<T: Decodable>(data: Data) throws -> T {
        let jsonDecoder = JSONDecoder()
        return try jsonDecoder.decode(T.self, from: data)
    }

    private func createRequest<T: Encodable>(url: String, model: T) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        let jsonEncoder = JSONEncoder()
        request.httpBody = try? jsonEncoder.encode(model)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let session = sessionInfo {
            request.addValue(session.sessionId, forHTTPHeaderField: "session_id")
        }
        
        return request
    }
    
    private func signIn(userName: String, password: String, completion: @escaping (Bool) -> Void) {
        let requestModel = SignInRequestModel(userName: userName, password: password)
        let request = createRequest(url: signInURL, model: requestModel)
        
        performNetworkTask(with: request, responseType: SignInResponseModel.self) { result in
            switch result {
            case let .success(responseModel):
                self.sessionInfo = SessionInfo(sessionId: responseModel!.sessionId, sessionExpiry: Date(timeIntervalSinceNow: 60*60))
                completion(true)
            case .failure:
                self.sessionInfo = nil
                completion(false)
            }
        }
    }
    
    private func signInIfNeeded(completion: @escaping (Bool) -> Void) {
        if sessionInfo == nil || Date() > sessionInfo!.sessionExpiry {
            signIn(userName: userName, password: password) { result in
                completion(result)
            }
        } else {
            completion(true)
        }
    }
}
