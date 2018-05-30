//
//  ViewController.swift
//  MemeMe
//
//  Created by Maria Carolina Santos on 29/05/2018.
//  Copyright © 2018 Maria Carolina Marinho Séves Santos. All rights reserved.
//

import UIKit

// MARK: - ViewController: UIViewController, UIImagePickerControllerDelegate

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{

    
    // MARK: Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var toolBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var albumButton: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    
    // MARK: Properties

    let textAttributes: [String: Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -5.0]
    
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let textFields: [UITextField] = [topTextField, bottomTextField]
        
        for text in textFields{
            text.delegate = self
            text.defaultTextAttributes = textAttributes
            text.autocapitalizationType = .allCharacters
            text.textAlignment = .center
        }
        
        cancelButton.isEnabled = false
        shareButton.isEnabled = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // keyboard adjustments
        subscribeToKeyboardNotifications()
        
        // Disabling buttons
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // keyboard adjustments
        unsubscribeFromKeyboardNotifications()

    }
    
    
    // MARK: UIImagePickerDelegate, picking images
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickImage(source: .photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickImage(source: .camera)
    }
    
    func pickImage( source: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        present(imagePicker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage? {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            shareButton.isEnabled = true
            topTextField.text = "TOP"
            bottomTextField.text = "BOTTOM"
        }
        dismiss(animated: true, completion: nil)
        // Enabling sharing button
        shareButton.isEnabled = true
        cancelButton.isEnabled = true
        print("cheguei aqui!")
    }
    
    
    // MARK: TextField methods
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = nil
        textField.text = ""
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.placeholder = "..."
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    // MARK: Keyboard Methods and Delegates
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)

    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder{
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    // MARK: Meme manipulation
    func save(){
        let memedImage = generateMemedImage()
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, alteredImage: memedImage)
    }
    
    func generateMemedImage() -> UIImage{
        
        // TODO: hide toolbar and navbar
        toolBar.isHidden = true
        navBar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // todo: show toolbar and navbar
        toolBar.isHidden = false
        navBar.isHidden = false
        
        return memedImage
    }
    
    // MARK: Share Actions
    
    @IBAction func shareSelected(_ sender: Any) {
        
        let resultingMeme: UIImage = generateMemedImage()
        
        let shareActivityVC = UIActivityViewController(activityItems: [resultingMeme], applicationActivities: nil)
        shareActivityVC.completionWithItemsHandler = {
            (activityType, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if completed {
                let meme = Meme(topText: self.topTextField.text!,
                             bottomText: self.bottomTextField.text!,
                             originalImage: self.imageView.image!,
                             alteredImage: resultingMeme)
                self.restartAll()
            }
        }
        present(shareActivityVC, animated: true)
    }
    
    @IBAction func cancelSelected(_ sender: Any) {
        restartAll()
    }
    
    // MARK: TextFields
    
    func restartAll(){
        
        imageView.image = nil
        cancelButton.isEnabled = false
        shareButton.isEnabled = false
        
        var textfield: UITextField!
        for textfield in [topTextField, bottomTextField]{
            textfield?.isEnabled = false
            textfield?.text = ""
        }
        topTextField.placeholder = "top"
        bottomTextField.placeholder = "bottom"
    }
    
    
}


