//
//  CategoryModel.swift
//  Dulce
//
//  Created by admin on 18/12/2020.
//  Copyright © 2020 colman. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class CategoryModel {
    let modelFirebase = ModelFirebase()
    let modelSql = ModelSql2.instance
    
    public init(){    }
    
    func addCategory(category: Category) -> () {
        let json = category.toJson()
        modelFirebase.ref.child("categories").child(json["id"] as! String).setValue(json)
    }
    
    func getAllCategories(callback: @escaping ([Category]?)->Void){
       //get the local last update date
        var lud = modelSql.getLastUpdateDate(name: "CATEGORIES");
        let oldLud = lud

        //get the cloud updates since the local update date
        modelFirebase.getAllCategoriesFB(since:lud) { (data) in
            //insert update to the local db
            for category in data!{
                self.modelSql.addCategory(category: category)
                
                if category.lastUpdate != nil && category.lastUpdate! > lud {
                    lud = category.lastUpdate!
                }
            }
            
            if (lud > oldLud){
                //update the students local last update date
                self.modelSql.setLastUpdate(name: "CATEGORIES", lastUpdated: lud)
            }
            
            // get the complete student list
            let finalData = self.modelSql.getAllCategories()
            callback(finalData);
        }
    }
    
}
