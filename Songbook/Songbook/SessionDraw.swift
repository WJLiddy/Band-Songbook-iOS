import UIKit
import Foundation

// This class is responsible for drawing a parsed musicXML ( A MusicXmlPart[]) onto the screen.
class SessionDraw
{
    // scroll speed: one note will travel 0.3 width of the screen per second.
    // TODO: This value should be increased if you want the scroll to be slower, at risk of notes being crowded together.
    let width_per_second = 0.3
    
    // extra whitespace at each edge as a ratio of the app height. Necessary so that tab lines do not cover the UI.
    let edgemargin = 0.1
    
    // width and height of screen, in pixels.
    let w: CGFloat;
    let h: CGFloat;
    
    // Count of staves (or, tabs, if you like) to display
    let stavecount: Int;
    // The ratio of the space that each tab gets.
    let stave_space_ratio: Double;
    // The amount of time that has passed since the start of the song.
    // updated in each draw() call.
    var song_seconds_elapsed : Double;
    //
    var staveLocations = [[Double]]()
    var staveFontSizes = [Double]()
    //refers to where we are drawing, in terms of seconds since song started.
    var playhead = 0.0;
    
    public init(frame: CGRect)
    {
        h = frame.height
        w = frame.width
        // how many parts to display?
        stavecount = Session.songPartIndexesToDisplay.count
        // What percent of the screen does each stave get?
        stave_space_ratio = ((1 - (2*edgemargin)) / Double(stavecount))
        
        //Get our position in the song.
        let currentTime = Date().timeIntervalSince1970
        
        if(Session.playbackStarted)
        {
            song_seconds_elapsed = currentTime - Session.playbackStartTime
            //scale based on tempo
            song_seconds_elapsed = song_seconds_elapsed * (((Double)(Session.playbackSpeed)) / 100.0)
        } else
        {
            // Here, stopMeasure is the point when the song stopped.
            // In retrospect I should have just passed the Session instance to this class but ain't got time for that now
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
            
            let size = staveFontSizes[0]
            let drawAttr = [ NSFontAttributeName: UIFont(name: "Avenir Next Condensed", size: CGFloat(size))! , NSForegroundColorAttributeName: UIColor.black]
            
            String(measurenumber).draw(with: CGRect(x: Double(w) * width_ratio, y: staveLocations[0][0], width: Double(size), height: Double(size)), options: .usesLineFragmentOrigin, attributes: drawAttr, context: nil)
            
            
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
                // only render notes near the screen
                if(width_ratio > 2 || width_ratio < -2)
                {
                    continue
                }
                let size = staveFontSizes[index]
                let drawAttr = [ NSFontAttributeName: UIFont(name: "Avenir Next Condensed", size: CGFloat(size))! , NSForegroundColorAttributeName:(((tempPlayhead - song_seconds_elapsed) > 0) ? ( UIColor.blue) : ( UIColor.orange))]
                
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
