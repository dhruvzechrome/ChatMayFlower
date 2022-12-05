//
//  UserDetailsCode.swift
//  ChatMayFlower
//
//  Created by iMac on 13/10/22.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FirebaseCoreInternal
import FirebaseStorage
import Kingfisher
import MBProgressHUD
import Contacts

class UserDetailsCode: UIViewController {
    let storeC = CNContactStore()
    var forgroupuser = [String]()
    var msgkey = [String]()
    var msgIdList = [String]()
    var msgstatus = false
    var usersNumber = ""
    @IBOutlet weak var tabelView: UITableView!
    var phones = ""
    var databaseRef: DatabaseReference!
    var messageId:String?
    var friends = [ChatAppUser]()
    var keyArray = [String]()
    var usersDetails = [[String:String]]()
    var allUser = [[String:String]]()
    let storageRef = Storage.storage().reference()
    
    func getContact(){
        let authorize = CNContactStore.authorizationStatus(for: .contacts)
        if authorize == .notDetermined {
            storeC.requestAccess(for: .contacts) { (chk, error) in
                if error == nil {
                    
                }
            }
        } else if authorize == .authorized {
            getContactList()
        }
    }
    
    func getContactList() {
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: storeC.defaultContainerIdentifier())
        let contct = try! storeC.unifiedContacts(matching: predicate, keysToFetch: [CNContactPhoneNumbersKey as CNKeyDescriptor,CNContactGivenNameKey as CNKeyDescriptor])
        
        for con in contct {
            print("*Name of contact number \(con.givenName)")
            
            for phNO in con.phoneNumbers {
                var hib =  phNO.value.stringValue
                hib = hib.replacingOccurrences(of: " ", with: "")
                hib = hib.replacingOccurrences(of: "-", with: "")
                hib = hib.replacingOccurrences(of: "(", with: "")
                hib = hib.replacingOccurrences(of: ")", with: "")
                allUser.append(["Name" : con.givenName,"Phone Number": hib])
                print("Name of contact number \(phNO.value.stringValue)")
                
            }
        }
        print("List of all user \(allUser)")
    }
    
    func getData(){
        
        databaseRef = Database.database().reference().child("Contact List")
        databaseRef.observe(.childAdded){[weak self](snapshot) in
            self!.mbProgressHUD(text: "Loading.")
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                
                for _ in snapshots {
                    //   let cata = snap.key
                    //   let ques = snap.value!
                    
                    let infoMap = snapshot.value! as! [String:String]
                    
                    if snapshot.key != self!.phones {
                        
                        if !self!.keyArray.contains("\(snapshot.key)") {
                            
                            self!.keyArray.append("\(snapshot.key)")
                            print("Aray of number is \(self!.keyArray)")
                            
                            if infoMap["group name"] != nil {
                                
                                
                            }
                            if infoMap["Name"] != nil {
                                
                                if infoMap["photo url"] != nil {
                                    self!.usersDetails.append(["Name" : infoMap["Name"]! , "Phone number": infoMap["Phone number"]!, "profilepic": infoMap["photo url"]!])
//                                    print("usersDetails----------->>>\(self!.usersDetails)")
                                } else {
                                    self!.usersDetails.append(["Name" : infoMap["Name"]! , "Phone number": infoMap["Phone number"]!, "profilepic": ""])
//                                    print("usersDetails----------->>>\(self!.usersDetails)")
                                }
                                
                            } else if infoMap["group name"] != nil {
                                self?.forgroupuser.removeAll()
                                let grps = "\(infoMap["group user"]!)"
                                let ffhhf = grps.split(separator: "+")
                                print("=====ffhhf=======\(ffhhf.count)")
                                for i in 0...ffhhf.count-1 {
                                    if self!.phones == "+\(ffhhf[i])" {
                                        print("yes")
                                        self!.usersDetails.append(["group name" : "\(infoMap["group name"]!)" , "Phone number": infoMap["group user"]!, "profilepic": ""])
                                        break
                                    } else {
                                        print("god")
                                    }
                                    
                                }
                                
                            }
                            else {
                                self!.usersDetails.append(["Name" : "" , "Phone number": infoMap["Phone number"]!, "profilepic": ""])
                                print("usersDetails----------->>>\(self!.usersDetails)")
                            }
                            
                        }
                    }
                    
                    
                }
            }
            print("Sbapshot is ", snapshot.value!)
            //            self?.tabelView.reloadData()
        }
    }
    
    var listOfData = [[String:String]]()
    func getMessageId() {
        print("My Chats \(usersDetails)")
        databaseRef = Database.database().reference().child("Chats")
        databaseRef.observe(.childAdded){[weak self](snapshot) in
            let key = snapshot.key
            //            print("Key",key)
            guard let _ = snapshot.value as? [String:Any] else {
                print("No data Found")
                return
            }
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for _ in snapshots {
                    let cata = key
                    if !(self?.msgIdList.contains("\(cata)"))!{
                        self?.msgIdList.append("\(cata)")
                    }
                    if !(self?.msgkey.contains("\(cata)"))!{
                        
                        var splt = cata.split(separator: "+")
                        if splt.count == 2 {
                            for i in 0...splt.count-1 {
                                if self!.phones == "+\(splt[i])" {
                                    print("iii \(i)")
                                    self!.msgkey.append("\(cata)")
                                    for int in 0...self!.usersDetails.count-1 {
                                        let fhg = self?.usersDetails[int]
                                        print("int \(int)]]]]] ")
                                        
                                        for op in 0...splt.count-1{
                                            
                                        if "+\(splt[op])" == fhg?["Phone number"] {
                                            print("fhg is \(fhg?["Phone number"])=====\(splt[op])")
                                            self?.listOfData.append(fhg!)
                                            break
                                        }
                                            
                                        }
                                        
                                    }
                                    break
                                }
                            }
                        }
                        else {
                            for int in 0...self!.usersDetails.count-1 {
                                let fhg = self?.usersDetails[int]
                                if cata == fhg?["Phone number"] {
                                    if !(self?.listOfData.contains(fhg!))!{
                                        self!.msgkey.append("\(cata)")
                                        self?.listOfData.append(fhg!)
                                    }
                                    break
                                }
                            }
                        }
                    }
                }
            } else {
                print("No data Found")
            }
            print("UserDetais \(self?.msgkey)--------\(self?.listOfData)")
            self?.tabelView.reloadData()
            self?.hideProgress()
        }
    }
    
    @IBAction func logout(_ sender: UIBarButtonItem) {
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            let vc = storyboard?.instantiateViewController(withIdentifier: "PhoneVerificationCode") as? PhoneVerificationCode
            navigationController?.pushViewController(vc!, animated: true)
            print("Sign out success")
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getContact()
        mbProgressHUD(text: "Loading..")
        tabelView.delegate = self
        tabelView.dataSource = self
        print(friends)
        getMessageId()
        getData()
        
        //        let refreshControl = UIRefreshControl()
        //        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        //           self.tabelView.refreshControl = refreshControl
        
        // Do any additional setup after loading the view.
    }
    
    @objc func refresh(_ sender : Any)
    {
        keyArray = [String]()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
            getData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
        validAuth()
        print("current User",phones)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
        navigationItem.hidesBackButton = true
        tabBarController?.tabBarItem.accessibilityElementIsFocused()
    }
    func validAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = storyboard?.instantiateViewController(withIdentifier: "ViewController") as? ViewController
            navigationController?.pushViewController(vc!, animated: true)
            hideProgress()
        }
        phones = FirebaseAuth.Auth.auth().currentUser?.phoneNumber ?? ""
    }
    
    @IBAction func newChat(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AllUsersList") as? AllUsersList
        vc?.usersDetails = usersDetails
        vc?.phones = phones
        vc?.msgIdList = msgIdList
        navigationController?.present(vc!, animated: true, completion: nil)
        
    }
    
}


