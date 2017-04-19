//
//  MainMenu.swift
//  Songbook
//
//  Created by William Liddy on 3/21/17.
//  Copyright © 2017 NeutralSpace. All rights reserved.
//

import Foundation
import UIKit
class MainMenu : UIViewController
{
    override func viewDidLoad() {

    }

    @IBOutlet weak var GroupNameField: UITextField!
    @IBOutlet weak var NameField: UITextField!
    
    @IBAction func joinGroupPressed(_ sender: AnyObject) {
        if(NameField.text == "" || GroupNameField.text == "")
        {
            UIErrorMessage.init(viewController: self, errorMessage: "Please enter a user name and a group name").show()
            return
        }
        if(setSocket() && requestOK(join: true))
        {
            Lobby.isBandLeader = false
            performSegue(withIdentifier: "ToLobby", sender: nil)
        }
    }
    @IBAction func createGroupPressed(_ sender: AnyObject) {
        if(NameField.text == "" || GroupNameField.text == "")
        {
            UIErrorMessage.init(viewController: self, errorMessage: "Please enter a user name and a group name").show()
            return
        }
        if(setSocket() && requestOK(join: false))
        {
            Lobby.isBandLeader = true
            Lobby.usernames = [NameField.text!]
            performSegue(withIdentifier: "ToLobby", sender: nil)
        }
    }
    
    // return true if connection was init'd, throws error and displays err message if not.
    public func setSocket() -> Bool
    {
        // Make sure we can connect to the server. If we cannot, throw an error message, and close the app.
        do
        {
            try SongSocket.socket = SongSocket();
        } catch
        {
            UIErrorMessage.init(viewController: self, errorMessage: "Server is offline").show()
            return false;
        }
        return true;
    }

        // return true if connection was init'd, throws error and displays err message if not.
    public func requestOK(join: Bool) -> Bool
        {
            // Networking on main???? Just for now....
            SongSocket.socket!.sendRequest(request : StartRequest(name: NameField.text!,group: GroupNameField.text!, join: join))
            // Let message arrive
            sleep(1)
            var recv: [String: Any]?
            do
            {
                recv = try SongSocket.socket!.recvJSON()
            } catch
            {
                UIErrorMessage.init(viewController: self, errorMessage: "There is an issue with the server. (CLIENT RECVD INVALID JSON)").show()
                return false;
            }
            
            if (recv!["response"] as! String != "ok")
            {
                UIErrorMessage.init(viewController: self, errorMessage: recv!["error message"] as! String).show()
                return false;
            }
            return true


        }
        
        // return true if connection was init'd, throws error and displays err message if not.
        public func createRequestOK() -> Bool
        {
            return true;
        }

}
