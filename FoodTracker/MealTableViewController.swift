//
//  MealTableViewController.swift
//  FoodTracker
//
//  Created by Cody King on 4/20/20.
//  Copyright © 2020 Cody J. King. All rights reserved.
//

import UIKit

import CoreData
import os.log

class MealTableViewController: UITableViewController {
    
    // MARK: Properties
    
    var meals = [NSManagedObject]()
    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    let managedContext: NSManagedObjectContext?
    let entity: NSEntityDescription?
    
    init() {
        self.managedContext = appDelegate?.persistentContainer.viewContext
        self.entity = NSEntityDescription.entity(forEntityName: "FoodItem", in: managedContext!)
        
        super.init(style: UITableView.Style.plain)
        NSObject.initialize()
    }
    required init?(coder aDecoder: NSCoder) {
        self.managedContext = appDelegate?.persistentContainer.viewContext
        self.entity = NSEntityDescription.entity(forEntityName: "FoodItem", in: managedContext!)
        
        super.init(coder: aDecoder)
        NSObject.initialize()
    }
    
    init(frame: CGRect) {
        self.managedContext = appDelegate?.persistentContainer.viewContext
        self.entity = NSEntityDescription.entity(forEntityName: "FoodItem", in: managedContext!)
        
        super.init(style: UITableView.Style.plain)
        NSObject.initialize()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FoodItem")
        
        do {
            meals = try managedContext!.fetch(fetchRequest)
        }
        catch {
            print("Could not fetch.")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Table view data source
    
    // Tells the table view how many sections to display.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Tells the table view how many rows to display in a given section.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return meals.count
    }
    
    // Configures and provides a cell to display for a given row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        // Fetches the appropriate meal for the data source layout.
        let meal = meals[indexPath.row]
        
        cell.nameLabel?.text = meal.value(forKeyPath: Meal.PropertyKey.name) as? String
        let uiImg = UIImage(data: meal.value(forKeyPath: Meal.PropertyKey.photo) as! Data)
        cell.photoImageView?.image = uiImg
        cell.ratingControl?.rating = meal.value(forKeyPath: Meal.PropertyKey.rating) as! Int
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete from Core Data
            managedContext?.delete(meals[indexPath.row])
            
            meals.remove(at: indexPath.row)
            
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        }
        else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    // segue: The segue object containing information about the view controllers involved in the segue.
    // sender: The object that initiated the segue. You might use this parameter to perform different actions based on which control (or other object) initiated the segue.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        // not necessary, but just to make sure superclass sets up everything it needs
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        // Add new item, so no need to populate MealView with data
        case "addItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
            
        // Get meal to show in MealView for viewing/editing
        case "showDetail":
            // The destination view controller for the segue.
            guard let mealDetailViewController = segue.destination as? MealViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // The object that initiated the segue.
            guard let selectedMealCell = sender as? MealTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            // Index path representing the row and section of a given table-view cell.
            guard let indexPath = tableView.indexPath(for: selectedMealCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            // Get Meal to display
            // Use section/row for table views, section/item for collection views, and direct subscripting for everything else.
            let selectedMeal = meals[indexPath.row]
            let mealObj = Meal(selectedMeal.value(forKeyPath: Meal.PropertyKey.name) as! String,
                               UIImage(data: selectedMeal.value(forKey: Meal.PropertyKey.photo) as! Data),
                               selectedMeal.value(forKey: Meal.PropertyKey.rating) as! Int)
            mealDetailViewController.meal = mealObj
            
        // Bad :(
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    
    // MARK: Actions
    
    // Save button pressed
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? MealViewController, let meal = sourceViewController.meal {
            
            // (Edit) Checks whether a row in the table view is selected (i.e. not the add button)
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update an existing meal.
                let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FoodItem")
                
                do {
                    let results = try managedContext?.fetch(fetchRequest)
                    if results?.count != 0 { // At least one was returned
                        
                        // In my case, I only updated the first item in results
                        results?[selectedIndexPath.row].setValue(meal.name, forKey: Meal.PropertyKey.name)
                        results?[selectedIndexPath.row].setValue(Meal.convertUIImageToPng(meal.photo), forKey: Meal.PropertyKey.photo)
                        results?[selectedIndexPath.row].setValue(meal.rating, forKey: Meal.PropertyKey.rating)
                        
                        meals[selectedIndexPath.row] = results![selectedIndexPath.row]
                    }
                } catch {
                    print("Fetch Failed: \(error)")
                }
                
                do {
                    try managedContext?.save()
                }
                catch {
                    print("Saving Core Data Failed: \(error)")
                }
                
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
                // (New) Add button was pressed
            else {
                // Add a new meal.
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                saveData(meal.name, meal.photo!, meal.rating)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            tableView.reloadData()
        }
    }
    
    
    // MARK: Private Methods
    
    // Save without specifying values?
    // Separate remove?
    private func saveData(_ name: String, _ photo: UIImage, _ rating: Int) {
        
        let meal = NSManagedObject(entity: entity!, insertInto: managedContext)
        meals.append(meal)
        
        meal.setValue(name, forKeyPath: Meal.PropertyKey.name)
        meal.setValue(Meal.convertUIImageToPng(photo), forKeyPath: Meal.PropertyKey.photo)
        meal.setValue(rating, forKeyPath: Meal.PropertyKey.rating)
    }
}
