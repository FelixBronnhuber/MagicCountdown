import SwiftUI
import CoreHaptics


///  Aranges a variable amount of `TimerView`s in a 2 column horizontal grid.
///  The second column holds one `TimerView` more if the amount is uneven.
///
///  Configure the view using the `TimerGridViewModel`.
struct TimerGridView: View {
    
    /// Own view model
    @StateObject var vm: TimerGirdViewModel
    
    /// Whether the reset confirmation dialog should currently be displayed or not
    @State private var showResetConfirmDialog: Bool = false
    
    var body: some View {
        
        HStack(spacing: 5.0) {
            VStack(spacing: 5.0) {
                
                /// The first column of `TimerView`s
                HStack(spacing: 5.0) {
                    ForEach((0..<vm.timerViewModels.count/2), id: \.self) { i in
                        TimerView(vm: vm.timerViewModels[i])
                            .rotationEffect(Angle.degrees(180))
                    }
                }
                
                SettingsBar
                
                /// The second column of `TimerView`s.
                /// It holds one `TimerView` more if the amount is uneven.
                HStack(spacing: 5.0) {
                    ForEach(
                        (vm.timerViewModels.count/2..<vm.timerViewModels.count),
                        id: \.self)
                    { i in
                        TimerView(vm: vm.timerViewModels[i])
                    }
                }
                
            }
        }
        .padding(5)
        .onAppear() {
            /// So the screen does not dim and turn of after a while.
            UIApplication.shared.isIdleTimerDisabled = true
        }
        .onDisappear() {
            /// The screen should dim normally when displaying other views.
            UIApplication.shared.isIdleTimerDisabled = false
        }
        .preferredColorScheme(.dark)
        
    }
    
    ///  An arangement of all the settings, informatiton and options that should be accessible on the view
    var SettingsBar: some View {
        GroupBox {
            HStack {
                ResetButton
                
                Spacer()
                
                OptionsButton
            }
        }
    }
    
    
    ///  Resets the view on pressed and changes the view to the `SettingsView`.
    ///  So that the user can configure and start a new session.
    ///  Pressing the button shows a confirmation popup. So that the session isn't accedentally reseted.
    var ResetButton: some View {
        Button(
            role: .destructive,
            action: {
                MainView.MainViewModel.instance.impactOccurred()
                self.showResetConfirmDialog = true
            }, label: {
                Label("Reset", systemImage: "xmark.square.fill")
            }
        )
        .controlSize(.small)
        
        /// Confirmation popup.
        /// Making the user confirm that they want to reset the session.
        .alert(
            Text("This will reset the current session."),
            isPresented: self.$showResetConfirmDialog,
            actions: {
                Button("Confirm", role: .destructive) {
                    self.showResetConfirmDialog = false
                    self.vm.stopAllTimers()
                    
                    withAnimation(.spring()) {
                        MainView.MainViewModel.instance.state = .settings
                    }
                }
                
                Button("Cancel", role: .cancel) {
                    self.showResetConfirmDialog = false
                }
            })
    }
    
    /// Shows options in a context menu that can configure the session without resetting it.
    var OptionsButton: some View {
        Menu(content: {
            Section {
                Button(action: {
                    MainView.MainViewModel.instance.impactOccurred()
                    self.vm.incrementAllTimers(seconds: 5*60)
                }, label: {
                    Label("5 min", systemImage: "plus.circle.fill")
                })
                
                Button(role: .destructive, action: {
                    MainView.MainViewModel.instance.impactOccurred()
                    self.vm.incrementAllTimers(seconds: -5*60)
                }, label: {
                    Label("5 min", systemImage: "minus.circle.fill")
                })
            }
        }, label: {
            Label("Options", systemImage: "gearshape.fill")
        })
        .controlSize(.small)
    }
}

