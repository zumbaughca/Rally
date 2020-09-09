//
//  NewRallyTableViewController.swift
//  
//
//  Created by Chuck Zumbaugh on 8/9/20.
//

import UIKit
import Firebase
import MapKit

class NewRallyTableViewController: UITableViewController, UITextViewDelegate, LocationSearchDelegate {

    @IBOutlet weak var rallyDateLabel: UILabel!
    @IBOutlet weak var rallyNameTextField: UITextField!
    @IBOutlet weak var rallyDatePicker: UIDatePicker!
    @IBOutlet weak var rallyDescriptionTextView: UITextView!
    @IBOutlet weak var locationLabel: UILabel!
    
    let datePickerIndexPath = IndexPath(row: 2, section: 0)
    let dateLabelIndexPath = IndexPath(row: 1, section: 0)
    let textFieldIndexPath = IndexPath(row: 4, section: 0)
    var isDatePickerShown: Bool = false {
        willSet {
            rallyDatePicker.isHidden = isDatePickerShown
        }
    }
    var rallyLocation: MKMapItem?
    let reference = Database.database().reference().child("Rallys")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextViewPlaceholderText()
        self.rallyDescriptionTextView.delegate = self
        rallyDescriptionTextView.layer.borderColor = UIColor.black.cgColor
        rallyDescriptionTextView.layer.borderWidth = CGFloat(1)
    }
    
    func updateDateLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        rallyDateLabel.text = dateFormatter.string(from: rallyDatePicker.date)
    }
    
    @IBAction func datePickerDateChenged(_ sender: Any) {
        updateDateLabel()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath {
        case dateLabelIndexPath:
            if isDatePickerShown {
                isDatePickerShown = false
            } else {
                isDatePickerShown = true
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath {
        case datePickerIndexPath:
            if isDatePickerShown {
                return 216
            } else {
                return 0
            }
        case textFieldIndexPath:
            return 200
        case IndexPath(row: 1, section: 0):
            return 50
        default:
            return UITableView.automaticDimension
        }
        
    }
    
    func didSelectLocation(location: MKMapItem) {
        locationLabel.text = location.placemark.title
        rallyLocation = location
        tableView.reloadData()
    }
    
    func setTextViewPlaceholderText() {
        rallyDescriptionTextView.text = "Enter a description for the event..."
        rallyDescriptionTextView.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if rallyDescriptionTextView.textColor == UIColor.lightGray {
            rallyDescriptionTextView.text = nil
            rallyDescriptionTextView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if rallyDescriptionTextView.text == "" || rallyDescriptionTextView.text == nil {
            setTextViewPlaceholderText()
        }
    }
    
    func validateRally() throws {
        if rallyNameTextField.text == nil || rallyNameTextField.text == "" || rallyNameTextField.text == " " {
            throw RallyError.nameIsEmpty
        }
        if rallyDateLabel.text == "Not Set" {
            throw RallyError.dateNotSet
        }
        if rallyLocation == nil {
            throw RallyError.locationNotSet
        }
        if rallyDescriptionTextView.text == "Enter a description for the event..." || rallyDescriptionTextView.text == "" || rallyDescriptionTextView.text == " " || rallyDescriptionTextView.text == nil {
            throw RallyError.descriptionIsEmpty
        }
    }
    
    func createErrorAlert(_ errorText: String) {
        let alertController = UIAlertController(title: "Error!", message: errorText, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func createNewDate() -> String {
        let dateFormatter = DateFormatter()
        let date = rallyDatePicker.date
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    func saveRallyToDatabase() {
        do {
            try validateRally()
            let newRallyReference = reference.childByAutoId()
            guard let user = Auth.auth().currentUser else {return}
            newRallyReference.updateChildValues(["Name": rallyNameTextField.text!, "Owner": user.displayName!, "OwnerUid": user.uid, "Date": createNewDate(), "Address": rallyLocation!.placemark.title!, "Longitude": rallyLocation!.placemark.coordinate.longitude, "Latitude": rallyLocation!.placemark.coordinate.latitude, "Description": rallyDescriptionTextView.text!, "Key": newRallyReference.key, "NumberOfAttendees": 0])
        } catch RallyError.nameIsEmpty {
            createErrorAlert("Please enter a name for the rally.")
        } catch RallyError.dateNotSet {
            createErrorAlert("Please set a date for the rally.")
        } catch RallyError.locationNotSet {
            createErrorAlert("Please set a location for the rally.")
        } catch RallyError.descriptionIsEmpty {
            createErrorAlert("Please enter a description for the rally.")
        } catch {
            createErrorAlert("Unexpected error. Please try again later.")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveRallyToDatabase()
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectLocationSegue" {
            let destinationViewController = segue.destination as? LocationSearchTableViewController
            destinationViewController?.delegate = self
        }
    }
    
}