extension UserDetailsCode: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let frd = listOfData[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TableViewCell
        
        cell?.userLabel.text = frd["Phone number"]
        let filt = allUser.filter { user in
            print("user is \(user)")
            var hib =  user["Phone Number"]
//            hib = hib?.replacingOccurrences(of: " ", with: "")
//            hib = hib?.replacingOccurrences(of: "-", with: "")
//            hib = hib?.replacingOccurrences(of: "(", with: "")
//            hib = hib?.replacingOccurrences(of: ")", with: "")
            print("Hib is +91\(hib!)")
            
            if hib == frd["Phone number"] || "+91\(hib!)" == frd["Phone number"]{
                cell?.userLabel.text = user["Name"]
            }
            return true
        }
        if frd["group name"] == nil {
            
        } else {
            cell?.userLabel.text = frd["group name"]
        }
        print("my image is \(frd["profilepic"]!)")
        
        if frd["profilepic"]! == "" {
            cell?.profile.image = UIImage(named: "person")
        } else {
            let url = URL(string: frd["profilepic"]! )
            cell?.profile.kf.setImage(with: url)
        }
        //        cell?.SetUp(with: data)
        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tabelView.deselectRow(at: indexPath, animated: true)
        let frd = listOfData[indexPath.row]
        usersNumber = frd["Phone number"]!
        print("userNumber is \(usersNumber)")
        if msgkey.count > 0 {
            for avl in 0...msgkey.count - 1 {
                print("msgkey at index  \(msgkey[avl])")
                if msgkey[avl] == "\(phones)\(usersNumber)" || msgkey[avl] == "\(usersNumber)\(phones)" || msgkey[avl] == "\(usersNumber)" {
                    messageId = msgkey[avl]
                    // print("True -----------")
                    msgstatus = true
                    break
                }
            }
        }
        mbProgressHUD(text: "Loading..")
        let vc = storyboard?.instantiateViewController(withIdentifier: "ChatConversionCode") as? ChatConversionCode
        vc?.receiverid = usersNumber
        if frd["group name"] == nil {
            
        } else {
            vc?.receiverid = frd["group name"] as! String
            vc?.groupK = "yes"
        }
        mychat()
        vc?.mid = messageId!
        vc?.phoneid = phones
        
        navigationController?.pushViewController(vc!, animated: true)
        hideProgress()
        //        friends = [ChatAppUser]()
    }
    
    
    func mychat() {
        
        if msgstatus == false {
            messageId = "\(phones)\(usersNumber)"
            databaseRef.child("Chat").observeSingleEvent(of: .value, with: { [self] (snapshot) in
                if snapshot.exists() {
                    print("true rooms exist")
                } else {
                    print("false room doesn't exist")
                    DataBaseManager.shared.createNewChat(with: Message( messagid: self.messageId!, chats: "", sender: "",uii: 0, chatPhotos: ""))
                }
            })
        }
    }
    
}

extension UserDetailsCode {
    func mbProgressHUD(text: String){
        DispatchQueue.main.async {
            let progressHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            progressHUD.label.text = text
            progressHUD.contentColor = .systemBlue
        }
    }
    func hideProgress(){
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: self.view, animated: false)
        }
    }
}
