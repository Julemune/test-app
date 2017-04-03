//
//  GifViewController.swift
//  Test App
//
//  Created by Julemune on 4/3/17.
//  Copyright © 2017 Sergey Stryuk. All rights reserved.
//

import UIKit

class GifViewController: UIViewController {

    @IBOutlet weak var imageView: FLAnimatedImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ServerManager.sharedInstance.getGif() { imageUrlString in
            
            let imageUrl:NSURL = NSURL(string: imageUrlString)!
            let imageData:NSData = NSData(contentsOf: imageUrl as URL)!
            
            let gif = FLAnimatedImage(animatedGIFData: imageData as Data!)
            self.imageView.animatedImage = gif
            self.imageView.contentMode = UIViewContentMode.scaleAspectFit
            
        }
    }

}
