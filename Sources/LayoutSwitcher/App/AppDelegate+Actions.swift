import AppKit

extension AppDelegate {
    @objc func toggleAutoSwitch() {
        NSLog("[Menu] toggleAutoSwitch called")
        AppSettings.shared.autoSwitchEnabled.toggle()
    }

    @objc func toggleSound() {
        AppSettings.shared.soundEnabled.toggle()
    }

    @objc func toggleDiary() {
        AppSettings.shared.diaryEnabled.toggle()
    }

    @objc func openDiary() {
        DiaryPanel.shared.show()
    }

    @objc func openPreferences() {
        NSLog("[Prefs] openPreferences called, shared=\(String(describing: AppDelegate.shared))")
        NSApp.activate(ignoringOtherApps: true)
        let result = NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSLog("[Prefs] showSettingsWindow result=\(result)")
        if !result {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }

    @objc func showClipboardHistory() {
        ClipboardHistoryPanel.shared.show()
    }

    @objc func openAutoReplaceList() {
        openPreferences()
    }

    @objc func clipboardSwitchLayout() {
        ClipboardManager.shared.switchLayout()
    }

    @objc func clipboardTransliterate() {
        ClipboardManager.shared.transliterate()
    }

    @objc func clipboardSpellCheck() {
        let result = ClipboardManager.shared.spellCheck()
        let alert = NSAlert()
        alert.messageText = "Spell Check"
        alert.informativeText = result
        alert.runModal()
    }

    @objc func switchToSource(_ sender: NSMenuItem) {
        guard let obj = sender.representedObject else { return }
        // TISInputSource is a CF type; we stored it as AnyObject via representedObject
        let source = unsafeBitCast(obj as AnyObject, to: TISInputSource.self)
        TISSelectInputSource(source)
    }
}

import Carbon
