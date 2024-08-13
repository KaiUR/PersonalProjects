Sub CATMain()

    '----------------------------------------------------------------
    'Description:
    '   This script is designed to hide all axis systems in
    '   an open product on all levels
    '
    '
    '
    '
    '
    '----------------------------------------------------------------

    '----------------------------------------------------------------
    'Open Current Document
    '----------------------------------------------------------------
    Set ProductDocument1 = CATIA.ActiveDocument

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
    Set product1 = ProductDocument1.Product


    Set selection1 = ProductDocument1.Selection
    selection1.Search "CatPrtSearch.AxisSystem,All"

    Set visPropertySet1 = selection1.VisProperties
    visPropertySet1.SetShow catVisPropertyNoShowAttr

    selection1.Clear
End Sub

