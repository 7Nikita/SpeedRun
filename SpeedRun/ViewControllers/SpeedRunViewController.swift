//
//  SpeedRunViewController.swift
//  SpeedRun
//
//  Created by Nikita Pekurin on 3/7/20.
//  Copyright © 2020 Nikita Pekurin. All rights reserved.
//

import UIKit
import CoreData

class SpeedRunViewController: UIViewController {
    
    private let cellIdentifier = "TimeCellIdentifier"
    
    var lapTimes = [LapTime]()
    private var timer = Timer()
    private var counter: TimeInterval = 0.00
    private var isEnabled = false
    
    @IBOutlet weak var timeTableView: UITableView! {
        didSet {
            timeTableView.delegate = self
            timeTableView.dataSource = self
        }
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timeTableView.register(UINib(nibName: "LapTimeTableViewCell", bundle: nil),
                               forCellReuseIdentifier: cellIdentifier)
        refresh()
    }
    
    @IBAction func timerButtonPressed(_ sender: UIButton) {
        isEnabled = !isEnabled
        if (!isEnabled) {
            timer.invalidate()
            refresh()
        } else {
            startTimer()
        }
    }
    
    
    @IBAction func addTimeButtonPressed(_ sender: UIBarButtonItem) {
        lapTimes.append(LapTime(time: counter))
        timeTableView.reloadData()
    }
    
    
    @objc private func updateTimer() {
        counter += 0.01
        timeLabel.text = String(format: "%.2f", counter)
    }
    
    private func refresh() {
        counter = 0.00
        self.title = "Результаты"
        timeLabel.text = String(format: "%.2f", counter)
        timerButton.setTitle("Старт", for: .normal)
        timerButton.setTitleColor(.systemBlue, for: .normal)
    }
    
    private func startTimer() {
        self.title = "Время пошло"
        timerButton.setTitle("Стоп", for: .normal)
        timerButton.setTitleColor(.red, for: .normal)
        timer = Timer.scheduledTimer(timeInterval: 0.01,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
    }
    
}

extension SpeedRunViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lapTimes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LapTimeTableViewCell
        cell.lapTimeLabel.text = String(format: "%.2f", lapTimes[indexPath.row].time)
        return cell
    }
}
