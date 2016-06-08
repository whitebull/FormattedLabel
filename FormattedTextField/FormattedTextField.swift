//
//  FormattedTextField.swift
//
//
//  Created by Christian Kiefl on 16.11.15.
//  Copyright © 2015 Christian Kiefl. All rights reserved.
//
/*
The MIT License (MIT)

Copyright (c) 2015 Christian Kiefl

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


import UIKit

class FormattedTextField: UITextField {
    
    private var restrictionChars: NSCharacterSet?
    
    private var replacementChar: Character?
    
    private var formatPattern: String?
    
    override var text: String? {
        didSet {
            if !isEvaluating {
                isEvaluating = true
                textDidChange()
            }
        }
    }
    
    var isEvaluating = false
    
    // MARK: API
    
    
    func textFormat(pattern: String, replacement: Character) {
        formatPattern = pattern
        replacementChar = replacement
    }
    
    func restrictToCharacterSet(restrictions: NSCharacterSet) {
        restrictionChars = restrictions
    }
    
    func unformattedString() -> String? {
        guard let text = text, let formatPattern = formatPattern, let replacementChar = replacementChar where text != "" else {
            return nil
        }
        
        if formatPattern.characters.count > 0 {
            
            var resultText = ""
            
            var formatterIndex = formatPattern.startIndex
            var charIndex = text.startIndex
            
            while true {
                let formattingPatternRange = formatterIndex ..< formatterIndex.advancedBy(1)
                
                if formatPattern.substringWithRange(formattingPatternRange) == String(replacementChar) {
                    
                    resultText = resultText.stringByAppendingString(text.substringWithRange(formattingPatternRange))
                    
                }
                
                formatterIndex = formatterIndex.advancedBy(1)
                charIndex = charIndex.advancedBy(1)
                
                if formatterIndex >= formatPattern.endIndex || charIndex >= text.endIndex {
                    break
                }
            }
            return resultText
        }
        return nil
    }
    
    // MARK: initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: implementation
    
    private func setup() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FormattedTextField.textDidChange), name: UITextFieldTextDidChangeNotification, object: self)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func textDidChange() {
       evaluateFormat()
    }
    
    private func evaluateFormat() {
        defer {
            isEvaluating = false
        }
        guard let text = text, let formatPattern = formatPattern, let replacementChar = replacementChar where text != "" else {
            return
        }
        
        if formatPattern.characters.count > 0 {
            
            let unformattedString = removeUnallowedChars(text)
            
            if unformattedString.characters.count == 0 {
                self.text = nil
                return
            }
            
            var resultText = ""
            
            var formatterIndex = formatPattern.startIndex
            var charIndex = unformattedString.startIndex
            
            while true {
                
                let formattingPatternRange = formatterIndex ..< formatterIndex.advancedBy(1)
                
                if formatPattern.substringWithRange(formattingPatternRange) != String(replacementChar) {
                    
                    resultText = resultText.stringByAppendingString(formatPattern.substringWithRange(formattingPatternRange))
                    
                } else {
                    
                    let pureStringRange = charIndex ..< charIndex.advancedBy(1)
                    resultText = resultText.stringByAppendingString(unformattedString.substringWithRange(pureStringRange))
                    charIndex = charIndex.advancedBy(1)
                }
                
                formatterIndex = formatterIndex.advancedBy(1)
                
                if formatterIndex >= formatPattern.endIndex || charIndex >= unformattedString.endIndex {
                    break
                }
            }
            self.text = resultText
        }
    }
    
    private func removeUnallowedChars(orgString: String) -> String {
        if restrictionChars != nil {
            return orgString.componentsSeparatedByCharactersInSet(restrictionChars!.invertedSet).joinWithSeparator("")
        }
        return orgString
    }
    
}