#if(DEBUG)
///  Preview provider for the `TimerGridView`.
struct ContentView_Preview: PreviewProvider {
    static var previews: some View {
        TimerGridView(vm: TimerGridView.TimerGirdViewModel(
            numberOfTimers: 4,
            seconds: 15*60,
            isIncrementOnTap: true,
            selectedIncrementSeconds: 30,
            showsHealth: true,
            healthPoints: 40
        ))
        .preferredColorScheme(.dark)
        .previewDevice("iPhone 13 Pro Max")
        .previewInterfaceOrientation(.landscapeRight)
        
        TimerGridView(vm: TimerGridView.TimerGirdViewModel(
            numberOfTimers: 4,
            seconds: 15*60,
            isIncrementOnTap: true,
            selectedIncrementSeconds: 30,
            showsHealth: true,
            healthPoints: 40
        ))
        .preferredColorScheme(.dark)
        .previewDevice("iPhone 13")
        .previewInterfaceOrientation(.landscapeRight)
        
        TimerGridView(vm: TimerGridView.TimerGirdViewModel(
            numberOfTimers: 4,
            seconds: 15*60,
            isIncrementOnTap: true,
            selectedIncrementSeconds: 30,
            showsHealth: true,
            healthPoints: 40
        ))
        .preferredColorScheme(.dark)
        .previewDevice("iPhone 13 Mini")
        .previewInterfaceOrientation(.landscapeRight)
        
        TimerGridView(vm: TimerGridView.TimerGirdViewModel(
            numberOfTimers: 8,
            seconds: 15*60,
            isIncrementOnTap: true,
            selectedIncrementSeconds: 30,
            showsHealth: true,
            healthPoints: 40
        ))
        .preferredColorScheme(.dark)
        .previewDevice("iPhone SE")
        .previewInterfaceOrientation(.landscapeRight)
    }
}
#endif

///  Adds the `TimerGridViewModel` class to the struct.
extension TimerGridView {
    
    /// View model to the `TimerGridView`.
    @MainActor class TimerGirdViewModel: ObservableObject {
        
        /// The amount of timers that the view should display.
        @Published var numberOfTimers: Int
        
        /// The view models for all the timers that are displayed.
        @Published var timerViewModels: [TimerView.TimerViewModel] = []
        
        /// Whether the increment time should be applied or not.
        var isIncrementOnTap: Bool = false
        
        /// The amount of seconds that are incremented if `isIncrementOnTap` is set to true.
        var selectedIncrementSeconds: Int = 10
        
        /// Whether the timers should show the health bar or not
        var showsHealth: Bool
        
        /// The health points in the beginning
        var healthPoints: Int
        
        /// Initializes the view models for the `TimerView`s.
        fileprivate func initTimerViewModels(_ numberOfTimers: Int, _ seconds: Int) {
            for id in (0..<numberOfTimers) {
                timerViewModels.append(
                    TimerView.TimerViewModel(
                        id: id,
                        seconds: seconds,
                        isIncrementOnTap: self.isIncrementOnTap,
                        selectedIncrementSeconds: self.selectedIncrementSeconds,
                        timerGridViewModel: self,
                        showsHealth: self.showsHealth,
                        healthPoints: self.healthPoints
                    )
                )
            }
        }
        
        
        /// Initializes a `TimerGridView` object and internally initializes all the
        /// `TimerViewModel`s for the `numberOfTimers` that should be displayed.
        ///
        /// - Parameters:
        ///   - numberOfTimers: An integer amount of how many `TimerView`s should be displayed.
        ///   - seconds: How many seconds every timer has on the clock.
        ///   - isIncrementOnTap: Whether the timer is incremented everytime that it is pressed.
        ///   - selectedIncrementSeconds: The amount of seconds that are incremented
        ///                               if `isIncrementOnTap` is set.
        init(
            numberOfTimers: Int,
            seconds: Int,
            isIncrementOnTap: Bool,
            selectedIncrementSeconds: Int,
            showsHealth: Bool,
            healthPoints: Int
        ) {
            self.numberOfTimers = numberOfTimers
            self.isIncrementOnTap = isIncrementOnTap
            self.selectedIncrementSeconds = selectedIncrementSeconds
            self.showsHealth = showsHealth
            self.healthPoints = healthPoints
            
            initTimerViewModels(numberOfTimers, seconds)
        }
        
        /// Stops all the timers that are displayed.
        func stopAllTimers() {
            for model in timerViewModels {
                model.stopTimer()
            }
        }
        
        
        /// Adds the provided `seconds` to the remainding seconds of every timer if within bounds.
        ///
        /// - Parameter seconds: How many seconds should be added (positive number)
        ///                      or decremented (negative number)
        func incrementAllTimers(seconds: Int) {
            stopAllTimers()
            
            for model in timerViewModels {
                model.safelyIncrementTimer(seconds: seconds)
            }
        }
    }
}
