inherited fRTFMsgList: TfRTFMsgList
  object MsgList: TExRichEdit
    Left = 0
    Top = 0
    Width = 242
    Height = 143
    Align = alClient
    AutoURLDetect = adDefault
    CustomURLs = <
      item
        Name = 'e-mail'
        Color = clWindowText
        Cursor = crDefault
        Underline = True
      end
      item
        Name = 'http'
        Color = clWindowText
        Cursor = crDefault
        Underline = True
      end
      item
        Name = 'file'
        Color = clWindowText
        Cursor = crDefault
        Underline = True
      end
      item
        Name = 'mailto'
        Color = clWindowText
        Cursor = crDefault
        Underline = True
      end
      item
        Name = 'ftp'
        Color = clWindowText
        Cursor = crDefault
        Underline = True
      end
      item
        Name = 'https'
        Color = clWindowText
        Cursor = crDefault
        Underline = True
      end
      item
        Name = 'gopher'
        Color = clWindowText
        Cursor = crDefault
        Underline = True
      end
      item
        Name = 'nntp'
        Color = clWindowText
        Cursor = crDefault
        Underline = True
      end
      item
        Name = 'prospero'
        Color = clWindowText
        Cursor = crDefault
        Underline = True
      end
      item
        Name = 'telnet'
        Color = clWindowText
        Cursor = crDefault
        Underline = True
      end
      item
        Name = 'news'
        Color = clWindowText
        Cursor = crDefault
        Underline = True
      end
      item
        Name = 'wais'
        Color = clWindowText
        Cursor = crDefault
        Underline = True
      end
      item
        Name = 'xmpp'
        Color = clBlack
        Cursor = crDefault
        Underline = True
      end
      item
        Name = 'jabber'
        Color = clBlack
        Cursor = crDefault
        Underline = True
      end>
    HideScrollBars = False
    LangOptions = [loAutoFont]
    Language = 1033
    ParentShowHint = False
    ReadOnly = True
    ScrollBars = ssVertical
    ShowHint = False
    ShowSelectionBar = True
    TabOrder = 0
    URLColor = clBlue
    URLCursor = crHandPoint
    OnKeyPress = MsgListKeyPress
    OnMouseUp = MsgListMouseUp
    OnURLClick = MsgListURLClick
    InputFormat = ifUnicode
    OutputFormat = ofRTF
    SelectedInOut = True
    PlainRTF = True
    UndoLimit = 0
    IncludeOLE = True
    AllowInPlace = False
  end
end
