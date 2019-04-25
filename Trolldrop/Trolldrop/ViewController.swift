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

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectButton: UIButton!
    let imagePicker = UIImagePickerController();
    var pathForImage: URL!
    var rechargeTime: TimeInterval = 3
    var output: [String] = [String]()
    let cellReuseIdentifier = "cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        self.textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        //setup tableView cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
        //init toolbar
        let toolbar:UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0,  width: self.view.frame.size.width, height: 30))
        
        //create left side empty space so that done button set on right side
        let flexSpace = UIBarButtonItem(barButtonSystemItem:    .flexibleSpace, target: nil, action: nil)
        
        let doneBtn: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneBtn], animated: false)
        toolbar.sizeToFit()
        
        //setting toolbar as inputAccessoryView
        self.textField.inputAccessoryView = toolbar
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
    }
    
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
            let trollController = TrollController(sharedURL: pathForImage, rechargeDuration: rechargeTime) { (message) in
                //self.output.append(message[0] as String)
                self.output.insert(message[0] as String, at: 0)
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                self.tableView.endUpdates()
            }
            trollController.start()
            
            
            RunLoop.main.run()
            
        }
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
    
    //UITextView
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if(textField.text?.isEmpty)!{
            rechargeTime = 3
        }else{
            rechargeTime = Double(textField.text!)!
        }
        return true
    }
    
    //TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.output.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = (self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as UITableViewCell?)!
        
        // set the text from the data model
        cell.textLabel?.text = self.output[indexPath.row]
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    

}


