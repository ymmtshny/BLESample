//
//  ViewController.swift
//  BLESample
//
//  Created by Shinya Yamamoto on 2016/11/01.
//  Copyright © 2016年 Shinya Yamamoto. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController,
                      CBCentralManagerDelegate,
                      CBPeripheralDelegate,
                      UITableViewDelegate,
                      UITableViewDataSource{
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    
    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var tableView:UITableView!
    var readDataArray = [String]()
    var deviceArray = [CBPeripheral]()
    
    enum displayType {
        case device
        case readValue
    }
    
    var currentDisplayType = displayType.device
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "MyCell")

        self.disconnectButton.addTarget(self, action: #selector(self.tapDisconnetButton), for: .touchUpInside)
        
        //centralManager初期化
        self.centralManager = CBCentralManager(delegate:self, queue:nil)
        
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state :\(central.state.rawValue)")
        print("state :\(central)")
        switch(central.state) {
            case .poweredOn:
                //スキャン処理
                self.centralManager.scanForPeripherals(withServices: nil, options: nil)
                break
            default:
                break
        }
    }
    
    func centralManager(_ central: CBCentralManager,
           didDiscover peripheral: CBPeripheral,
                advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        print("検出したデバイス \(peripheral)")
        
//        var shouldAppend = true
//        for device in deviceArray {
//            if(device.identifier.uuidString == peripheral.identifier.uuidString) {
//                shouldAppend = false
//                
//            }
//        }
//        if shouldAppend {
//            self.deviceArray.append(peripheral)
//            self.tableView.reloadData()
//        }
        
        //macbook air 10E96671-E2B2-41FC-85BA-35CF006970F2
        if(peripheral.identifier.uuidString == "10E96671-E2B2-41FC-85BA-35CF006970F2") {
            if self.deviceArray.count == 0 {
                peripheral.delegate = self
                self.deviceArray.append(peripheral)
            }
            self.tableView.reloadData()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("接続成功")
        
        //Service探索
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("接続失敗...")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        let services:[CBService]? = peripheral.services
        print("\(services?.count)個のサービスを発見")
        if let services = services {
            for aService in services {
                peripheral.discoverCharacteristics(nil, for:aService)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?){
        let characteristics:[CBCharacteristic]? = service.characteristics
        print("\(characteristics?.count)個のキャラクタリスティックを発見")
        
        if let characteristics = characteristics {
            for aCharacteristic in characteristics {
                if aCharacteristic.properties == CBCharacteristicProperties.read {
                    peripheral.readValue(for: aCharacteristic)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("***********************")
        print("読み取り成功")
        currentDisplayType = .readValue
        print("uuid :\(characteristic.service.uuid)")
        print("uuid :\(characteristic.uuid)")
        print("value:\(characteristic.value)")
        
        if let data = characteristic.value {
            print(String(data: data, encoding: .utf8))
            if let str = String(data: data, encoding: .utf8) {
                self.readDataArray.append(str)
                self.tableView.reloadData()
            }
        }
        
        let uuid = CBUUID(string:characteristic.uuid.uuidString)
        print(uuid)
        print("***********************")
        
    }
    
    //接続解除
    @IBAction func tapDisconnetButton(sender:Any) {
        currentDisplayType = .device
        self.tableView.reloadData()
    }
    
    //MARK:- TableView関連
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch currentDisplayType{
        case .device:
            return deviceArray.count
        case .readValue:
            return readDataArray.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath as IndexPath)
        
        switch currentDisplayType{
        case .device:
            let peripheral = deviceArray[indexPath.row]
            var str = "\(peripheral.identifier.uuidString)\n"
            str = str.appending("\(peripheral.name)\n")
            str = str.appending("\(peripheral.state.rawValue)\n")
            cell.textLabel!.text = str
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.systemFont(ofSize: 12)
            
        case .readValue:
            cell.textLabel!.text = readDataArray[indexPath.row]
            
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //保持しておく
        self.peripheral = deviceArray[indexPath.row]
        
        //接続処理
        self.centralManager.connect(self.peripheral, options:nil)
        
    }
    
}


