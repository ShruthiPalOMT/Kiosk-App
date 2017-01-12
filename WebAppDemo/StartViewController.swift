//
//  StartViewController.swift
//  WebAppDemo
//
//  Created by Yilei He on 6/12/16.
//  Copyright © 2016 Yilei He. All rights reserved.
//

import UIKit

let argumentsUserDefaultsKey = "com.rightcrowd.argumentsUserDefaultsKey"

class StartViewController: UIViewController {

    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var idleSecondsTexField: UITextField!
    @IBOutlet weak var argumentsTableView: UITableView!
    var arguments: [String: String] {
        get {
            return UserDefaults.standard.value(forKey: argumentsUserDefaultsKey) as? [String: String] ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: argumentsUserDefaultsKey)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        view.addTapToHideKeyboardGesture()
        versionLabel.text = UIApplication.versionBuildInformation
        idleSecondsTexField.delegate = self
        argumentsTableView.delegate = self
        argumentsTableView.dataSource = self
        argumentsTableView.layer.borderWidth = 1
        argumentsTableView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func buttonTapped(button: UIButton) {
        let vc = WebViewController()
        var urlString = urlTextField.text!.trimmed()
        if let arguments = UserDefaults.standard.value(forKey: argumentsUserDefaultsKey) as? [String: String] {
            if let _ = urlString.range(ofRegularExpression: "\\?\\w*=\\w*[&\\w*=\\w*]*") {
                for (key, value) in arguments {
                    urlString += "&\(key)=\(value)"
                }
            } else {
                urlString += "?"
                var temp = ""
                for (key, value) in arguments {
                    temp += "&\(key)=\(value)"
                }
                temp = String(temp.characters.dropFirst())
                urlString += temp
            }
        }
        
        vc.urlString = urlString
        present(vc, animated: true, completion: nil)
    }
}

extension StartViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let view = view as? YHKeyboardAvoidingView {
            view.focusedView = textField
        }
    }
    
//    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
//    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let period = Double(textField.text!) {
            idlePeriodSeconds = period
        }
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


extension StartViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arguments.keys.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ArgumentsTableViewCell else {return}
        let key = Array(arguments.keys)[indexPath.row]
        cell.keyLabel.text = key
        cell.valueLabel.text = arguments[key]
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let key = Array(arguments.keys)[indexPath.row]
            arguments[key] = nil
            tableView.reloadData()
        }
    }
    
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let action = UITableViewRowAction(style: .destructive, title: "Delete") {[unowned self] (action, indexPath) in
//            let key = Array(self.arguments.keys)[indexPath.row]
//            self.arguments[key] = nil
//            tableView.reloadData()
//        }
//        return [action]
//    }
    
    
    
    
    
    @IBAction func editButtonTapped(button: UIButton) {
        if argumentsTableView.isEditing {
            button.setTitle("Edit", for: .normal)
        } else {
            button.setTitle("Done", for: .normal)
        }
        argumentsTableView.setEditing(!argumentsTableView.isEditing, animated: true)
    }
    
    
    @IBAction func addButtonTapped() {
        let alertControl = UIAlertController(title: "Adding", message: nil, preferredStyle: .alert)
        var keyTextField: UITextField!
        var valueTextField: UITextField!
        alertControl.addTextField { (textField) in
            textField.placeholder = "Key"
            keyTextField = textField
        }
        alertControl.addTextField { (textField) in
            textField.placeholder = "Value"
            valueTextField = textField
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "OK", style: .default) { [unowned self] (_) in
            if let key = keyTextField.text, let value = valueTextField.text, !key.isEmpty && !value.isEmpty {
                self.arguments[key] = value
                self.argumentsTableView.reloadData()
            }
        }
        
        alertControl.addAction(cancelAction)
        alertControl.addAction(okAction)
        
        
        present(alertControl, animated: true, completion: nil)
    }
}
