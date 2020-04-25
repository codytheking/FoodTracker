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
        
        // Initialize stored properties.
        self.name = name
        self.photo = photo
        self.rating = rating
    }
    
    // Return UIImage as a PNG
    static func convertUIImageToPng(_ image: UIImage?) -> Data? {
        return image?.pngData()
    }
}
