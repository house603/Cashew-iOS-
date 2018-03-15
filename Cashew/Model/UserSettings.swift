//
//  UserSettings.swift
//  Cashew
//
//  Created by Robo Atenaga on 3/15/18.
//  Copyright © 2018 Robo Atenaga. All rights reserved.
//

import Foundation

class UserSettings {
    let userDefaults = UserDefaults.standard
    
    func saveLastCurrencies(_ topCurrency: Currency, _ bottomCurrency: Currency){
        print(topCurrency)
        print(bottomCurrency)
        let topCurrencyObject = NSKeyedArchiver.archivedData(withRootObject: topCurrency)
        let bottomCurrencyObject = NSKeyedArchiver.archivedData(withRootObject: bottomCurrency)
        print(topCurrencyObject)
        print(bottomCurrencyObject)
        userDefaults.set(topCurrencyObject, forKey: "lastTopCurrency")
        userDefaults.set(bottomCurrencyObject, forKey: "lastBottomCurrency")
        userDefaults.synchronize()
    }
    
//    func saveUserTheme(){
//
//    }
    
    func getLastCurrencies() -> [Currency]{
        var lastCurrencies = [Currency]()
        print("last currencies")
        guard let lastTopCurrencyData = userDefaults.object(forKey: "lastTopCurrency") as? NSData else{
            return lastCurrencies
        }
        guard let lastTopCurrency = NSKeyedUnarchiver.unarchiveObject(with: lastTopCurrencyData as Data) as? Currency else {
            return lastCurrencies
        }
        guard let lastBottomCurrencyData = userDefaults.object(forKey: "lastBottomCurrency") as? NSData else{
            return lastCurrencies
        }
        guard let lastBottomCurrency = NSKeyedUnarchiver.unarchiveObject(with: lastBottomCurrencyData as Data) as? Currency else {
            return lastCurrencies
        }
        lastCurrencies = [lastTopCurrency, lastBottomCurrency]
        return lastCurrencies
    }
    
//    func getUserTheme(){
//
//    }
}
