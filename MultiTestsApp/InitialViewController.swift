//
//  InitialViewController.swift
//  MultiTestsApp
//
//  Created by Afzal Hossain on 9/21/18.
//  Copyright © 2018 NDMobileCompLab. All rights reserved.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var birthYearTextField: UITextField!
    @IBOutlet weak var diagnosisTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func startAction(_ sender: Any) {

        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        

        let firstName = firstNameTextField.text?.lowercased()
        let lastName = lastNameTextField.text?.lowercased()
        let birthYear = birthYearTextField.text?.lowercased()
        let diagnosis = diagnosisTextField.text?.lowercased()
        
        
        var token = "\(firstName)_\(lastName)_\(birthYear)_\(diagnosis)"
        if Utils.getDataFromUserDefaults(key: token) != nil{
            //print("found data for user token \(Utils.getDataFromUserDefaults(key: token))")
            let initialViewController = storyBoard.instantiateViewController(withIdentifier: "maintablevc") as! MainTableViewController
            initialViewController.firstName = firstName!
            initialViewController.lastName = lastName!
            initialViewController.birthYear = birthYear!
            initialViewController.diagnosis = diagnosis!
            self.navigationController?.pushViewController(initialViewController, animated: true)

        } else{
            //print("first time user token \(Utils.getDataFromUserDefaults(key: token))")
            Utils.saveDataToUserDefaults(data: "1", key: token)
            let initialViewController = storyBoard.instantiateViewController(withIdentifier: "consentvc") as! ConsentViewController
            initialViewController.firstName = firstName!
            initialViewController.lastName = lastName!
            initialViewController.birthYear = birthYear!
            initialViewController.diagnosis = diagnosis!
            self.navigationController?.pushViewController(initialViewController, animated: true)

        }
        

    }
    
}
