//
//  MagicCountdownTests.swift
//  MagicCountdownTests
//
//  Created by Felix Bronnhuber on 25.05.22.
//

import XCTest
@testable import MagicCountdown

@MainActor
class MagicCountdownTests: XCTestCase {
    
    // No increment:
    var timerGridViewModelNoIncrement: TimerGridView.TimerGirdViewModel = TimerGridView.TimerGirdViewModel.init(
        numberOfTimers: 10,
        seconds: 100,
        isIncrementOnTap: false,
        selectedIncrementSeconds: 100
    )
    var timerViewModelsNoIncrement: [TimerView.TimerViewModel] = []
    
    // With Increment:
    var timerGridViewModelIncrement: TimerGridView.TimerGirdViewModel = TimerGridView.TimerGirdViewModel.init(
        numberOfTimers: 10,
        seconds: 100,
        isIncrementOnTap: true,
        selectedIncrementSeconds: 77
    )
    var timerViewModelsIncrement: [TimerView.TimerViewModel] = []
    
    @MainActor override func setUpWithError() throws {
        
        for id in 0..<10 {
            // No increment
            self.timerViewModelsNoIncrement.append(
                TimerView.TimerViewModel.init(
                    id: id,
                    seconds: 0,
                    isIncrementOnTap: false,
                    selectedIncrementSeconds: 77,
                    timerGridViewModel: self.timerGridViewModelNoIncrement
                )
            )
            
            // With increment
            self.timerViewModelsIncrement.append(
                TimerView.TimerViewModel.init(
                    id: id,
                    seconds: 0,
                    isIncrementOnTap: true,
                    selectedIncrementSeconds: 77,
                    timerGridViewModel: self.timerGridViewModelIncrement
                )
            )
            
        }
        
    }
    
    @MainActor override func tearDownWithError() throws {
        self.timerViewModelsNoIncrement = []
        self.timerViewModelsIncrement = []
    }
    
    func startingATimerStopsOtherTimers() throws {
        
        self.timerViewModelsNoIncrement[7].startTimer()
        
        self.timerViewModelsIncrement[7].startTimer()
        
        self.timerViewModelsNoIncrement[0].startTimer()
        
        self.timerViewModelsIncrement[0].startTimer()
        
        XCTAssert(self.timerViewModelsNoIncrement[0].isActive)
        
        XCTAssert(self.timerViewModelsIncrement[0].isActive)
        
        // all other timers should be inactive
        for i in 1..<10 {
            XCTAssert(!self.timerViewModelsNoIncrement[i].isActive)
            XCTAssert(!self.timerViewModelsNoIncrement[i].isActive)
        }
    }
    
}
