import Foundation
import UIKit

public class SessionMusicDisplay: UIView
{

    var updateTimer: Timer?
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Start a timer
        updateTimer = Timer.scheduledTimer(timeInterval: 0.05, target:self, selector: #selector(drawNextFrame), userInfo: nil, repeats: true)
    }
    
    public override func draw(_ frame: CGRect) {
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
        Session.playbackStartTime = Date().timeIntervalSince1970;
        Session.playbackStartTime -= (Session.songParts?[0].measures[Session.stopMeasure].timeFromStart)!
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
        print("stop pressed")
    }
    
    @IBAction func onRewind(_ sender: Any) {
        Session.stopMeasure = max(Session.stopMeasure - 1, 0)
        print("rw pressed")
    }
}
