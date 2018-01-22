//
//  ExpenseReportTableViewController.swift
//  ExpenseEntry
//
//  Created by Scott Champ on 2016-12-21.
//  Copyright © 2016 Touch Sciences. All rights reserved.
//

import UIKit
import CoreData

class ExpenseReportTableViewController: UITableViewController {
    
    private var expensesModel: ExpensesModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    func set(expensesModel: ExpensesModel) {
        self.expensesModel = expensesModel
    }
    
    @IBAction func shareButtonAction(sender: UIBarButtonItem) {
        guard let url = self.exportToFileURL() else {
                return
        }
        
        let activityViewController = UIActivityViewController(
            activityItems: ["Expenses.", url],
            applicationActivities: nil)
        activityViewController.completionWithItemsHandler = {
            (activity, success, items, error) in
            try? FileManager.default.removeItem(at: url)
        }
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.barButtonItem = (sender)
        }
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func trashButtonAction(sender: UIBarButtonItem) {
        let alertViewController = UIAlertController(title: "Delete Expenses", message: "Are you sure you want to delete all expenses?", preferredStyle: UIAlertControllerStyle.alert)
        let okAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler:
            {(alert: UIAlertAction!) in
                self.expensesModel!.expenses.removeAll()
                try? self.expensesModel!.save()
                self.tableView.reloadData()
        })
        let cancelAlertAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default, handler: nil)
        alertViewController.addAction(okAlertAction)
        alertViewController.addAction(cancelAlertAction)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    func exportToFileURL() -> URL? {
//        let expense = expensesModel.expenses[0]
//        let blankDocPath: String = Bundle.main.path(forResource: "blank", ofType: "xlsx")!
//        let spreadsheet = BRAOfficeDocumentPackage.open(blankDocPath)!
//        let firstWorksheet = spreadsheet.workbook.worksheets[0] as! BRAWorksheet
//        var cell = firstWorksheet.cell(forCellReference: "A1", shouldCreate: true)!
//        cell.setStringValue(expense.type)
//        cell = firstWorksheet.cell(forCellReference: "B1", shouldCreate: true)!
//        cell.setStringValue(expense.toDateString())
//        cell = firstWorksheet.cell(forCellReference: "C1", shouldCreate: true)!
//        cell.setStringValue(String(expense.toAmountString()))
//        let image = UIImage(data: expense.recieptImage)
//        //preserveTransparency force JPEG (NO) or PNG (YES)
//        let drawing = firstWorksheet.add(image, inCellReferenced: "D20", withOffset: CGPoint.zero, size: CGSize.init(width: 200, height: 200), preserveTransparency: false)
//        //let drawing: BRAWorksheetDrawing = firstWorksheet.add(image, betweenCellsReferenced: "D1", and: "E10", with: UIEdgeInsets.zero, preserveTransparency: false)
//        //Set drawing insets (percentage)
//        drawing!.insets = UIEdgeInsetsMake(0.0, 0.0, 0.5, 0.5)
//        let sheetImage = firstWorksheet.image(forCellReference: "D1")
//        let sheetImageData = UIImageJPEGRepresentation(sheetImage!.uiImage!, 0.8)
//        guard let path = FileManager.default
//            .urls(for: .documentDirectory, in: .userDomainMask).first else {
//                return nil
//        }
//        let saveFileURL = path.appendingPathComponent(expensesModel.expenses[0].toMonthString() + "-Expenses.xlsx")
//        spreadsheet.save(as: saveFileURL.path)
//
//        return saveFileURL
        guard let path = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask).first else {
                return nil
        }

        return expensesModel!.generateZip(path: path)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expensesModel!.expenses.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseEntry", for: indexPath) as! ExpenseEntryTableViewCell

        // Configure the cell...
        let expenseEntry = expensesModel!.expenses[indexPath.row]
        cell.dateLabel.text = expenseEntry.toDateString()
        cell.typeLabel.text = expenseEntry.type
        cell.amountLabel.text = expenseEntry.toAmountString()
        cell.recieptImage.image = UIImage(data: expenseEntry.recieptImage)
        

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            expensesModel!.expenses.remove(at: indexPath.row)
            try? expensesModel!.save()
            self.tableView.reloadData()
        }
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
