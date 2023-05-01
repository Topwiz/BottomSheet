//
//  BottomSheetView.swift
//
//  Created by Lucas Zischka.
//  Copyright © 2022 Lucas Zischka. All rights reserved.
//

import SwiftUI

internal struct BottomSheetView<HContent: View, MContent: View>: View {
    
    // For iPhone landscape and iPad support
#if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass: UserInterfaceSizeClass?
    @Environment(\.verticalSizeClass) var verticalSizeClass: UserInterfaceSizeClass?
#endif
    
    @Binding var bottomSheetPosition: BottomSheetPosition
    @State var translation: CGFloat = 0
    
#if !os(macOS)
    // For `appleScrollBehaviour`
    @State var isScrollEnabled: Bool = false
    @State var dragState: DragGesture.DragState = .none
#endif
    
    // View heights
    @State var headerContentHeight: CGFloat = 0
    @State var dynamicMainContentHeight: CGFloat = 0
    
#if !os(macOS)
    @ObservedObject var keyboardHeight: KeyboardHeight = KeyboardHeight()
#endif
    
    @State var orientation = UIDeviceOrientation.unknown
    @GestureState var isDragging: Bool = false
    @State var lastDragValue: DragGesture.Value?
    @State var lastAppleScrollDragValue: DragGesture.Value?
    @State var draggingIsEnabled: Bool = true
    
    // Views
    let headerContent: HContent?
    let mainContent: MContent
    
    let switchablePositions: [BottomSheetPosition]
    
    // Configuration
    let configuration: BottomSheetConfiguration
    
    var body: some View {
        // GeometryReader for size calculations
        GeometryReader { geometry in
            // ZStack for aligning content
            ZStack(
                // On iPad floating and Mac the BottomSheet is aligned to the top left
                // On iPhone and iPad not floating it is aligned to the bottom center,
                // in horizontal mode to the bottom left
                alignment: self.isIPadFloatingOrMac ? .topLeading : .bottomLeading
            ) {
                // Hide everything when the BottomSheet is hidden
                if !self.bottomSheetPosition.isHidden {
                    // Full screen background for aligning and used by `backgroundBlur` and `tapToDismiss`
                    self.fullScreenBackground(with: geometry)
                    
                    // The BottomSheet itself
                    self.bottomSheet(with: geometry)
                }
            }
            .onChange(of: self.isDragging) { newValue in    
                guard !newValue else { return }
                if let value = self.lastDragValue {
                    self.onEnded(with: geometry, value: value)
                } else if let value = self.lastAppleScrollDragValue {
                    self.appleScrollViewOnEnded(with: geometry, value: value)
                }
            }
            // Animate value changes
#if !os(macOS)
            .animation(
                self.configuration.animation,
                value: self.horizontalSizeClass
            )
            .animation(
                self.configuration.animation,
                value: self.verticalSizeClass
            )
#endif
            .animation(
                self.configuration.animation,
                value: self.bottomSheetPosition
            )
            .animation(
                self.configuration.animation,
                value: self.translation
            )
#if !os(macOS)
            .animation(
                self.configuration.animation,
                value: self.isScrollEnabled
            )
            .animation(
                self.configuration.animation,
                value: self.dragState
            )
#endif
            .animation(
                self.configuration.animation,
                value: self.headerContentHeight
            )
            .animation(
                self.configuration.animation,
                value: self.dynamicMainContentHeight
            )
            .animation(
                self.configuration.animation,
                value: self.configuration
            )
        }
        // Make the GeometryReader ignore specific safe area (for transition to work)
        // On iPhone and iPad not floating ignore bottom safe area, because the BottomSheet moves to the bottom edge
        // On iPad floating and Mac ignore top safe area, because the BottomSheet moves to the top edge
        .edgesIgnoringSafeArea(
            self.isIPadFloatingOrMac ? .top : .bottom
        )
        .onRotate {
            self.draggingIsEnabled = false
            self.orientation = $0
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.draggingIsEnabled = true
            }
        }
    }
}
