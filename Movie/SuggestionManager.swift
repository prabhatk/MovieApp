//
//  SuggestionManager.swift
//  Movie
//
//  Created by Prabhat Kasera on 29/04/17.
//  Copyright © 2017 Prabhat Kasera. All rights reserved.
//

import Foundation
class SuggestionManager : NSObject {
    
    class func saveValue(_ value : String) {
        let suggestionString = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if let mutableArray = getValue(){ // if this is not first time we are adding suggestion to suggetion list
            // if value is alrady saved in suggestion it will never be saved twice
            if(mutableArray.contains(suggestionString)){ // if search keyword is already exist it will come on top for suggestion
                let newMutableArray = NSMutableArray(array: mutableArray)
                newMutableArray.remove(suggestionString)
                newMutableArray.insert(suggestionString, at: 0)
                UserDefaults.standard.set(newMutableArray, forKey: suggestion_Key)
                return;
            }
            let newMutableArray = NSMutableArray(array: mutableArray)
            if(newMutableArray.count > 0){
                newMutableArray.insert(suggestionString, at: 0)
                if(newMutableArray.count > NUM_OF_SUGGESTION){
                    newMutableArray.removeLastObject()
                }
            }
            else{
                newMutableArray.add(suggestionString)
            }
            UserDefaults.standard.set(newMutableArray, forKey: suggestion_Key)
        }
        else { // this is first time when we are saving suggestion
            let mutableArray = NSMutableArray()
            mutableArray.insert(suggestionString, at: 0)
            UserDefaults.standard.set(mutableArray, forKey: suggestion_Key)
        }
        UserDefaults.standard.synchronize()
    }
    class func getValue() -> NSMutableArray? { // return suggestion array
        if let array =  UserDefaults.standard.object(forKey:suggestion_Key) as? NSMutableArray {
            return array
        }
        return NSMutableArray()
    }
}
