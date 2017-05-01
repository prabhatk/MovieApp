//
//  CommunicationManager.swift
//  Movie
//
//  Created by Prabhat Kasera on 29/04/17.
//  Copyright © 2017 Prabhat Kasera. All rights reserved.
//

import Foundation
import UIKit

class CommunicationManager: NSObject {
    
    
    // declare enum and internal function return URL for the same
    
    public enum WebServiceType :Int
    {
        case searchMovie = 1
        case moviePoster
        case WhetherSearch
        func getRequestURLByType(appendString: String) -> String
        {
            switch self
            {
            case .searchMovie:
                return "http://api.themoviedb.org/3/search/movie?api_key=\(API_KEY)&query=" + appendString
            case .moviePoster:
                return "http://image.tmdb.org/t/p/w92"
            case .WhetherSearch:
                return "http://api.worldweatheronline.com/free/v1/weather.ashx?key=vzkjnx2j5f88vyn5dhvvqkzc&format=json&q="
                
            }
        }
    }
    func getMovieResults(searchString:String, existingCount: Int, callBack:@escaping(_ responseData: NSDictionary?)->()){
        let request = NSMutableURLRequest(url: URL(string: WebServiceType.searchMovie.getRequestURLByType(appendString: searchString+"&page=\((existingCount/NO_OF_ROW_PER_PAGE)+1)"))!)
        // page will be count automatically as we are using window of 20 records per page "NO_OF_ROW_PER_PAGE"
        request.httpMethod = "GET"
        request.addValue("application/json",forHTTPHeaderField: "Content-Type")
        request.addValue("application/json",forHTTPHeaderField: "Accept")
        
        self.callWebservice(request as URLRequest!) { (responseData) in
            
            DispatchQueue.main.async(execute: {
                if responseData is NSDictionary {
                    // handle data here1
                    //                    print(responseData)
                    callBack(responseData as? NSDictionary)
                }
                else {
                    //call back else case
                    callBack(nil)
                }
            })
            
        }
    }
    
    // main web service call function.
    func callWebservice(_ request: URLRequest!,callback:@escaping (_ responseData : AnyObject?) -> ()) {
        let appDelegate  = UIApplication.shared.delegate as! AppDelegate
        if appDelegate.reachability.isReachable {
            let task = URLSession.shared
                .dataTask(with: request, completionHandler: {
                    (data, response, error) -> Void in
                    if (error != nil) {
                        print(error!.localizedDescription)
                        callback(nil)
                    } else {
                        do {
                            //print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                            let parsedJSON = try JSONSerialization.jsonObject(with: data!, options:JSONSerialization.ReadingOptions(rawValue: 0))
                            callback(parsedJSON as AnyObject)
                        }
                        catch let JSONError as NSError {
                            print(JSONError.description)
                            callback(nil)
                        }
                    }
                })
            task.resume()
        }
    }
}
