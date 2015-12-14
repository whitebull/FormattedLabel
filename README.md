# FormattedTextView
UITextView subclass that can format its text based on a pattern

# Usage

```swift
// initialize like every other TextView
var someTextView = FormattedTextView(frame: CGRect(x: 0, y: 0, width: 150, height: 48))

// set options
someTextView.textFormat("**** **** **** ****", replacement: "*")
someTextView.restrictToCharacterSet(NSCharacterSet.decimalDigitCharacterSet())

// get unformatted text at any time
var text = demoTextView.unformattedString()
```
