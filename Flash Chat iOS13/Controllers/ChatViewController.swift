import UIKit
import Firebase
import FirebaseFirestore

struct Message {
    let sender: String
    let body: String
}

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    
//    Message(sender: "kevin@rnw.com", body: "Hey!!"),
//    Message(sender: "kevin@rnw.com", body: "Hey!!"),
//    Message(sender: "kevin@rnw.com", body: "Hey!!")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "resusableCell", bundle: nil), forCellReuseIdentifier: "resusableCell")
        loadMessage()
    }
    
    func loadMessage(){
        
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { (querySnapshort, error) in
            
            self.messages = []
            
            if let e = error{
                print("Data not Retrieve\(e)")
            }else {
                if let snapShortDocuments = querySnapshort?.documents {
                    for doc in snapShortDocuments{
                        let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as? String, let messagebody = data[K.FStore.bodyField] as? String{
                            let newMessage = Message(sender: messageSender, body:  messagebody)
                            self.messages.append(newMessage)
                        
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField: messageSender,
                                                                      K.FStore.bodyField: messageBody,
                                                                      K.FStore.dateField: Date().timeIntervalSince1970]) { (error) in
                
                if let e = error{
                    print("Issue\(e)")
                }else {
                    print("Successfully saved data.")
                }
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
}

extension ChatViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resusableCell", for: indexPath) as! resusableCell
        cell.meLabel.text = message.body
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.myView.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.meLabel.textColor = UIColor(named: K.BrandColors.purple)
        } else {
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
            cell.myView.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.meLabel.textColor = UIColor(named: K.BrandColors.lightPurple)
        }
//        cell.meLabel.text = messages[indexPath.row].body
        return cell
    }
}
