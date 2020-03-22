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
    
    var backgroundContext: NSManagedObjectContext!
    var context: NSManagedObjectContext! {
        didSet {
            setupFetchedResultsController(for: context)
            fetchData()
        }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<LapTime>?

    private let cellIdentifier = "TimeCellIdentifier"
    
    private var timer = Timer()
    private var counter = 0.00
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave(notification:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
        
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
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let lapTime = LapTime(context: self.backgroundContext)
            lapTime.lap = self.counter
            
            self.backgroundContext.performAndWait {
                do {
                    try self.backgroundContext.save()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    @objc func managedObjectContextDidSave(notification: Notification) {
        context.perform {
            self.context.mergeChanges(fromContextDidSave: notification)
        }
    }
    
    func setupFetchedResultsController(for context: NSManagedObjectContext) {
        let sortDescriptor = NSSortDescriptor(key: "lap", ascending: true)
        let request = NSFetchRequest<LapTime>(entityName: "LapTime")
        request.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController?.delegate = self
    }
    
    
    func fetchData() {        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print(error)
        }
        
        timeTableView.reloadData()
    }
    
    @objc private func updateTimer() {
        counter += 0.01
        timeLabel.text = counter.timeFromDouble()
    }
    
    private func refresh() {
        counter = 0.00
        self.title = "Результаты"
        timeLabel.text = counter.timeFromDouble()
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

// MARK: - UITableView
extension SpeedRunViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                guard let self = self else { return }
                guard let lapTime = self.fetchedResultsController?.object(at: indexPath) else { return }
                self.context.delete(lapTime)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LapTimeTableViewCell
        guard let lapTime = fetchedResultsController?.object(at: indexPath) else { return cell }
        cell.lapTimeLabel.text = lapTime.lap.timeFromDouble()
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension SpeedRunViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        timeTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            timeTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .update:
            timeTableView.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            timeTableView.deleteRows(at: [indexPath!], with: .automatic)
            timeTableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            timeTableView.deleteRows(at: [indexPath!], with: .automatic)
        @unknown default:
            fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        timeTableView.endUpdates()
    }
    
}
