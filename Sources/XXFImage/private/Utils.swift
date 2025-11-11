
#if canImport(CoreGraphics)

    import CoreGraphics
    import Foundation

    /// Draw into a single-page PDF document
    /// - Parameters:
    ///   - size: The drawing size
    ///   - pdfResolution: The resolution of the pdf output
    ///   - drawBlock: The drawing block
    /// - Returns: The pdf data for the drawing, or nil if an error occurred.
    func UsingSinglePagePDFContext(
        size: CGSize,
        pdfResolution: CGFloat = 72.0,
        _ drawBlock: (CGContext, CGRect) throws -> Void
    ) throws -> Data {
        let pageWidth = size.width * (72.0 / pdfResolution)
        let pageHeight = size.height * (72.0 / pdfResolution)
        var mediaBox = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        guard
            let data = CFDataCreateMutable(nil, 0),
            let pdfConsumer = CGDataConsumer(data: data),
            let pdfContext = CGContext(consumer: pdfConsumer, mediaBox: &mediaBox, nil)
        else {
            throw ImageReadWriteError.cannotCreatePDFContext
        }

        // Start a new page of the required size
        pdfContext.beginPage(mediaBox: &mediaBox)

        // Perform the context drawing
        do {
            try drawBlock(pdfContext, mediaBox)
        } catch {
            throw error
        }

        // And end the page
        pdfContext.endPDFPage()

        // Close the pdf to make sure all data is written to the consumer
        pdfContext.closePDF()

        return data as Data
    }

#endif
