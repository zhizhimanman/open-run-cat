// OpenRunCat/Utilities/NSImageExtensions.swift

import AppKit

extension NSImage {
    func tinted(with color: NSColor) -> NSImage? {
        dispatchPrecondition(condition: .onQueue(.main))
        guard let image = self.copy() as? NSImage else { return nil }
        image.lockFocus()
        color.set()
        let rect = NSRect(origin: .zero, size: image.size)
        rect.fill(using: .sourceAtop)
        image.unlockFocus()
        return image
    }

    func resized(to size: NSSize) -> NSImage {
        dispatchPrecondition(condition: .onQueue(.main))
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        self.draw(in: NSRect(origin: .zero, size: size))
        newImage.unlockFocus()
        return newImage
    }

    static func templateImage(named: String) -> NSImage? {
        let image = NSImage(named: named)
        image?.isTemplate = true
        return image
    }
}