Option Explicit

    '----------------------------------------------------------------
    '   Macro: Create_splines.bas
    '   Version: 1.0
    '   Code: CATIA VBA
    '   Release:   V5R32
    '   Purpose: Macro to create spline for points.
    '   Author: Kai-Uwe Rathjen
    '   Date: 23.09.24
    '----------------------------------------------------------------
    '
    '   Change:
    '
    '
    '----------------------------------------------------------------
Sub CATMain()
    CATIA.StatusBar = "Create_splines, Version 1.0"                         'Update Status Bar text
    
    'On Error Resume Next
    
    '----------------------------------------------------------------
    'Defenitions
    '----------------------------------------------------------------
    Const GEOSETNAME = "GENERATED_SPLINES"                                    'Name of geo set
    
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
    
    Dim geoSet As HybridBody                                                'Current geometric set
    Dim geoSetTemp As HybridBody                                            'Temp geometric set
    Dim Wzk3D As CATBaseDispatch                                            'HybridShapeFactoy
    
    Dim InputObjectType(0) As Variant                                       'iFilter for user input
    Dim Status As String                                                    'Status of User selectin
    
    Dim pointSelect() As AnyObject                                          'Array of points selected
    Dim pointRef() As Reference                                             'Ref to points
    Dim pointCount As Integer                                               'Numbe rof curve selected
    Dim newSpline As HybridShapeSpline                                      'New spline created
    
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
    
    If sel.Count2 = 0 Then                                                  'If no selection, exit
        Exit Sub
    End If
    
    pointCount = sel.Count2                                                 'Get amount of points
    ReDim pointSelect(pointCount)                                           'Re-dimention Array
    ReDim pointRef(pointCount)                                              'Re-Dimention Array
    For Index = 1 To pointCount                                             'Store selection in array
        Set pointSelect(Index) = sel.Item2(Index).Value
    Next Index
    sel.Clear
    
    '----------------------------------------------------------------
    'Make Selection for sorting
    '----------------------------------------------------------------
    SelectXYZ.Show                                                          'Show for for selection

    Call sortPoints(pointSelect, pointCount, SelectXYZ.OptionButton1, SelectXYZ.OptionButton2, SelectXYZ.OptionButton3) 'Call insertion sort sub
    
    '====================================================================
    '
    '   Degbug Start
    '
    '   Print array after sorting to see what we get
    '=====================================================================
    Call debugPointArray(pointSelect, pointCount)
    
    Exit Sub
    '====================================================================
    '
    '   Degbug End
    '
    '
    '=====================================================================
    
    '----------------------------------------------------------------
    ' Create spline
    '----------------------------------------------------------------
    Set geoSet = oPart.HybridBodies.Add                                     'Add set for result
    Set geoSetTemp = oPart.HybridBodies.Add                                 'Add temp set
    geoSet.Name = GEOSETNAME                                                'Rename result set
    
    Set Wzk3D = oPart.HybridShapeFactory                                    'Anchor hybridshapefactory for use
    
    For Index = 1 To pointCount                                             'Create references for all selection
        Set pointRef(Index) = oPart.CreateReferenceFromObject(pointSelect(Index))
    Next
    
    Set newSpline = Wzk3D.AddNewSpline                                      'Add new spline

    For Index = 1 To pointCount                                             'Add Points to spline
        newSpline.AddPoint pointRef(Index)
    Next Index
    
    geoSetTemp.AppendHybridShape newSpline                                  'Add spline to geometric set
    
    oPart.Update                                                            'Update part
    
    '----------------------------------------------------------------
    ' Clean up
    '----------------------------------------------------------------
    sel.Add geoSetTemp.HybridShapes.Item(1)                                 'Copy spline
    sel.Copy
    sel.Clear
    sel.Add geoSet
    sel.PasteSpecial ("CATPrtResultWithOutLink")                            'Paste from clipboard as result without links
    sel.Clear
    sel.Add geoSetTemp                                                      'Delete construction
    sel.Delete
    
    oPart.Update

