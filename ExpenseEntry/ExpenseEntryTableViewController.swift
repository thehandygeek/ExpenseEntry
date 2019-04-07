import UIKit
import MobileCoreServices
import TPKeyboardAvoiding

class ExpenseEntryTableViewController: UIViewController {
    
    enum TableRow: Int {
        case company = 0, date = 1, type = 2, amount = 3, capture = 4
    }
    
    private let tableRows: [TableRow] = [.company, .date, .type, .amount, .capture]
    private let companyKey = "Company"
    private let documentTypes = [String(kUTTypeJPEG), String(kUTTypeGIF), String(kUTTypePNG)]
 
    private var expensesModel: ExpensesModel!

    private var selectedDate = Date()
    private var enteredAmount = ""
    private var selectedType: ExpenseType = .meal
    private var recieptImage: UIImage?
    private var companyExpanded = false
    private var dateExpanded = false
    private var typeExpanded = false
    
    private let companyNameDict: [Company: String] = [.touchSciences: "Touch", .etp: "ETP", .hollandSunset: "Holland", .splashTravelling: "Splash"]
    
    private var companyNames: [String] {
        return companyNameDict.map { $0.value }
    }
    private var expenseTypes: [String] {
        return [ExpenseType.meal.rawValue, ExpenseType.auto.rawValue, ExpenseType.supplies.rawValue, ExpenseType.travel.rawValue]
    }

    @IBOutlet weak var tableView: TPKeyboardAvoidingTableView!
    @IBOutlet weak var countLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        expensesModel = ExpensesModel(company: getSavedCompany(), eventTarget: self)

        tableView.register(cellTypes: [.amount, .date, .picker, .capture])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateCount()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCamera" {
            if let cameraViewController = segue.destination as? CameraViewController {
                cameraViewController.delegate = self
            }
        }
        else if segue.identifier == "ShowReport" {
            if let reportController = segue.destination as? ExpenseReportTableViewController {
                reportController.set(expensesModel: expensesModel!)
            }
        }
    }
    
    @objc
    func applicationDidBecomeActive(_ notification: NSNotification) {
        selectedDate = Date()
        tableView.reloadData()
    }
    
    private func updateCount() {
        countLabel.text = "Record count: \(expensesModel.expenses.count)"
    }
    
    private func getSavedCompany() -> Company {
        guard let savedCompanyName = UserDefaults.standard.string(forKey: companyKey) else { return .touchSciences }
        return companyFrom(name: savedCompanyName)
    }
    
    private func saveCompany(company: Company) {
        let companyName = companyNameDict[company]
        UserDefaults.standard.set(companyName, forKey: companyKey)
    }
    
    private func companyFrom(name: String) -> Company {
        guard let company = companyNameDict.first(where: { $0.value == name }) else { return .touchSciences }
        
        return company.key
    }
    
    private func companyName(from company: Company) -> String {
        return companyNameDict[company] ?? "Touch"
    }
}

extension ExpenseEntryTableViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableRows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellDetails = cellDetailsFor(row: indexPath.row) else { return UITableViewCell() }
        guard let tableCell = tableView.dequeueReusableCell(withIdentifier: cellDetails.type.rawValue, for: indexPath) as? UITableViewCell & ConfigurableCell else {
            return UITableViewCell()
        }
        
        tableCell.configure(with: cellDetails)
        
        return tableCell
    }
    
    @IBAction func reportAction(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowReport", sender: nil)
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        guard let image = recieptImage,
            let imageData = UIImageJPEGRepresentation(image, 0.6),
            enteredAmount != "" else {
                return
        }
        
        let successTitle = "Expense Added"
        let successMessage = "You successfully added your expense"
        let failureTitle = "Expense Not Added"
        let failureMessage = "Request to add expense failed"
        let spinner = displaySpinner()
        expensesModel.addExpense(type: selectedType, date: selectedDate, amount: enteredAmount, reciept: imageData) { success in
            self.removeSpinner(spinner: spinner)
            let title = success ? successTitle : failureTitle
            let message = success ? successMessage : failureMessage
            self.showAlert(title: title, message: message)
            if success {
                self.enteredAmount = ""
                self.recieptImage = nil
                self.tableView.reloadData()
            }
        }
    }
    
    private func cellDetailsFor(row: Int) -> CellDetails? {
        guard let tableRow = TableRow(rawValue: row) else { return nil }
        switch tableRow {
        case .company:
            return PickerCellDetails(id: "Company", title: "Company", selectedValue: companyName(from:expensesModel.company), values: companyNames, expanded: companyExpanded, delegate: self)
        case .amount:
            return ExpenseAmountCellDetails(amount: enteredAmount, delegate: self)
        case .date:
            return DateCellDetails(date: selectedDate, expanded: dateExpanded, delegate: self)
        case .type:
            return PickerCellDetails(id: "Type", title: "Type", selectedValue: selectedType.rawValue, values: expenseTypes, expanded: typeExpanded, delegate: self)
        case .capture:
            return CaptureCellDetails(image: recieptImage, delegate: self)

        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        alertViewController.addAction(alertAction)
        self.present(alertViewController, animated: true, completion: nil)
    }
    
}

