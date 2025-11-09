//
//  NFCScannerView.swift
//  tappy
//
//  Created by Maria Jose Cordova igartua on 11/9/25.
//
import SwiftUI
import CoreNFC

struct NFCScannerView: View {
    @ObservedObject var viewModel: MenuViewModel
    @State private var isScanning = false
    @State private var detectedURL: String?
    @State private var nfcReader: NFCReaderSession?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                if isScanning {
                    Image(systemName: "wave.3.right")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                        .symbolEffect(.variableColor.iterative)
                    
                    Text("Hold near NFC tag")
                        .font(.title2)
                        .fontWeight(.semibold)
                } else if let url = detectedURL {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.green)
                    
                    Text("Menu Found!")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Button(action: {
                        viewModel.loadMenuFromURL(url)
                        dismiss()
                    }) {
                        Label("Load Menu", systemImage: "arrow.down.circle")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                } else {
                    Image(systemName: "wave.3.right.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text("Ready to Scan")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Button(action: {
                        startScanning()
                    }) {
                        Label("Start Scanning", systemImage: "wave.3.right")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 40)
                    .disabled(!isNFCAvailable)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("NFC Scanner")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            if isNFCAvailable {
                startScanning()
            } else {
                viewModel.errorMessage = "NFC not available on this device."
            }
        }
    }
    
    private var isNFCAvailable: Bool {
        #if targetEnvironment(simulator)
        // CoreNFC is not available on the simulator.
        return false
        #else
        if #available(iOS 13.0, *) {
            return NFCNDEFReaderSession.readingAvailable
        } else {
            return false
        }
        #endif
    }
    
    func startScanning() {
        guard isNFCAvailable else { return }
        isScanning = true
        detectedURL = nil
        
        nfcReader = NFCReaderSession()
        nfcReader?.scanForMenu { result in
            DispatchQueue.main.async {
                isScanning = false
                switch result {
                case .success(let url):
                    detectedURL = url
                case .failure(let error):
                    if !error.localizedDescription.contains("cancelled") {
                        viewModel.errorMessage = error.localizedDescription
                    }
                    dismiss()
                }
            }
        }
    }
}
