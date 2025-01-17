//
//  ConsoleNetworkRequestContextMenuViewPro.swift
//  Pulse Pro
//
//  Created by Alexander Grebenyuk on 10/1/21.
//  Copyright © 2021 kean. All rights reserved.
//

import Foundation
import CoreData
import Combine
import AppKit
import Pulse

final class ConsoleNetworkRequestContextMenuViewModelPro {
    private let message: LoggerMessageEntity
    private let task: NetworkTaskEntity
    private let pins: PinsService
    
    init(message: LoggerMessageEntity, task: NetworkTaskEntity, pins: PinsService) {
        self.message = message
        self.task = task
        self.pins = pins
    }

    // MARK: Pins

    var isPinned: Bool {
        pins.isPinned(task)
    }

    func togglePin() {
        pins.togglePin(for: task)
    }

    // MARK: Context Menu

    var containsResponseData: Bool {
        task.responseBodySize > 0
    }

    // WARNING: This call is relatively expensive.
    var responseString: String? {
        task.responseBody?.data.flatMap { String(data: $0, encoding: .utf8) }
    }

    var url: String? {
        task.url
    }

    var host: String? {
        task.host?.value
    }

    var cURLDescription: String {
        task.cURLDescription()
    }
}


final class ConsoleNetworkRequestContextMenuViewPro: NSView {
    let model: ConsoleNetworkRequestContextMenuViewModelPro
    
    init(model: ConsoleNetworkRequestContextMenuViewModelPro) {
        self.model = model
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        let menu = NSMenu()

        let copyURL = NSMenuItem(title: "Copy URL", action: #selector(buttonCopyURLTapped), keyEquivalent: "")
        copyURL.target = self
        copyURL.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: nil)
        menu.addItem(copyURL)

        let copyHost = NSMenuItem(title: "Copy Host", action: #selector(buttonCopyHostTapped), keyEquivalent: "")
        copyHost.target = self
        copyHost.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: nil)
        menu.addItem(copyHost)

        if model.containsResponseData {
            let copyResponse = NSMenuItem(title: "Copy Response", action: #selector(buttonCopyResponseBodyTapped), keyEquivalent: "")
            copyResponse.target = self
            copyResponse.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: nil)
            menu.addItem(copyResponse)
        }

        let copyCURL = NSMenuItem(title: "Copy cURL", action: #selector(buttonCopycURLDescriptionTapped), keyEquivalent: "")
        copyCURL.target = self
        copyCURL.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: nil)
        menu.addItem(copyCURL)

        menu.addItem(NSMenuItem.separator())

        let isPinned = model.isPinned
        let pinItem = NSMenuItem(title: isPinned ? "Remove Pin" : "Pin", action: #selector(togglePinTapped), keyEquivalent: "p")
        pinItem.target = self
        pinItem.image = NSImage(systemSymbolName: isPinned ? "pin.slash" : "pin", accessibilityDescription: nil)
        menu.addItem(pinItem)

        return menu
    }

    @objc private func buttonCopyURLTapped() {
        NSPasteboard.general.string = model.url
    }

    @objc private func buttonCopyHostTapped() {
        NSPasteboard.general.string = model.host
    }

    @objc private func buttonCopyResponseBodyTapped() {
        NSPasteboard.general.string = model.responseString
    }

    @objc private func buttonCopycURLDescriptionTapped() {
        NSPasteboard.general.string = model.cURLDescription
    }

    @objc private func togglePinTapped() {
        model.togglePin()
    }
}
