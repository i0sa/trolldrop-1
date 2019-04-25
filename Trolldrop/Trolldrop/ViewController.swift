//
//  ViewController.swift
//  Trolldrop
//
//  Created by midnightchips on 4/24/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

import UIKit

extension UIButton {
    func toBarButtonItem() -> UIBarButtonItem? {
        return UIBarButtonItem(customView: self)
    }
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    let imagePicker = UIImagePickerController();
    var pathForImage: URL!
    
    //Get Image
    @IBAction func selectImageTapped(_ sender: UIButton) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        imagePicker.modalPresentationStyle = .popover
        present(imagePicker, animated: true, completion: nil)
        imagePicker.popoverPresentationController?.barButtonItem = sender.toBarButtonItem()
    }
    
    @IBAction func startTroll(_ sender: UIButton) {
        if(pathForImage == nil){
            let alert = UIAlertController(title: "Error", message: "Please Select an Image", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "Ok", style: .default) { (action:UIAlertAction) in
            }
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil);
        }else{
            NSLog("trollDrop STARTINGTROLL")
            let trollController = TrollController(sharedURL: pathForImage, rechargeDuration: 3) { (message) in
                NSLog("trollDrop Hello \(message)");
            }
            trollController.start()
            
            
            RunLoop.main.run()
            
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        // Do any additional setup after loading the view, typically from a nib.
    }
    //Full Screen when image is tapped
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        if(imageView.image == nil){
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            imagePicker.modalPresentationStyle = .popover
            present(imagePicker, animated: true, completion: nil)
            //Fix this at some point for iPads
            imagePicker.popoverPresentationController?.barButtonItem = selectButton.toBarButtonItem()
        }else{
            let newImageView = UIImageView(image: imageView.image)
            newImageView.frame = UIScreen.main.bounds
            newImageView.backgroundColor = .black
            newImageView.contentMode = .scaleAspectFit
            newImageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
            newImageView.addGestureRecognizer(tap)
            UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                self.view.addSubview(newImageView)
            }, completion: nil)
            //self.view.addSubview(newImageView)
            self.navigationController?.isNavigationBarHidden = true
            self.tabBarController?.tabBar.isHidden = true
        }
        
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            sender.view?.removeFromSuperview()
            self.tabBarController?.tabBar.isHidden = false
        }, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //UIImagePickerControllerDelegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imgUrl = info[UIImagePickerControllerImageURL] as? URL{
            //NSLog(imgUrl.absoluteString)
            pathForImage = imgUrl
            NSLog("trollDrop \(pathForImage.absoluteString)")
        }
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .scaleAspectFit
            imageView.image = pickedImage
            dismiss(animated:true, completion: nil)
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}


