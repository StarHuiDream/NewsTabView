//
//  NewsTabView.swift
//  NewsTab_Swift
//
//  Created by StarHui on 2018/4/23.
//  Copyright © 2018年 StarHui. All rights reserved.
//

import UIKit

protocol NewsTabViewDelegate : class {
    
    func changeCurrentTapOnClick(index:Int)
}

// 字体

// 选中后的颜色

// 正常的颜色

// 标题间距

// 底边的颜色

class NewsTabView: UIView {
    //  MARK: -Lazy
    
    //  MARK: -Set
    var currentIndex : Int! = 0 {
        didSet{
            if currentIndex >= taskBtnArr.count {
                return
            }
            let btn = taskBtnArr[currentIndex]
            taskTapOnClick(btn: btn)
        }
    }
    
    /// 标题
    var taskTitleStrArr:[String]! {
        didSet{
            for i in 0...taskTitleStrArr.count - 1{
                let titleStr = taskTitleStrArr[i]
                let btn = UIButton()
                btn.addTarget(self, action: #selector(taskTapOnClick(btn:)), for: UIControlEvents.touchDown)
                btn.tag = i
                btn.setTitle(titleStr, for: UIControlState.normal)
                btn.setTitle(titleStr, for: UIControlState.selected)
                btn.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
                btn.setTitleColor(UIColor.red, for: UIControlState.selected)
                btn.titleLabel?.font = titleFont
                self.scrollView.addSubview(btn)
                taskBtnArr.append(btn)
            }
            currentSelectBtn = taskBtnArr.first
        }
    }
    
    // MARK: -变量
    
    var titleFont = UIFont.systemFont(ofSize: 18)
    /// 当前选中的按钮
    private var currentSelectBtn:UIButton! = UIButton()
    ///
    private var taskBtnArr:[UIButton]! = Array()
    
    weak var delegate : NewsTabViewDelegate?
    
    // MARK: -常量
    let scrollView = UIScrollView()
    let bottomeLineView = UIView()
    let indicatorView = UIView()
    let bottomeLineViewH:CGFloat = 1
    let indicatorViewH:CGFloat = 3.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let selfH = self.bounds.size.height
        let selfW = self.bounds.size.width
        
        let scrollViewH = selfH - bottomeLineViewH
        scrollView.frame = CGRect.init(x: 0, y: 0, width: selfW, height: scrollViewH)
        
        var btnX:CGFloat = 8
        let btnY:CGFloat = 0
        let btnH = scrollView.bounds.size.height - indicatorViewH
        let margin:CGFloat = 15
        for i in 0...taskBtnArr.count - 1 {
            
            let btn = taskBtnArr[i]
            let titleStr = btn.titleLabel?.text ?? ""
            let btnW = self.wordWidthWith(font: titleFont,str: titleStr)
            btn.frame = CGRect.init(x: btnX, y: btnY, width: btnW, height: btnH)
            btnX += btnW + margin
        }
        indicatorView.frame = CGRect.init(x:currentSelectBtn.frame.minX, y: currentSelectBtn.frame.maxY, width: currentSelectBtn.bounds.size.width, height: indicatorViewH)
        
        var contentSizeW : CGFloat = taskBtnArr.last?.frame.maxX ?? 0
        contentSizeW += 8
        self.scrollView.contentSize = CGSize.init(width: contentSizeW, height: scrollViewH)
        
        let bottomeLineViewY = indicatorView.frame.maxY
        bottomeLineView.frame = CGRect.init(x: 0, y: bottomeLineViewY, width: selfW, height: bottomeLineViewH)
    } // layoutSubviews
    
    
    /// 计算文字的单行高度
    func heightOfSingleLineWord(font:UIFont,str:String!) -> CGFloat {
        
        let str = str as NSString
        let size = CGSize.init(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let attr = [NSAttributedStringKey.font:font]
        let rect = str.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attr, context: nil)
        return rect.height
    }
    
    /// 计算单行文本宽度
    func wordWidthWith(font:UIFont,str:String!) -> CGFloat {
        
        let height = self.heightOfSingleLineWord(font: font,str: str)
        let str = str as NSString
        let size = CGSize.init(width: CGFloat.greatestFiniteMagnitude, height:height)
        let attr = [NSAttributedStringKey.font:font]
        let rect = str.boundingRect(with: size, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attr, context: nil)
        return rect.width
    }
    
    // MARK: -Private
    
    @objc func taskTapOnClick(btn:UIButton){
        
        if currentSelectBtn == btn {
            return
        }
        
        btn.isSelected = true
        currentSelectBtn.isSelected = false
        currentSelectBtn = btn
        
        changeindicatorViewFrame()
        delegate?.changeCurrentTapOnClick(index: currentSelectBtn.tag)
    } // taskTapOnClick
    
    /// 点击事件 滚动到当前所点击的按钮
    func changeindicatorViewFrame(){
        
        UIView.animate(withDuration:0.25, animations: {
            
            let selfW = self.bounds.size.width
            
            self.indicatorView.frame = CGRect.init(x:self.currentSelectBtn.frame.minX, y: self.currentSelectBtn.frame.maxY, width: self.currentSelectBtn.bounds.size.width, height: self.indicatorViewH)
            
            // 如果scrollview的内容宽度小于等于self的宽度，不滚动
            if self.scrollView.contentSize.width <= self.bounds.size.width{
                return
            }
            
            var offsetX:CGFloat = 0
            
            // 是否能显示到当前视图的正中间
            let tempOffsetX = self.currentSelectBtn.center.x - selfW / 2
            let maxOffsetX = self.scrollView.contentSize.width - selfW
            let minOffsetX:CGFloat = 0
            let isCanScrollCenter = (tempOffsetX < maxOffsetX) && (tempOffsetX > minOffsetX)
            
            // 当前按钮是否在第一页
            let isInFirstPage = (selfW - self.currentSelectBtn.frame.maxX) >= 0
            // 当前按钮相对于当前视图的位置
            let frameConvertSelf = self.currentSelectBtn.convert(self.currentSelectBtn.bounds, to: self)
            // 是否相对靠右
            let isInRight = (frameConvertSelf.midX - selfW / 2) > 0
            
            if isCanScrollCenter{ // 可以显示在最中间
                offsetX = self.currentSelectBtn.center.x - selfW / 2
            }else if isInFirstPage && !isInRight { // 属于第一页，且偏左
                offsetX = 0
            }else {  // 当前按钮在最后一页
                offsetX = self.scrollView.contentSize.width - selfW
            }
            
            self.scrollView.setContentOffset(CGPoint.init(x: offsetX, y: 0), animated: false)
            
        }) { (isFinish) in
            
        }
    } // changeindicatorViewFrame
    
    /// 初始化子控件
    func setupSubViews(){
        
        bottomeLineView.backgroundColor = UIColor.black
        indicatorView.backgroundColor = UIColor.red
        self.addSubview(scrollView)
        self.addSubview(bottomeLineView)
        self.scrollView.addSubview(indicatorView)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.bounces = false
    } // setupSubViews
}



