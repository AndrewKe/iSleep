//
//  TimerViewController.swift
//  iSleep
//
//  Created by Andrew Ke on 10/10/15.
//  Copyright © 2015 Andrew. All rights reserved.
//

import UIKit

class TimerViewController: UIViewController {
    
    @IBOutlet weak var weekday: UIDatePicker!
    @IBOutlet weak var weekend: UIDatePicker!
    @IBOutlet weak var alarmSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        weekday.setDate(defaults.valueForKey("Weekday") as! NSDate, animated: false)
        weekend.setDate(defaults.valueForKey("Weekend") as! NSDate, animated: false)
        
        let alarmsOn = defaults.valueForKey("alarmsOn")
        if let on = alarmsOn as? Bool
        {
            alarmSwitch.on = on
        }
        defaults.synchronize()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func switchChanged() {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setBool(alarmSwitch.on, forKey: "alarmsOn");
        defaults.synchronize()
    }
    
    @IBAction func changedAlarmTime() {
        updateAlarms()
    }
    
    override func viewWillDisappear(animated: Bool) {
        updateAlarms()
    }
    
    func updateAlarms()
    {
        if (alarmSwitch.on == true)
        {
            let defaults = NSUserDefaults.standardUserDefaults()
            defaults.setValue(weekday.date, forKey: "Weekday");
            defaults.setValue(weekend.date, forKey: "Weekend");
            
            UIApplication.sharedApplication().cancelAllLocalNotifications()
            
            for i in 1...7
            {
                if (i >= 2 && i <= 6)
                {
                    let calendar = NSCalendar.currentCalendar()
                    calendar.locale = NSLocale.currentLocale()
                    
                    let components = calendar.components([.Month, .Day, .Weekday, .Year, .Hour, .Minute, .Second], fromDate: weekday.date)
                    components.second = 0
                    components.day = components.day + (i - components.weekday)
                    
                    createAlarmForDayOfWeek(i, date: calendar.dateFromComponents(components)!)
                }
                else
                {
                    let calendar = NSCalendar.currentCalendar()
                    calendar.locale = NSLocale.currentLocale()
                    
                    let components = calendar.components([.Month, .Day, .Weekday, .Year, .Hour, .Minute, .Second], fromDate: weekend.date)
                    components.second = 0
                    components.day = components.day + (i - components.weekday)
                    
                    createAlarmForDayOfWeek(i, date: calendar.dateFromComponents(components)!)
                }
                
            }

        }
        else
        {
            UIApplication.sharedApplication().cancelAllLocalNotifications()
        }
    }
    
    func isWeekday(offset offset: Int) -> Bool
    {
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: NSDate())
        let dayOfWeek = myComponents.weekday + offset
        return dayOfWeek <= 6 && dayOfWeek >= 2
    }
    
    func createAlarmForDayOfWeek(week: Int, date: NSDate)
    {
        let notification = UILocalNotification()
        notification.fireDate = date
        notification.alertBody = "Good Morning! Swipe over to stop alarm and see how long you have slept."
        notification.applicationIconBadgeNumber = 0
        notification.soundName = "ringer.caf"
        notification.timeZone = NSTimeZone.defaultTimeZone()
        notification.repeatInterval = NSCalendarUnit.NSWeekCalendarUnit
        
        let formatter = NSDateFormatter();
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss aaa";
        print("Recurring alarm created at \(formatter.stringFromDate(date))")
        
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    func incrementDateByOneDay(date: NSDate) -> NSDate
    {
        let dayComponent = NSDateComponents()
        dayComponent.day = 1
        
        let calendar = NSCalendar.currentCalendar()
        let nextDate = calendar.dateByAddingComponents(dayComponent, toDate: date, options: NSCalendarOptions(rawValue: 0))
        
        return nextDate!
    }
    
}
