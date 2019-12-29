import Foundation
import ExpenseLibrary

private struct SessionInfo {
    let sessionId: String
    let sessionExpiry: Date
}

class NetworkHelper {
    private let userName = "user"
    private let password = "uvFwncaZ8vCmAH"

    private var sessionInfo: SessionInfo? = nil

    public init() {
    }

    public func addExpense(expense: ExpenseEntry, completion: @escaping (Result<String, ServiceError>) -> Void ) {
        signInIfNeeded() { result in
            switch result {
            case let .success(sessionId):
                let expenseService = ExpenseService(withSession: sessionId)
                expenseService.addExpense(expense: expense) { result in
                    completion(result)
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func addReciept(expenseId: String, imageData: Data, completion: @escaping (Bool) -> Void) {
        signInIfNeeded() { result in
            switch result {
            case let .success(sessionId):
                let receiptService = ReceiptService(withSession: sessionId)
                receiptService.addReceipt(expenseId: expenseId, imageData: imageData) { result in
                    switch result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
            case .failure:
                completion(false)
            }
        }
    }

    public func getExpenses(company: Company, completion: @escaping (Result<[ExpenseEntry], ServiceError>) -> Void) {
        signInIfNeeded() { result in
            switch result {
            case let .success(sessionId):
                let expenseService = ExpenseService(withSession: sessionId)
                expenseService.getExpenses(companyFilter: company) { result in
                    completion(result)
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    public func deleteExpense(expenseId: String, completion: @escaping (Bool) -> Void) {
        signInIfNeeded() { result in
            switch result {
            case let .success(sessionId):
                let expenseService = ExpenseService(withSession: sessionId)
                expenseService.deleteExpense(expenseId: expenseId) { result in
                    switch result {
                    case .success:
                        completion(true)
                    case .failure:
                        completion(false)
                    }
                }
            case .failure:
                completion(false)
            }
        }
    }

    private func signInIfNeeded(completion: @escaping (Result<String, ServiceError>) -> Void) {
        if sessionInfo == nil || Date() > sessionInfo!.sessionExpiry {
            let signInService = SignInService()
            signInService.perform(with: userName, password: password) { result in
                switch result {
                case let .success(sessionId):
                    self.sessionInfo = SessionInfo(sessionId: sessionId, sessionExpiry: Date(timeIntervalSinceNow: 60*60))
                    completion(.success(sessionId))
                case let .failure(error):
                    self.sessionInfo = nil
                    completion(.failure(error))
                }
            }
        } else {
            completion(.success(sessionInfo!.sessionId))
        }
    }
}

