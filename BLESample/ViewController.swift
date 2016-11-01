//
//  ViewController.swift
//  BLESample
//
//  Created by Shinya Yamamoto on 2016/11/01.
//  Copyright © 2016年 Shinya Yamamoto. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate {
    var centralManager: CBCentralManager!
    var peripheral: CBPeripheral!
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //centralManager初期化
        self.centralManager = CBCentralManager(delegate:self, queue:nil)
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("state :\(central.state)")
        switch(central.state) {
            case .poweredOn:
                //スキャン処理
                //self.centralManger.scanForPeripheralsWithServices(nil, option:nil)
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
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("接続失敗...")
    }
}


