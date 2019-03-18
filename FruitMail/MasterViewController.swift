//
//  MasterViewController.swift
//  FruitMail
//
//  Created by Florian Hermouet-Joscht on 12/2/18.
//  Copyright © 2018 Florian Hermouet-Joscht. All rights reserved.
//

import UIKit
import OAuthSwift

class MasterViewController: UITableViewController {

    var folderViewController: FolderViewController? = nil
    var objects: FolderList? = nil
    
    var oauthswift: OAuth2Swift?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        //let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        //navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            folderViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? FolderViewController
        }
        
        // Check oauth token
        let token = UserDefaults.standard.string(forKey: "token")
        if (token == nil) {
            self.oauthswift = OAuth2Swift(
                consumerKey:    "mail-ios",
                consumerSecret: "********",
                authorizeUrl:   "https://auth.fruitice.fr/oauth/interface",
                responseType:   "token"
            )
            self.oauthswift?.authorize(
                withCallbackURL: URL(string: "fruitmail://oauth-callback/fruitice")!,
                scope: "infos mails", state: "fruitice",
                success: { credential, response, parameters in
                    print(credential.oauthToken)
                    UserDefaults.standard.set(credential.oauthToken, forKey: "token")
                    self.getFolders()
            },
                failure: { error in
                    print(error.localizedDescription)
            }
            )
        } else {
            getFolders()
        }
    }
    
    func getFolders() {
        let url = URL(string: "https://mail-2.fruitice.fr/v2/folders")!
        var request = URLRequest(url: url)
        request.addValue("Bearer " + UserDefaults.standard.string(forKey: "token")!, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                return
            }
            
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseJSON = responseJSON as? [String: Any] {
                print(responseJSON)
            }
            
            let t = try? JSONDecoder().decode(FolderList.self, from: data)
            self.objects = t
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
        task.resume()
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("segue: " + segue.identifier!)
        if segue.identifier == "showFolder" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let object = getItem(indexPath: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! FolderViewController
                controller.title = getSectionName(section: indexPath.section).lowercased() + "/" + object!.name
                controller.folderState = getSectionName(section: indexPath.section)
                controller.folderName = object!.name
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (objects == nil) {
            return 0
        }
        switch section {
        case 0:
            return (objects?.new.count)!
        case 1:
            return (objects?.read.count)!
        case 2:
            return (objects?.done.count)!
        default:
            return 0
        }
    }
    
    func getItem(indexPath: IndexPath) -> Folder? {
        switch indexPath.section {
        case 0:
            return objects?.new[indexPath.row]
        case 1:
            return objects?.read[indexPath.row]
        case 2:
            return objects?.done[indexPath.row]
        default:
            return nil
        }
    }
    
    func getSectionName(section: Int) -> String {
        switch section {
        case 0:
            return "New"
        case 1:
            return "Read"
        case 2:
            return "Done"
        default:
            return "Segmentation fault"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel!.text = getItem(indexPath: indexPath)!.name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getSectionName(section: section)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        /*if editingStyle == .delete {
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }*/
    }


}

