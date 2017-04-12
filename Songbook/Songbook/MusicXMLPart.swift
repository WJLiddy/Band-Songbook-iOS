// This class parses the musicXML into a usable data structure.
// Right now, there are two types of basic notes. TabNotes, and PercussionNotes.

// every note has a "rhythm" which consists of two parts
// the offset (which measures where the note is relative to the start of it's measure)
// and the duration (how long the note is)
// Both of these are measured in "divisions", a unit which will be described later.
class Rhythm
{
    let offset: Int
    let duration: Int
    init(offset: Int, duration: Int)
    {
        self.offset = offset;
        self.duration = duration;
    }
}

// If we are playing stringed instr., we have a "TabNote" which contains the string and fret
class TabNote
{
    let string: Int
    let fret: Int
    let rhythm: Rhythm

    init(string: Int, fret: Int, rhythm: Rhythm)
    {
        self.string = string;
        self.fret = fret;
        self.rhythm = rhythm
    }
}

// On a drum, we have an enum that says the type of the note to sound
class DrumNote
{
    enum NoteType {
        case bass, snare, hat_open, hat_close, hat_pedal, crash, ride, tom
    }
    let noteType: NoteType
    let rhythm: Rhythm
    
    init(noteType: NoteType, rhythm: Rhythm)
    {
        self.noteType = noteType;
        self.rhythm = rhythm
    }
}

// The notetype that sounds is based on the midi code.
// http://www.pjb.com.au/muscript/gm.html
// In our case, we want to group midi codes into the proper instrument.
// No drummer is going to have a 50-piece drum set as described in the midi spec,
// So we write a quick helper class that coverts a midi code into the proper drum code.
class MidiCodeConverter
{
    var codeMap : [Int: DrumNote.NoteType];
    init()
    {
        codeMap = [:]
        codeMap[35] = DrumNote.NoteType.bass;
        codeMap[36] = DrumNote.NoteType.bass;
        codeMap[38] = DrumNote.NoteType.snare;
    }
    
    public func doesDrumExist(midiCode: Int) -> Bool
    {
        return codeMap[midiCode] != nil
    }
    
    public func midiCodeToDrumNote(midiCode: Int) -> DrumNote.NoteType
    {
        return codeMap[midiCode]!
    }
}

// finally we have two types of measure containers, which store tab / drum notes.
class Measure
{
    //duration, in divisions.
    let duration: Int;
    let secondsPerDivision: Double;
    // How many seconds away is this measure from the start?
    var timeFromStart: Double;
    init(duration: Int, secondsPerDivision: Double, timeFromStart: Double)
    {
        self.duration = duration;
        self.secondsPerDivision = secondsPerDivision;
        self.timeFromStart = timeFromStart
    }
}

// measures to hold each kind of note.
class DrumMeasure : Measure
{
    var notes : [DrumNote]
    override init(duration: Int, secondsPerDivision: Double, timeFromStart: Double)
    {
        super.init(duration: duration,secondsPerDivision : secondsPerDivision,timeFromStart: timeFromStart)
        notes = []
    }
}

class TabMeasure : Measure
{
    var notes : [TabNote]
    override init(duration: Int, secondsPerDivision: Double, timeFromStart: Double)
    {
        super.init(duration: duration,secondsPerDivision : secondsPerDivision,timeFromStart: timeFromStart)
        notes = []
    }
}


// A MusicXML part has a list of measures, and a part name.
// By passing in an music XML, you get a list of parts.
// TODO: Will crash if there is any XML that does not follow the spec.
class MusicXMLPart
{
    let partName: String
    let measures: [Measure]
    
    public init(partName: String, measures: [Measure])
    {
        self.partName = partName;
        self.measures = measures;
    }
    
    // Give XML, get parts
    public static func parseMusicXML(xml: XMLIndexer) -> [MusicXMLPart]
    {
        var parts: [MusicXMLPart] = []
        
        // Iterate over every part.
        for (index,element) in Session.songXMLs[0]["score-partwise"]["part-list"]["score-part"].all.enumerated()
        {
            let partName = element["part-name"][0].element!.text!
            let midiChannel = element["midi-channel"][0].element!.text!
            // We need to see if this is a percussion or a tabbed part.
            // Do this by checking the midi channel: 10 means percussion
            
            if(midiChannel == "10")
            {
                // this is a PERCUSSION part.
                let measures = MusicXMLDrumPart.parseMeasures(xml: Session.songXMLs[0]["score-partwise"]["part"][index])
                let part = MusicXMLDrumPart(partName: partName, measures: measures);
                parts.append(part)
            } else
            {
                // this is a TAB part.
                // we can get the string count in the first measure.
                let scoreAttrs = Session.songXMLs[0]["score-partwise"]["part"][index]["measure"][0]["attributes"]
                let stringCount = Int(scoreAttrs["staff-details"]["staff-lines"].element!.text!)
                let measures = MusicXMLTabPart.parseMeasures(xml: Session.songXMLs[0]["score-partwise"]["part"][index])
                let part = MusicXMLTabPart(partName: partName, strings: stringCount!, measures: measures);
                parts.append(part)
                
            }
        }
        return parts
    }
}

