//  Created by Islam on 20/08/2018.
//  Copyright (c) 2018 Islam ElGaafary. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework
class ChatViewController: UIViewController , UITableViewDelegate , UITableViewDataSource, UITextFieldDelegate {
    
    
    var messageArray : [Message] = [Message]()
    
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        messageTextfield.delegate = self

        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)

        messageTableView.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        configureTableView()
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
       
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
        
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String! {
            cell.avatarImageView.backgroundColor = UIColor.flatSkyBlue()
            cell.messageBackground.backgroundColor = UIColor.flatBlueColorDark()
        }else {
            cell.avatarImageView.backgroundColor = UIColor.flatGray()
            cell.messageBackground.backgroundColor = UIColor.flatGrayColorDark()
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    
    @objc func tableViewTapped (){
        messageTextfield.endEditing(true)
    }
    
    
    func configureTableView(){
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded()
        })
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = 60
            self.view.layoutIfNeeded()
        })
    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        messageTextfield.endEditing(true)
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messageDB = Database.database().reference().child("Messages")
        let messageDictionary = ["Sender" : Auth.auth().currentUser?.email ,
                                 "MessageBody" : messageTextfield.text!]
        
        messageDB.childByAutoId().setValue(messageDictionary){
            (error , reference) in
            
            if error != nil {
                print(error!)
            }else {
                print("Message sent Successfully!")
                
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                self.messageTextfield.text = ""
                
            }
            
        }
        
        
        
    }
  
    func retrieveMessages(){
        let MessageDB = Database.database().reference().child("Messages")
        MessageDB.observe(.childAdded) { (snapshot) in
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let messageTxt = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            
            let messageObj = Message()
            messageObj.messageBody = messageTxt
            messageObj.sender = sender
            
            self.messageArray.append(messageObj)
            
            self.configureTableView()
            self.messageTableView.reloadData()
        }
        
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {

        do {
            try Auth.auth().signOut()
            
           guard (navigationController?.popToRootViewController(animated: true)) != nil
            else {
                print("NO NavControlle to pop off !")
                return
            }
            
        } catch {
            print("Error :  Can't Sign out !")
        }
        
    }
    


}
