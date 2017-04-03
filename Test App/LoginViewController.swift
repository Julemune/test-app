import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Something wrong", message: "Wrong email or password", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Try again", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func signInPressed(_ sender: UIButton) {
        
        if emailTextField.text == nil || emailTextField.text == "" {
            showAlert()
            return
        } else if passwordTextField.text == nil || passwordTextField.text == "" {
            showAlert()
            return
        }
        
        let email = emailTextField.text!
        let password = passwordTextField.text!
        
        ServerManager.sharedInstance.login(withEmail: email, password: password) { response in
            if let JSON = response.result.value as? [String: AnyObject] {
                if JSON["token"] != nil {
                    DataManager.sharedInstance.token = JSON["token"] as! String?
                    
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "UINavigationController") as! UINavigationController
                    self.present(vc, animated: true, completion: nil)
                } else {
                    self.showAlert()
                }
            }
        }
    }
    
    @IBAction func signUpPressed(_ sender: UIButton) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "RegistrationViewController") as! RegistrationViewController
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - UITextFieldDelegate
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(emailTextField) {
            passwordTextField.becomeFirstResponder();
        } else {
            textField.resignFirstResponder();
        }
        return true;
    }

}