extension ExpenseEntryTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableRow = TableRow(rawValue: indexPath.row) else { return }
        
        if case .date = tableRow {
            dateExpanded.toggle()
            typeExpanded = false
            companyExpanded = false
            tableView.beginUpdates()
            tableView.reloadData()
            tableView.endUpdates()
        } else if case .company = tableRow {
            companyExpanded.toggle()
            typeExpanded = false
            dateExpanded = false
            tableView.beginUpdates()
            tableView.reloadData()
            tableView.endUpdates()
        } else if case .type = tableRow {
            typeExpanded.toggle()
            dateExpanded = false
            companyExpanded = false
            tableView.beginUpdates()
            tableView.reloadData()
            tableView.endUpdates()
        }
    }
}

extension ExpenseEntryTableViewController: DateTableViewCellDelegate {
    func dateUpdated(date: Date) {
        self.selectedDate = date
    }
}

extension ExpenseEntryTableViewController: PickerTableViewCellDelegate {
    func valueUpdated(id: String, value: String) {
        if id == "Company" {
            let company = companyFrom(name: value)
            expensesModel = ExpensesModel(company: company, eventTarget: self)
            saveCompany(company: company)
        } else if id == "Type" {
            selectedType = ExpenseType(rawValue: value) ?? .meal
        }
    }
}

extension ExpenseEntryTableViewController: ExpenseAmountTableViewCellDelegate {
    func amountUpdated(amount: String) {
        enteredAmount = amount
    }
}

extension ExpenseEntryTableViewController: CaptureTableViewCellDelegate {
    func captureAction(_ sender: UIButton) {
        performSegue(withIdentifier: "ShowCamera", sender: nil)
    }
    
    func selectAction(_ sender: UIButton) {
        let actionSheet = UIAlertController(title: "Select Source", message: nil, preferredStyle: .actionSheet)
        let documentAction = UIAlertAction(title: "File", style: .default) { action in
            let importMenu = UIDocumentMenuViewController(documentTypes: self.documentTypes, in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.present(importMenu, animated: true, completion: nil)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { action in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let photoPicker = UIImagePickerController()
                photoPicker.delegate = self
                photoPicker.sourceType = .photoLibrary
                
                self.present(photoPicker, animated: true, completion: nil)
            }
        }
        
        actionSheet.addAction(documentAction)
        actionSheet.addAction(photoLibraryAction)
        self.present(actionSheet, animated: true, completion: nil)
    }
}

extension ExpenseEntryTableViewController: CameraViewContollerDelegate {
    func dismiss(viewController: CameraViewController, image: UIImage) {
        recieptImage = image
        navigationController?.popViewController(animated: true)
        
        tableView.reloadData()
    }
}

extension ExpenseEntryTableViewController: ExpensesModelEvents {
    func expensesChanged(expenses: [ExpenseEntry]) {
        updateCount()
    }
}

extension ExpenseEntryTableViewController: UIDocumentMenuDelegate,UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let myURL = url as URL
        let fileManager = FileManager.default
        guard let imageData = fileManager.contents(atPath: myURL.path),
            let image = UIImage.init(data: imageData , scale: 1.0) else { return }
        recieptImage = image
        
        tableView.reloadData()
    }
    
    
    public func documentMenu(_ documentMenu:UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("view was cancelled")
        dismiss(animated: true, completion: nil)
    }
    
}

extension ExpenseEntryTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            recieptImage = image
            tableView.reloadData()
        }
        dismiss(animated: true, completion: nil)
    }
}
