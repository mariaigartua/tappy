//
//  ContentView.swift
//  tappy
//
//  Created by Maria Jose Cordova igartua on 11/9/25.
//

import SwiftUI
import CoreNFC

struct ContentView: View {
    // NOTE: You'll need to add an image named "header_image", "background_image", and "app_logo"
    // to your asset catalog for this code to compile and display correctly.
    
    @StateObject private var viewModel = MenuViewModel()
    @State private var showCamera = false
    @State private var showNFCScanner = false
    
    // Define a consistent blue color palette
    let primaryBlue = Color(red: 0.1, green: 0.4, blue: 0.8) // Primary color for actions
    let secondaryBlue = Color(red: 0.25, green: 0.55, blue: 0.95) // Accent color
    
    var body: some View {
        NavigationView {
            ZStack { // Use ZStack for the background image
                
                // 1. Background Image (Minimalistic)
                Image("background_image")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                    .opacity(0.1) // Very subtle background
                
                VStack(spacing: 30) {
                    
                    // 2. Header Image (MODIFIED FOR FULL WIDTH AND HEIGHT)
                    Image("header_image")
                        .resizable()
                        .aspectRatio(contentMode: .fill) // Changed to .fill to occupy full width
                        .frame(maxHeight: 250) // Increased height from 200 to 250
                        .edgesIgnoringSafeArea(.horizontal) // Ensure it spans the full horizontal edge
//                        .clipped() // Ensure the image is clipped to its frame
                        .accessibilityLabel("Illustration of a group of people sharing what they are seeing to others. ")
                    
                    // ⭐️ TEXT CONTAINER (THE "INVISIBLE BOX")
                    VStack(spacing: 15) {
                        
                        // ⭐️ App Logo
                        Image("app_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100) // Adjust size of the logo
                            .shadow(radius: 5)
                            .accessibilityLabel("Tappy") // Alt text as requested
                        
                        // Tagline (ORIGINAL TEXT 1)
                        Text("Your independent dining")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        Text("experience starts here.")
                            .font(.title2)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)

//                        Text("Tappy transforms physical restaurant menus into fully accessible digital experiences, giving you total autonomy to explore and engage with the menu.")
//                            .font(.body) // Use .body for better readability of long text
//                            .foregroundColor(.primary)
//                            .multilineTextAlignment(.center)
//                            .fixedSize(horizontal: false, vertical: true)
//                            .lineLimit(nil)
                    }
                    .frame(maxWidth: 300) // ⬅️ THIS IS THE INVISIBLE BOX/FIXED FRAME
                    .padding(.horizontal) // Retain some padding outside the fixed frame
                    
                    Spacer()
                    
                    // Buttons Container
                    VStack(spacing: 18) {
                        
                        // 3. Scan Menu Button
                        Button(action: {
                            showCamera = true
                        }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Scan Menu")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(primaryBlue)
                            .foregroundColor(.white)
                            .font(.title2)
                            .fontWeight(.bold)
                            .cornerRadius(12)
                        }
                        
                        // Read NFC Tag Button
                        Button(action: {
                            showNFCScanner = true
                        }) {
                            HStack {
                                Image(systemName: "wave.3.right")
                                Text("Read NFC Tag")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(secondaryBlue)
                            .foregroundColor(.white)
                            .font(.title2)
                            .fontWeight(.bold)
                            .cornerRadius(12)
                        }
                        
                        // View Menu Button
                        if let menu = viewModel.currentMenu, !menu.sections.isEmpty {
                            NavigationLink(destination: MenuResultsView(viewModel: viewModel)) {
                                HStack {
                                    Image(systemName: "list.bullet.clipboard.fill")
                                    Text("View Menu")
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(primaryBlue.opacity(0.8)) // Slightly different shade for distinction
                                .foregroundColor(.white)
                                .font(.title2)
                                .fontWeight(.bold)
                                .cornerRadius(12)
                            }
                        }
                    }
                    // APPLY MAX WIDTH TO BUTTON CONTAINER AND CENTER IT
                    .frame(maxWidth: 350)
                    .padding(.horizontal, 40)
                    
                    Spacer()
                    
                    // Processing Indicator
                    if viewModel.isProcessing {
                        VStack(spacing: 10) {
                            ProgressView()
                                .tint(primaryBlue)
                            Text("Processing menu...")
                                .foregroundColor(.gray)
                        }
                        .padding()
                    }
                    
                    // Error Message
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCamera) {
                CameraView(viewModel: viewModel)
            }
            .sheet(isPresented: $showNFCScanner) {
                NFCScannerView(viewModel: viewModel)
            }
        }
    }
}
