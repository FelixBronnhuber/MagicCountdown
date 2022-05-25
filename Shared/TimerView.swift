//
//  TimerView.swift
//  MagicCountdown
//
//  Created by Felix Bronnhuber on 17.05.22.
//

import SwiftUI


///  Displays a singular timer view.
///
///  Configure the view using the `TimerViewModel`.
struct TimerView: View {
    
    /// The own view model.
    @StateObject var vm: TimerViewModel
    
    var body: some View {
        
        GeometryReader { gp in
            VStack(spacing: 5.0) {
                ZStack(alignment: .center) {
                    
                    /// Background shape
                    RoundedRectangle(cornerRadius: 10.0)
                        .foregroundColor(
                            vm.getBackgroundColor()
                        )
                    
                    /// Displays the time as text
                    Text(vm.getTimestamp())
                        .lineLimit(1)
                        .font(.monospacedDigit(
                            .system(size: vm.getFontSize(for: gp, scale: 0.4))
                        )())
                        .foregroundColor(
                            vm.getTextColor()
                        )
                        .padding(1.0)
                    
                }
                //.contextMenu {
                //    contextMenu
                //}
                
                colorAccent
            }
            .onTapGesture {
                vm.toggleTimer()
            }
        }
        
    }
    
    /// A pill shaped form with a color accent that is automatically set for the view.
    var colorAccent: some View {
        Capsule()
            .foregroundColor(vm.getAccentColor())
            .frame(height: 5)
    }
    
    /// Currently unused.
    /// Context menu for individual options of the timer.
    var contextMenu: some View {
        Group {
            Button(role: .none, action: {
                // Code
            }) {
                Label("None", systemImage: "checkmark.circle")
            }
            Button(role: .cancel, action: {
                // Code
            }) {
                Label("Cancel", systemImage: "clear")
            }
            Button(role: .destructive, action: {
                // Code
            }) {
                Label("Destructive", systemImage: "trash")
            }
        }
    }
    
}

#if(DEBUG)
/// Preview provider for the `TimerView`.
struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(vm: TimerView.TimerViewModel(
            id: 1,
            seconds: 15*60,
            isIncrementOnTap: true,
            selectedIncrementSeconds: 30,
            timerGridViewModel: TimerGridView.TimerGirdViewModel.init(
                numberOfTimers: 8,
                seconds: 15*60,
                isIncrementOnTap: true,
                selectedIncrementSeconds: 30
            )
        ))
        .frame(width: 260, height: 200)
        .preferredColorScheme(.dark)
        .previewDevice("iPhone 11")
        .previewInterfaceOrientation(.landscapeRight)
    }
}
#endif

/// Adds the `TimerViewModel` class to the struct.
extension TimerView {
    
    /// View model to the `TimerView`.
    @MainActor class TimerViewModel: ObservableObject {
        
        /// The seconds on the clock.
        @Published var seconds: Int
        
        /// Whether the timer is running or not.
        @Published var isActive: Bool = false
        
        /// The timer responsible for counting down the seconds.
        @Published var timer: Timer?
        
        /// Unique identifier. Mainly changes the accentColor.
        @Published var id: Int
        
        /// Whether the timer is incremented per turn or not.
        var isIncrementOnTap: Bool
        
        /// The amount of incremented seconds if `isIncrementedOnTap` is set.
        var selectedIncrementSeconds: Int
        
        /// The order in which the accentcolors are assigned.
        private var _colors: [Color] = [
            .blue, .green, .red, .yellow, .teal, .orange, .pink, .brown, .purple, .indigo
        ]
        
