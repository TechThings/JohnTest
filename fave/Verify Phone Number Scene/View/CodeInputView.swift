// Taken from https://github.com/acani/CodeInputView
// Modified to fit our view
// Gaddafi Rusli ;P

import UIKit

public final class CodeInputView: UIView, UIKeyInput {
    public var delegate: CodeInputViewDelegate?
    private var nextTag = 1

    // MARK: - UIResponder

    public override func canBecomeFirstResponder() -> Bool {
        return true
    }

    // MARK: - UIView

    public override init(frame: CGRect) {
        super.init(frame: frame)

        // Add four digitLabels
        var frame = CGRect(x: 15, y: 0, width: 35, height: 50)
        for index in 1...4 {
            let digitLabel = UILabel(frame: frame)
            digitLabel.font = UIFont.systemFontOfSize(40)
            digitLabel.tag = index
            digitLabel.text = "–"
            digitLabel.textAlignment = .Center
            digitLabel.textColor = UIColor.whiteColor()
            addSubview(digitLabel)
            frame.origin.x += 35 + 15
        }
    }
    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") } // NSCoding

    // MARK: - UIKeyInput

    public func hasText() -> Bool {
        if nextTag > 1 {
            return true
        }
        return false
    }

    public func insertText(text: String) {
        if nextTag < 5 {
            (viewWithTag(nextTag)! as! UILabel).text = text
            nextTag += 1

            if nextTag == 5 {
                var code = ""
                for index in 1..<nextTag {
                    code += (viewWithTag(index)! as! UILabel).text!
                }
                delegate?.codeInputView(self, didFinishWithCode: code)
                delegate?.codeInputView(self, isCompleted: true)
            }
        }
    }

    public func deleteBackward() {
        if nextTag > 1 {
            nextTag -= 1
            (viewWithTag(nextTag)! as! UILabel).text = "–"
            delegate?.codeInputView(self, isCompleted: false)
        }
    }

    public func clear() {
        while nextTag > 1 {
            deleteBackward()
        }
    }

    // MARK: - UITextInputTraits

    public var keyboardType: UIKeyboardType { get { return .NumberPad } set { } }
}

public protocol CodeInputViewDelegate {
    func codeInputView(codeInputView: CodeInputView, didFinishWithCode code: String)
    func codeInputView(codeInputView: CodeInputView, isCompleted: Bool)
}
