//
//  UWBManager.swift
//  PiPi
//
//  Created by Jia Jang on 8/7/24.
//

import SwiftUI
import Combine
import CoreBluetooth
import NearbyInteraction
import MultipeerConnectivity


// MARK: - UWB
protocol UWB: ObservableObject {
    var discoveredPeers: [DiscoveredPeer] { get set }
}

struct DiscoveredPeer {
    let token: NIDiscoveryToken
    let distance: Float
    let direction: SIMD3<Float>?
}

// MARK: - CBUWB

final class CBUWB: NSObject, UWB {
    private var niSession: NISession!
    private var peripheral: CBPeripheralManager!
    private var central: CBCentralManager!
    private var transferCharacteristic: CBMutableCharacteristic!
    private var peripherals = [CBPeripheral]()
    
    private let SERVICE_UUID: CBUUID
    private let CHARACTERISTIC_UUID: CBUUID

    @Published var discoveredPeers = [DiscoveredPeer]()
    
    init(activityID: String) {
        self.SERVICE_UUID = CBUUID(string: activityID)
        self.CHARACTERISTIC_UUID = CBUUID(string: activityID)
        self.niSession = NISession()
        self.peripheral = CBPeripheralManager(
            delegate: nil,
            queue: nil,
            options:[CBPeripheralManagerOptionShowPowerAlertKey: true]
        )
        self.central = CBCentralManager()
                                              
        super.init()
        
        niSession.delegate = self
        peripheral.delegate = self
        central.delegate = self
    }

    private func sendDiscoveryToken() {
        guard let discoveryToken = niSession.discoveryToken else {
            return
        }
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: discoveryToken, requiringSecureCoding: true) else { return }
        
        transferCharacteristic.value = data
        peripheral.updateValue(transferCharacteristic.value!, for: transferCharacteristic, onSubscribedCentrals: nil)
    }
}

extension CBUWB: NISessionDelegate {
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        for object in nearbyObjects {
            let discoveredPeer = DiscoveredPeer(token: object.discoveryToken, distance: object.distance ?? 0.0, direction: object.direction)

            if let index = discoveredPeers.firstIndex(where: { $0.token == object.discoveryToken }) {
                discoveredPeers[index] = discoveredPeer
            } else {
                discoveredPeers.append(discoveredPeer)
            }
        }
    }

    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        if let index = discoveredPeers.firstIndex(where: { $0.token == session.discoveryToken }) {
            discoveredPeers.remove(at: index)
        }
    }
}

extension CBUWB: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        guard peripheral.state == .poweredOn else { return }

        transferCharacteristic = CBMutableCharacteristic(
            type: CHARACTERISTIC_UUID,
            properties: [.read, .notify],
            value: nil,
            permissions: [.readable]
        )

        let transferService = CBMutableService(
            type: SERVICE_UUID,
            primary: true
        )
        transferService.characteristics = [transferCharacteristic]

        peripheral.add(transferService)
        peripheral.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [transferService.uuid]
        ])
    }
}

extension CBUWB: CBCentralManagerDelegate {
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {}

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }

        central.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            
            central.scanForPeripherals(withServices: [self.SERVICE_UUID], options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
        }
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([SERVICE_UUID])
        sendDiscoveryToken()
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let index = peripherals.firstIndex(of: peripheral) {
            peripherals.remove(at: index)
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let index = peripherals.firstIndex(of: peripheral) {
            peripherals.remove(at: index)
        }
    }
}

extension CBUWB: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let service = peripheral.services?.first(where: { $0.uuid == SERVICE_UUID }) else { return }
        peripheral.discoverCharacteristics([CHARACTERISTIC_UUID], for: service)
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristic = service.characteristics?.first(where: { $0.uuid == CHARACTERISTIC_UUID }) else { return }
        peripheral.setNotifyValue(true, for: characteristic)
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data = characteristic.value else {
            return
        }
        
        do {
            guard let discoveryToken = try NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) else {
                return
            }

            let config = NINearbyPeerConfiguration(peerToken: discoveryToken)
            niSession.run(config)
        } catch {}
    }
}
