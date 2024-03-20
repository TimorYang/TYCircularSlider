//
//  ViewController.swift
//  HGCircularSlider
//
//  Created by Hamza Ghazouani on 10/19/2016.
//  Copyright (c) 2016 Hamza Ghazouani. All rights reserved.
//

import UIKit
import HGCircularSlider

extension Date {
    
}

class ClockViewController: UIViewController {
    

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var bedtimeLabel: UILabel!
    @IBOutlet weak var wakeLabel: UILabel!
    @IBOutlet weak var rangeCircularSlider: TYRangeCircularSlider!
    @IBOutlet weak var clockFormatSegmentedControl: UISegmentedControl!
    var timelineList: [TYCircularTimeRange]?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: "TimeLineViewCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TimeLineViewCell")
        // setup O'clock
        rangeCircularSlider.startThumbImage = UIImage(named: "start")
        rangeCircularSlider.endThumbImage = UIImage(named: "end")
        
        let dayInSeconds = 24 * 60 * 60
        rangeCircularSlider.maximumValue = CGFloat(dayInSeconds)
        
        rangeCircularSlider.startPointValue = 1 * 60 * 60
        rangeCircularSlider.endPointValue = 8 * 60 * 60
        rangeCircularSlider.lineWidth = 26
        rangeCircularSlider.backtrackLineWidth = 36
        rangeCircularSlider.trackFillColor = UIColor(red: 0.21, green: 0.67, blue: 0.23, alpha: 0.4500)
        rangeCircularSlider.trackColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
        rangeCircularSlider.minDistance = 1 * 60 * 60

        updateTexts(rangeCircularSlider)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateTexts(_ sender: TYRangeCircularSlider) {
        timelineList = sender.timeRangeList
        if let timeRangeList = sender.timeRangeList {
            print("888 888: --------------充电计划--------------")
            for item: TYCircularTimeRange in timeRangeList {
                print("888 888: start: \(formatValue(value: item.start)), end: \(formatValue(value: item.end))")
            }
            print("888 888: --------------充电计划--------------")
        }
        tableView.reloadData()
        /*
        adjustValue(value: &rangeCircularSlider.startPointValue)
        adjustValue(value: &rangeCircularSlider.endPointValue)

        
        let bedtime = TimeInterval(rangeCircularSlider.startPointValue)
        let bedtimeDate = Date(timeIntervalSinceReferenceDate: bedtime)
        bedtimeLabel.text = dateFormatter.string(from: bedtimeDate)
        
        let wake = TimeInterval(rangeCircularSlider.endPointValue)
        let wakeDate = Date(timeIntervalSinceReferenceDate: wake)
        wakeLabel.text = dateFormatter.string(from: wakeDate)
        
        let duration = wake - bedtime
        let durationDate = Date(timeIntervalSinceReferenceDate: duration)
        dateFormatter.dateFormat = "HH:mm"
        durationLabel.text = dateFormatter.string(from: durationDate)
        dateFormatter.dateFormat = "hh:mm a"
         */
    }
    
    func adjustValue(value: inout CGFloat) {
        let minutes = value / 60
        let adjustedMinutes =  ceil(minutes / 5.0) * 5
        value = adjustedMinutes * 60
    }
    
    func formatValue(value: CGFloat?) -> CGFloat? {
        var result = value
        if let _value = value {
            let minutes = _value / 60
            let adjustedMinutes =  ceil(minutes / 5.0) * 5
            result = adjustedMinutes * 60
        }
        return result
    }

}

extension ClockViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timelineList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimeLineViewCell", for: indexPath) as! TimeLineViewCell
        if let _timeLineList = timelineList {
            let item = _timeLineList[indexPath.row]
            if let _start = formatValue(value: item.start), let _end = formatValue(value: item.end) {
                var text = String()
                let bedtime = TimeInterval(_start)
                let bedtimeDate = Date(timeIntervalSinceReferenceDate: bedtime)
                text.append(dateFormatter.string(from: bedtimeDate))
                text.append(" - ")
                let wake = TimeInterval(_end)
                let wakeDate = Date(timeIntervalSinceReferenceDate: wake)
                text.append(dateFormatter.string(from: wakeDate))
                cell.time = text
            }
            cell.deleteAction = { [weak self] in
                self?.rangeCircularSlider.removeTimeRange(timeRange: item)
            }
        }
        
        return cell
    }
}

