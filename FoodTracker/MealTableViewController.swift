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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        
        
        
        
        // Load sample data
        //loadSampleMeals()
        /*if let savedMeals = loadMeals() {
         meals += savedMeals
         }*/
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FoodItem")
        
        do {
            meals = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
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
        
        cell.nameLabel?.text = meal.value(forKeyPath: "dish") as? String
        let uiImg = UIImage(data: meal.value(forKeyPath: "image") as! Data)
        cell.photoImageView?.image = uiImg
        cell.ratingControl?.rating = meal.value(forKeyPath: "stars") as! Int
        //        cell.nameLabel.text = meal.name
        //        cell.photoImageView.image = meal.photo
        //        cell.ratingControl.rating = meal.rating
        
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
            meals.remove(at: indexPath.row)
            
            // SAVE THE MEALS
            //saveMeals()
            //saveData(<#T##name: String##String#>, <#T##photo: UIImage##UIImage#>, <#T##rating: Int##Int#>)
            // remove from saved data
            
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
            
            // Use section/row for table views, section/item for collection views, and direct subscripting for everything else.
            let selectedMeal = meals[indexPath.row]
            //mealDetailViewController.meal = selectedMeal
            
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
                //meals[selectedIndexPath.row] = meal
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
                // (New) Add button was pressed
            else {
                // Add a new meal.
                let newIndexPath = IndexPath(row: meals.count, section: 0)
                //meals.append(meal)
                saveData(meal.name, meal.photo!, meal.rating)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            // Save the info
            //saveData(meal.value(forKeyPath: "dish") as! String, meal.value(forKeyPath: "image") as! Data, meal.value(forKeyPath: "stars") as! Int)
            
            tableView.reloadData()
        }
    }
    
    
    // MARK: Private Methods
    
    // Save without specifying values
    // Separate remove?

    private func saveData(_ name: String, _ photo: UIImage, _ rating: Int) {
        
        // TODO
        // Some of the code here, such as getting the managed object context and entity,
        // could be done just once in your own init() or viewDidLoad() then reused later.
        // TODO
        // These should be declared above
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "FoodItem", in: managedContext)!
        let meal = NSManagedObject(entity: entity, insertInto: managedContext)
        meals.append(meal)
        
        // 3
        meal.setValue(name, forKeyPath: "dish")
        meal.setValue(Meal.convertUIImageToPng(photo), forKeyPath: "image")
        meal.setValue(rating, forKeyPath: "stars")
        
        // 4
        /*do {
            try managedContext.save()
            meals.append(meal)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }*/
    }
    
    /*private func loadSampleMeals() {
        let photo1 = UIImage(named: "meal1")
        let photo2 = UIImage(named: "meal2")
        let photo3 = UIImage(named: "meal3")
        
        // TODO
        // These should be declared above
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "FoodItem", in: managedContext)!
        
        if let meal1 = Meal(name: "Chicken Chow Mein", photo: photo1, rating: 5) {
            let meal = NSManagedObject(entity: entity, insertInto: managedContext)
            meal.setValue(meal1.name, forKey: "dish")
            meal.setValue(Meal.convertUIImageToPng(meal1.photo), forKey: "image")
            meal.setValue(meal1.rating, forKey: "stars")
            meals.append(meal)
        }
        else {
            fatalError("Unable to instantiate meal1.")
        }
        
        if let meal2 = Meal(name: "Rack of Lamb", photo: photo2, rating: 4) {
            let meal = NSManagedObject(entity: entity, insertInto: managedContext)
            meal.setValue(meal2.name, forKey: "dish")
            meal.setValue(Meal.convertUIImageToPng(meal2.photo), forKey: "image")
            meal.setValue(meal2.rating, forKey: "stars")
            meals.append(meal)
        }
        else {
            fatalError("Unable to instantiate meal2.")
        }
        
        if let meal3 = Meal(name: "Shrimp Tempura Roll", photo: photo3, rating: 5) {
            let meal = NSManagedObject(entity: entity, insertInto: managedContext)
            meal.setValue(meal3.name, forKey: "dish")
            meal.setValue(Meal.convertUIImageToPng(meal3.photo), forKey: "image")
            meal.setValue(meal3.rating, forKey: "stars")
            meals.append(meal)
        }
        else {
            fatalError("Unable to instantiate meal3.")
        }
        
        //meals += [meal1, meal2, meal3]  // or meals.append(contentsOf: [meal1, meal2, meal3])
    }*/
}
