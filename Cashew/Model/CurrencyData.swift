//
//  CurrencyData.swift
//  Cashew
//
//  Created by Robo Atenaga on 3/7/18.
//  Copyright © 2018 Robo Atenaga. All rights reserved.
//

import Foundation
import FirebaseDatabase
import Alamofire

class CurrencyData {
    
    var didGetCurrencies: ((_ currencies: [Currency]) -> ())?
    var didFinishConversion: ((_ amount: Double) -> ())?
    var didGetHistoricalData: ((_ toISOData: [String: Any], _ fromISOData: [String: Any]) -> ())?
    var apiUrl = "https://free.currencyconverterapi.com/api/v5/"
    
    func loadCurrencies(){
        let dbRef = Database.database().reference()
        let flagsRef = dbRef.child("flags")
        flagsRef.observe(DataEventType.value) { (snapshot) in
            var flagsFromDB = [Currency]()
            for loadedSnapshot in snapshot.children {
                let loadedFlag = Currency(snapshot: loadedSnapshot as! DataSnapshot)
                flagsFromDB.append(loadedFlag)
            }
            self.didGetCurrencies?(flagsFromDB)
        }
    }
    
    func convert(_ from: String, _ to: String, _ amount: String){
        let endPoint = "convert?q=\(from)_\(to)&compact=y"
        let amountFromString: Double = changeAmountToDouble(amount)
        if(amountFromString != -999){
            var convertedAmount: Double!
            Alamofire.request(URL(string: "\(apiUrl)\(endPoint)")!).responseJSON { (response) in
                guard response.result.isSuccess else {
                    print("Error while fetching value: \(String(describing: response.result.error))")
                    return
                }
                guard let result = response.result.value as? [String: Any] else {
                    print("Invalid info received")
                    return
                }
                guard let valueHolder = result["\(from)_\(to)"] as? [String: Any] else {
                    print("Invalid info received2")
                    return
                }
                print(valueHolder)
                guard let value = valueHolder["val"] as? Double else{
                    print("Invalid conversion")
                    return
                }
                convertedAmount = amountFromString * value
                self.didFinishConversion?(convertedAmount)
            }
        }
    }
    
    func changeAmountToDouble(_ amount: String) -> Double {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 1
        
        if formatter.number(from: amount) != nil {
            return formatter.number(from: amount) as! Double
        }
        else{
            return -999
        }
    }
    
    func getHistoricalData(_ from: String, _ to: String){
        let startAndEndDates = calcStartAndEndDatesForChart()
        let endPoint = "convert?q=\(from)_\(to),\(to)_\(from)&compact=ultra&date=\(startAndEndDates[0])&endDate=\(startAndEndDates[1])"
        Alamofire.request(URL(string: "\(apiUrl)\(endPoint)")!).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching value: \(String(describing: response.result.error))")
                return
            }
            guard let result = response.result.value as? [String: Any] else {
                print("Invalid info received")
                return
            }
            guard let toISOData = result["\(from)_\(to)"] as? [String: Any] else {
                print("Invalid info received2")
                return
            }
            guard let fromISOData = result["\(to)_\(from)"] as? [String: Any] else {
                print("Invalid info received3")
                return
            }
            self.didGetHistoricalData?(toISOData,fromISOData)
        }

    }
    
    func calcStartAndEndDatesForChart() -> [String]{
        let userCalendar = Calendar.current
        let dateFormatter = DateFormatter()
        let today = Date()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayDateInString = dateFormatter.string(from: today)
        // subtracting one week from current date
        let oneWeekBefore = userCalendar.date(byAdding: .weekOfYear, value: -1, to: today)
        let oneWeekBeforeDateInString = dateFormatter.string(from: oneWeekBefore!)
        return [oneWeekBeforeDateInString,todayDateInString]
    }
    
    // check connectivity status of the device
    func isConnectedToInternet() ->Bool {
        print(NetworkReachabilityManager()!.isReachable)
        return NetworkReachabilityManager()!.isReachable
    }
    
}
