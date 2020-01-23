//
//  ChartVC.swift
//  testtaskNatLex
//
//  Created by Nikitin Nikita on 22/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import UIKit
import Charts

class ChartVC: UIViewController {
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonEnd: UIButton!
    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var chartView: LineChartView!
    
    var nameCity = ""
    var isFarengate = false
    
    private let vm = ChartModelView()
    private var isOpenPicker = false
    private var selectButton: UIButton? = nil
    private var indexStart = 0
    private var indexStop = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.isHidden = true
        datePicker.delegate = self
        datePicker.dataSource = self
        vm.getData(city: nameCity, isFarengate: isFarengate){ error in
            if let error = error{
                return
            }
            self.indexStop = self.vm.modelsWeather.count
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd.MM.yyyy HH:mm:ss"
            self.buttonStart.setTitle(dateFormatterPrint.string(from: self.vm.modelsWeather[0].time), for: .normal)
            self.buttonEnd.setTitle(dateFormatterPrint.string(from: self.vm.modelsWeather[self.vm.modelsWeather.count-1].time), for: .normal)
            self.datePicker.reloadAllComponents()
            self.drawChart(element: self.vm.modelsWeather)
        }
    }

    
    private func drawChart(element: [ModelWeather]){
        var lineChartEntry  = [ChartDataEntry]()
        var lineChartEntryTempMax  = [ChartDataEntry]()
        var lineChartEntryTempMin  = [ChartDataEntry]()
        var arrayX = [String]()

        //here is the for loop
        for i in indexStart..<indexStop {
            lineChartEntry.append(ChartDataEntry(x: Double(i) , y: Double(element[i].temp)))
            lineChartEntryTempMax.append(ChartDataEntry(x: Double(i) , y: Double(element[i].tempMax)))
            lineChartEntryTempMin.append(ChartDataEntry(x: Double(i) , y: Double(element[i].tempMin)))
        }
        
        for item in element{
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "HH.mm"
            arrayX.append(dateFormatterPrint.string(from: item.time))
        }
        
        let line1 = LineChartDataSet(entries: lineChartEntry, label: "Temp")
        let line2 = LineChartDataSet(entries: lineChartEntryTempMax, label: "Temp Max")
        line2.colors = [NSUIColor.red]
        let line3 = LineChartDataSet(entries: lineChartEntryTempMin, label: "Temp Min")
        line3.colors = [NSUIColor.blue]
        
        let data = LineChartData()
        data.addDataSet(line1)
        data.addDataSet(line2)
        data.addDataSet(line3)
        let leftAxisFormatter = DateValueFormatter()
        leftAxisFormatter.arrayX = arrayX
        chartView.xAxis.valueFormatter = leftAxisFormatter
        
        chartView.xAxis.centerAxisLabelsEnabled = false
        chartView.data = data
    }
    
    @IBAction func clickStart(_ sender: Any) {
        self.isOpenPicker = true
        self.datePicker.isHidden = !self.isOpenPicker
        self.selectButton = self.buttonStart
        self.datePicker.selectRow(self.indexStart, inComponent: 0, animated: false)
    }
    
    @IBAction func clickEnd(_ sender: Any) {
        self.isOpenPicker = true
        self.datePicker.isHidden = !self.isOpenPicker
        self.selectButton = self.buttonEnd
        self.datePicker.selectRow(self.indexStop, inComponent: 0, animated: false)
    }
}

extension ChartVC: UIPickerViewDelegate{
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd.MM.yyyy HH:mm:ss"
        let str = dateFormatterPrint.string(from: self.vm.modelsWeather[row].time)
        self.selectButton?.setTitle(str, for: .normal)
        
        if self.selectButton == self.buttonEnd{
            self.indexStop = row + 1
        } else if self.selectButton == self.buttonStart{
            self.indexStart = row
        }
        
        if self.indexStart < self.indexStop{
            self.isOpenPicker = false
            self.datePicker.isHidden = !self.isOpenPicker
            self.selectButton = nil
            self.drawChart(element: self.vm.modelsWeather)
        }
    }
}

extension ChartVC: UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
         return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return vm.modelsWeather.count
    }
    
    // The data to return fopr the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd.MM.yyyy HH:mm:ss"
        return dateFormatterPrint.string(from: vm.modelsWeather[row].time)
    }
}

class DateValueFormatter: NSObject, IAxisValueFormatter {
    private let dateFormatter = DateFormatter()
    var arrayX = [String]()

    override init() {
        super.init()
        dateFormatter.dateFormat = "dd MMM HH:mm"
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return arrayX[Int(value)]
    }
}
