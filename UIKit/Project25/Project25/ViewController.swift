//
//  ViewController.swift
//  Project25
//
//  Created by Iaroslav Denisenko on 18.12.2020.
//  Copyright © 2020 Iaroslav Denisenko. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {
    
    // MARK:- Properties
    
    @IBOutlet var flowLayout: UICollectionViewFlowLayout!
    
    var images = [UIImage]()
    let peerID = MCPeerID(displayName: UIDevice.current.name)
    var session: MCSession?
    var advertiser: MCAdvertiserAssistant?
    let serviceType = "hws-project25"

    // MARK:- View setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSession()
    }
    
    func setupUI() {
        title = "Picture share"
        flowLayout.estimatedItemSize = CGSize.zero
        let picturePicker = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(selectPicture))
        let showConnection = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        let promptButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(sendText))
        let deviceListing = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(showDeviceListing))
        navigationItem.leftBarButtonItems = [showConnection, deviceListing]
        navigationItem.rightBarButtonItems = [picturePicker, promptButton]
    }
    
    @objc func showDeviceListing() {
        if let devicesList = session?.connectedPeers.map({$0.displayName}).joined(separator: ",") {
            showAlert(title: "Currently connected devices", message: devicesList.isEmpty ? "No connected devices" : devicesList, actionTitle: "OK", handler: nil)
        }
    }

    // MARK:- imagePickerController setup
    
    @objc func selectPicture() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let picture = info[.editedImage] as? UIImage else { return }
        dismiss(animated: true)
        images.insert(picture, at: 0)
        collectionView.reloadData()
        if let imageData = picture.pngData() {
            sendData(imageData)
        }
    }
    
    // MARK:- Sending data methods
    
    @objc func sendText() {
        let ac = UIAlertController(title: "Send text", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        ac.addAction(UIAlertAction(title: "Send", style: .default, handler: { [weak ac, weak self] action in
            if let text = ac?.textFields?[0].text {
                self?.sendData(Data(text.utf8))
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(ac, animated: true)
    }
    
    func showAlert(title: String?, message: String?, actionTitle: String?, handler: ((UIAlertAction) -> Void)?) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: actionTitle, style: .default, handler: handler))
        present(ac, animated: true)
    }
    
    func sendData(_ data: Data) {
        guard let session = session else { return }
        if session.connectedPeers.count > 0 {
            do {
                try session.send(data, toPeers: session.connectedPeers, with: .reliable)
            } catch {
                showAlert(title: "Send error", message: error.localizedDescription, actionTitle: "OK", handler: nil)
            }
        }
    }
    
    // MARK:- MultipeerConnectivity setup
    
    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true)
    }
    
    func setupSession() {
        session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session?.delegate = self
    }
    
    func startHosting(action: UIAlertAction) {
        guard let session = session else { return }
        advertiser = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: nil, session: session)
        advertiser?.start()
    }
    
    func joinSession(action: UIAlertAction) {
        guard let session = session else { return }
        let browser = MCBrowserViewController(serviceType: serviceType, session: session)
        browser.delegate = self
        present(browser, animated: true)
    }
    
    // MARK:- MCSessionDelegate methods
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("\(peerID.displayName) connected")
        case .connecting:
            print("\(peerID.displayName) connecting")
        case .notConnected:
            print("\(peerID.displayName) not connected")
            showAlert(title: "Warning", message: "\(peerID.displayName) has disconnected", actionTitle: "OK", handler: nil)
        @unknown default:
            print("\(peerID.displayName) unknow state")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async() { [weak self] in
            if let image = UIImage(data: data) {
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
            } else {
                let text = String(decoding: data, as: UTF8.self)
                self?.showAlert(title: "Message from \(peerID.displayName)", message: text, actionTitle: "OK", handler: nil)
            }
        }
    }
    
    // MARK:- MCBrowserViewControllerDelegate methods
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }

    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }

    // MARK:- Setup collectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        return cell
    }

}

