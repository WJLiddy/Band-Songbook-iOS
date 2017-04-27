
import Foundation
import UIKit
// Launch menu for the app.
class MainMenu : UIViewController
{

    // References to the text fiels.
    @IBOutlet weak var GroupNameField: UITextField!
    @IBOutlet weak var NameField: UITextField!
    
    @IBAction func joinGroupPressed(_ sender: AnyObject) {
        if(NameField.text == "" || GroupNameField.text == "")
        {
            UIErrorMessage.init(viewController: self, errorMessage: "Please enter a user name and a group name").show()
            return
        }
        // setSocket() returns true if the socket could be set up properly, returns false and shows error msg otherwise.
        // requestOK() returns true if the user passed a valid group name, returns false and shows error msg otherwise
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
    // Socket is accessible at SongSocket.socket
    // While this is (effectively) a global variable, passing classes between each new UIview is a pain
    public func setSocket() -> Bool
    {
        // Make sure we can connect to the server. If we cannot, throw an error message.
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

    // return true if the user made a valid request to join or create a group.
    public func requestOK(join: Bool) -> Bool
        {
            SongSocket.socket!.sendRequest(request : StartRequest(name: NameField.text!,group: GroupNameField.text!, join: join))
            // Let message arrive
            sleep(1)
            var recv: [String: Any]?
            do
            {
                recv = try SongSocket.socket!.recvJSON()
            } catch
            {
                // Throws JSON parse error if recv failed.
                // This should not happen -  the server has been tested.
                UIErrorMessage.init(viewController: self, errorMessage: "There is an issue with the server.").show()
                return false;
            }
            
            // If the server says "ok" in response JSON then the connection made a valid request and has been accepted.
            // See the server protocols doc.
            if (recv!["response"] as! String != "ok")
            {
                UIErrorMessage.init(viewController: self, errorMessage: recv!["error message"] as! String).show()
                return false;
            }
            return true
        }
}
