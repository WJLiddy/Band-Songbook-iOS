//
//  MusicXMLPart.swift
//  Songbook
//
//  Created by William Liddy on 3/22/17.
//  Copyright © 2017 NeutralSpace. All rights reserved.
//

// Could use inheritence but this is fine. for now.
struct TabNote {
    let isRest: Bool
    let duration: Int
    let stringNumber: Int
    let fret: Int
}

import Foundation
class MusicXMLPart
{
    public var partName: String
    public var stringCount: Int
    public var divCount: Int
    public var tabNotes: [TabNote]
    
    // should use a builder here.
    private init(pname: String, strings: Int, dCount: Int)
    {
        partName = pname
        stringCount = strings
        divCount = dCount
        tabNotes = []
    }
    
    public static func parseMusicXML(xml: XMLIndexer) -> [MusicXMLPart]
    {
        var parts: [MusicXMLPart] = []
        
        for (index,element) in Session.songXMLs[0]["score-partwise"]["part-list"]["score-part"].all.enumerated()
        {
            let partName = element["part-name"][0].element!.text!
            // we can get the string count in the first measure.
            let scoreAttrs = Session.songXMLs[0]["score-partwise"]["part"][index]["measure"][0]["attributes"]
            
            let divCount = Int(scoreAttrs["divisions"][0].element!.text!)
            
            let stringCount = Int(scoreAttrs["staff-details"]["staff-lines"].element!.text!)
            
            let part = MusicXMLPart(pname: partName, strings: stringCount!, dCount: divCount!)
            
            // the "divcount" seems to be the qtr note.
            // Now let's extract the beats per measure.
            // Also consider the beat type.
            
            //he divisions element provided the unit of measure for the duration element in terms of divisions per quarter note.
        
            // In a tab, the only thing we care about is time,
            // So keep track of the time of each note in the "div" unit.
            
            // WAYY too complex
            for measure in Session.songXMLs[0]["score-partwise"]["part"][index]["measure"].all
            {
                //cannot handle backup or forward yet.
                for event in measure.children
                {
                    if(event.element!.name == "note")
                    {
                        var foundRest = false;
                        //first look for a rest.
                        for maybeRest in event.children
                        {
                            //If there is a rest, rest.
                            if(maybeRest.element!.name == "rest")
                            {
                            let duration = event["duration"].element!.text!
                            part.tabNotes.append(TabNote(isRest: false, duration: Int(duration)!, stringNumber: -1, fret: -1))
                                foundRest = true
                            }
                        }
                        
                        if(!foundRest)
                        {
                        
                        let duration = event["duration"].element!.text!
                        let a = event["notations"]
                        let b = a["technical"]
                        let stringNumber = event["notations"]["technical"]["string"][0].element!.text!
                        let fretNumber = event["notations"]["technical"]["fret"][0].element!.text!
                        part.tabNotes.append(TabNote(isRest: false, duration: Int(duration)!, stringNumber: Int(stringNumber)!, fret: Int(fretNumber)!))
                        }

                    }
                    
                    
                }
                
                
            }
            parts.append(part)
            
        }
        return parts
    }
    
}
