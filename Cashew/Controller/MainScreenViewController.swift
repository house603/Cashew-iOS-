//
//  MainScreenViewController.swift
//  Cashew
//
//  Created by Robo Atenaga on 3/2/18.
//  Copyright © 2018 Robo Atenaga. All rights reserved.
//

import UIKit
import SDWebImage
import Charts

class MainScreenViewController: UIViewController {

    @IBOutlet weak var topFlag: UIImageView!
    @IBOutlet weak var bottomFlag: UIImageView!
    @IBOutlet weak var topISO: UILabel!
    @IBOutlet weak var bottomISO: UILabel!
    @IBOutlet weak var txtBottom: UITextField!
    @IBOutlet weak var txtTop: UITextField!
    @IBOutlet weak var barChart: BarChartView!
    @IBOutlet weak var lineChart: LineChartView!
    
    let numberToolbar: UIToolbar = UIToolbar()
    let currencyData = CurrencyData()
    let userSettings = UserSettings()
    
    var topCurrency: Currency! = nil
    var bottomCurrency: Currency! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        setUpInitConfigs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpViews()
    }
    
    func setUpInitConfigs(){
        // Setup gesture recognizer for the flag imageviews & iso labels
        var tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectCurrency(tapGestureRecognizer:)))
        topFlag.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectCurrency(tapGestureRecognizer:)))
        bottomFlag.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectCurrency(tapGestureRecognizer:)))
        topISO.addGestureRecognizer(tapGestureRecognizer)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectCurrency(tapGestureRecognizer:)))
        bottomISO.addGestureRecognizer(tapGestureRecognizer)
        
        // Setup "Done" button for keypad
        numberToolbar.barStyle = .default
        numberToolbar.items=[
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(hideKeypad)),
        ]
        numberToolbar.sizeToFit()
        txtTop.inputAccessoryView = numberToolbar
    }

    func setUpViews() {
        // check for internet connectivity
        if !currencyData.isConnectedToInternet(){
            // show alert dialog
            showAlertDialog()
            return
        }
        
        // save and get last currencies user selected
        if topCurrency == nil && bottomCurrency == nil{
            getUserSettings()
        }
        else if topCurrency != nil && bottomCurrency != nil{
            saveUserSettings()
        }
        
        // check if currency values are nil, if no, assign values, if yes, use default values.
        if topCurrency != nil {
            topFlag.sd_setImage(with: URL(string: topCurrency.flag), completed: nil)
            topISO.text = topCurrency.iso
        }
        if bottomCurrency != nil {
            bottomFlag.sd_setImage(with: URL(string: bottomCurrency.flag), completed: nil)
            bottomISO.text = bottomCurrency.iso
        }

        // Do conversion if top textfield is not empty
        if txtTop.text != nil && txtTop.text != ""{
            sendConversionData(txtTop.text!)
        }
        
        // Get historical data
        currencyData.getHistoricalData(topISO.text!, bottomISO.text!)
        currencyData.didGetHistoricalData = didGetHistoricalData
    }
    
    func getUserSettings(){
        print("something to test get settings")
        let lastcurriencies = userSettings.getLastCurrencies()
        if lastcurriencies.count <= 0{
            return
        }
        topCurrency = lastcurriencies[0]
        bottomCurrency = lastcurriencies[1]
    }
    
    func saveUserSettings(){
        print("something to test set settings")
        userSettings.saveLastCurrencies(topCurrency, bottomCurrency)
    }
    
    func showAlertDialog(){
        let alert = UIAlertController(title: "Notice", message: "Internet connection is required!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alertActionHandler) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    @IBAction func swapTapped(_ sender: UIButton) {
        if topCurrency != nil && bottomCurrency != nil{
            let tempCurrency = topCurrency
            topCurrency = bottomCurrency
            bottomCurrency = tempCurrency
            setUpViews()
        }
        else {
            // we're using default values
            let tempIso = topISO.text
            topISO.text = bottomISO.text
            bottomISO.text = tempIso
            
            let tempFlag = topFlag.image
            topFlag.image = bottomFlag.image
            bottomFlag.image = tempFlag
            
            if currencyData.isConnectedToInternet(){
                // Send conversion data
                sendConversionData(txtTop.text!)
                // Get historical data
                currencyData.getHistoricalData(topISO.text!, bottomISO.text!)
                currencyData.didGetHistoricalData = didGetHistoricalData
            }
        }
    }
    
    @objc func selectCurrency(tapGestureRecognizer: UITapGestureRecognizer) {
        // check for internet connectivity
        if !currencyData.isConnectedToInternet(){
            // show alert dialog
            showAlertDialog()
            return
        }
        let tappedViewTag = tapGestureRecognizer.view?.tag
        // push the CurrencyList VC
        if let nextVC = storyboard?.instantiateViewController(withIdentifier: "CurrencyList") as? CurrencyListViewController {
            nextVC.previousVC = self
            nextVC.senderTag = tappedViewTag!
            navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    @objc func hideKeypad () {
        txtTop.resignFirstResponder()
    }
    
    func didFinishConversion(_ amount: Double) -> (){
        txtBottom.text = String(format: "%.2f",amount)
    }
    
    func didGetHistoricalData(_ toISOData: [String: Any], _ fromISOData: [String: Any]) -> (){
        // Show chart here
//        var dates = [String]()
//        var topISOValues : [BarChartDataEntry] = [BarChartDataEntry]()
//        //var bottomISOValues : [ChartDataEntry] = [ChartDataEntry]()
//        var i = 0
//        for (key,value) in toISOData {
//            dates.append(key)
//            let dataEntry = BarChartDataEntry(x: Double(i + 1), y: value as! Double)
//            topISOValues.append(dataEntry)
//            //topISOValues.append(ChartDataEntry(x: Double(i + 1), y: value as! Double))
//            i = i+1
//        }
//        let chartDataSet = BarChartDataSet(values: topISOValues, label: "\(topISO.text!) to \(bottomISO.text!) ")
//        chartDataSet.colors = ChartColorTemplates.material()
//        let chartData = BarChartData(dataSet: chartDataSet)
//        barChart.data = chartData
//        barChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
//        barChart.xAxis.granularityEnabled = true
//        barChart.xAxis.granularity = 3.0
//        barChart.xAxis.labelPosition = .bottom
//        barChart.xAxis.centerAxisLabelsEnabled = true
//        barChart.rightAxis.enabled = false
//        barChart.chartDescription?.enabled = false
//        barChart.animate(xAxisDuration: 3.0, yAxisDuration: 3.0, easingOption: .easeInBounce)
//        barChart.xAxis.setLabelCount(dates.count, force: true)
        
        var dates = [String]()
        var topISOValues : [ChartDataEntry] = [ChartDataEntry]()
        var bottomISOValues : [ChartDataEntry] = [ChartDataEntry]()
        var i = 0
        for (key,value) in toISOData {
            dates.append(key)
            topISOValues.append(ChartDataEntry(x: Double(i + 1), y: value as! Double))
            i = i+1
        }
//        let chartDataSet = LineChartDataSet(values: topISOValues, label: "\(topISO.text!) to \(bottomISO.text!) ")
//        chartDataSet.colors = ChartColorTemplates.material()
//        let chartData = LineChartData(dataSet: chartDataSet)
//        lineChart.data = chartData
//        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
//        lineChart.xAxis.granularityEnabled = true
//        lineChart.xAxis.granularity = 3.0
//        lineChart.xAxis.labelPosition = .bottom
//        lineChart.xAxis.centerAxisLabelsEnabled = true
//        lineChart.rightAxis.enabled = false
//        lineChart.chartDescription?.enabled = false
//        lineChart.animate(xAxisDuration: 3.0, yAxisDuration: 3.0, easingOption: .easeInBounce)
//        lineChart.xAxis.setLabelCount(dates.count, force: true)

        
        var j = 0
        for (_,value) in fromISOData {
            bottomISOValues.append(ChartDataEntry(x: Double(j + 1), y: value as! Double))
            j = j+1
        }
        lineChart.xAxis.valueFormatter = IndexAxisValueFormatter(values: dates)
        //lineChart.xAxis.valueFormatter = DefaultAxisValueFormatter { (value, axis) -> String in return dates[Int(value)] }
        lineChart.xAxis.granularity = 1
        lineChart.xAxis.centerAxisLabelsEnabled = true
        let topDataSet = LineChartDataSet(values: topISOValues, label: bottomISO.text!)
        topDataSet.colors = ChartColorTemplates.vordiplom()
        let bottomDataSet = LineChartDataSet(values: bottomISOValues, label: topISO.text!)
        bottomDataSet.colors = ChartColorTemplates.material()
        //let data = LineChartData(dataSets: [topDataSet, bottomDataSet])
        let data = LineChartData(dataSet: topDataSet)
        lineChart.data = data
        bottomDataSet.drawCircleHoleEnabled = false
        bottomDataSet.circleRadius = 3
        topDataSet.drawCircleHoleEnabled = false
        topDataSet.circleRadius = 3
        lineChart.chartDescription?.enabled = false
        lineChart.legend.enabled = true

        lineChart.xAxis.drawGridLinesEnabled = false
        lineChart.xAxis.labelPosition = .bottom
        lineChart.rightAxis.enabled = false
        lineChart.xAxis.setLabelCount(dates.count, force: true)
        
        // This must always be at the end of function
        lineChart.notifyDataSetChanged()
    }
    
    func sendConversionData(_ amount: String){
        currencyData.convert(topISO.text!, bottomISO.text!, amount)
        currencyData.didFinishConversion = didFinishConversion
    }
    
}

extension MainScreenViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // if backspace pressed
        if string.isEmpty {
            if replacementText == ""{
                txtBottom.text = ""
            }
            else{
                // check for internet connectivity
                if !currencyData.isConnectedToInternet(){
                    // show alert dialog
                    showAlertDialog()
                }
                else{
                    // send conversion data
                    sendConversionData(replacementText)
                }
            }
            return true
        }
        
        if(replacementText.isValidDouble()){
            // check for internet connectivity
            if !currencyData.isConnectedToInternet(){
                // show alert dialog
                showAlertDialog()
            }
            else{
                // send conversion data
                sendConversionData(replacementText)
            }
            return true
        }
        else{
            return false
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        txtBottom.text = ""
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension String {
    func isValidDouble() -> Bool {
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 8
        formatter.minimumFractionDigits = 1
        
        if formatter.number(from: self) != nil {
            return true
        }
        else{
            return false
        }
    }
}

