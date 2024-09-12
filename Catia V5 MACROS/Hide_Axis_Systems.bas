Attribute VB_Name = "Hide_Axis_Systems"
Option Explicit

Sub CATMain()
    
    '----------------------------------------------------------------
    '   Macro: Hide_Axis_Systems.bas
    '   Version: 1.0
    '   Code: CATIA VBA
    '   Release:   V5R32
    '   Purpose: This script is designed to hide all axis systems in
    '   an open product on all levels
    '   Author: Kai-Uwe Rathjen
    '   Date: 18.06.24
    '----------------------------------------------------------------
    '
    '   Change:
    '
    '
    '----------------------------------------------------------------
    CATIA.StatusBar = "Hide_Axis_Systems.bas, Version 1.0"    'Update Status Bar text
    
    '----------------------------------------------------------------
    'Declare varibles
    '----------------------------------------------------------------
    Dim ProductDocument1 As Document                            'Document Object
    Dim product1 As Product                                     'Product Object
    
    Dim selection1 As Selection                                 'Selection
    Dim visPropertySet1 As VisPropertySet                       'Set of visible properties

    '----------------------------------------------------------------
    'Open Current Document
    '----------------------------------------------------------------
    Set ProductDocument1 = CATIA.ActiveDocument                 'Anchor to current open document

    '----------------------------------------------------------------
    ' Make sure CATProduct is open
    '----------------------------------------------------------------
    If Not (Right(ProductDocument1.Name, (Len(ProductDocument1.Name) - InStrRev(ProductDocument1.Name, "."))) = "CATProduct") Then
        Dim Error As Integer
        Error = MsgBox("This Script only works with .CATProduct Files" & vbNewLine & "Please Open a .CATProduct to use this script", vbCritical)
        Exit Sub
    End If

    '----------------------------------------------------------------
    ' Select all axis systems and hide
    '----------------------------------------------------------------
    Set product1 = ProductDocument1.Product                       'Anchor to product collection


    Set selection1 = ProductDocument1.Selection                    'Create a new selection for all products
    selection1.Search "CatPrtSearch.AxisSystem,All"                 'Search for all axis systems and select them

    Set visPropertySet1 = selection1.VisProperties                  'Get the visible properties of selection
    visPropertySet1.SetShow catVisPropertyNoShowAttr                'Change visibility to hidden

    selection1.Clear                                                'Clear Selection
End Sub

