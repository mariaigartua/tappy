//
//  NFCReaderSession.swift
//  tappy
//
//  Created by Maria Jose Cordova igartua on 11/9/25.
//
import CoreNFC
import Foundation

class NFCReaderSession: NSObject, NFCNDEFReaderSessionDelegate {
    private var session: NFCNDEFReaderSession?
    private var completion: ((Result<String, Error>) -> Void)?
    
    func scanForMenu(completion: @escaping (Result<String, Error>) -> Void) {
        self.completion = completion
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold iPhone near NFC tag"
        session?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let message = messages.first,
              let record = message.records.first,
              let url = record.wellKnownTypeURIPayload() else {
            session.invalidate(errorMessage: "No valid URL found")
            completion?(.failure(NSError(domain: "NFC", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid tag"])))
            return
        }
        
        session.alertMessage = "Menu found!"
        session.invalidate()
        completion?(.success(url.absoluteString))
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let completion = completion {
            completion(.failure(error))
            self.completion = nil
        }
    }
}
