Attribute VB_Name = "Points_To_Excel"
Option Explicit

    '----------------------------------------------------------------
    '   Macro: Points_To_Excel.bas
    '   Version: 1.0
    '   Code: CATIA VBA
    '   Release:   V5R32
    '   Purpose: Macro to export points to excel
    '   Author: Kai-Uwe Rathjen
    '   Date: 25.09.24
    '----------------------------------------------------------------
    '
    '   Change:
    '
    '
    '----------------------------------------------------------------
    
    
Sub CATMain()
    CATIA.StatusBar = "Points_To_Excel.bas, Version 1.0"                         'Update Status Bar text
    
    'On Error Resume Next
    
    '----------------------------------------------------------------
    'Declarations
    '----------------------------------------------------------------
    Dim oDocument As Document                                               'Current Open Document
    Dim PPRDocumentCurrent As Document                                      'PPRDocument
    Dim oPart As Part                                                       'Current Open part
    Dim sel As CATBaseDispatch                                              'User Selection

    Dim Index As Integer                                                    'Index for loops
    Dim Error As Integer
    Dim Msg As Integer                                                      'Message status
    
    Dim InputObjectType(0) As Variant                                       'iFilter for user input
    Dim Status As String                                                    'Status of User selectin
    
    Dim pointSelect() As AnyObject                                          'Array of points selected
    Dim pointCount As Integer                                               'Numbe rof curve selected
    
    Dim objexcel As Object
    Dim objWorkbook As Object
    Dim objsheet1 As Object
    
    Dim rowCount As Integer
    
    Dim coord(2) As Variant
    Dim tempPoint As AnyObject
    
    '----------------------------------------------------------------
    'Open Current Document
    '----------------------------------------------------------------
    Set oDocument = CATIA.ActiveDocument                                    'Current Open Document Anchor

    'If cat product is open, get first part, if no part exit macro
    If (Right(oDocument.Name, (Len(oDocument.Name) - InStrRev(oDocument.Name, "."))) = "CATProduct") Then
        If (oDocument.Product.Products.count < 1) Then
            Error = MsgBox("No Parts found" & vbNewLine & "Please Open a .CATPart to use this script or Open part in new window", vbCritical)
            Exit Sub
        End If
        Set oPart = oDocument.Product.Products.Item(1).ReferenceProduct.Parent.Part
    'If cat process is open, get first part, if no part exit macro
    ElseIf (Right(oDocument.Name, (Len(oDocument.Name) - InStrRev(oDocument.Name, "."))) = "CATProcess") Then
        Set PPRDocumentCurrent = oDocument.PPRDocument                      'Anchor PPR Document
        If (PPRDocumentCurrent.Products.count < 1) Then
            Error = MsgBox("No Products Found" & vbNewLine & "Please Open a .CATPart to use this script or Open part in new window", vbCritical)
            Exit Sub
        End If
        Set oPart = PPRDocumentCurrent.Products.Item(1).ReferenceProduct.Parent.Part
    Else
        Set oPart = oDocument.Part                                          'Current Open Part Anchor
    End If

    Set sel = oDocument.Selection                                           'Set up user selection
    sel.Clear                                                               'Clear Selection
    
    '----------------------------------------------------------------
    'Make Selection
    '----------------------------------------------------------------
    InputObjectType(0) = "Point"                                            'Set input type to point
    'Get Input from User, get selections untill user acepts
    '
    '   Get curves
    '
    Status = sel.SelectElement3(InputObjectType, "Select points", False, CATMultiSelTriggWhenUserValidatesSelection, False)
    
    If (Status = "Cancel") Then                                             'If User cancels or presses Esc, Exit Macro
        Exit Sub
    End If
    
    If sel.Count2 = 0 Then                                                  'If no selection or less than 2, exit
        Error = MsgBox("Nothing Selected", vbCritical)
        Exit Sub
    End If

    
    pointCount = sel.Count2                                                 'Get amount of points
    ReDim pointSelect(pointCount)                                           'Re-dimention Array
    For Index = 1 To pointCount                                             'Store selection in array
        Set pointSelect(Index) = sel.Item2(Index).Value
    Next Index
    
    sel.Clear
    
    '----------------------------------------------------------------
    'Open Excel Document
    '----------------------------------------------------------------
    Set objexcel = CreateObject("Excel.Application")
    objexcel.Visible = True
    Set objWorkbook = objexcel.workbooks.Add()
    Set objsheet1 = objWorkbook.Sheets.Item(1)
    objsheet1.Name = "Points_Export"
    
    objsheet1.Cells(1, 1) = "X Coordinate"
    objsheet1.Cells(1, 2) = "Y Coordinate"
    objsheet1.Cells(1, 3) = "Z Coordinate"
    objsheet1.Cells(1, 4) = "Point Name"
    
    rowCount = 2

    '----------------------------------------------------------------
    'Get Points
    '----------------------------------------------------------------
    
    For Index = 1 To pointCount
        Set tempPoint = findHybridShape(pointSelect(Index).Name, oPart.HybridBodies)
        
        If tempPoint Is Nothing Then
            GoTo skipLoop
        Else
            tempPoint.GetCoordinates (coord)
            objsheet1.Cells(rowCount, 1) = coord(0)
            objsheet1.Cells(rowCount, 2) = coord(1)
            objsheet1.Cells(rowCount, 3) = coord(2)
            objsheet1.Cells(rowCount, 4) = tempPoint.Name
            
            rowCount = rowCount + 1
        End If
        
