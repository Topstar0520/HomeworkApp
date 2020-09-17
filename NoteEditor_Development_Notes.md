    NoteEditor development notes
    
    1. How rich texts are stored and formatted
        All inputted texts and link urls are stored in unicode characters, while attached images/docs are stored locally and refered by url.
        To refer these raw texts, use UITextView.textStorage.text
        
        SyntaxStylizer will format raw texts into NSAttributedString which are stored in UITextView.textStorage
        
        We use similar syntaxes of Bear app to format texts. 
        E.g: double asterisk will bold the texts.
            *sample* will bold the word 'sample'
            or double back slashes will make the texts italic.
        
        To hide texts of a link, an customized empty font is used to format the url text.
        To draw the split line, we override LayoutManager.
        To insert header texts, we use an attachment image.
        
    2. An overview to the approach to implement text editing
        NoteEditor is developed on top of UITextView. For performance reason, instead of overriding NSTextStorage of UITextView to support rich text editing. In shouldChangeTextIn of UITextView delegates, the default behavior is cancelled and textStorage of the UITextView is edited manually inside NoteEditor class.
        Based on inputted/removed characters, each correponding EditActions are generated to process textStorage.
        E.g: 
            '\n' will generate new line action or '' means delete characters
        When a special character occurs, SyntaxStylizer will be used to format text.
        
        All EditActions will be processed by an undoable function inside NoteEditor.

    3. Other notes
        To support different font/color texts for library displayment, note editing or exporting. We use support different theme types. 
        To support text alignment or images/document insertation, tabs(\t) or attachments are inserted to NSAttributedString which also complicate the development at some points. The length of texts beneath will be longer so these tabs or attachments need to be inserted or deleted at different times to adapt specific use cases.
        E.g: 
            When displaying, we insert tabs. But for exporting, we remove these tabs.

    Please, refer to codes for detail implementation.
    If anything need to be clearified, please drop me an email at phamthangnt@gmail.com .
