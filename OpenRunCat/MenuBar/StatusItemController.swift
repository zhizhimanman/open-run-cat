// OpenRunCat/MenuBar/StatusItemController.swift

import AppKit

class StatusItemController {
    private var statusItem: NSStatusItem?

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    }

    func updateIcon(_ image: NSImage) {
        DispatchQueue.main.async {
            let resizedImage = image.resized(to: NSSize(width: Constants.iconSize, height: Constants.iconSize))
            self.statusItem?.button?.image = resizedImage
        }
    }

    func setMenu(_ menu: NSMenu) {
        DispatchQueue.main.async {
            self.statusItem?.menu = menu
        }
    }
}