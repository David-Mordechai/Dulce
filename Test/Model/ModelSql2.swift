//
//  ModelSql2.swift
//  Dulce
//
//  Created by admin on 02/01/2021.
//  Copyright © 2021 colman. All rights reserved.
//

import Foundation

class ModelSql2{
    var database: OpaquePointer? = nil
    
    static let instance = ModelSql2()
    
    private init(){
        connect()
    }
    
    private func connect() {
        let dbFileName = "database2.db"
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            let path = dir.appendingPathComponent(dbFileName)
            if sqlite3_open(path.absoluteString, &database) != SQLITE_OK {
                print("Failed to open db file: \(path.absoluteString)")
                return
            }
        }
        create()
    }

    // MARK: CREATE TABLES
    private func create(){
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        var res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS USERS (ID TEXT PRIMARY KEY, NAME TEXT, PICTURE TEXT)", nil, nil, &errormsg);

        if(res != 0){
            print("error creating users table");
            return
        }
        
        res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS RECIPES (ID TEXT PRIMARY KEY, TITLE TEXT, DIFFICULTY INTEGER, TIME_TO_MAKE INTEGER, PUBLISHER TEXT, INSTRUCTIONS TEXT, PICTURE TEXT, CATEGORY_ID TEXT)", nil, nil, &errormsg);

        if(res != 0){
            print("error creating recipes table");
            return
        }
        
        res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS CATEGORIES (ID TEXT PRIMARY KEY, NAME TEXT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating categories table");
            return
        }
        
        res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS FAVORITES (ID TEXT PRIMARY KEY, USER_ID TEXT, RECIPE_ID TEXT)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating favorites table");
            return
        }
        
        res = sqlite3_exec(database, "CREATE TABLE IF NOT EXISTS LAST_UPDATE_DATE (NAME TEXT PRIMARY KEY, DATE DOUBLE)", nil, nil, &errormsg);
        if(res != 0){
            print("error creating last update date table");
            return
        }
    }
     
    // MARK: LAST UPDATE DATE
    func setLastUpdate(name:String, lastUpdated:Int64){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO LAST_UPDATE_DATE( NAME, DATE) VALUES (?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){

            sqlite3_bind_text(sqlite3_stmt, 1, name,-1,nil);
            sqlite3_bind_int64(sqlite3_stmt, 2, lastUpdated);
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("new row added succefully")
            }
        }
        sqlite3_finalize(sqlite3_stmt)
    }
    
    func getLastUpdateDate(name:String)->Int64{
        var date:Int64 = 0;
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"SELECT * from LAST_UPDATE_DATE where NAME like ?;",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            
            sqlite3_bind_text(sqlite3_stmt, 1, name,-1,nil);

            if(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                date = Int64(sqlite3_column_int64(sqlite3_stmt,1))
            }
        }
        sqlite3_finalize(sqlite3_stmt)
        return date
    }

    // MARK: USERS
    
    func addUser(user: User){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO USERS( ID, NAME, PICTURE) VALUES (?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){

            let id = user.Id.cString(using: .utf8)
            let name = user.Name.cString(using: .utf8)
            let picture = user.Picture.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, name,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, picture,-1,nil);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("user added succefully")
            }
        }
    }
    
    func getUserbyId(uid:String)-> User? {
        var sqlite3_stmt: OpaquePointer? = nil
        var data = [User]()
        
        if (sqlite3_prepare_v2(database,"SELECT * from USERS;",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            
            //sqlite3_bind_text(sqlite3_stmt, 1, uid,-1,nil);
            
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){

                let id = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                let name = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
                let picture = String(cString:sqlite3_column_text(sqlite3_stmt,2)!)
                
                let user = User(Id: id, name: name, Picture: picture)
                                
                data.append(user)
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
        
        let users = data.filter{user in return user.Id == uid}
        return users.first
    }
    
    // MARK: RECIPES
    func addRecipe(recipe: Recipe){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO RECIPES(ID, TITLE, DIFFICULTY, TIME_TO_MAKE, PUBLISHER, INSTRUCTIONS, PICTURE, CATEGORY_ID) VALUES (?,?,?,?,?,?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            let id = recipe.Id.cString(using: .utf8)
            let title = recipe.Title.cString(using: .utf8)
            let difficulty = recipe.Difficulty
            let timeTomake = recipe.TimeToMake
            let publisher = recipe.Publisher.cString(using: .utf8)
            let instructions = recipe.Instructions.cString(using: .utf8)
            let picture = recipe.Picture.cString(using: .utf8)
            let categoryId = recipe.CategoryId.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, title,-1,nil);
            sqlite3_bind_int(sqlite3_stmt, 3, Int32(difficulty))
            sqlite3_bind_int(sqlite3_stmt, 4, Int32(timeTomake))
            sqlite3_bind_text(sqlite3_stmt, 5, publisher,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 6, instructions,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 7, picture,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 8, categoryId,-1,nil);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("recipe added succefully")
            }
        }
    }
    
    func getAllRecipes()->[Recipe]{
        var sqlite3_stmt: OpaquePointer? = nil
        var data = [Recipe]()
        
        if (sqlite3_prepare_v2(database,"SELECT * from RECIPES;",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){

                let id = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                let title = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
                let difficulty = Int(sqlite3_column_int(sqlite3_stmt,2))
                let timeTomake = Int(sqlite3_column_int(sqlite3_stmt,3))
                let publisher = String(cString:sqlite3_column_text(sqlite3_stmt,4)!)
                let instructions = String(cString:sqlite3_column_text(sqlite3_stmt,5)!)
                
                let a = sqlite3_column_text(sqlite3_stmt,6)
                var picture:String = ""
                if (a != nil){ picture = String(cString: a!) }
                           
                let categoryId = String(cString:sqlite3_column_text(sqlite3_stmt,7)!)

                let recipe = Recipe(Id: id, Title: title, Difficulty: difficulty, TimeToMake: timeTomake, Publisher: publisher, Instructions: instructions, Picture: picture, CategoryId: categoryId)
                                
                data.append(recipe)
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
        return data
    }
    
    func getCategoryRecipes(categoryId:String)->[Recipe]{
        var sqlite3_stmt: OpaquePointer? = nil
        var data = [Recipe]()
        
        if (sqlite3_prepare_v2(database,"SELECT * from RECIPES;",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                let id = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                let title = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
                let difficulty = Int(sqlite3_column_int(sqlite3_stmt,2))
                let timeTomake = Int(sqlite3_column_int(sqlite3_stmt,3))
                let publisher = String(cString:sqlite3_column_text(sqlite3_stmt,4)!)
                let instructions = String(cString:sqlite3_column_text(sqlite3_stmt,5)!)
                
                let a = sqlite3_column_text(sqlite3_stmt,6)
                var picture:String = ""
                if (a != nil){ picture = String(cString: a!) }
                           
                let categoryId = String(cString:sqlite3_column_text(sqlite3_stmt,7)!)

                let recipe = Recipe(Id: id, Title: title, Difficulty: difficulty, TimeToMake: timeTomake, Publisher: publisher, Instructions: instructions, Picture: picture, CategoryId: categoryId)
                                
                data.append(recipe)
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
        
        let categoryData = data.filter{recipe in return recipe.CategoryId == categoryId}
        return categoryData
    }
    
    func deleteRecipe(recipe: Recipe){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"DELETE FROM RECIPES WHERE ID = ?;",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            let id = recipe.Id.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("recipe deleted succefully")
            }
        }
    }
    
    // MARK: CATEGORIES
    func addCategory(category: Category){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO CATEGORIES(ID, NAME) VALUES (?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            let id = category.Id.cString(using: .utf8)
            let name = category.Name?.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, name,-1,nil);
            
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("category added succefully")
            }
        }
    }
    
    func getAllCategories()->[Category]{
        var sqlite3_stmt: OpaquePointer? = nil
        var data = [Category]()
        
        if (sqlite3_prepare_v2(database,"SELECT * from CATEGORIES;",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){

                let id = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                let name = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
                
                let category = Category(id: id, name: name)
                data.append(category)
            }
        }
        
        sqlite3_finalize(sqlite3_stmt)
        return data
    }
    
    // MARK: FAVORITES
    
    func addFavorite(favorite: Favorite){
        var sqlite3_stmt: OpaquePointer? = nil
        if (sqlite3_prepare_v2(database,"INSERT OR REPLACE INTO FAVORITES(ID, USER_ID, RECIPE_ID) VALUES (?,?,?);",-1, &sqlite3_stmt,nil) == SQLITE_OK){
            
            let id = favorite.Id.cString(using: .utf8)
            let userId = favorite.UserId.cString(using: .utf8)
            let recipeId = favorite.RecipeId.cString(using: .utf8)
            
            sqlite3_bind_text(sqlite3_stmt, 1, id,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 2, userId,-1,nil);
            sqlite3_bind_text(sqlite3_stmt, 3, recipeId,-1,nil);
            
            if(sqlite3_step(sqlite3_stmt) == SQLITE_DONE){
                print("favorite added succefully")
            }
        }
    }
    
    func getUserFavorites(userId:String)->[Favorite]{
        var sqlite3_stmt: OpaquePointer? = nil
        var data = [Favorite]()
        
        if (sqlite3_prepare_v2(database,"SELECT * from FAVORITES;",-1,&sqlite3_stmt,nil)
            == SQLITE_OK){
            while(sqlite3_step(sqlite3_stmt) == SQLITE_ROW){
                
                let id = String(cString:sqlite3_column_text(sqlite3_stmt,0)!)
                let uid = String(cString:sqlite3_column_text(sqlite3_stmt,1)!)
                let recipeId = String(cString:sqlite3_column_text(sqlite3_stmt,2)!)
                

                let favorite = Favorite(Id: id, userId: uid, recipeId: recipeId)
                
                data.append(favorite)
            }
        }

        let userFavorites = data.filter{favorite in return favorite.UserId == userId}
        return userFavorites
    }
    
    // MARK: DROP TABLES
    func drop(){
        var errormsg: UnsafeMutablePointer<Int8>? = nil
        var res = sqlite3_exec(database, "DROP TABLE IF EXISTS USERS;", nil, nil, &errormsg);

        if(res != 0){
            print("error creating table");
            return
        }
        
        res = sqlite3_exec(database, "DROP TABLE IF EXISTS RECIPES;", nil, nil, &errormsg);

        if(res != 0){
            print("error creating table");
            return
        }
        
        res = sqlite3_exec(database, "DROP TABLE IF EXISTS CATEGORIES;", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
        
        res = sqlite3_exec(database, "DROP TABLE IF EXISTS LAST_UPDATE_DATE;", nil, nil, &errormsg);
        if(res != 0){
            print("error creating table");
            return
        }
    }
}
