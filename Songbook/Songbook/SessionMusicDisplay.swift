import Foundation
import UIKit

public class SessionMusicDisplay: UIView
{
    @IBOutlet weak var rwb: UIButton!
    @IBOutlet weak var rwb2: UIButton!
    @IBOutlet weak var rwb3: UIButton!
    @IBOutlet weak var stopb: UIButton!
    @IBOutlet weak var playb: UIButton!
    @IBOutlet weak var ffb: UIButton!
    @IBOutlet weak var ffb2: UIButton!

    var didRemove = false;
    var updateTimer: Timer?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public func listenForBandLeader()
    {
        var recv: [String: Any]?
        do
        {
            recv = try SongSocket.socket!.recvJSON()
        } catch
        {
            //UIErrorMessage.init(viewController: self, errorMessage: "There is an issue with the server. (CLIENT RECVD INVALID JSON)").show()
            return;
        }
        
        if(recv != nil)
        {
            if (recv!["session"] != nil && recv!["session"] as! String == "begin playback")
            {
                let date = recv!["time"] as! Int
                Session.playbackSpeed = (Int)((100 * (recv!["tempo"] as! Double)))
                let measure = recv!["measure"] as! Int
                Session.playbackStarted = true;
                Session.playbackStartTime = Double(date) - (Session.songParts?[0].measures[measure].timeFromStart)!
                print("play pressed")

            }
            
            if (recv!["session"] != nil && recv!["session"] as! String == "stop playback")
            {
                Session.playbackStarted = false;
                
            }
        
            if (recv!["session"] != nil && recv!["session"] as! String == "switch")
            {

                Session.playbackStarted = false;
                Session.playbackStartTime = Date().timeIntervalSince1970;
                Session.stopMeasure = 0;
                Session.songPartIndexesToDisplay = [0];
                Session.currentSong = recv!["song id"] as! Int
                Session.songParts = MusicXMLPart.parseMusicXML(xml: Session.songXMLs[Session.currentSong])
                Session.updateClientPart = true;
            }
   
        }
    
    }
    
    func viewController(_ view: UIView) -> UIViewController {
        var responder: UIResponder? = view
        while !(responder is UIViewController) {
            responder = responder?.next
            if nil == responder {
                break
            }
        }
        return (responder as? UIViewController)!
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Start a timer
        updateTimer = Timer.scheduledTimer(timeInterval: 0.05, target:self, selector: #selector(drawNextFrame), userInfo: nil, repeats: true)
    }
    
    
    public override func draw(_ frame: CGRect) {
        if(!didRemove && !Lobby.isBandLeader && rwb != nil)
        {
            rwb.removeFromSuperview()
            rwb2.removeFromSuperview()
            rwb3.removeFromSuperview()
            stopb.removeFromSuperview()
            playb.removeFromSuperview()
            ffb.removeFromSuperview()
            ffb2.removeFromSuperview()
            if(!Lobby.isBandLeader)
            {
                updateTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(listenForBandLeader), userInfo: nil, repeats: true)
                
            }
         }
        SessionDraw(frame: frame).draw()
        
        //print("it ran")
        //NSLog("drawRect has updated the view")
    }

    
    @IBAction func onFastForwardFast(_ sender: Any) {
        print("fff pressed")
        Session.stopMeasure = min(Session.stopMeasure + 8, (Session.songParts?[0].measures.count)! - 1)
    }
    @IBAction func onFastForward(_ sender: Any) {
        Session.stopMeasure = min(Session.stopMeasure + 1, (Session.songParts?[0].measures.count)! - 1)
        print("ff pressed")
    }
    @IBAction func onPlay(_ sender: Any) {
        Session.playbackStarted = true;
        let date = Int(Date().timeIntervalSince1970 + 3);
        Session.playbackStartTime = (Double(date) - (100 / (Double)(Session.playbackSpeed)) *
(Session.songParts?[0].measures[Session.stopMeasure].timeFromStart)!)         // send JSONs over the network and await an "ok"
        SongSocket.socket!.sendRequest(request : StartPlaybackRequest(time: Int(date), tempo: ((Double)(Session.playbackSpeed) / 100.0), measure: Session.stopMeasure))
        print("play pressed")
        
    }
    public func drawNextFrame()
    {
        self.setNeedsDisplay()
    }
    
    @IBAction func onRestart(_ sender: Any) {
        print("restart pressed")
        Session.stopMeasure = 0;
    }
    
    @IBAction func onRewindFast(_ sender: Any) {
        Session.stopMeasure = max(Session.stopMeasure - 8, 0)
        print("rwf pressed")
    }
    @IBAction func onStop(_ sender: Any) {
        Session.playbackStarted = false;
        SongSocket.socket!.sendRequest(request : StopPlaybackRequest())
        print("stop pressed")
    }
    
    @IBAction func onRewind(_ sender: Any) {
        Session.stopMeasure = max(Session.stopMeasure - 1, 0)
        print("rw pressed")
    }
}
