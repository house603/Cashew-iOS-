//
//  TestViewController.swift
//  Cashew
//
//  Created by Robo Atenaga on 3/8/18.
//  Copyright © 2018 Robo Atenaga. All rights reserved.
//

import UIKit
import Alamofire

//struct Currenc: Decodable {
//    let currencyName: String
//    let id: String
//}

class TestViewController: UIViewController {

    @IBOutlet weak var lblValue: UILabel!
    var currencies = [Currency]()
    //var currencies2 = [Currenc]()
    
    var apiUrl = "https://free.currencyconverterapi.com/api/v5/"
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func convert(_ sender: UIButton) {
        convertValue(from: "USD", to: "NGN", amount: 100)
        //getCurrencies()
    }
    
    func convertValue(from: String, to: String, amount: Double){
        let endPoint = "convert?q=\(from)_\(to)&compact=y"
        Alamofire.request(URL(string: "\(apiUrl)\(endPoint)")!).responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error while fetching value: \(String(describing: response.result.error))")
                return
            }
            
            guard let result = response.result.value as? [String: Any] else {
                print("Invalid info received")
                return
            }
            
            print(result)
        }
    }
    
//    func getCurrencies(){
//        let endPoint = "currencies"
//
//        Alamofire.request(URL(string: "\(apiUrl)\(endPoint)")!).responseJSON { (response) in
//            guard response.result.isSuccess else {
//                print("Error while fetching value: \(String(describing: response.result.error))")
//                return
//            }
//
////            guard let result = response.result.value as? [String: Any] else {
////                print("Invalid info received")
////                return
////            }
//
//                        guard let result = response.data else {
//                            print("Invalid info received")
//                            return
//                        }
//
//            print(result)
//
//            do{
//                self.currencies2 = try JSONDecoder().decode([Currenc].self, from: result)
//                for currency in self.currencies {
//                    print(currency.currencyName, ":", currency.id)
//                }
//            }catch{
//                print("error")
//            }
//        }
//    }
}
