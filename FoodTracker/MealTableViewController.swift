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
    
    static var numMeals = 0
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "FoodItem")
        
        do {
            MealTableViewController.numMeals = try managedContext.fetch(fetchRequest).count
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
        return MealTableViewController.numMeals  // meals.count
    }
    
    // Configures and provides a cell to display for a given row.
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "MealTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? MealTableViewCell else {
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }

        let meal = retrieveData(atRow: indexPath.row)
        cell.nameLabel?.text = meal!.name
        cell.photoImageView?.image = meal!.photo
        cell.ratingControl?.rating = meal!.rating
        
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
            deleteData(atRow: indexPath.row)
            MealTableViewController.numMeals -= 1
            tableView.reloadData()
            
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
            if let selectedMeal = retrieveData(atRow: indexPath.row) {
                mealDetailViewController.meal = Meal(selectedMeal.name, selectedMeal.photo, selectedMeal.rating, selectedMeal.id)
            }
            
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
                updateData(meal, atRow: selectedIndexPath.row)
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            // (New) Add button was pressed
            else {
                // Add a new meal.
                let newIndexPath = IndexPath(row: MealTableViewController.numMeals, section: 0)
                saveNewMeal(meal)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
            tableView.reloadData()
        }
    }
    
    
    // MARK: Private Methods
    
    private func saveNewMeal(_ meal: Meal) {
        let managedContext = appDelegate!.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "FoodItem", in: managedContext)!
        
        let mealManObj = NSManagedObject(entity: entity, insertInto: managedContext)
        mealManObj.setValue(meal.name, forKeyPath: Meal.PropertyKey.name)
        mealManObj.setValue(Meal.convertUIImageToPng(meal.photo), forKeyPath: Meal.PropertyKey.photo)
        mealManObj.setValue(meal.rating, forKeyPath: Meal.PropertyKey.rating)
        mealManObj.setValue(meal.id, forKey: Meal.PropertyKey.id)
        
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        MealTableViewController.numMeals += 1
    }
    
    private func retrieveData(atRow index: Int) -> Meal? {
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FoodItem")
        
        // Put in order so that id of Meal matches index of array. Could maybe try to use a function to find our value in array.
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: Meal.PropertyKey.id, ascending: true)]
    
        do {
            let result = try managedContext.fetch(fetchRequest)
            let manObj = result[index] as! NSManagedObject
            let name = manObj.value(forKey: Meal.PropertyKey.name) as! String
            let photo = UIImage(data: manObj.value(forKey: Meal.PropertyKey.photo) as! Data)
            let rating = manObj.value(forKey: Meal.PropertyKey.rating) as! Int
            let id = manObj.value(forKey: Meal.PropertyKey.id) as! Int
            return Meal(name, photo, rating, id)
        }
        catch {
            print("Failed fetching objects.")
        }
        
        return nil
    }
    
    private func updateData(_ meal: Meal, atRow row: Int) {
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "FoodItem")
        
        //fetchRequest.predicate = NSPredicate(format: <#T##String#>, <#T##args: CVarArg...##CVarArg#>)
        
        // Put in order so that id of Meal matches index of array. Could maybe try to use a function to find our value in array.
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: Meal.PropertyKey.id, ascending: true)]
    
        do {
            let result = try managedContext.fetch(fetchRequest)
            let manObj = result[row] as! NSManagedObject
            manObj.setValue(meal.name, forKeyPath: Meal.PropertyKey.name)
            manObj.setValue(Meal.convertUIImageToPng(meal.photo), forKeyPath: Meal.PropertyKey.photo)
            manObj.setValue(meal.rating, forKeyPath: Meal.PropertyKey.rating)
            do {
                try managedContext.save()
            }
            catch {
                print("Failed to save object.")
            }
        }
        catch {
            print("Failed fetch object.")
        }
    }
    
    private func deleteData(atRow row: Int) {
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FoodItem")
        
        //fetchRequest.predicate = NSPredicate(format: "id == %@", row)
        
        // Put in order so that id of Meal matches index of array. Could maybe try to use a function to find our value in array.
        fetchRequest.sortDescriptors = [NSSortDescriptor.init(key: Meal.PropertyKey.id, ascending: true)]
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            let manObj = result[row] as! NSManagedObject
            managedContext.delete(manObj)
            
            do {
                try managedContext.save()
            }
            catch {
                print("Failed to delete object.")
            }
        }
        catch {
            print("Failed fetch object.")
        }
    }
    
    // batchDelete
    // crashes if multiple objects have the same name
    /*private func deleteData(atRow row: Int, _ meal: Meal) {
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "FoodItem")
        fetch.predicate = NSPredicate(format: "name == %@", meal.name)
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try managedContext.execute(request)
        }
        catch {
            fatalError("Failed to execute request: \(error)")
        }
        
        do {
            let result = try managedContext.execute(request) as? NSBatchDeleteResult
            let objectIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey : objectIDArray]
            //NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [managedContext])
        }
        catch {
            fatalError("Failed to perform batch update: \(error)")
        }
    }*/
}