        /// Own view model.
        var timerGridViewModel: TimerGridView.TimerGirdViewModel
        
        
        /// Initializes the `TimerViewModel` and configures it.
        ///
        /// - Parameters:
        ///   - id: should be unique (
        ///   - seconds: the seconds on the clock
        ///   - isIncrementOnTap: whether the timer is incremented per turn
        ///   - selectedIncrementSeconds: the amount of seconds incremented by
        ///   - timerGridViewModel: the view model
        init(
            id: Int,
            seconds: Int,
            isIncrementOnTap: Bool,
            selectedIncrementSeconds: Int,
            timerGridViewModel: TimerGridView.TimerGirdViewModel
        ) {
            self.id = id
            self.seconds = seconds
            self.isIncrementOnTap = isIncrementOnTap
            self.selectedIncrementSeconds = selectedIncrementSeconds
            self.timerGridViewModel = timerGridViewModel
        }
        
        
        /// Returns the assigned accentcolor (chosen via the `id`)
        ///
        /// - Returns: A unique accent color if the `id` is in range of [0, 10]
        ///            or gray (`Color.secondary`) otherwise.
        func getAccentColor() -> Color {
            if self.id < _colors.count {
                return self._colors[id]
            }
            
            return Color.secondary
        }
        
        
        /// Returns the foregroundcolor the text should have.
        ///
        /// - Returns: Either `Color.black` when the timer `isActive` otherwise `Color.white`.
        ///            When out of time and not active `Color.red`.
        func getTextColor() -> Color {
            return self.isActive ? Color.black : ((self.seconds <= 0) ? Color.red : Color.white)
        }
        
        
        /// Returns the color the background shape should have.
        ///
        /// - Returns: The oposite color of `getTextColor()` for good contrast.
        func getBackgroundColor() -> Color {
            return self.isActive ? ((self.seconds <= 0) ? Color.red : Color.white) : Color.black
        }
        
        
        /// Calculates the font size so that the text is maximized.
        /// Fine tune using the `scale` parameter.
        ///
        /// - Parameters:
        ///   - gp: Provide a `GeometryProxy` for access to measurements.
        ///   - scale: Scales the accessible `width` and `height` by the factor. Should be within (0, 1].
        ///
        /// - Returns: The font size that is recommended for the text.
        func getFontSize(for gp: GeometryProxy, scale: Double) -> Double {
            return gp.size.height > gp.size.width ? (gp.size.width * scale) : (gp.size.height * scale)
        }
        
        
        /// Formats the remaining `seconds` as a time string: "mm:ss"
        func getTimestamp() -> String {
            return String(format: "%d:%02d", self.seconds / 60, self.seconds % 60)
        }
        
        
        /// Initalizes and returns a new `Timer` that decrements its initial value every second.
        ///
        /// - Returns: A new running `Timer`.
        fileprivate func produceTimer() -> Timer {
            
            return Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                if self.seconds > 0 {
                    self.seconds -= 1
                } else {
                    if self.timer != nil {
                        self.timer?.invalidate()
                    }
                }
            }
            
        }
        
        
        /// Safely starts the timer. And tries to stop all other timers beforehand.
        /// This ensures that only one timer can be active at a time.
        func startTimer() {
            
            // can't be started twice
            if self.isActive {
                return
            }
            
            self.timerGridViewModel.stopAllTimers()
            
            // per turn increment if active
            if self.isIncrementOnTap {
                safelyIncrementTimer(seconds: self.selectedIncrementSeconds)
            }
            
            // generate a new running timer
            self.timer = produceTimer()
            
            // changes the apperance
            withAnimation(.spring()) {
                self.isActive = true
            }
            
        }
        
        
        /// Stops the timer.
        func stopTimer() {
            if self.timer != nil {
                self.timer?.invalidate()
                self.timer = nil
            }
            
            // changes the apperance
            withAnimation(.spring()) {
                self.isActive = false
            }
            
        }
        
        
        /// Either starts or stops the timer dependant of the current state of `isActive`.
        func toggleTimer() {
            
            if self.isActive {
                stopTimer()
            } else {
                startTimer()
            }
            
        }
        
        
        /// Adds the number `seconds` onto the clock while checking the boundries.
        /// Bounds: [0, 86.400]
        ///
        /// - Parameter seconds: Choose a positive integer to add seconds to the clock
        ///                      or choose a negative interger to subtract seconds from the clock.
        func safelyIncrementTimer(seconds: Int) {
            let sum = self.seconds + seconds
            
            if sum >= 0 && sum <= 24*60*60 {
                self.seconds = sum
            }
        }
    }
    
}
