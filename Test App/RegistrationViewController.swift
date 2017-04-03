import UIKit

class RegistrationViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    let serverManager = ServerManager.sharedInstance
    
    var avatarImage: UIImage?
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
    }
    
    func showAlert(message:String) {
        let alert = UIAlertController(title: "Something wrong", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    // MARK: - Actions
    
    @IBAction func selectImagePressed(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        if usernameTextField.text == nil || usernameTextField.text == "" {
            showAlert(message: "Incorect username")
            return
        } else if emailTextField.text == nil || emailTextField.text == "" {
            showAlert(message: "Incorect email")
            return
        } else if passwordTextField.text == nil || passwordTextField.text == "" {
            showAlert(message: "Incorect password")
            return
        }
        
        if !isValidEmail(testStr: emailTextField.text!) {
            showAlert(message: "Incorect email")
            return
        }
        
        let username = usernameTextField.text!
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        if avatarImage != nil {
            serverManager.register(withName: username, email: email, password: password, image: avatarImage!) { response in
                if response.result.value != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
        
    }
    
    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(usernameTextField) {
            emailTextField.becomeFirstResponder()
        } else if textField.isEqual(emailTextField) {
            passwordTextField.becomeFirstResponder()
        } else {
            passwordTextField.resignFirstResponder()
        }
        return true;
    }
    
    // MARK: - UIImagePickerControllerDelegate
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            avatarImage = pickedImage
        }
        
        self.dismiss(animated: true, completion: nil)
    }

}
