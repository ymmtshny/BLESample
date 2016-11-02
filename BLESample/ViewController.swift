//
//  ViewController.swift
//  BLESample
//
//  Created by Shinya Yamamoto on 2016/11/01.
//  Copyright © 2016年 Shinya Yamamoto. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate  {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    override func viewDidLoad() {
        super.viewDidLoad()
    
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
        
        //保持しておく
        self.peripheral = peripheral
        
        //接続処理
        self.centralManager.connect(self.peripheral, options:nil)
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
        print("uuid :\(characteristic.service.uuid)")
        print("uuid :\(characteristic.uuid)")
        print("value:\(characteristic.value)")
        
        let uuid = CBUUID(string:characteristic.uuid.uuidString)
        print(uuid)
        print("***********************")
        
    }
}


