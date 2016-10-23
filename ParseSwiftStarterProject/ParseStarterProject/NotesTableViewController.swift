//
//  NotesTableViewController.swift
//  ParseStarterProject
//
//  Created by Tyler Weitzman on 6/27/15.
//  Copyright (c) 2015 Parse. All rights reserved.
//

import Foundation
import UIKit
import Parse
import ParseUI

class NotesTableViewController: PFQueryTableViewController {
    
    
    var arrayTitles = ["Alexander Hamilton", "The Universe", "HackHarvard", "Jazz Music"]
    var arrayTimes = ["Alexander Hamilton (January 11, 1755 or 1757 – July 12, 1804) was an American statesman and one of the Founding Fathers of the United States. He was an influential interpreter and promoter of the U.S. Constitution, as well as the founder of the nation's financial system, the Federalist Party, the United States Coast Guard, and The New York Post newspaper. As the first Secretary of the Treasury, Hamilton was the main author of the economic policies of the George Washington administration. He took the lead in the funding of the states' debts by the Federal government, as well as the establishment of a national bank, a system of tariffs, and friendly trade relations with Britain. He was opposed by the Democratic-Republican Party led by Thomas Jefferson and James Madison. They denounced Hamilton as too friendly toward Britain and to monarchy in general.", "The Universe is all of time and space and its contents. It includes planets, moons, minor planets, stars, galaxies, the contents of intergalactic space, and all matter and energy. The observable universe is about 28 billion parsecs (91 billion light-years) in diameter.[3] The size of the entire Universe is unknown, but there are many hypotheses about the composition and evolution of the Universe. The earliest scientific models of the Universe were developed by ancient Greek and Indian philosophers and were geocentric, placing the Earth at the center of the Universe. Over the centuries, more precise astronomical observations led Nicolaus Copernicus (1473–1543) to develop the heliocentric model with the Sun at the center of the Solar System. In developing the law of universal gravitation, Sir Isaac Newton (NS: 1643–1727) built upon Copernicus's work as well as observations by Tycho Brahe (1546–1601) and Johannes Kepler's (1571–1630) laws of planetary motion. Further observational improvements led to the realization that our Solar System is located in the Milky Way galaxy and is one of many solar systems and galaxies. It is assumed that galaxies are distributed uniformly and the same in all directions, meaning that the Universe has neither an edge nor a center. Discoveries in the early 20th century have suggested that the Universe had a beginning and that it is expanding[16] at an increasing rate.[17] The majority of mass in the Universe appears to exist in an unknown form called dark matter.", "Here at HackHarvard, it means to create new and innovative solutions by building on previous discoveries. In this era of iPhones with no headphone jacks and bikes with no handlebars, we have increasingly been lead to re-examine classic technologies — to create the next iterations of well-known solutions. Because classic technologies provide priceless templates for improvement, we have chosen to focus on the intersection between technologies from the past and the present. By embracing both the old and the new, we are saying that baking cakes with box mixes is just as good as baking cakes from scratch. We are saying that in order to get that coveted Blastoise, you have to start with a Squirtle first. Everybody must start somewhere, and we prefer starting by standing on the shoulders of giants.", "Jazz is a music genre that originated from African American communities of New Orleans in the United States during the late 19th and early 20th centuries. It emerged in the form of independent traditional and popular musical styles, all linked by the common bonds of African American and European American musical parentage with a performance orientation.[1] Jazz spans a period of over a hundred years, encompassing a very wide range of music, making it difficult to define. Jazz makes heavy use of improvisation, polyrhythms, syncopation and the swing note,[2] as well as aspects of European harmony, American popular music,[3] the brass band tradition, and African musical elements such as blue notes and African-American styles such as ragtime.[1] Although the foundation of jazz is deeply rooted within the black experience of the United States, different cultures have contributed their own experience and styles to the art form as well. Intellectuals around the world have hailed jazz as one of America's original art forms."]
    var newTitle = ""
    var numberAudio = 0
    var speechTxt: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.parseClassName = ParseConstants.NotesClass
        let rightButton = UIBarButtonItem(title: "New Track", style: .Done, target: self, action: #selector(addText))
        self.navigationItem.rightBarButtonItem = rightButton
//        self.tableView.delegate = self
    }
    @IBAction func logOut(sender: AnyObject) {
        PFUser.logOutInBackgroundWithBlock { (error: NSError?) -> Void in
//            
            let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
            delegate.displayWindow()
            print("hello")
        }
    }
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery()//PFQuery(className: ParseConstants.NotesClass)
        /*query.whereKey("user", equalTo: PFUser.currentUser()!)
        query.orderByDescending("createdAt")*/
        return query
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayTitles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath)
        cell.textLabel?.text = arrayTitles[indexPath.row]
        let time = Speech.defaultLengthForString(arrayTimes[indexPath.row])
        cell.detailTextLabel?.text = time
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        speechTxt = arrayTimes[indexPath.row] as String!
        numberAudio = indexPath.row
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(speechTxt!, forKey: "speechText")
        defaults.setObject(numberAudio, forKey: "index")
        defaults.synchronize()
    }
    
    func addText()
    {
        /*let alert = UIAlertController(title: "Add a Title", message: "Add a title for your note from the clipboard", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok",
            style: UIAlertActionStyle.Cancel,
            handler: {(action: UIAlertAction!) in
                let str = UIPasteboard.generalPasteboard().string!
                let title = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(0), end: str.startIndex.advancedBy(5)))
                self.arrayTimes.append(UIPasteboard.generalPasteboard().string!)
                let textField = alert.textFields![0]
                self.arrayTitles.append(textField.text!)
                self.tableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) in
            
        }
        self.presentViewController(alert, animated: true, completion: nil)*/
        let str = UIPasteboard.generalPasteboard().string!
        let title = str.substringWithRange(Range<String.Index>(start: str.startIndex.advancedBy(0), end: str.startIndex.advancedBy(35)))
        
        self.arrayTimes.append(UIPasteboard.generalPasteboard().string!)
        self.arrayTitles.append(title)
        
        self.tableView.reloadData()
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowExistingNote"{
            let view = segue.destinationViewController as! ListenViewController
            view.numberAudio = self.numberAudio
        }
    }
    
    /*override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell?
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath) as! PFTableViewCell
        cell.textLabel?.text = "Hola"
        let time = Speech.defaultLengthForString("Happy Birthday")
        cell.detailTextLabel?.text = time
        return cell
    }*/

    
    /*override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {

        let cell = tableView.dequeueReusableCellWithIdentifier("NoteCell", forIndexPath: indexPath) as! PFTableViewCell

        //if let obj = object {
            cell.textLabel?.text = ""//obj["title"] as? String
            if ("Happy Birthday" as? String) != nil { //obj["content"]
//                if content != nil {
                    let time = Speech.defaultLengthForString("Happy Birthday")//content)
                    cell.detailTextLabel?.text = time
//                }
            }

//          obj["content"] as? String
        //}
        
        return cell
        
    }*/



    /*override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowExistingNote" {
            let vc = segue.destinationViewController as! ListenViewController
            let indexPath = tableView.indexPathForSelectedRow
            if let obj = self.objectAtIndexPath(indexPath) {
                if let title = obj["title"] as? String, let content = obj["content"] as? String {
                    selectedNote = (title, content)
                    vc.note = selectedNote
                    vc.obj = obj
                    if let cursor : Double = obj.objectForKey("cursor") as! Double? {
                        //                speech.cursor = cursor
                        vc.cursor = cursor
                        //                speech.pause()
                    }
                    print(selectedNote!.1)
                    
                } else {
                    // Casting unsuccessful
                }
            }

        }
    }*/
    /*
override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
if segue.identifier == "ShowExistingNote" {
var vc = segue.destinationViewController as! ListenViewController
let indexPath = tableView.indexPathForSelectedRow()
if let obj = self.objectAtIndexPath(indexPath) {
if let title = obj["title"], let content = obj["content"] {
selectedNote = (title as! String, content as! String)
vc.note = selectedNote
vc.obj = obj
if let cursor : Double = obj.objectForKey("cursor") as! Double? {
//                speech.cursor = cursor
vc.cursor = cursor
//                speech.pause()
}
println(selectedNote!.1)

}
}

}
}*/


}

