//
//  BotsiUITextView.swift
//
//
//  Created by Aleksey Goncharov on 2.4.24..
//

#if canImport(UIKit)

import Botsi
import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
struct BotsiUITextView: View {
    @EnvironmentObject var productsViewModel: BotsiProductsViewModel
    @EnvironmentObject var customTagResolverViewModel: BotsiTagResolverViewModel

    private var text: VC.Text

    @Environment(\.colorScheme)
    private var colorScheme: ColorScheme

    init(_ text: VC.Text) {
        self.text = text
    }

    var body: some View {
        let (richText, productInfo) = text.extract(productsInfoProvider: productsViewModel)

        switch productInfo {
        case .notApplicable:
            richText
                .convertToSwiftUIText(
                    tagResolver: customTagResolverViewModel,
                    productInfo: nil,
                    colorScheme: colorScheme
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.01 : 1.0)
        case .notFound:
            richText
                .convertToSwiftUIText(
                    tagResolver: customTagResolverViewModel,
                    productInfo: nil,
                    colorScheme: colorScheme
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.01 : 1.0)
                .redactedAsPlaceholder(true)
        case let .found(productInfoModel):
            richText
                .convertToSwiftUIText(
                    tagResolver: customTagResolverViewModel,
                    productInfo: productInfoModel,
                    colorScheme: colorScheme
                )
                .multilineTextAlignment(text.horizontalAlign)
                .lineLimit(text.maxRows)
                .minimumScaleFactor(text.overflowMode.contains(.scale) ? 0.01 : 1.0)
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension BotsiUI {
    enum RichTextError: Error {
        case tagReplacementNotFound
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension Array where Element == BotsiViewConfiguration.RichText.Item {
    func convertToSwiftUITextThrowingError(
        tagResolver: BotsiTagResolver,
        productInfo: ProductInfoModel?,
        colorScheme: ColorScheme
    ) throws -> Text {
        try reduce(Text("")) { partialResult, item in
            switch item {
            case let .text(value, attr):
                return partialResult + Text(
                    AttributedString.createFrom(
                        value: value,
                        attributes: attr
                    )
                )
            case let .tag(value, attr):
                let tagReplacementResult: String

                if let customTagResult = tagResolver.replacement(for: value) {
                    tagReplacementResult = customTagResult
                } else if let productTag = VC.ProductTag(rawValue: value),
                          let productTagResult = productInfo?.stringByTag(productTag)
                {
                    switch productTagResult {
                    case .notApplicable:
                        tagReplacementResult = ""
                    case let .value(string):
                        tagReplacementResult = string
                    }

                } else {
                    throw BotsiUI.RichTextError.tagReplacementNotFound
                }

                return partialResult + Text(
                    AttributedString.createFrom(
                        value: tagReplacementResult,
                        attributes: attr
                    )
                )
            case let .image(value, attr):
                guard let uiImage = value?.of(colorScheme).textAttachmentImage(
                    font: attr.uiFont,
                    tint: attr.imgTintColor?.asSolidColor?.uiColor
                ) else {
                    return partialResult
                }

                return partialResult + Text(
                    Image(
                        uiImage: uiImage
                    )
                )
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.RichText {
    func convertToSwiftUIText(
        tagResolver: BotsiTagResolver,
        productInfo: ProductInfoModel?,
        colorScheme: ColorScheme
    ) -> Text {
        let result: Text

        do {
            result = try items.convertToSwiftUITextThrowingError(
                tagResolver: tagResolver,
                productInfo: productInfo,
                colorScheme: colorScheme
            )
        } catch {
            if let fallback, let fallbackText = try? fallback.convertToSwiftUITextThrowingError(
                tagResolver: tagResolver,
                productInfo: productInfo,
                colorScheme: colorScheme
            ) {
                result = fallbackText
            } else {
                result = Text("")
            }
        }

        return result
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.ImageData {
    private var uiImage: UIImage? {
        switch self {
        case let .raster(data):
            UIImage(data: data)
        case let .resources(value):
            UIImage(named: value)
        default:
            nil
        }
    }

    func textAttachmentImage(font: UIFont, tint: UIColor?) -> UIImage? {
        guard var image = uiImage else { return nil }

        let size = CGSize(width: image.size.width * font.capHeight / image.size.height,
                          height: font.capHeight)

        image = image.imageWith(newSize: size)

        if let tint {
            image = image
                .withRenderingMode(.alwaysTemplate)
                .withTintColor(tint, renderingMode: .alwaysTemplate)
        }

        return image
    }
}

extension UIImage {
    func imageWith(newSize: CGSize) -> UIImage {
        let image = UIGraphicsImageRenderer(size: newSize).image { _ in
            draw(in: CGRect(origin: .zero, size: newSize))
        }

        return image.withRenderingMode(renderingMode)
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
@MainActor
extension VC.Text {
    enum ProductInfoContainer {
        case notApplicable
        case notFound
        case found(ProductInfoModel)
    }

    func extract(productsInfoProvider: ProductsInfoProvider) -> (VC.RichText, ProductInfoContainer) {
        switch value {
        case let .text(value):
            return (value, .notApplicable)
        case let .productText(value):
            guard let underlying = productsInfoProvider.productInfo(by: value.botsiProductId) else {
                return (value.richText(byPaymentMode: .unknown), .notFound)
            }

            return (value.richText(byPaymentMode: underlying.paymentMode), .found(underlying))
        case let .selectedProductText(value):
            guard let underlying = productsInfoProvider.selectedProductInfo(by: value.productGroupId),
                  let botsiProductId = underlying.botsiProduct?.botsiProductId
            else {
                return (value.richText(), .notFound)
            }

            return (value.richText(botsiProductId: botsiProductId, byPaymentMode: underlying.paymentMode), .found(underlying))
        }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension AttributedString {
    static func createFrom(
        value: String,
        attributes: VC.RichText.TextAttributes?
    ) -> AttributedString {
        var result = AttributedString(value)

        result.foregroundColor = attributes?.uiColor ?? .darkText
        result.font = attributes?.uiFont ?? .botsiDefault

        if let background = attributes?.background?.asSolidColor {
            result.backgroundColor = background.swiftuiColor
        }

        if attributes?.strike ?? false {
            result.strikethroughStyle = .single
        }

        if attributes?.underline ?? false {
            result.underlineStyle = .single
        }

        return result
    }
}

extension UIFont {
    static let botsiDefault = UIFont.systemFont(ofSize: 15.0)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, visionOS 1.0, *)
extension VC.RichText.TextAttributes {
    var uiFont: UIFont { font.uiFont(size: size) }
    var uiColor: UIColor? { txtColor.asSolidColor?.uiColor }
    var backgroundUIColor: UIColor? { background?.asSolidColor?.uiColor }
}

#endif
