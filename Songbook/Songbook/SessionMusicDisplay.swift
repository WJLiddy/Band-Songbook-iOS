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
        let h = frame.height
        let w = frame.width
        
        let stavecount = Double(Session.songPartIndexesToDisplay.count)
        let edgemargin = 0.1
        let stave_space_ratio = (1 - (2*edgemargin)) / stavecount
        
        for (index, indexToDisplay) in Session.songPartIndexesToDisplay.enumerated()
        {
            let partToDraw = Session.songParts![indexToDisplay]
            let top = edgemargin + (Double(index) * stave_space_ratio)
            


            let linecount = partToDraw.stringCount
            
            let linespacing = stave_space_ratio / Double(linecount+2)
            for line in 0...(linecount - 1)
            {
                //Draw each stave on the screen
                let aPath = UIBezierPath()
                let string_y = top + (linespacing)*Double(line+1)
                aPath.move(to: CGPoint(x:0, y:string_y * Double(h)))
                
                aPath.addLine(to: CGPoint(x:Double(w), y:string_y * Double(h)))
                aPath.close()
                
                //If you want to stroke it with a red color
                UIColor.black.set()
                aPath.stroke()
            }
            
            //Draw note marker
            let aPath = UIBezierPath()
            aPath.move(to: CGPoint(x:Double(w)/4.0, y:0))
            
            aPath.addLine(to: CGPoint(x:Double(w)/4.0, y:Double(h)))
            aPath.close()
            
            //If you want to stroke it with a red color
            UIColor.red.set()
            aPath.stroke()
        }
        

        
        //print("it ran")
        //NSLog("drawRect has updated the view")
    }
    
    public func drawNextFrame()
    {
        self.setNeedsDisplay()
    }
    
}
