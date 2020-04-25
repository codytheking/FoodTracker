//
//  Meal.swift
//  FoodTracker
//
//  Created by Cody King on 4/19/20.
//  Copyright © 2020 Cody J. King. All rights reserved.
//

import UIKit
import os.log

class Meal: NSObject {
    
    // MARK: Properties
    
    var name: String
    var photo: UIImage?
    var rating: Int
    
    // FOR SAVING THE MEALS
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
    }
    
    
    //MARK: Archiving Paths
     
    // FOR SAVING THE MEALS
    
    // Will always be at least one URL in the array (so it's fine to force unwrap the Optional)
    //static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    
    // After determining the URL for the documents directory, you use this URL to create the URL for your apps data.
    // Here, you create the file URL by appending meals to the end of the documents URL.
    //static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")


    //MARK: Initialization
     
    init?(_ name: String, _ photo: UIImage?, _ rating: Int) {
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
         
        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        // FOR SAVING THE MEALS
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
    }
    
    static func convertUIImageToPng(_ image: UIImage?) -> Data? {
        return image?.pngData()
    }
}
