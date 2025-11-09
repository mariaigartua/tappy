import SwiftUI
import UIKit
import CoreImage.CIFilterBuiltins

struct MenuResultsView: View {
    @ObservedObject var viewModel: MenuViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Display Menu
                if let menu = viewModel.currentMenu {
                    FormattedMenuView(menu: menu)
                        .padding()
                }
                
                // Upload Section
                VStack(spacing: 16) {
                    if viewModel.menuURL == nil {
                        Button(action: {
                            viewModel.uploadToFirebase()
                        }) {
                            if viewModel.isUploading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Label("Generate Link & QR Code", systemImage: "link")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(viewModel.isUploading)
                    } else if let url = viewModel.menuURL {
                        VStack(spacing: 16) {
                            // QR Code
                            if let qrImage = generateQRCode(from: url) {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 200, height: 200)
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(radius: 5)
                            }
                            
                            Text("Scan QR or Write to NFC Tag")
                                .font(.headline)
                            
                            Text(url)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                                .multilineTextAlignment(.center)
                            
                            // Action buttons
                            HStack(spacing: 12) {
                                Button(action: {
                                    shareQRCode(url: url)
                                }) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                        .font(.subheadline)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                                
                                Button(action: {
                                    UIPasteboard.general.string = url
                                }) {
                                    Label("Copy", systemImage: "doc.on.doc")
                                        .font(.subheadline)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                            }
                            
                            if let destination = URL(string: url) {
                                Link(destination: destination) {
                                    Label("Open Menu", systemImage: "safari")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Menu Ready")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        if let outputImage = filter.outputImage {
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            let context = CIContext()
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                return UIImage(cgImage: cgImage)
            }
        }
        return nil
    }
    
    func shareQRCode(url: String) {
        guard let qrImage = generateQRCode(from: url) else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [qrImage, url],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
