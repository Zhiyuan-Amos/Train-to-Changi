//
//  LineNumberViewController.swift
//  TrainToChangi
//
//  Created by Ang Wei Hao Desmond on 2/4/17.
//  Copyright © 2017 nus.cs3217.a0139655u. All rights reserved.
//

import UIKit

class LineNumberViewController: UIViewController {

    var model: Model!
    let semaphore = DispatchSemaphore(value: 0)

    fileprivate var programCounter: UIImageView!

    @IBOutlet weak var lineNumberCollection: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgramCounter()
        connectDataSourceAndDelegate()
        lineNumberCollection.isScrollEnabled = false
        registerObservers()
    }

    override func viewDidLayoutSubviews() {
        setBackgroundGradient()
    }

    private func setBackgroundGradient() {
        let gradient = CAGradientLayer()
        gradient.startPoint = Constants.Background.leftToRightGradientPoints["startPoint"]!
        gradient.endPoint = Constants.Background.leftToRightGradientPoints["endPoint"]!

        gradient.frame = view.bounds
        gradient.colors = [Constants.Background.editorGradientStartColor,
                           Constants.Background.editorGradientEndColor]
        view.layer.insertSublayer(gradient, at: 0)
    }

    private func connectDataSourceAndDelegate() {
        lineNumberCollection.dataSource = self
        lineNumberCollection.delegate = self
    }

    fileprivate func setupProgramCounter() {
        programCounter = UIImageView(image: Constants.UI.ProgramCounter.programCounterImage)
        programCounter.frame.origin.x = 0
        programCounter.frame.origin.y = 0
        programCounter.frame.size.height = Constants.UI.commandCollectionCellHeight
        programCounter.frame.size.width = Constants.UI.ProgramCounter.programCounterWidth
        programCounter.isHidden = true
        programCounter.frame = view.convert(programCounter.frame, to: lineNumberCollection)
        lineNumberCollection.addSubview(programCounter)
    }

    fileprivate func resetProgramCounter() {
        programCounter.frame.origin.x = 0
        programCounter.frame.origin.y = Constants.UI.ProgramCounter.programCounterOffsetY
    }
}

// MARK: - LineNumberUpdateDelegate
extension LineNumberViewController: LineNumberUpdateDelegate {
    func updateLineNumbers() {
        lineNumberCollection.reloadData()
        programCounter.isHidden = true
    }

    func scrollToOffset(offset: CGPoint) {
        var contentOffset = lineNumberCollection.contentOffset
        contentOffset.y = offset.y
        lineNumberCollection.setContentOffset(contentOffset, animated: false)
    }
}

// MARK: - Event Handling
extension LineNumberViewController {
    fileprivate func registerObservers() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleProgramCounterUpdate(notification:)),
            name: Constants.NotificationNames.moveProgramCounter,
            object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRunStateUpdate(notification:)),
            name: Constants.NotificationNames.runStateUpdated, object: nil)

        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAnimationEnd(notification:)),
            name: Constants.NotificationNames.animationEnded, object: nil)
    }

    // Updates the position of the program counter image depending on which
    // command is currently being executed.
    @objc fileprivate func handleProgramCounterUpdate(notification: Notification) {
        let serialQueue = DispatchQueue(label: Constants.Concurrency.serialQueue)

        serialQueue.async {
            if self.model.runState == .running(isAnimating: true)
                || self.model.runState == .stepping(isAnimating: true) {
                self.semaphore.wait()
            }

            DispatchQueue.main.sync {
                self.updateProgramCounterCoordinates(notification: notification)
            }
        }
    }

    private func updateProgramCounterCoordinates(notification: Notification) {
        if let index = notification.userInfo?["index"] as? Int {
            UIView.animate(withDuration: Constants.Animation.programCounterMovementDuration, animations: {
                guard let cell = self.lineNumberCollection.cellForItem(at: IndexPath(item: index, section: 0)) else {
                    return
                }
                self.programCounter.frame.origin.y = cell.frame.midY
                    - Constants.UI.ProgramCounter.programCounterChangeOffset
            })
        }
    }

    @objc fileprivate func handleAnimationEnd(notification: Notification) {
        semaphore.signal()
    }

    // Updates the display of program counter depending on `runState`.
    @objc fileprivate func handleRunStateUpdate(notification: Notification) {
        if programCounter.isHidden {
            resetProgramCounter()
            programCounter.isHidden = true
        }

        switch model.runState {
        case .start, .lost:
            programCounter.isHidden = true
        default:
            programCounter.isHidden = false
        }
    }
}
