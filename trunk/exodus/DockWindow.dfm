object frmDockWindow: TfrmDockWindow
  Left = 0
  Top = 0
  Caption = 'frmDockWindow'
  ClientHeight = 412
  ClientWidth = 638
  Color = 13681583
  DockSite = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDockDrop = FormDockDrop
  OnHide = FormHide
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object splAW: TTntSplitter
    Left = 185
    Top = 0
    Height = 412
    ResizeStyle = rsUpdate
    ExplicitHeight = 398
  end
  object AWTabControl: TTntPageControl
    Left = 188
    Top = 0
    Width = 450
    Height = 412
    Align = alClient
    DockSite = True
    OwnerDraw = True
    Style = tsButtons
    TabOrder = 0
    OnDockDrop = AWTabControlDockDrop
    OnUnDock = AWTabControlUnDock
  end
  object pnlActivityList: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 412
    Align = alLeft
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 1
    OnDockDrop = FormDockDrop
  end
  object timFlasher: TTimer
    Enabled = False
    Interval = 500
    OnTimer = timFlasherTimer
    Left = 224
    Top = 40
  end
end
