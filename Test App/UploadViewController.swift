import UIKit
import MapKit
import CoreLocation

class UploadViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var descriptionTextField: TextField!
    @IBOutlet weak var tagTextField: TextField!
    
    let imagePicker = UIImagePickerController()
    let locationManager = CLLocationManager()
    
    var latitude: Double?
    var longitude: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    func showAlert(message:String) {
        let alert = UIAlertController(title: "Something wrong", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func addImagePressed(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func uploadPressed(_ sender: UIButton) {
        if imageView.image == nil {
            showAlert(message: "Choose image")
            return
        } else if descriptionTextField.text == nil || descriptionTextField.text == "" {
            showAlert(message: "Fill the fields")
            return
        } else if tagTextField.text == nil || tagTextField.text == "" {
            showAlert(message: "Fill the fields")
            return
        } else if self.latitude == nil || self.longitude == nil {
            showAlert(message: "Wrong location")
            return
        }
        
        let description = descriptionTextField.text!
        let tag = tagTextField.text!
        
        let lat = String(describing: self.latitude!)
        let long = String(describing: self.longitude!)
        
        
        ServerManager.sharedInstance.upload(image: imageView.image!, description:description, tag:tag, latitude:lat, longitude:long) { response in
            if let JSON = response.result.value as? [String: AnyObject] {
                print("JSON: \(JSON)")
                if JSON["smallImage"] != nil {
                    self.navigationController!.popViewController(animated: true)
                } else {
                    self.showAlert(message: "The image width is too small or too large. Minimum width expected is 600px. Allowed maximum size is 2 MB.")
                }
            }
        }
        
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(descriptionTextField) {
            tagTextField.becomeFirstResponder();
        } else {
            textField.resignFirstResponder();
        }
        return true;
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        self.latitude = locValue.latitude
        self.longitude = locValue.longitude
    }
    
}
