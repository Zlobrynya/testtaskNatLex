//
//  ChartVC.swift
//  testtaskNatLex
//
//  Created by Nikitin Nikita on 22/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Charts

class ChartVC: UIViewController {
    @IBOutlet weak var buttonStart: UIButton!
    @IBOutlet weak var buttonEnd: UIButton!
    @IBOutlet weak var datePicker: UIPickerView!
    @IBOutlet weak var chartView: LineChartView!
    
    var nameCity = ""
    
    private let vm = ChartModelView()
    private var isOpenPicker = false
    private let disposeBag = DisposeBag()
    private var selectButton: UIButton? = nil
    private var indexStart = 0
    private var indexStop = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.isHidden = true
        
        _ = buttonEnd.rx.tap.bind{
            self.isOpenPicker = true
            self.datePicker.isHidden = !self.isOpenPicker
            self.selectButton = self.buttonEnd
            self.datePicker.selectRow(self.indexStop, inComponent: 0, animated: false)
        }
        
        _ = buttonStart.rx.tap.bind{
            self.isOpenPicker = true
            self.datePicker.isHidden = !self.isOpenPicker
            self.selectButton = self.buttonStart
            self.datePicker.selectRow(self.indexStart, inComponent: 0, animated: false)
        }
        
        _ = vm.modelsWeatherSubject?.subscribe({ event in
            if let elements = event.element{
                self.indexStop = elements.count
                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "dd.MM.yyyy HH:mm:ss"
                self.buttonStart.setTitle(dateFormatterPrint.string(from: elements[0].time), for: .normal)
                self.buttonEnd.setTitle(dateFormatterPrint.string(from: elements[elements.count-1].time), for: .normal)

                self.drawChart(element: elements)
                //self.datePicker.
            }
        })
        
        vm.modelsWeatherSubject?.bind(to: datePicker.rx.itemTitles) { (row, element) in
            let dateFormatterPrint = DateFormatter()
            dateFormatterPrint.dateFormat = "dd.MM.yyyy HH:mm:ss"
            return dateFormatterPrint.string(from: element.time)
        }.disposed(by: disposeBag)
        
        datePicker.rx.itemSelected.subscribe { (event) in
            switch event {
            case .next(let selected):
                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "dd.MM.yyyy HH:mm:ss"
                let str = dateFormatterPrint.string(from: self.vm.modelsWeather[selected.row].time)
                self.selectButton?.setTitle(str, for: .normal)
                
                if self.selectButton == self.buttonEnd{
                    self.indexStop = selected.row + 1
                } else if self.selectButton == self.buttonStart{
                    self.indexStart = selected.row
                }
                
                if self.indexStart < self.indexStop{
                    self.isOpenPicker = false
                    self.datePicker.isHidden = !self.isOpenPicker
                    self.selectButton = nil
                    self.drawChart(element: self.vm.modelsWeather)
                }
            default:
                break
            }
        }.disposed(by: disposeBag)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vm.getData(city: nameCity)
    }
    
    
    private func drawChart(element: [ModelWeather]){
        var lineChartEntry  = [ChartDataEntry]()
        var lineChartEntryTempMax  = [ChartDataEntry]()
        var lineChartEntryTempMin  = [ChartDataEntry]()
        var arrayX = [String]()

        //here is the for loop
        print("indexStart \(indexStart)  indexStop \(indexStop)")
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
