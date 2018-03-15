//
//  Currency.swift
//  Cashew
//
//  Created by Robo Atenaga on 3/7/18.
//  Copyright © 2018 Robo Atenaga. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Currency: NSObject, NSCoding {
    var flag: String
    var currencyName: String
    var iso: String
    var itemRef: DatabaseReference?
    
    init(flag: String, currencyName: String, iso: String) {
        self.flag = flag
        self.currencyName = currencyName
        self.iso = iso
        self.itemRef = nil
    }
    
    init(snapshot: DataSnapshot) {
        self.iso = snapshot.key
        itemRef = snapshot.ref
        let snapshotValue = snapshot.value as? NSDictionary
        
        if let currencyName = snapshotValue?["currencyName"] as? String {
            self.currencyName = currencyName
        }
        else{
            self.currencyName = ""
        }
        
        if let flagUrl = snapshotValue?["flag"] as? String {
            self.flag = flagUrl
        }
        else{
            self.flag = ""
        }
    }
    
    // NSCoding required protocols
    // decoder
    required init(coder aDecoder: NSCoder) {
        self.flag = aDecoder.decodeObject(forKey: "flag") as! String
        self.currencyName = aDecoder.decodeObject(forKey: "currencyName") as! String
        self.iso = aDecoder.decodeObject(forKey: "iso") as! String
        self.itemRef = nil
    }
    
    // encoder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.flag, forKey: "flag")
        aCoder.encode(self.iso, forKey: "iso")
        aCoder.encode(self.currencyName, forKey: "currencyName")
    }
}

