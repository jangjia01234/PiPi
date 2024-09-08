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


// MARK: - MCUWB
class MCUWB: NSObject, UWB {
    private var _niSession: NISession!
    private var _mcSession: MCSession!
    private var _mcPeerID: MCPeerID!
    private var _mcAdvertiser: MCNearbyServiceAdvertiser!
    private var _mcBrowser: MCNearbyServiceBrowser!

    @Published var discoveredPeers = [DiscoveredPeer]()
    
    private let activityID: String

    init(activityID: String) {
        self.activityID = activityID
        self._niSession = NISession()
        self._mcPeerID = MCPeerID(displayName: UIDevice.current.name)
        self._mcSession = MCSession(peer: _mcPeerID, securityIdentity: nil, encryptionPreference: .required)
        self._mcAdvertiser = MCNearbyServiceAdvertiser(peer: _mcPeerID, discoveryInfo: nil, serviceType: "radar")
        self._mcBrowser = MCNearbyServiceBrowser(peer: _mcPeerID, serviceType: "radar")
        
        super.init()

        _niSession.delegate = self
        _mcSession.delegate = self
        _mcAdvertiser.delegate = self
        _mcBrowser.delegate = self
        
        _mcAdvertiser.startAdvertisingPeer()
        _mcBrowser.startBrowsingForPeers()
    }

    private func sendDiscoveryToken() {
        guard let discoveryToken = _niSession.discoveryToken else {
            return
        }

        let data = try! NSKeyedArchiver.archivedData(withRootObject: discoveryToken, requiringSecureCoding: true)

        try! _mcSession.send(data, toPeers: _mcSession.connectedPeers, with: .reliable)
    }
}

extension MCUWB: NISessionDelegate {
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
}

extension MCUWB: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        guard state == .connected else { return }
        sendDiscoveryToken()
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        do {
            guard let discoveryToken = try NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) else {
                return
            }

            let config = NINearbyPeerConfiguration(peerToken: discoveryToken)
            _niSession.run(config)
        } catch {}
    }

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {}

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {}

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {}
}

extension MCUWB: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        guard let context,
              let opponentActivityID = String(data: context, encoding: .utf8) else { return }
        
        invitationHandler((opponentActivityID == activityID), _mcSession)
    }
}

extension MCUWB: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {
        guard let contextData = activityID.data(using: .utf8) else { return }
        
        _mcBrowser.invitePeer(peerID, to: _mcSession, withContext: contextData, timeout: 10)
    }

    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {}

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {}
}


// MARK: - CBUWB
let SERVICE_UUID = CBUUID(string: "0000180D-0000-1000-8000-00805F9B34FB")
let CHARACTERISTIC_UUID = CBUUID(string: "00002A37-0000-1000-8000-00805F9B34FB")

class CBUWB: NSObject, UWB {
    private var _niSession: NISession!
    private var _peripheral: CBPeripheralManager!
    private var _central: CBCentralManager!
    private var _transferCharacteristic: CBMutableCharacteristic!
    private var _peripherals = [CBPeripheral]()

    @Published var discoveredPeers = [DiscoveredPeer]()

    override init() {
        super.init()

        _niSession = NISession()
        _niSession.delegate = self
        
        _peripheral = CBPeripheralManager(delegate: self, queue: nil, options: [CBPeripheralManagerOptionShowPowerAlertKey: true])

        _central = CBCentralManager(delegate: self, queue: nil)
        _central.delegate = self
    }

    private func sendDiscoveryToken() {
        guard let discoveryToken = _niSession.discoveryToken else {
            return
        }

        let data = try! NSKeyedArchiver.archivedData(withRootObject: discoveryToken, requiringSecureCoding: true)

        _transferCharacteristic.value = data
        _peripheral.updateValue(_transferCharacteristic.value!, for: _transferCharacteristic, onSubscribedCentrals: nil)
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

        _transferCharacteristic = CBMutableCharacteristic(
            type: CHARACTERISTIC_UUID,
            properties: [.read, .notify],
            value: nil,
            permissions: [.readable]
        )

        let transferService = CBMutableService(
            type: SERVICE_UUID,
            primary: true
        )
        transferService.characteristics = [_transferCharacteristic]

        peripheral.add(transferService)
        peripheral.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [transferService.uuid],
            CBAdvertisementDataLocalNameKey: UIDevice.current.name
        ])
    }
}

extension CBUWB: CBCentralManagerDelegate {
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {}

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else { return }

        central.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            central.scanForPeripherals(withServices: [SERVICE_UUID], options: nil)
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        _peripherals.append(peripheral)
        central.connect(peripheral, options: nil)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([SERVICE_UUID])
        sendDiscoveryToken()
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let index = _peripherals.firstIndex(of: peripheral) {
            _peripherals.remove(at: index)
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let index = _peripherals.firstIndex(of: peripheral) {
            _peripherals.remove(at: index)
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
            _niSession.run(config)
        } catch {}
    }
}
