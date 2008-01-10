inherited frmPrefDisplay: TfrmPrefDisplay
  Left = 320
  Top = 256
  Align = alLeft
  Caption = 'frmPrefFont'
  ClientHeight = 994
  ClientWidth = 594
  OldCreateOrder = True
  ShowHint = True
  ExplicitWidth = 606
  ExplicitHeight = 1006
  PixelsPerInch = 120
  TextHeight = 16
  object pnlContainer: TExBrandPanel [0]
    Left = 0
    Top = 27
    Width = 551
    Height = 967
    Align = alLeft
    AutoSize = True
    Color = 13681583
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentColor = False
    ParentFont = False
    TabOrder = 1
    TabStop = True
    AutoHide = False
    ExplicitHeight = 755
    object gbContactList: TExGroupBox
      AlignWithMargins = True
      Left = 0
      Top = 6
      Width = 551
      Height = 166
      Margins.Left = 0
      Margins.Top = 6
      Margins.Right = 0
      Margins.Bottom = 6
      Align = alTop
      AutoSize = True
      Color = 13681583
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      TabOrder = 0
      TabStop = True
      AutoHide = True
      Caption = 'Contact List:'
      object pnlContactLeft: TExBrandPanel
        Left = 0
        Top = 17
        Width = 166
        Height = 149
        AutoSize = True
        Color = 13681583
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentColor = False
        ParentFont = False
        TabOrder = 1
        TabStop = True
        AutoHide = True
        object pnlBackColor: TExBrandPanel
          AlignWithMargins = True
          Left = 3
          Top = 6
          Width = 160
          Height = 47
          Margins.Top = 6
          Align = alTop
          AutoSize = True
          Color = 13681583
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 0
          TabStop = True
          AutoHide = True
          object lblRosterBG: TTntLabel
            AlignWithMargins = True
            Left = 0
            Top = 3
            Width = 103
            Height = 16
            Margins.Left = 0
            Caption = '&Background color:'
            FocusControl = cbRosterBG
          end
          object cbRosterBG: TColorBox
            AlignWithMargins = True
            Left = 0
            Top = 25
            Width = 154
            Height = 22
            Margins.Left = 0
            Margins.Top = 0
            Margins.Bottom = 0
            DefaultColorColor = clBlue
            Selected = clBlue
            Style = [cbStandardColors, cbExtendedColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
            DropDownCount = 12
            ItemHeight = 16
            TabOrder = 0
            OnChange = cbRosterBGChange
          end
        end
        object pnlRosterFG: TExBrandPanel
          AlignWithMargins = True
          Left = 3
          Top = 65
          Width = 160
          Height = 50
          Margins.Top = 9
          Align = alTop
          AutoSize = True
          TabOrder = 1
          TabStop = True
          AutoHide = True
          object lblRosterFG: TTntLabel
            AlignWithMargins = True
            Left = 0
            Top = 3
            Width = 62
            Height = 16
            Margins.Left = 0
            Caption = '&Font color:'
            FocusControl = cbRosterFont
          end
          object cbRosterFont: TColorBox
            AlignWithMargins = True
            Left = 0
            Top = 25
            Width = 154
            Height = 22
            Margins.Left = 0
            DefaultColorColor = clBlue
            Selected = clBlue
            Style = [cbStandardColors, cbExtendedColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
            DropDownCount = 12
            ItemHeight = 16
            TabOrder = 0
            OnChange = cbRosterFontChange
          end
        end
        object pnlContactFontBtn: TExBrandPanel
          AlignWithMargins = True
          Left = 3
          Top = 118
          Width = 160
          Height = 28
          Margins.Top = 0
          Align = alTop
          AutoSize = True
          TabOrder = 2
          TabStop = True
          AutoHide = True
          object btnRosterFont: TTntButton
            AlignWithMargins = True
            Left = 0
            Top = 3
            Width = 68
            Height = 22
            Margins.Left = 0
            Caption = 'F&ont...'
            TabOrder = 0
            OnClick = btnRosterFontClick
          end
        end
      end
      object pnlContactRight: TExBrandPanel
        Left = 172
        Top = 17
        Width = 335
        Height = 128
        AutoSize = True
        TabOrder = 2
        TabStop = True
        AutoHide = True
        object pnlRosterPreview: TExBrandPanel
          Left = 0
          Top = 0
          Width = 335
          Height = 128
          Align = alTop
          TabOrder = 0
          TabStop = True
          AutoHide = True
          object lblRosterPreview: TTntLabel
            Left = 23
            Top = 9
            Width = 50
            Height = 16
            Caption = 'Preview:'
          end
          object colorRoster: TTntTreeView
            Left = 23
            Top = 31
            Width = 201
            Height = 106
            BevelWidth = 10
            Indent = 19
            ReadOnly = True
            ShowButtons = False
            ShowLines = False
            TabOrder = 0
          end
        end
      end
    end
    object grpActivityWindow: TExGroupBox
      AlignWithMargins = True
      Left = 0
      Top = 190
      Width = 548
      Height = 219
      Margins.Left = 0
      Margins.Top = 12
      Align = alTop
      AutoSize = True
      TabOrder = 1
      TabStop = True
      AutoHide = True
      Caption = 'Activity window:'
      object pnlActivityLeft: TExBrandPanel
        Left = 0
        Top = 17
        Width = 169
        Height = 202
        Align = alLeft
        AutoSize = True
        TabOrder = 1
        TabStop = True
        AutoHide = True
        object pnlChatBG: TExBrandPanel
          AlignWithMargins = True
          Left = 3
          Top = 6
          Width = 163
          Height = 47
          Margins.Top = 6
          Align = alTop
          AutoSize = True
          Color = 13681583
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -13
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentColor = False
          ParentFont = False
          TabOrder = 0
          TabStop = True
          AutoHide = True
          object lblChatBG: TTntLabel
            AlignWithMargins = True
            Left = 0
            Top = 3
            Width = 103
            Height = 16
            Margins.Left = 0
            Caption = 'B&ackground color:'
            FocusControl = cbChatBG
          end
          object cbChatBG: TColorBox
            AlignWithMargins = True
            Left = 0
            Top = 25
            Width = 154
            Height = 22
            Margins.Left = 0
            Margins.Top = 0
            Margins.Bottom = 0
            DefaultColorColor = clBlue
            Selected = clBlue
            Style = [cbStandardColors, cbExtendedColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
            DropDownCount = 12
            ItemHeight = 16
            TabOrder = 0
            OnChange = cbChatBGChange
          end
        end
        object pnlChatElement: TExBrandPanel
          AlignWithMargins = True
          Left = 3
          Top = 59
          Width = 163
          Height = 52
          Align = alTop
          AutoSize = True
          TabOrder = 1
          TabStop = True
          AutoHide = True
          object lblChatWindowElement: TTntLabel
            AlignWithMargins = True
            Left = 0
            Top = 3
            Width = 154
            Height = 16
            Margins.Left = 0
            Caption = 'Choose &element to format:'
            FocusControl = cboChatElement
          end
          object cboChatElement: TTntComboBox
            AlignWithMargins = True
            Left = 0
            Top = 25
            Width = 154
            Height = 24
            Margins.Left = 0
            Style = csDropDownList
            ItemHeight = 16
            TabOrder = 0
            OnChange = cboChatElementChange
          end
        end
        object pnlChatFont: TExBrandPanel
          AlignWithMargins = True
          Left = 3
          Top = 117
          Width = 163
          Height = 81
          Align = alTop
          AutoSize = True
          TabOrder = 2
          TabStop = True
          AutoHide = True
          object pnlChatFG: TExBrandPanel
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 157
            Height = 47
            Align = alTop
            AutoSize = True
            TabOrder = 0
            TabStop = True
            AutoHide = True
            object lblChatFG: TTntLabel
              Left = 25
              Top = 0
              Width = 62
              Height = 16
              Caption = 'Font &color:'
              FocusControl = cbChatFont
            end
            object cbChatFont: TColorBox
              AlignWithMargins = True
              Left = 25
              Top = 22
              Width = 129
              Height = 22
              DefaultColorColor = clBlue
              Selected = clBlue
              Style = [cbStandardColors, cbExtendedColors, cbIncludeDefault, cbCustomColor, cbPrettyNames]
              DropDownCount = 12
              ItemHeight = 16
              TabOrder = 0
              OnChange = cbChatFontChange
            end
          end
          object pnlChatFontBtn: TExBrandPanel
            AlignWithMargins = True
            Left = 3
            Top = 56
            Width = 157
            Height = 22
            Align = alTop
            AutoSize = True
            TabOrder = 1
            TabStop = True
            AutoHide = True
            object btnChatFont: TTntButton
              Left = 25
              Top = 0
              Width = 68
              Height = 22
              Caption = 'Fo&nt...'
              TabOrder = 0
              OnClick = btnFontClick
            end
          end
        end
      end
      object pnlChatPreview: TExBrandPanel
        Left = 175
        Top = 17
        Width = 373
        Height = 202
        Align = alRight
        TabOrder = 2
        TabStop = True
        AutoHide = True
        object lblChatPreview: TTntLabel
          Left = 20
          Top = 9
          Width = 50
          Height = 16
          Caption = '&Preview:'
          FocusControl = colorChat
        end
        object Label5: TTntLabel
          Left = 20
          Top = 141
          Width = 266
          Height = 13
          Caption = 'Elements can also be directly selected from the preview'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = []
          ParentFont = False
        end
        object colorChat: TExRichEdit
          Left = 20
          Top = 31
          Width = 303
          Height = 106
          AutoURLDetect = adNone
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
            end>
          LangOptions = [loAutoFont]
          Language = 1033
          ReadOnly = True
          ScrollBars = ssBoth
          ShowSelectionBar = False
          TabOrder = 0
          URLColor = clBlue
          URLCursor = crHandPoint
          WordWrap = False
          OnMouseDown = colorChatMouseDown
          InputFormat = ifRTF
          OutputFormat = ofRTF
          SelectedInOut = False
          PlainRTF = False
          UndoLimit = 0
          AllowInPlace = False
        end
      end
    end
    object gbOtherPrefs: TExGroupBox
      AlignWithMargins = True
      Left = 0
      Top = 424
      Width = 548
      Height = 167
      Margins.Left = 0
      Margins.Top = 12
      Align = alTop
      AutoSize = True
      TabOrder = 2
      TabStop = True
      AutoHide = True
      Caption = 'Other display preferences:'
      object chkRTEnabled: TTntCheckBox
        AlignWithMargins = True
        Left = 0
        Top = 20
        Width = 545
        Height = 18
        Hint = 'Send and display messages with different fonts, colors etc.'
        Margins.Left = 0
        Align = alTop
        Caption = 'Enable &rich text formatting'
        TabOrder = 0
        OnClick = chkRTEnabledClick
      end
      object chkEmoticons: TTntCheckBox
        AlignWithMargins = True
        Left = 0
        Top = 92
        Width = 545
        Height = 18
        Margins.Left = 0
        Align = alTop
        Caption = 'Auto &detect emoticons'
        TabOrder = 3
      end
      object pnlTimeStamp: TExBrandPanel
        AlignWithMargins = True
        Left = 0
        Top = 116
        Width = 545
        Height = 48
        Margins.Left = 0
        Align = alTop
        AutoSize = True
        TabOrder = 4
        TabStop = True
        AutoHide = True
        object lblTimestampFmt: TTntLabel
          Left = 23
          Top = 27
          Width = 46
          Height = 16
          Caption = 'Forma&t:'
          FocusControl = txtTimestampFmt
        end
        object chkTimestamp: TTntCheckBox
          Left = 0
          Top = 0
          Width = 209
          Height = 18
          Caption = 'Show timestamp &with messages'
          TabOrder = 0
        end
        object txtTimestampFmt: TTntComboBox
          Left = 75
          Top = 24
          Width = 198
          Height = 24
          ItemHeight = 16
          TabOrder = 1
          Text = 'h:mm am/pm'
          Items.Strings = (
            'm/d/y h:mm am/pm'
            'mm/dd/yy hh:mm:ss'
            'h:mm am/pm'
            'hh:mm:ss')
        end
      end
      object chkShowPriority: TTntCheckBox
        AlignWithMargins = True
        Left = 0
        Top = 68
        Width = 545
        Height = 18
        Margins.Left = 0
        Align = alTop
        Caption = 'Show &message priority in chat windows'
        TabOrder = 2
      end
      object chkChatAvatars: TTntCheckBox
        AlignWithMargins = True
        Left = 0
        Top = 44
        Width = 545
        Height = 18
        Margins.Left = 0
        Align = alTop
        Caption = '&Show avatars in chat windows'
        TabOrder = 1
      end
    end
    object gbAdvancedPrefs: TExGroupBox
      AlignWithMargins = True
      Left = 0
      Top = 606
      Width = 548
      Height = 118
      Margins.Left = 0
      Margins.Top = 12
      Align = alTop
      AutoSize = True
      TabOrder = 3
      TabStop = True
      AutoHide = True
      Caption = 'Advanced display preferences:'
      object pnlAdvancedLeft: TExBrandPanel
        AlignWithMargins = True
        Left = 3
        Top = 20
        Width = 320
        Height = 95
        Align = alLeft
        AutoSize = True
        TabOrder = 1
        TabStop = True
        AutoHide = True
        object gbRTIncludes: TExGroupBox
          AlignWithMargins = True
          Left = 0
          Top = 3
          Width = 317
          Height = 89
          Margins.Left = 0
          Align = alTop
          AutoSize = True
          TabOrder = 0
          TabStop = True
          AutoHide = True
          Caption = 'Messages may include:'
          object chkAllowFontFamily: TTntCheckBox
            AlignWithMargins = True
            Left = 0
            Top = 20
            Width = 267
            Height = 18
            Margins.Left = 0
            Align = alTop
            Caption = 'Multip&le fonts'
            TabOrder = 0
            OnClick = chkAllowFontFamilyClick
            ExplicitWidth = 314
          end
          object chkAllowFontSize: TTntCheckBox
            AlignWithMargins = True
            Left = 0
            Top = 44
            Width = 267
            Height = 18
            Margins.Left = 0
            Align = alTop
            Caption = 'Different si&zed text'
            TabOrder = 1
            OnClick = chkAllowFontFamilyClick
            ExplicitWidth = 314
          end
          object chkAllowFontColor: TTntCheckBox
            AlignWithMargins = True
            Left = 0
            Top = 68
            Width = 267
            Height = 18
            Margins.Left = 0
            Align = alTop
            Caption = 'Different colored te&xt'
            TabOrder = 2
            OnClick = chkAllowFontFamilyClick
            ExplicitWidth = 314
          end
        end
      end
    end
  end
  inherited pnlHeader: TTntPanel
    Width = 594
    ExplicitWidth = 594
    inherited lblHeader: TTntLabel
      Width = 151
      Caption = 'Display Preferences'
      ExplicitWidth = 151
    end
  end
  object FontDialog1: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Options = []
    Left = 453
    Top = 51
  end
end
