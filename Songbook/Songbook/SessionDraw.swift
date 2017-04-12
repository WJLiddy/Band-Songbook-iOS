import UIKit
import Foundation
class SessionDraw
{
    // scroll speed: one note will travel 0.3 width of the screen per second.
    let width_per_second = 0.3
    // edgemargin: extra whitespace at each edge
    let edgemargin = 0.1
    
    let w: CGFloat;
    let h: CGFloat;
    let stavecount: Int;
    let stave_space_ratio: Double;
    let song_seconds_elapsed : Double;
    var staveLocations = [[Double]]()
    var staveFontSizes = [Double]()
    //refers to where we drawing the note or barline.
    var playhead = 0.0;
    
    public init(frame: CGRect)
    {
        h = frame.height
        w = frame.width
        // how many parts to display?
        stavecount = Session.songPartIndexesToDisplay.count
        // What percent of the screen does each stave get?
        stave_space_ratio = ((1 - (2*edgemargin)) / Double(stavecount))
        
        let currentTime = Date().timeIntervalSince1970
        
        //Get our position in the song.
        if(Session.playbackStarted)
        {
            song_seconds_elapsed = currentTime - Session.playbackStartTime
        } else
        {
            song_seconds_elapsed = Session.songParts![0].measures[Session.stopMeasure].timeFromStart
        }
    }
    
    public func findStaveLocations() -> [[Double]]
    {
        var staveLocs = [[Double]]()
        for (index, indexToDisplay) in Session.songPartIndexesToDisplay.enumerated()
        {
            let partToDraw = Session.songParts![indexToDisplay]
            var stave = [Double]()
            let top = edgemargin + (Double(index) * stave_space_ratio)
            // drummer gets 5 staves.
            let linecount = (type(of: partToDraw) is MusicXMLDrumPart.Type) ? 5 : (partToDraw as! MusicXMLTabPart).strings
            let linespacing = stave_space_ratio / Double(linecount+2)
            // This is font size calc
            staveFontSizes.append((Double(h) * linespacing) / 1.5)
            for line in 0...(linecount - 1)
            {
                let string_y = top + (linespacing)*Double(line+1)
                stave.append(string_y)
            }
            staveLocs.append(stave)
        }
        return staveLocs
    }
    
    public func draw()
    {
        //determine placement information about the "y" coord of each stave
        staveLocations = findStaveLocations()
        
        // draw the underlying stave
        drawStaves()
        for (index, indexToDisplay) in Session.songPartIndexesToDisplay.enumerated()
        {
            // draw the measures and the notes.
            drawMeasures(index: index, partToDraw: Session.songParts![indexToDisplay])

            /**
            //draw double barline
            let cPath = UIBezierPath()
            //playhead centered at 0.25
            let width_ratio = (0.25) + (playhead - song_seconds_elapsed)*width_per_second
            cPath.move(to: CGPoint(x:Double(w) * width_ratio, y:0))
            cPath.addLine(to: CGPoint(x:Double(w) * width_ratio, y:Double(h)))
            cPath.close()
            
            let bPath = UIBezierPath()
            //playhead centered at 0.25
            let bwidth_ratio = (0.26) + (playhead - song_seconds_elapsed)*width_per_second
            bPath.move(to: CGPoint(x:Double(w) * bwidth_ratio, y:0))
            bPath.addLine(to: CGPoint(x:Double(w) * bwidth_ratio, y:Double(h)))
            bPath.close()
            */
            
            //Draw note marker
            let aPath = UIBezierPath()
            aPath.move(to: CGPoint(x:Double(w)/4.0, y:0))
            
            aPath.addLine(to: CGPoint(x:Double(w)/4.0, y:Double(h)))
            aPath.close()
            
            //If you want to stroke it with a red color
            UIColor.red.set()
            aPath.stroke()
        }
    }
    
    public func drawMeasures(index: Int, partToDraw: MusicXMLPart)
    {
        playhead = 0.0
        for (measurenumber, measure) in partToDraw.measures.enumerated()
        {
            //measure is underway but not finished
            if(Session.playbackStarted)
            {
                let dif = song_seconds_elapsed - measure.timeFromStart
                if(dif > 0 && dif < Double(measure.duration) * measure.secondsPerDivision)
                {
                    Session.stopMeasure = measurenumber
                }
                //print(Session.stopMeasure)
            }
            //draw barline
            let aPath = UIBezierPath()
            //playhead centered at 0.25
            let width_ratio = (0.25) + (playhead - song_seconds_elapsed)*width_per_second
            aPath.move(to: CGPoint(x:Double(w) * width_ratio, y:0))
            aPath.addLine(to: CGPoint(x:Double(w) * width_ratio, y:Double(h)))
            aPath.close()
            
            UIColor.gray.set()
            aPath.stroke()
            
            if(type(of: measure) is TabMeasure.Type)
            {
            for note in (measure as! TabMeasure).notes
            {
                let fret = String(note.fret)
                let string_y = staveLocations[index][note.string-1]
                let y = string_y * Double(h)
                let tempPlayhead = playhead + Double(note.rhythm.offset) * measure.secondsPerDivision
                let width_ratio = (0.25) + (tempPlayhead - song_seconds_elapsed)*width_per_second
                let size = staveFontSizes[index]
                let drawAttr = [ NSFontAttributeName: UIFont(name: "Avenir Next Condensed", size: CGFloat(size))! , NSForegroundColorAttributeName: UIColor.blue]
                
                let textoffset = note.fret > 9 ? (size/2) : (size/4)
                fret.draw(with: CGRect(x: Double(w) * width_ratio - textoffset, y: y - (size/2), width: Double(h), height: Double(h)), options: .usesLineFragmentOrigin, attributes: drawAttr, context: nil)
            }
            
            playhead = playhead + Double(measure.duration) * measure.secondsPerDivision
        }
        }

    }
    
    
    public func drawStaves()
    {
        for stave in staveLocations
        {
            for line in stave
            {
                //Draw each stave on the screen
                let aPath = UIBezierPath()
                aPath.move(to: CGPoint(x:0, y:line * Double(h)))
                aPath.addLine(to: CGPoint(x:Double(w), y:line * Double(h)))
                aPath.close()
                UIColor.black.set()
                aPath.stroke()
            }
        }
    }
}
