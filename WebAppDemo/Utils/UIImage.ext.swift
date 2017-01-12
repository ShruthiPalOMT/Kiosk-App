//
//  ImageColorUtils.swift
//
//
//  Created by Yilei He on 14/04/2016.
//  Copyright © 2016 lionhylra.com. All rights reserved.
//

import UIKit


// MARK: - UIImage -
extension UIImage {
    
    class func createDivider(_ width: CGFloat, height: CGFloat, color:UIColor, lineWidth: CGFloat = 1) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), false, 0)
        
        let frame = CGRect(x: 0, y: height-lineWidth, width: width, height: lineWidth)
        color.setFill()
        UIRectFill(frame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    /*
    class func createLongDivider(width: CGFloat, height: CGFloat, color:UIColor) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), false, 0)
        
        let frame = CGRectMake(0, 0, width, height)
        color.setFill()
        UIRectFill(frame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    class func createBorderImage(theFrame:CGRect, theColor:UIColor = UIColor.blackColor()) -> UIImage? {
        
        UIGraphicsBeginImageContext(theFrame.size)
        
        theColor.setFill()
        UIRectFill(theFrame)
        let theInnerFrame = theFrame.insetBy(dx: 1, dy: 1)
        UIColor.whiteColor().setFill()
        UIRectFill(theInnerFrame)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
 */
    
    class func imageWithColor(_ color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    
    /**
     This method generate a line graph based on the data input. The line graph
     
     - parameter data:         A set of double value
     - parameter szie:         The size of the image
     - parameter color:        The color that used to draw. Black, by default.
     - parameter padding:      The padding is used to make inset of the line graph.
     - parameter drawZeroLine: A flag indicate whether to draw the dash line at zero xAxis. By default, true.
     - parameter drawFrame:    A flag indicate whether to draw a frame. By default, false.
     
     - returns: An image that contains the line graph. If the rect's size is 0, this method returns nil
     */
    static func pulseGraph(data:[Double], size:CGSize, lineWidth:CGFloat = 0.5, color:UIColor = UIColor.black, padding:CGFloat = 5, drawZeroLine:Bool = true, drawFrame:Bool = false) -> UIImage? {
        
        let canvas = CGRect(origin: CGPoint.zero, size: size).insetBy(dx: padding, dy: padding)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        defer {
            UIGraphicsEndImageContext()
        }
        
        
        
        
        /* start drawing */
        let maxValue = data.max() ?? 0
        let minValue = data.min() ?? 0
        let yStep:CGFloat = canvas.height / CGFloat(maxValue - minValue)
        let xStep:CGFloat = canvas.width / CGFloat(data.count - 1)
        
        /* configuration */
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        
        context.setStrokeColor(color.cgColor)
        context.setShouldAntialias(true)
        context.setLineWidth(lineWidth)
        
        if data.count == 0 {
            /* Draw a straight line */
            context.saveGState()
            context.setStrokeColor(color.cgColor)
            let yPos = canvas.height * 0.85
            context.move(to: CGPoint(x: canvas.minX, y: canvas.minY + yPos))
            context.addLine(to: CGPoint(x: canvas.maxX, y: canvas.minY + yPos))
            context.strokePath()
            
            /* Draw text */
            let p = NSMutableParagraphStyle()
            p.alignment = .center
            let fontSize = UIFont.smallSystemFontSize * 0.6
            let attr = [NSFontAttributeName: UIFont.systemFont(ofSize: fontSize),
                        NSForegroundColorAttributeName: color,
                        NSParagraphStyleAttributeName: p]
            
            var textRect = canvas
            textRect.origin.y = yPos - fontSize
            NSString(string:"No data available.".uppercased()).draw(in: textRect, withAttributes: attr)
            context.restoreGState()
        }else{
            /* Draw lines */
            context.saveGState()
            // transform coordinate: Flip Y axis.
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            
            let points = data.enumerated().map { (index, value) -> CGPoint in
                let transformedValue = value - minValue
                return CGPoint(x: canvas.minX + CGFloat(index) * xStep, y: canvas.minY + CGFloat(transformedValue) * yStep)
            }
            context.addLines(between: points)
            context.strokePath()
            context.restoreGState()
            
        }
        
        /* Draw frame */
        if drawFrame {
            UIRectFrame(canvas)
        }
        
        
        /* Draw zero line */
        
        if drawZeroLine && minValue < 0 && maxValue > 0 {
            context.saveGState()
            context.setLineDash(phase: 0, lengths: [3])
            
            context.setStrokeColor(color.withAlphaComponent(0.5).cgColor)
            // transform coordinate: Flip Y axis.
            context.translateBy(x: 0, y: size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            
            let zeroValue = -minValue
            context.move(to:CGPoint(x: canvas.minX, y: canvas.minY + CGFloat(zeroValue) * yStep))
            context.addLine(to:CGPoint(x: canvas.maxX, y: canvas.minY + CGFloat(zeroValue) * yStep))
            context.strokePath()
            context.restoreGState()
        }
        
        /* end drawing */
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image
    }
    
    
}



extension UIImage {
    /**
     Crop the image using a given CGRect
     
     - parameter rect: the rect is used in the image bounds to get the sub image view
     
     - returns: An sub image view
     */
    func crop(_ rect: CGRect) -> UIImage? {
        let imageRef = self.cgImage
        let resultRef = imageRef?.cropping(to: rect)
        return resultRef.flatMap{UIImage(cgImage: $0)}
    }
    
    
    
    
    /// This function removes the orientation info from UIImage and rotate it to normal orientation
    ///
    /// - Returns: A image that can be used without orientation information
    func normalized() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        defer {UIGraphicsEndImageContext()}
        
        draw(at: CGPoint.zero)
        return UIGraphicsGetImageFromCurrentImageContext() ?? self//in case image.size is 0
    }
}


