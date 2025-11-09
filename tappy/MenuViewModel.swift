//
//  MenuViewModel.swift
//  tappy
//
//  Created by Maria Jose Cordova igartua on 11/9/25.
//


import SwiftUI
import Vision
import UIKit
import Combine

class MenuViewModel: ObservableObject {
    @Published var currentMenu: Menu?
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var menuURL: String?
    @Published var isUploading = false
    
    func processImage(_ image: UIImage) {
        isProcessing = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.performOCR(on: image) { recognizedText in
                DispatchQueue.main.async {
                    self?.parseMenuText(recognizedText)
                    self?.isProcessing = false
                }
            }
        }
    }
    
    func uploadToFirebase() {
        guard let menu = currentMenu else { return }
        
        isUploading = true
        errorMessage = nil
        
        FirebaseService.shared.uploadMenu(menu) { [weak self] result in
            DispatchQueue.main.async {
                self?.isUploading = false
                switch result {
                case .success(let url):
                    self?.menuURL = url
                    print("Menu uploaded! URL: \(url)")
                case .failure(let error):
                    self?.errorMessage = "Upload failed: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func loadMenuFromURL(_ url: String) {
        // Extract ID from URL
        guard let urlComponents = URLComponents(string: url),
              let queryItems = urlComponents.queryItems,
              let id = queryItems.first(where: { $0.name == "id" })?.value else {
            errorMessage = "Invalid menu URL"
            return
        }
        
        isProcessing = true
        FirebaseService.shared.fetchMenu(id: id) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessing = false
                switch result {
                case .success(let menu):
                    self?.currentMenu = menu
                case .failure(let error):
                    self?.errorMessage = "Failed to load menu: \(error.localizedDescription)"
                }
            }
        }
    }
    
    private func performOCR(on image: UIImage, completion: @escaping (String) -> Void) {
        guard let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid image"
            }
            completion("")
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            if let error = error {
                print("OCR Error: \(error)")
                DispatchQueue.main.async {
                    self.errorMessage = "OCR failed"
                }
                completion("")
                return
            }
            
            let observations = request.results as? [VNRecognizedTextObservation] ?? []
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            completion(recognizedText)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Failed to perform OCR: \(error)")
            DispatchQueue.main.async {
                self.errorMessage = "Failed to process image"
            }
            completion("")
        }
    }
    
    private func parseMenuText(_ text: String) {
        print("Raw OCR Text:\n\(text)")
        
        guard !text.isEmpty else {
            DispatchQueue.main.async {
                self.errorMessage = "No text found in image"
            }
            return
        }
        
        let lines = text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        var sections: [MenuSection] = []
        var currentSectionName = "Menu Items"
        var currentItems: [MenuItem] = []
        
        for line in lines {
            if isSectionHeader(line) {
                if !currentItems.isEmpty {
                    sections.append(MenuSection(name: currentSectionName, items: currentItems))
                    currentItems = []
                }
                currentSectionName = formatSectionName(line)
                continue
            }
            
            if let menuItem = extractMenuItem(from: line) {
                currentItems.append(menuItem)
            }
        }
        
        if !currentItems.isEmpty {
            sections.append(MenuSection(name: currentSectionName, items: currentItems))
        }
        
        if sections.isEmpty {
            DispatchQueue.main.async {
                self.errorMessage = "No menu items detected"
            }
        }
        
        let menu = Menu(name: "Scanned Menu", sections: sections)
        
        DispatchQueue.main.async {
            self.currentMenu = menu
        }
    }
    
    private func isSectionHeader(_ line: String) -> Bool {
        let commonSections = ["appetizer", "starter", "main", "entree", "entrée",
                             "dessert", "drink", "beverage", "wine", "cocktail"]
        let lowercased = line.lowercased()
        let isAllCaps = line == line.uppercased() && line.count > 2 && line.count < 30
        let containsSectionName = commonSections.contains { lowercased.contains($0) }
        let hasNoPrice = !line.contains("$")
        
        return (isAllCaps || containsSectionName) && hasNoPrice
    }
    
    private func formatSectionName(_ name: String) -> String {
        if name == name.uppercased() {
            return name.capitalized
        }
        return name
    }
    
    private func extractMenuItem(from line: String) -> MenuItem? {
        let pricePatterns = [
            "\\$\\s*([0-9]+\\.?[0-9]*)",
            "([0-9]+\\.?[0-9]*)\\s*\\$"
        ]
        
        for pattern in pricePatterns {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { continue }
            let range = NSRange(location: 0, length: line.utf16.count)
            
            if let match = regex.firstMatch(in: line, options: [], range: range) {
                let priceRange = match.range(at: 1)
                guard let swiftRange = Range(priceRange, in: line) else { continue }
                let priceValue = String(line[swiftRange])
                
                guard let fullRange = Range(match.range, in: line) else { continue }
                let itemName = String(line[..<fullRange.lowerBound])
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !itemName.isEmpty else { continue }
                
                return MenuItem(name: itemName, price: "$\(priceValue)")
            }
        }
        
        return nil
    }
}
