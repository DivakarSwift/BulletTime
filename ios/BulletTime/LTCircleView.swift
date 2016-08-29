//
//  LTCircleView.swift
//  LTCircleView
//
//  Created by leo on 16/8/12.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit


protocol LTCircleViewDataSource: class {
    func numberOfItemsInCircleView(circleView: LTCircleView) -> Int
    func viewAtIndex(index: Int, inCircleView circleView: LTCircleView) -> UIView
}

@IBDesignable
class LTCircleView: UIView {
    
    var reusableViews: [UILabel] = []
    var itemSize = 30
    var spacingAngle: Double = 30
    var views: [UIView] = []
    
    var imageView: UIImageView!
    let gestures = [R.image.iconGesture1()!, R.image.iconGesture2()!, R.image.iconGesture3()!]
    
    weak var dataSource: LTCircleViewDataSource!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.load()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.load()
    }
    
    func load() {
        imageView = UIImageView(frame: bounds)
        imageView.contentMode = .Center
        imageView.image = gestures.randomItem()
        addSubview(imageView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        reArrange()
    }
    
    func reloadData() {
        let totalItems = dataSource.numberOfItemsInCircleView(self)
        for view in views {
            view.removeFromSuperview()
        }
        guard totalItems > 0 else {
            return
        }
        views = []
        for index in 0...(totalItems - 1) {
            let view = dataSource.viewAtIndex(index, inCircleView: self)
            views.append(view)
            addSubview(view)
        }
        reArrange()
    }
    
    func reArrange() {
        for (index, view) in views.enumerate() {
            view.center = centerForItem(atIndex: index)
        }
    }
    
    func insertItemAtIndex(index: Int) {
        guard index <= views.count else {
            return
        }
        let viewToAdd = dataSource.viewAtIndex(index, inCircleView: self)
        viewToAdd.center = centerForItem(atIndex: index)
        viewToAdd.alpha = 0
        addSubview(viewToAdd)
        
        views.insert(viewToAdd, atIndex: index)
        
        UIView.animateWithDuration(0.5,delay: 0, options: [.BeginFromCurrentState], animations: {
            self.reArrange()
            viewToAdd.alpha = 1
        }, completion: { finished in
            self.reloadData()
        })
    }
    
    func removeItemAtIndex(index: Int) {
        guard index < views.count else {
            return
        }
        let viewToRemove = views[index]
        views.removeAtIndex(index)
        UIView.animateWithDuration(0.5, delay: 0, options: [.BeginFromCurrentState], animations: {
            self.reArrange()
            viewToRemove.alpha = 0
        }, completion: { finished in
            viewToRemove.removeFromSuperview()
            self.reloadData()
        })
    }
    
    override func drawRect(rect: CGRect) {
        let path = UIBezierPath(ovalInRect: rect.insetBy(dx: 1, dy: 1))
        let pattern: [CGFloat] = [6.0, 6.0]
        path.setLineDash(pattern, count: 2, phase: 0.0)
        path.lineCapStyle = CGLineCap.Round
        UIColor.grayColor().setStroke()
        path.stroke()
    }
    
    func centerForItem(atIndex index: Int) -> CGPoint {
        
        let count = views.count
        let radius = frame.width / 2
        let indexAtCenter = count / 2
        let initialAngle = count % 2 == 0 ? spacingAngle / 2 : 0
        
        let angle = (Double(index - indexAtCenter) * spacingAngle + Double(initialAngle)) * M_PI / 180
        let tx = CGFloat(sin(angle)) * radius
        let ty = CGFloat(cos(angle)) * radius
        
        return CGPoint(x: bounds.width / 2 + tx, y: bounds.height / 2 + ty)
    }
}
