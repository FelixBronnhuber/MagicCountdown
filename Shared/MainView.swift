//
//  MainView.swift
//  MagicCountdown
//
//  Created by Felix Bronnhuber on 19.05.22.
//

import SwiftUI
import CoreHaptics


///  The entry view of the app.
///  Responsible for switching between views.
///
///  Configure the view by changing the `MainView.MainViewModel.state`.
struct MainView: View {
    
    /// Own view model
    @StateObject private var vm: MainViewModel = MainViewModel.instance
    
    var body: some View {
        vm.getCurrentView()
    }
    
}

#if(DEBUG)
///  Preview provider for the `MainView`
struct MainView_Previews: PreviewProvider {
    
    static var previews: some View {
        MainView()
            .preferredColorScheme(.dark)
            .previewDevice("iPhone 11")
            .previewInterfaceOrientation(.landscapeRight)
    }
    
}
#endif

///  Adds the `MainViewModel` class to the struct.
extension MainView {
    
    ///  Every case responds to a `View` that the `MainView` can display.
    enum ViewStates {
        case settings
        case timers
    }
    
    ///  View model to the `MainView` view.
    ///
    ///  Singleton: Access the object via `instance`.
    @MainActor class MainViewModel: ObservableObject {
        
        /// Changing the `state` changes the displayed view accordingly.
        ///
        /// Change it using a fitting animation for a smooth transition:
        ///
        /// ```
        /// withAnimation(.spring()) {
        ///   MainView.MainViewModel.instance.state = .timers
        /// }
        /// ```
        @Published var state: ViewStates = .settings
        
        /// Singleton instance
        private(set) static var instance: MainViewModel = MainViewModel.init()
        
        /// Only one feedback generator for the app.
        private let feedbackGenerator = UIImpactFeedbackGenerator.init(style: .light)
        
        /// So the user selected options remain when thee `SettingsView` is displayed again.
        private var settingsViewModel: SettingsView.SettingsViewModel!
        
        /// Use the `instance` property to access the singleton instance of this class.
        private init() {
            self.settingsViewModel = SettingsView.SettingsViewModel()
        }
        
        ///  Returns the current view that should be displayed.
        ///  The returned view is chosen through the value of `state`.
        ///
        ///  - Returns: A `View` associated with the value of `state`.
        @ViewBuilder func getCurrentView() -> some View {
            switch state {
            case .settings:
                SettingsView(vm: self.settingsViewModel)
            case .timers:
                TimerGridView(
                    vm: self.makeTimerGridViewModel()
                )
            }
        }
        
        ///  Factory for the `TimerGridViewModel`.
        ///  Produces a `TimerGridViewModel` object
        ///  and populates it with the values form the `self.settingsViewModel`.
        ///
        ///  - Returns: A `TimerGridViewModel` configured by the user.
        private func makeTimerGridViewModel() -> TimerGridView.TimerGirdViewModel {
            return TimerGridView.TimerGirdViewModel.init(
                numberOfTimers: self.settingsViewModel.selectedCount,
                seconds: self.settingsViewModel.selectedMinutes * 60,
                isIncrementOnTap: self.settingsViewModel.isIncrementOnTap,
                selectedIncrementSeconds: self.settingsViewModel.selectedIncrementSeconds
            )
        }
        
        /// Triggers a haptic impact feedback.
        public func impactOccurred() {
            self.feedbackGenerator.impactOccurred()
        }
        
    }
    
}
