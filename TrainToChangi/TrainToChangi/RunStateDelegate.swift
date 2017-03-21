//
//  RunStateDelegate.swift
//  TrainToChangi
//
//  Provides the functionality to maintain the running state of the game
//

protocol RunStateDelegate {

    func getRunState() -> RunState
    func setRunState(to newRunState: RunState)
    
}
