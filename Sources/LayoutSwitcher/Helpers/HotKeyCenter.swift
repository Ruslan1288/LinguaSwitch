import AppKit

struct HotKeyBinding {
    let keyCode: Int64
    let modifiers: NSEvent.ModifierFlags
    let action: () -> Void
}

class HotKeyCenter {
    static let shared = HotKeyCenter()
    private(set) var bindings: [HotKeyBinding] = []

    private init() {}

    func register(keyCode: Int64, modifiers: NSEvent.ModifierFlags, action: @escaping () -> Void) {
        bindings.append(HotKeyBinding(keyCode: keyCode, modifiers: modifiers, action: action))
    }

    func unregisterAll() { bindings.removeAll() }

    /// Called from EventMonitor's CGEvent tap. Returns true if the event was consumed.
    func handle(keyCode: Int64, modifiers: CGEventFlags) -> Bool {
        let nsModifiers = nsFlags(from: modifiers)
        for binding in bindings where keyCode == binding.keyCode && nsModifiers == binding.modifiers {
            DispatchQueue.main.async { binding.action() }
            return true // consume the event
        }
        return false
    }

    private func nsFlags(from cgFlags: CGEventFlags) -> NSEvent.ModifierFlags {
        var result: NSEvent.ModifierFlags = []
        if cgFlags.contains(.maskCommand) { result.insert(.command) }
        if cgFlags.contains(.maskShift)   { result.insert(.shift) }
        if cgFlags.contains(.maskAlternate) { result.insert(.option) }
        if cgFlags.contains(.maskControl) { result.insert(.control) }
        return result
    }
}
