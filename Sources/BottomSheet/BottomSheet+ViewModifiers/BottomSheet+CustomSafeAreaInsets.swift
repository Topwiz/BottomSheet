
import SwiftUI

public extension BottomSheet {
    public func safeAreaInsets(_ insets: EdgeInsets) -> BottomSheet {
        self.configuration.safeAreaInsets = insets
        return self
    }
}
