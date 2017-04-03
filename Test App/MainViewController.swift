import UIKit

class MainViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var images = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        add.tintColor = UIColor.white
        let play = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playTapped))
        play.tintColor = UIColor.white
        
        navigationItem.rightBarButtonItems = [add, play]
        
        automaticallyAdjustsScrollViewInsets = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.images = [AnyObject]()
        
        ServerManager.sharedInstance.getImages() { response in
            if let JSON = response.result.value as? [String: AnyObject] {
                if JSON["images"] != nil {
                    let json = JSON["images"]!
                    for dict in json as! Array<Any> {
                        self.images.append(dict as AnyObject)
                    }
                    
                    self.collectionView!.reloadData()
                }
            }
        }
        
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: 100, height: collectionView.frame.height * 0.9)
    }
    
    
    // MARK: - Actions

    func addTapped() {
        self.navigationController!.pushViewController(self.storyboard!.instantiateViewController(withIdentifier: "UploadViewController") as! UploadViewController, animated: true)
    }
    
    func playTapped() {
        self.navigationController!.pushViewController(self.storyboard!.instantiateViewController(withIdentifier: "GifViewController") as! GifViewController, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath as IndexPath)
        myCell.backgroundColor = UIColor.black
        myCell.subviews.forEach({ $0.removeFromSuperview() })
        
        let imageDictionary = self.images[indexPath.row] as! NSDictionary
        let imageUrlString = imageDictionary.object(forKey: "smallImagePath") as! String
        let imageUrl:NSURL = NSURL(string: imageUrlString)!
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            let imageData:NSData = NSData(contentsOf: imageUrl as URL)!
            let imageView = UIImageView(frame: CGRect(x:0, y:0, width:myCell.frame.size.width, height:myCell.frame.size.height))
            
            DispatchQueue.main.async {
                
                let image = UIImage(data: imageData as Data)
                imageView.image = image
                imageView.contentMode = UIViewContentMode.scaleAspectFit
                
                myCell.addSubview(imageView)
            }
        }
        
        return myCell
    }

}
