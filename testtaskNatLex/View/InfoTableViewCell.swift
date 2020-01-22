//
//  InfoTableViewCell.swift
//  testtaskNatLex
//
//  Created by Nikitin Nikita on 21/01/2020.
//  Copyright © 2020 Zlobrynya. All rights reserved.
//

import UIKit
import RxCocoa

class InfoTableViewCell: UITableViewCell {
    @IBOutlet weak var labelCity: UILabel!
    @IBOutlet weak var labelTemp: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var delegate: ClickDetals?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        _ = button.rx.tap.bind{
            if let name = self.labelCity.text{
                self.delegate?.clickDetals(name: name.replacingOccurrences(of: ",", with: "", options: .literal, range: nil))
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func setData(model: ModelWeather, isF: Bool){
        labelCity.text = model.name + ","
        var temp = model.temp
        if isF{
            temp *= 32
            labelTemp.text = String(temp) + "˚F"
        }else{
            labelTemp.text = String(temp) + "˚C"
        }
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd.MM.yyyy HH:mm:ss"
        labelDate.text = dateFormatterPrint.string(from: model.time)
        button.isHidden = model.countUnique == 1
    }

}
