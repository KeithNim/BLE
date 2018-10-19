//
//  ViewController.swift
//  BLE
//
//  Created by 14223775 on 19/10/2018.
//  Copyright © 2018 14223775. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITextFieldDelegate {
    var centralManager:CBCentralManager!
    var heartRateMonitor:CBPeripheral?
    var characteristic_2a38:CBCharacteristic?
    var characteristic_2a39:CBCharacteristic?
    
    @IBOutlet var locField: UITextField!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var heartLabel: UILabel!
    @IBOutlet var locLabel: UILabel!
    
    @IBAction func scan_clicked(_ sender: Any) {
        let uuid = CBUUID(string: "180D");
        
        centralManager.scanForPeripherals(withServices: [uuid], options: nil)
    }
    
    @IBAction func read_clicked(_ sender: Any) {
        heartRateMonitor?.readValue(for: characteristic_2a38!)
    }
    
    @IBAction func write_clicked(_ sender: Any) {
        if let text:String = locField.text {
            
            if (text.count >= 2) {
                
                var buf:[UInt8] = [];
                
                let byte = String(text.prefix(2))
                
                buf.append(UInt8(byte, radix: 16)!)
                
                heartRateMonitor?.writeValue(Data(bytes: buf), for: characteristic_2a39!, type: .withResponse)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber){
        
        print(peripheral);
        
        stateLabel.text = peripheral.name
        
        if peripheral.name == "Keith’s MacBook Air" {  // modify this, use your computer name!
            
            // 1 - save a reference to the heat
            heartRateMonitor = peripheral
            
            // 2 - set the delegate property to point to the view controller
            heartRateMonitor!.delegate = self
            
            // 3 - Request a connection to the peripheral
            centralManager.connect(heartRateMonitor!, options: nil)
            
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("**** SUCCESSFULLY CONNECTED TO A PERIPHERAL!!!")
        
        stateLabel.text = "**** SUCCESSFULLY CONNECTED TO A PERIPHERAL!!!"
        
        // - NOTE:  we pass nil here to request ALL services be discovered.
        //          If there was a subset of services we were interested in, we could pass the UUIDs here.
        //          Doing so saves battery life and saves time.
        peripheral.discoverServices(nil)
    }
    
    // When the specified services are discovered, the peripheral calls the peripheral:didDiscoverServices: method of its delegate object.
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        // Core Bluetooth creates an array of CBService objects —- one for each service that is discovered on the peripheral.
        if let services = peripheral.services {
            for service in services {
                print("Discovered service \(service)")
                stateLabel.text = "Discovered service \(service)"
                
                if (service.uuid == CBUUID(string: "180D")) {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    /*
     Invoked when you discover the characteristics of a specified service.
     
     If the characteristics of the specified service are successfully discovered, you can access
     them through the service's characteristics property.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let characteristics = service.characteristics {
            
            for characteristic in characteristics {
                
                if characteristic.uuid == CBUUID(string: "2A38") {
                    
                    stateLabel.text = "charactistic 2A38 discovered."
                    characteristic_2a38 = characteristic
                    
                }
                
                if characteristic.uuid == CBUUID(string: "2A39") {
                    
                    stateLabel.text = "charactistic 2A39 discovered."
                    characteristic_2a39 = characteristic
                    
                }
                
                if characteristic.uuid == CBUUID(string: "2A37") {
                    
                    stateLabel.text = "Charactistic 2A37 discovered."
                    heartRateMonitor?.setNotifyValue(true, for: characteristic)
                    
                }
                
            }
        }
    }
    
    /*
     Invoked when you retrieve a specified characteristic’s value,
     or when the peripheral device notifies your app that the characteristic’s value has changed.
     
     This method is invoked when your app calls the readValueForCharacteristic: method,
     or when the peripheral notifies your app that the value of the characteristic for
     which notifications and indications are enabled has changed.
     
     If successful, the error parameter is nil.
     If unsuccessful, the error parameter returns the cause of the failure.
     */
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if (characteristic.uuid == CBUUID(string: "2A38")) {
            
            if let dataBytes = characteristic.value {
                
                let value = Int(UInt8(bigEndian: dataBytes.withUnsafeBytes { $0.pointee }))
                
                locLabel.text = "\(value)"
                
            }
        }
        
        if (characteristic.uuid == CBUUID(string: "2A37")) {
            
            if let dataBytes = characteristic.value {
                
                let value = Int(UInt16(bigEndian: dataBytes.withUnsafeBytes { $0.pointee }))
                
                heartLabel.text = "\(value)"
                
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var state = ""
        
        switch central.state {
        case .poweredOn:
            state = "Bluetooth on this device is currently powered on."
        case .poweredOff:
            state = "Bluetooth on this device is currently powered off."
        case .unsupported:
            state = "This device does not support Bluetooth Low Energy."
        case .unauthorized:
            state = "This app is not authorized to use Bluetooth Low Energy."
        case .resetting:
            state = "The BLE Manager is resetting; a state update is pending."
        case .unknown:
            state = "The state of the BLE Manager is unknown."
        }
        
        stateLabel.text = state;
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

