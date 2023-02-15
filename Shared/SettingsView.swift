//
//  SettingsView.swift
//  MagicCountdown
//
//  Created by Felix Bronnhuber on 19.05.22.
//

import SwiftUI


/// Displays all the different input readers that the user needs to configure the porperties of a session.
///
/// Configure the view using the `SettingsViewModel`.
struct SettingsView: View {
    
    /// Own view model
    @StateObject var vm: SettingsViewModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 0) {
            
            VStack(alignment: .leading) {
                
                titleBar
                    .padding(.top, 5.0)
                
                /// Scroll through the settings
                ScrollView(showsIndicators: false) {
                    
                    playerCountPicker
                    
                    baseTimePicker
                    
                    timeIncrementPicker
                    
                    healthBarPicker
                }
                .cornerRadius(10.0)
                
            }
            .padding(5.0)
        }
        
    }
    
    /// Shows the title label and a button to start the session.
    var titleBar: some View {
        
        HStack {
            Label("Configure the session", systemImage: "gearshape.fill")
                .font(.title)
                .foregroundColor(.accentColor)
            
            Spacer()
            
            Button(
                action: {
                    MainView.MainViewModel.instance.impactOccurred()
                    self.vm.submit()
                },
                label: {
                    Label("Start", systemImage: "play.fill")
                }
            )
            .buttonStyle(.bordered)
            .controlSize(.regular)
        }
        
    }
    
    /// Lets the user configure the amount of players / countdowns.
    var playerCountPicker: some View {
        
        GroupBox(content: {
            Picker("Players", selection: self.$vm.selectedCount) {
                ForEach((2...10), id: \.self) { i in
                    Text("\(i)").tag(i)
                }
            }
            .pickerStyle(.segmented)
            .scaledToFill()
            .onChange(of: self.vm.selectedCount) { _ in
                MainView.MainViewModel.instance.impactOccurred()
            }
        }, label: {
            Label("Players", systemImage: "person.3.fill")
        })
        
    }
    
    /// Lets the user configure the base time of the timers.
    var baseTimePicker: some View {
        
        GroupBox(content: {
            Picker("Time", selection: self.$vm.selectedMinutes) {
                ForEach([5, 10, 15, 20, 30, 45, 60], id: \.self) { i in
                    Text("\(i) min").tag(i)
                }
            }
            .pickerStyle(.segmented)
            .scaledToFill()
            .onChange(of: self.vm.selectedMinutes) { _ in
                MainView.MainViewModel.instance.impactOccurred()
            }
            
            Stepper(value: self.$vm.selectedMinutes, in: (1...360)) {
                Text("\(vm.selectedMinutes) min")
            }
            
        }, label: {
            Label("Base time", systemImage: "hourglass")
        })
        
    }
    
    /// Lets the user configure whether they want an increment and the amount af incremented seconds.
    var timeIncrementPicker: some View {
        
        GroupBox(content: {
            
            /// Sets the `isIncrementOnTap`
            Toggle(isOn: self.$vm.isIncrementOnTap.animation(.easeIn), label: {
                VStack(alignment: .leading) {
                    Text("Enable bonus time")
                    
                    Label(
                        "A small amount of time that is added to the timer everytime it is started.",
                        systemImage: "info.circle"
                    )
                    .foregroundColor(.secondary)
                    .font(.footnote)
                }
            })
            .tint(.accentColor)
            
            /// Selector for the amount of seconds to increment
            /// Only shown if the `isIncrementOnTap` toggle is set.
            if vm.isIncrementOnTap {
                Group {
                    Picker("bonus time", selection: self.$vm.selectedIncrementSeconds) {
                        ForEach([5, 10, 15, 20, 25, 30, 60, 120, 180, 240, 300], id: \.self) { i in
                            Text("\(i) sec").tag(i)
                        }
                    }
                    .pickerStyle(.segmented)
                    .scaledToFill()
                    .onChange(of: self.vm.selectedIncrementSeconds) { _ in
                        MainView.MainViewModel.instance.impactOccurred()
                    }
                    
                    Stepper(value: self.$vm.selectedIncrementSeconds, in: (1...600)) {
                        Text("\(vm.selectedIncrementSeconds) sec")
                    }
                }
            }
        }, label: {
            Label("Increment", systemImage: "hourglass.badge.plus")
        })
        
    }
    
    /// Lets the user configure whether they want a health bar or not and the starting health points
    var healthBarPicker: some View {
        
        GroupBox(content: {
            
            /// Sets the `isIncrementOnTap`
            Toggle(isOn: self.$vm.showsHealth.animation(.easeIn), label: {
                VStack(alignment: .leading) {
                    Text("Show health points")
                }
            })
            .tint(.accentColor)
            
            /// Selector for the amount of seconds to increment
            /// Only shown if the `isIncrementOnTap` toggle is set.
            if vm.showsHealth {
                Group {
                    Stepper(value: self.$vm.healthPoints, in: (1...10000)) {
                        Text("Starting health points: \(vm.healthPoints)")
                    }
                }
            }
        }, label: {
            Label("Health points", systemImage: "heart.circle")
        })
        
    }
    
}

#if(DEBUG)
/// Preview provider for the `SettingsView`
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(vm: SettingsView.SettingsViewModel())
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 13")
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
#endif

/// Adds the `SettingsViewModel` to the struct.
extension SettingsView {
    
    /// View model to the `SettingsView`.
    @MainActor class SettingsViewModel: ObservableObject {
        
        /// Default player count / starting position of the picker
        @Published var selectedCount: Int = 4
        
        /// Default base time / starting position if the picker
        @Published var selectedMinutes: Int = 15
        
        /// Whether the timer is incremented per turn / toggle is off per default
        @Published var isIncrementOnTap: Bool = false
        
        /// Default amount of incremented seconds / starting position of the picker
        @Published var selectedIncrementSeconds: Int = 30
        
        /// Whether the timers should show the health bar or not
        @Published var showsHealth: Bool = false
        
        /// The health points in the beginning
        @Published var healthPoints: Int = 40
        
        
        /// Initializes the `SettingsViewModel` and overrides the default values.
        ///
        /// - Parameters:
        ///   - selectedCount: new default value of selected players
        ///   - selectedTime: new default value for the selected base time
        init(selectedCount: Int, selectedTime: Int) {
            self.selectedCount = selectedCount
            self.selectedMinutes = selectedTime
        }
        
        
        /// Initializes the `SettingsViewModel` without overriding the default values.
        init() {
            // does not override the default values
        }
        
        
        /// Changes the view to the `TimerGridView`.
        func submit() {
            withAnimation(.spring()) {
                MainView.MainViewModel.instance.state = .timers
            }
        }
        
    }
    
}
