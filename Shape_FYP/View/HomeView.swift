//
//  HomeView.swift
//  Shape_FYP
//
//  Created by Evan Wong on 9/4/2024.
//

import SwiftUI


struct HomeView: View {
    @EnvironmentObject var loginViewModel: LoginViewModel
    @State private var showingAlert = false
    @State private var selectedExercise: String? = nil
    @State private var mod: String? = nil
    @State private var showingOptions = false
    @StateObject var historyViewModel = HistoryViewModel()
    @State private var navigationLinkActive = false
    @State private var showingSheet = false
    @State private var pushUpCount = 0
    @State private var sitUpCount = 0
    
    
    @State private var restTime = 0
    @State private var exerciseList = [String]()
    @State private var exerciseCountList = [Int]()
    
    @State private var exerciseType = "push_up"
    @State private var exerciseCountString = ""
    
    private var exerciseCount: Int {
        return Int(exerciseCountString) ?? 0
    }

    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
            
                
                Button(action: {
                    exerciseList = []
                    exerciseCountList = []
                    showingOptions = true
                }) {
                    Text("Start Training")
                        .frame(width: UIScreen.main.bounds.width - 100, height: 20)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .overlay(
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: UIScreen.main.bounds.width - 100, height: 20)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingOptions = true
                        }
                )
                .confirmationDialog("Select an exercise", isPresented: $showingOptions, titleVisibility: .visible) {
                    Button("Push Up") {
                        exerciseList = []
                        exerciseCountList = []
                        selectedExercise = "push_up"
                        mod = "training"
                        showingOptions = false
                        navigateToDetectionView()
                    }
                    Button("Sit Up") {
                        exerciseList = []
                        exerciseCountList = []
                        selectedExercise = "sit_up"
                        mod = "training"
                        showingOptions = false
                        navigateToDetectionView()
                    }
                }

        
                
                Button(action: {
                    exerciseList = []
                    exerciseCountList = []
                    showingSheet = true
                }) {
                    Text("Start Custom Training")
                        .frame(width: UIScreen.main.bounds.width - 100, height: 20)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .overlay(
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: UIScreen.main.bounds.width / 2, height: 20)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingSheet = true
                        }
                )
                
                
                NavigationLink(destination: HistoryView()) {
                    Text("History")
                        .frame(width: UIScreen.main.bounds.width - 100, height: 20)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                
                Button(action: {
                    showingAlert = true
                }) {
                    Text("Logout")
                        .frame(width: UIScreen.main.bounds.width / 2, height: 20)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .overlay(
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: UIScreen.main.bounds.width / 2, height: 20)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            showingAlert = true
                        }
                )

                
                NavigationLink(destination: DetectionView(selectedExercise: $selectedExercise, mod: $mod, exerciseList: $exerciseList, exerciseCountList: $exerciseCountList, restTime: $restTime), isActive: $navigationLinkActive) {
                    EmptyView()
                }
                .hidden()
                
            }
            .padding()
            .navigationBarTitle("Home", displayMode: .inline)
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Logout"),
                      message: Text("Are you sure you want to log out?"),
                      primaryButton: .destructive(Text("Logout")) {
                    Task {
                        try await loginViewModel.signOut()
                    }
                }, secondaryButton: .cancel(Text("Cancel")))
            }
            .sheet(isPresented: $showingSheet) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Custom Training")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            // Dropdown for exercise type
                            Picker("Exercise", selection: $exerciseType) {
                                Text("Push Up").tag("push_up")
                                Text("Sit Up").tag("sit_up")
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 115)
                            
                            // Input field for exercise count
                            TextField("Count", text: $exerciseCountString)
                                .keyboardType(.numberPad)
                                
                            
                            // Add button
                            Button(action: {
                                if exerciseCount > 0 {
                                    exerciseList.append(exerciseType)
                                    exerciseCountList.append(exerciseCount)
                                    exerciseCountString = "" // Clear the text field after adding
                                }
                            }) {
                                Text("Add")
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 10)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Stepper("Rest Time (seconds): \(restTime)", value: $restTime, in: 0...Int.max)
                            .onChange(of: restTime) { newValue in
                                restTime = max(newValue, 0)
                            }

                    }
                    .padding()
                    
                    // List to display added exercises
                    List {
                        ForEach(Array(zip(exerciseList, exerciseCountList)), id: \.0) { exercise, count in
                            HStack {
                                Text(exercise)
                                Spacer()
                                Text("\(count)")
                            }
                        }
                        .onDelete(perform: deleteExercise)
                    }

                    
                    // Start training button
                    Button(action: {
                        mod = "custom"
                        showingSheet = false
                        navigateToDetectionView()
                    }) {
                        Text("Start Training")
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(exerciseList.isEmpty)
                }
                .frame(maxWidth: 300)

            }




        }.navigationBarBackButtonHidden(true)
    }
    
    
    func navigateToDetectionView() {
        navigationLinkActive = true
    }
    
    func deleteExercise(at offsets: IndexSet) {
        exerciseList.remove(atOffsets: offsets)
    }


    
}




#Preview {
    HomeView()
}
