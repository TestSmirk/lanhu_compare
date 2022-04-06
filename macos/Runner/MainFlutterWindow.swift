import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController.init()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
      self.backgroundColor = NSColor.clear
      self.isOpaque = false
      self.setFrame(windowFrame, display: true)

//      self.titleVisibility = NSWindow.TitleVisibility.hidden
//      self.titlebarAppearsTransparent = true
//      self.styleMask = NSWindow.StyleMask.fullSizeContentView
    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }


}
