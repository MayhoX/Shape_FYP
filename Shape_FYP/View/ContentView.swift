//
//  ContentView.swift
//  FYP_YOLO
//
//  Created by Evan Wong on 7/2/2024.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    
    var body: some View {
        
        if !loginViewModel.login {
            LoginView()
        } else {
            HomeView()
        }
        
        
    }
}

 #Preview {
    ContentView()
}