End Sub

    '----------------------------------------------------------------
    '   This sub will insertion sort an array of points by x, y or z
    '   This sub will sort the array inplace, byreference
    '
    '   Assumption: Only one of sX, sY or sZ will be true, however the first true
    '               value will be the one used to sort: x>y>Z
    '
    '   Inputs:
    '       ByRef pointSelect() As AnyObject
    '           This is the array to be sorted
    '
    '       pointCount As Integer
    '           This is the size of the array
    '
    '       sX As Boolean
    '           If true will sort by x
    '       sY As Boolean
    '           If true will sort by y
    '       sZ As Boolean
    '           If true will sort by z
    '----------------------------------------------------------------
    
Sub sortPoints(ByRef pointSelect() As AnyObject, pointCount As Integer, sX As Boolean, sY As Boolean, sZ As Boolean)
    Dim lngCounter1 As Long                                                 'Index for loops
    Dim lngCounter2 As Long                                                 'Index for loops
    Dim coord(3) As Variant                                                 'Coordinates
    Dim coord2(3) As Variant                                                'Coordinates
    Dim sel As CATBaseDispatch                                              'Current selection
    
    Dim varTemp As Double                                                   'Current coordinate to be sorted
    Dim varTemp2 As Double                                                  'Current coordinate to be sorted
    
    Dim tempObj As AnyObject
    
    Set sel = CATIA.ActiveDocument.Selection                                'Anchor selection
    sel.Clear

    'Insertion sort by x coordinate
    If sX = True Then
        For lngCounter1 = 1 To pointCount
        
            pointSelect(lngCounter1).GetCoordinates (coord)
            varTemp = coord(0)
            Set tempObj = pointSelect(lngCounter1)
            
            For lngCounter2 = lngCounter1 To 1 Step -1
                If pointSelect(lngCounter1 - 1) Is Nothing Then
                    Exit For
                End If
            
                pointSelect(lngCounter1 - 1).GetCoordinates (coord2)
                varTemp2 = coord2(0)
            
                If varTemp2 > varTemp Then
                     Set pointSelect(lngCounter2) = pointSelect(lngCounter2 - 1)
                Else
                    Exit For
                End If
            Next lngCounter2
            Set pointSelect(lngCounter2) = tempObj
        
        Next lngCounter1
    
    'Insertion sort by y coordinate
    ElseIf sY = True Then
        For lngCounter1 = 1 To pointCount
        
            pointSelect(lngCounter1).GetCoordinates (coord)
            varTemp = coord(1)
            Set tempObj = pointSelect(lngCounter1)
            
            For lngCounter2 = lngCounter1 To 1 Step -1
            
                If pointSelect(lngCounter1 - 1) Is Nothing Then
                    Exit For
                End If
            
                pointSelect(lngCounter1 - 1).GetCoordinates (coord2)
                varTemp2 = coord2(1)
            
                If varTemp2 > varTemp Then
                    Set pointSelect(lngCounter2) = pointSelect(lngCounter2 - 1)
                Else
                    Exit For
                End If
            Next lngCounter2
            Set pointSelect(lngCounter2) = tempObj
        
        Next lngCounter1
    
    'Insertion sort by z coordinate
    ElseIf sZ = True Then
        For lngCounter1 = 1 To pointCount
      
            pointSelect(lngCounter1).GetCoordinates (coord)
            varTemp = coord(2)
            Set tempObj = pointSelect(lngCounter1)
            
            For lngCounter2 = lngCounter1 To 1 Step -1
            
                If pointSelect(lngCounter1 - 1) Is Nothing Then
                    Exit For
                End If
            
                pointSelect(lngCounter1 - 1).GetCoordinates (coord2)
                varTemp2 = coord2(2)
            
                If varTemp2 > varTemp Then
                    Set pointSelect(lngCounter2) = pointSelect(lngCounter2 - 1)
                Else
                    Exit For
                End If
            Next lngCounter2
            Set pointSelect(lngCounter2) = tempObj
        
        Next lngCounter1
    End If
End Sub

'Debug print points values
Sub debugPointArray(points() As AnyObject, size As Integer)

    Dim Index As Integer
    Dim coords(3) As Variant
    
    For Index = 1 To size
        If points(Index) Is Nothing Then
            Debug.Print "Nothing " & Index
        Else
            points(Index).GetCoordinates (coords)
            Debug.Print points(Index).Name & " " & coords(0) & " " & coords(1) & " " & coords(2)
        End If

    Next Index
    
End Sub