class MusicXMLDrumPart : MusicXMLPart
{
    
    public static func parseMeasures(xml: XMLIndexer) -> [Measure]
    {
        return []
    }
}

class MusicXMLTabPart : MusicXMLPart
{
    let strings : Int
    public init(partName: String, strings: Int, measures: [Measure])
    {
        super.init(partName: partName, measures: measures)
        self.strings = strings;
    }
    
    
    
    public static func parseNote(xml: XMLIndexer) -> TabNote
    {
        var duration: Int = 0;
        var stringNumber: Int = 0;
        var fretNumber: Int = 0;
        var isRest: Bool = false;
        var isChordal: Bool = false
        for noteattr in xml.children
        {
            switch(noteattr.element!.name)
            {
            case "duration":
                duration = Int(noteattr[0].element!.text!)!
                break;
            case "rest":
                isRest = true
                break;
            case "chord":
                isChordal = true
                break;
            case "notations":
                stringNumber = Int(noteattr["technical"]["string"][0].element!.text!)!
                fretNumber = Int(noteattr["technical"]["fret"][0].element!.text!)!
                break;
            default:
                break;
            }
        }
        let tabnote: TabNote =  TabNote(rest: isRest, offset: 0, duration: duration, stringNumber: stringNumber, fret: fretNumber, chordal: isChordal)
        return tabnote
    }
    
    public static func parseMeasures(xml: XMLIndexer) -> [Measure]
    {
        var measures: [Measure] = []
        var divisions: Int = 0
        var lastMeasureDuration: Int = 0;
        var tempo: Int = 0;
        var timeFromStart = 0.0;
        for XMLmeasure in xml["measure"].all
        {
            var measure: Measure = Measure()
            var playhead: Int = 0;
            var playheadLast: Int = 0;
            
            
            for event in XMLmeasure.children
            {
                switch(event.element!.name)
                {
                case "attributes":
                    //read any attributes passed that are relevant
                    // We care about divisions, and time.
                    for attribute in event.children
                    {
                        switch(attribute.element!.name)
                        {
                        case "divisions":
                            divisions = Int(attribute[0].element!.text!)!
                            break;
                        case "time":
                            // Find duration, in divisions.
                            let beats: Double = Double(attribute["beats"][0].element!.text!)!
                            let beattype: Int = Int(attribute["beat-type"][0].element!.text!)!
                            // beattype is 4 for quarter notes, and 8 for eighth notes, etc...
                            // so, let's find quater notes per beat.
                            let quarterNotesPerBeat: Double = 4.0 / Double(beattype)
                            
                            //careful-- might lose some precision here
                            let totalDurationInDivisions: Int = Int(beats * quarterNotesPerBeat * Double(divisions))
                            
                            lastMeasureDuration = totalDurationInDivisions
                            break;
                        default:
                            //print("In measure attributes: Ignored " + attribute.element!.name)
                            break;
                        }
                    }
                    break;
                    
                case "note":
                    var tabNote:TabNote = parseNote(xml: event)
                    if(!tabNote.rest)
                    {
                        tabNote.offset = tabNote.chordal ? playheadLast : playhead
                        measure.tabNotes.append(tabNote)
                    }
                    
                    if(!tabNote.chordal)
                    {
                        playheadLast = playhead
                        playhead += tabNote.duration
                    }
                    break;
                    
                case "direction":
                    tempo = Int((event["sound"][0].element?.attribute(by: "tempo")?.text)!)!
                    //set tempo <direction placement="above">
                    //<sound tempo="160"/>
                    //</direction>
                    break;
                default:
                    break;
                }
                
            }
            measure.timeFromStart = timeFromStart;
            measure.duration = lastMeasureDuration;
            measure.secondsPerDivision =  1.0 / (Double(divisions) * (Double(tempo) / 60.0))
            timeFromStart += Double(measure.duration) * measure.secondsPerDivision;
            measures.append(measure)
            // tempo is in quarters per minute
            // "divisions" is one quarter note
        }
        return measures
    }
    
    
    
}




}

  
