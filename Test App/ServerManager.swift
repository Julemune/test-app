import UIKit
import Alamofire

class ServerManager {

    static let sharedInstance = ServerManager()
    
    let apiURL = "http://api.doitserver.in.ua"
    
    enum methods: String {
        case login  = "/login"
        case all    = "/all"
        case gif    = "/gif"
        case image  = "/image"
        case create = "/create"
    }
    
    func login(withEmail email:String, password:String, completionHandler:@escaping (DataResponse<Any>) -> Void) {
        let url = URL(string: apiURL + methods.login.rawValue)!
        let parameters = ["email":email,
                          "password":password]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON { response in
            completionHandler(response)
        }
    }
    
    func register(withName name:String, email:String, password:String, image:UIImage, completionHandler:@escaping (DataResponse<Any>) -> Void) {
        let url = URL(string: apiURL + methods.create.rawValue)!
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if let imageData = UIImageJPEGRepresentation(image, 1) {
                multipartFormData.append(imageData, withName: "avatar", fileName: "file.png", mimeType: "image/png")
            }
            
            multipartFormData.append(name.data(using: .utf8)!, withName: "username")
            multipartFormData.append(email.data(using: .utf8)!, withName: "email")
            multipartFormData.append(password.data(using: .utf8)!, withName: "password")
            
        }, to: url, method: .post, headers: nil, encodingCompletion: { encodingResult in
            switch encodingResult {
            case .success(let upload, _, _):
                upload.response { response in
                    upload.responseJSON { response in
                        completionHandler(response)
                    }
                }
            case .failure(let encodingError):
                print("error:\(encodingError)")
            }
        })
    }
    
    func getImages(completionHandler:@escaping (DataResponse<Any>) -> Void) {
        let url = URL(string: apiURL + methods.all.rawValue)!
        
        let headers: HTTPHeaders = [
            "token": DataManager.sharedInstance.token!,
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            completionHandler(response)
        }
    }
    
    func getGif(completionHandler:@escaping (String) -> Void) {
        let url = URL(string: apiURL + "/gif")!
        
        let headers: HTTPHeaders = [
            "token": DataManager.sharedInstance.token!,
            "Content-Type": "application/json"
        ]
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers).responseJSON { response in
            if let JSON = response.result.value as? [String: AnyObject] {
                if JSON["gif"] != nil {
                    completionHandler(JSON["gif"] as! String)
                }
            }
        }
        
    }
    
    func upload(image:UIImage, description:String, tag:String, latitude:String, longitude:String, completionHandler:@escaping (DataResponse<Any>) -> Void) {
        let url = URL(string: apiURL + "/image")!
        
        let headers: HTTPHeaders = [
            "token": DataManager.sharedInstance.token!,
            "Content-Type": "application/json"
        ]
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                let imageData = UIImageJPEGRepresentation(image, 1)!
                multipartFormData.append(imageData, withName: "image", fileName: "file.jpg", mimeType: "image/jpg")
                multipartFormData.append(description.data(using: .utf8)!, withName: "description")
                multipartFormData.append(tag.data(using: .utf8)!, withName: "hashtag")
                multipartFormData.append(latitude.data(using: .utf8)!, withName: "latitude")
                multipartFormData.append(longitude.data(using: .utf8)!, withName: "longitude")
        }, to: url, method: .post, headers: headers, encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        completionHandler(response)
                    }
                case .failure(let encodingError):
                    print("error:\(encodingError)")
                }
        }
        )
    }
    
}
