//
//  ExpensesAPI.swift
//  ExpenseEntry
//
//  Created by Scott Champ on 2016-12-21.
//  Copyright © 2016 Touch Sciences. All rights reserved.
//

import UIKit
import CoreData

class ExpensesAPI {
    
    fileprivate var context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func addExpense(date: Date, type: String, amount: NSDecimalNumber) {
        do {
            let expense = ExpenseEntry(context: self.context)
            //3
            expense.type = type
            expense.date = date as NSDate?
            expense.amount = amount
            
            try self.context.save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func getExpenses() -> [ExpenseEntry] {
        var expenses = [ExpenseEntry]()
        
        do {
            let fetchRequest = NSFetchRequest<ExpenseEntry>(entityName: "ExpenseEntry")
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
            
            expenses = try self.context.fetch(fetchRequest)
        } catch let error as NSError  {
            print("Could not load \(error), \(error.userInfo)")
        }
        
        return expenses
    }
    
    func getExpenseCount() -> Int {
        var result: Int = 0
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExpenseEntry")
            result = try context.count(for: fetchRequest)
        } catch let error as NSError  {
            print("Could not count expenses \(error), \(error.userInfo)")
        }
        
        return result
    }
    
    func deleteExpense(expense: ExpenseEntry) {
        do {
            self.context.delete(expense)
            try self.context.save()
        } catch let error as NSError  {
            print("Could not delete \(error), \(error.userInfo)")
        }
    }
    
    func deleteAll() {
        do {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExpenseEntry")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            try self.context.execute(deleteRequest)
        } catch let error as NSError  {
            print("Could not delete all \(error), \(error.userInfo)")
        }
    }
    
    func generateCSVContent() -> String {
        let expenses = self.getExpenses()
        var csvText: String = ""
        
        for expense in expenses {
            csvText.append(String(format: "%@,%@,%@\r\n", expense.toDateString(), expense.type!, expense.toAmountString()))
        }
        return csvText
    }
    
}
