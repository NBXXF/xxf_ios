//

#if canImport(CoreGraphics)

    import Foundation

    #if canImport(SwiftUI)
        import SwiftUI

        @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
        extension PlatformImage {
            func imageUI(label _: Text) -> SwiftUI.Image {
                #if os(macOS)
                    SwiftUI.Image(nsImage: self)
                #else
                    SwiftUI.Image(uiImage: self)
                #endif
            }
        }

        extension CGImage {
            /// Return a SwiftUI Image representation of this CGImage
            /// - Parameters:
            ///   - scale: The scale to apply to the resulting image
            ///   - label: The label
            /// - Returns: A SwiftUI image
            @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
            func imageUI(scale: CGFloat = 1.0, label: Text) -> SwiftUI.Image {
                SwiftUI.Image(self, scale: scale, label: label)
            }
        }

        @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
        public extension CGImage.ImageRepresentation {
            /// Return a SwiftUI Image representation of this CGImage
            /// - Parameter
            ///   - scale: The image scale
            ///   - label: The label
            /// - Returns: An image
            func swiftUI(scale: CGFloat = 1.0, label: Text) -> SwiftUI.Image {
                owner.imageUI(scale: scale, label: label)
            }
        }

    #endif

#endif