skipLoop:
    Next Index
    
    

End Sub

'----------------------------------------------------------------
' Function to search for hybridshape by name
'
' Will check top level geometric sets first, then recursivly go through lower levels
'----------------------------------------------------------------
Function findHybridShape(searchName As String, currentHybridBodies As HybridBodies) As HybridShape
    Dim Index As Integer                                            'Index for loop
    Dim IndexShapes As Integer                                       'Index for loop
    
    For Index = 1 To currentHybridBodies.count                      'For all geometric sets
        If currentHybridBodies.Item(Index).HybridShapes.count > 0 Then  'If elements exist
            For IndexShapes = 1 To currentHybridBodies.Item(Index).HybridShapes.count   'Loop all elements
                If InStr(1, currentHybridBodies.Item(Index).HybridShapes.Item(IndexShapes).Name, searchName, vbTextCompare) <> 0 Then 'if found
                    Set findHybridShape = currentHybridBodies.Item(Index).HybridShapes.Item(IndexShapes)
                    Exit Function
                End If
            Next
        Else
            If currentHybridBodies.Item(Index).HybridBodies.count > 0 Then  'If geo sets exist
                Set findHybridShape = findHybridShapeR(searchName, currentHybridBodies.Item(Index).HybridBodies)    'Call recursive function
            End If
        End If
    Next
    
    If findHybridShape Is Nothing Then                                    'If not found
        Err.Raise vbObjectError + 1000, , "HybridShape not found"
        Exit Function
    End If
End Function

'----------------------------------------------------------------
' Recursive Function
'----------------------------------------------------------------
Function findHybridShapeR(searchName As String, currentHybridBodies As HybridBodies) As HybridShape
    Dim Index As Integer                                                'Index for loop
    Dim IndexShapes As Integer                                          'Index for loop
    
    For Index = 1 To currentHybridBodies.count                          'For all geometric sets
        If currentHybridBodies.Item(Index).HybridShapes.count > 0 Then  'If elements exist
            For IndexShapes = 1 To currentHybridBodies.Item(Index).HybridShapes.count   'Loop all elements
                If InStr(1, currentHybridBodies.Item(Index).HybridShapes.Item(IndexShapes).Name, finalJoinName, vbTextCompare) <> 0 Then   'If found
                    Set findHybridShapeR = currentHybridBodies.Item(Index).HybridShapes.Item(IndexShapes)
                    Exit Function
                End If
            Next
        Else
            If currentHybridBodies.Item(Index).HybridBodies.count > 0 Then  'If geo sets exist
                Set findHybridShape = findHybridShapeR(searchName, currentHybridBodies.Item(Index).HybridBodies)   'call this function on sets
            End If
        End If
    Next
End Function
