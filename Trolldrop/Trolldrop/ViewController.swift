//
//  ViewController.swift
//  Trolldrop
//
//  Created by midnightchips on 4/24/19.
//  Copyright © 2019 midnightchips. All rights reserved.
//

import UIKit


extension UIImage {
    
    func getImageRatio() -> CGFloat {
        
        let imageRatio = CGFloat(self.size.width / self.size.height)
        
        return imageRatio
        
    }
    
}


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

//TableCell Classes

class ImageCell : UITableViewCell{
    
    @IBOutlet weak var displayImage: UIImageView!
}

class ImageSelectCell : UITableViewCell{
    
    @IBOutlet weak var selectImageLabel: UILabel!
}

class CoolDownPickerCell : UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource{
    var pickerData: [String] = [String]()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    
    
    
    @IBOutlet weak var picker: UIPickerView!
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var selectButton: UIButton!
    let imagePicker = UIImagePickerController();
    var pathForImage: URL!
    var output: [String] = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Target")
        imagePicker.delegate = self
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        segue.destination.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    @objc func doneButtonAction() {
        self.view.endEditing(true)
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
            let indexPath = IndexPath(row: 0, section: 1)
            let cell = tableView.cellForRow(at: indexPath) as! CoolDownPickerCell
            let coolDown = cell.picker.selectedRow(inComponent: 0)
            NSLog(String(coolDown));
            let trollController = TrollController(sharedURL: pathForImage, rechargeDuration: TimeInterval(coolDown)) { (message) in
                //self.output.append(message[0] as String)
                self.output.insert(message[0] as String, at: 0)
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 2)], with: .automatic)
                self.tableView.endUpdates()
                
            }
            trollController.start()
            
            
            RunLoop.main.run()
            
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
    
    //TableView
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "Image"
        }else if(section == 1){
            return "Cooldown"
        }else{
            return "Targets"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 2
        }else if(section == 1){
            return 1
        }else{
            return output.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(indexPath == [0,0]){
            if(pathForImage != nil){
                let data = try? Data(contentsOf: pathForImage!)
                let currentImage = UIImage(data: data!)
                let imageRatio = currentImage?.getImageRatio()
                return tableView.frame.width / imageRatio!
            }
        }
        if(indexPath == [0,1]){
            return CGFloat(44)
        }else{
            return UITableViewAutomaticDimension;
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath == [0,0]){
            let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageCell
            
            // set the text from the data model
            if(pathForImage != nil){
                let data = try? Data(contentsOf: pathForImage!)
                cell.displayImage!.image = UIImage(data: data!)
            }
            
            
            return cell
        }
        if(indexPath == [0,1]){
            // create a new cell if needed or reuse an old one
            let cell = tableView.dequeueReusableCell(withIdentifier: "SelectImage", for: indexPath) as! ImageSelectCell
            
            // set the text from the data model
            cell.selectImageLabel?.text = "Select Image"
            
            return cell
        }
        if(indexPath == [1,0]){
            // create a new cell if needed or reuse an old one
            let cell = tableView.dequeueReusableCell(withIdentifier: "PickerCell", for: indexPath) as! CoolDownPickerCell
            
            cell.picker.delegate = cell
            cell.picker.dataSource = cell
            if(cell.pickerData.isEmpty){
                for number in 0...60{
                    if(number == 1){
                        cell.pickerData.append("\(String(number)) Second" )
                    }else{
                        cell.pickerData.append("\(String(number)) Seconds" )
                    }
                }
            }
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Target", for: indexPath)
            cell.textLabel?.text = output[indexPath.row]
            return cell
        }
        
        
        
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.section).")
        if(indexPath == [0,0]){
            //let cell = tableView.cellForRow(at:indexPath) as! ImageCell
            
            if(pathForImage == nil){
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                imagePicker.modalPresentationStyle = .popover
                present(imagePicker, animated: true, completion: nil)
                //Fix this at some point for iPads
                imagePicker.popoverPresentationController?.barButtonItem = selectButton.toBarButtonItem()
            }else{
                let data = try? Data(contentsOf: pathForImage!)
                let currentImage = UIImage(data: data!)
                let newImageView = UIImageView(image: currentImage)
                newImageView.frame = UIScreen.main.bounds
                newImageView.backgroundColor = .black
                newImageView.contentMode = .scaleAspectFit
                newImageView.isUserInteractionEnabled = true
                let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
                //let swipe = UISwipeGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
                newImageView.addGestureRecognizer(tap)
                //newImageView.addGestureRecognizer(swipe)
                UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
                    self.view.addSubview(newImageView)
                }, completion: nil)
                //self.view.addSubview(newImageView)
                self.navigationController?.isNavigationBarHidden = true
                self.tabBarController?.tabBar.isHidden = true
            }
        }else if(indexPath == [0,1]){
            imagePicker.allowsEditing = false
            imagePicker.sourceType = .photoLibrary
            imagePicker.modalPresentationStyle = .popover
            present(imagePicker, animated: true, completion: nil)
            //imagePicker.popoverPresentationController?.barButtonItem =
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    //UIImagePickerControllerDelegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let imgUrl = info[UIImagePickerControllerImageURL] as? URL{
            //NSLog(imgUrl.absoluteString)
            pathForImage = imgUrl
            NSLog("trollDrop \(pathForImage.absoluteString)")
            tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        dismiss(animated:true, completion: nil)
        
        /*if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            DisplayCell.imageView?.contentMode = .scaleAspectFit
            DisplayCell.imageView?.image = pickedImage
            dismiss(animated:true, completion: nil)
        }*/
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //Scroll Picker
    
    
    
    
    
    
    
    

}


