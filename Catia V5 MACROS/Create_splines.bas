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
    Public Const SUCCESIVEPOINTCHECK = 0.1                                  'Distance to check for succesive points
    
    Public SelectXYZTerminated As Boolean
    Public SplineOrPoliLineTerminated As Boolean
    
    
Sub CATMain()
    CATIA.StatusBar = "Create_splines, Version 1.0"                         'Update Status Bar text
    
    'On Error Resume Next
    On Error GoTo myErrorHandler
    
    SelectXYZTerminated = False
    SplineOrPoliLineTerminated = False
    
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
    Dim newPolyLine As HybridShapePolyline                                  'New polyLine created
    
    Dim splineSelect As Boolean                                             'True if spline, false for polyline
    
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
    
    If sel.Count2 < 2 Then                                                  'If no selection or less than 2, exit
        Error = MsgBox("Select at least 2 points", vbCritical)
        Exit Sub
    End If
    
    'Two successive points are geometrically identical fix
    Call RemoveSuccessivePoints
    
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
    
    If SelectXYZTerminated = True Then
        Exit Sub
    End If

    Call sortPoints(pointSelect, pointCount, SelectXYZ.OptionButton1, SelectXYZ.OptionButton2, SelectXYZ.OptionButton3) 'Call insertion sort sub
    
    splineSelect = True                                                     'Initilise Selection
    
    SplineOrPolyline.Show
    
    If SplineOrPoliLineTerminated = True Then
        Exit Sub
    End If
    
    If SplineOrPolyline.OptionButton1 = True Then
        splineSelect = True
    Else
        splineSelect = False
    End If
    
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
    
    If splineSelect = True Then
        Set newSpline = Wzk3D.AddNewSpline                                      'Add new spline

        For Index = 1 To pointCount                                             'Add Points to spline
            'Sub AddPointWithConstraintExplicit(Reference ipIAPoint,
            'HybridShapeDirection ipIADirTangency,double iTangencyNorm,long iInverseTangency,
            'HybridShapeDirection ipIADirCurvature,double iCurvatureRadius)
            newSpline.AddPointWithConstraintExplicit pointRef(Index), Nothing, -1#, 1, Nothing, 0#
        Next Index
    
        newSpline.SetSplineType (0)                                             'Cubic spline (0) or WilsonFowler (1)
        newSpline.SetClosing (0)                                                'Not closed
    
        geoSetTemp.AppendHybridShape newSpline                                  'Add spline to geometric set
    Else
        Set newPolyLine = Wzk3D.AddNewPolyline                                  'Add new Polyline
    
        For Index = 1 To pointCount                                             'Add points to polyline
            newPolyLine.InsertElement pointRef(Index), Index
        Next Index
    
        geoSetTemp.AppendHybridShape newPolyLine                                'Add polyline to geo set
    End If
 
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
    
    oPart.InWorkObject = geoSet.HybridShapes.Item(1)
    oPart.Update

    Exit Sub
    
myErrorHandler:
    'Handle part update errors and manifold errors
    If StrComp("Method 'Update' of object 'Part' failed", Err.Description, vbTextCompare) = 0 Then
        Error = MsgBox("Method 'Update' of object 'Part' failed." & vbNewLine & vbNewLine & _
        "Try selecting a differned direction to sort or there are two points very close to each other", vbCritical)
        
        If geoSetTemp Is Nothing Then
            sel.Clear
        Else
            sel.Clear
            sel.Add geoSetTemp
            sel.Add geoSet
            sel.Delete
        End If
        
        Exit Sub
    'All other errors
    Else
        Error = MsgBox(Err.Description, vbCritical)
        Exit Sub
    End If
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
    Dim coord(2) As Variant                                                 'Coordinates
    Dim coord2(2) As Variant                                                'Coordinates
    Dim sel As CATBaseDispatch                                              'Current selection
    
    Dim tempObj As AnyObject
    Dim coordIndex As Integer
    
    Set sel = CATIA.ActiveDocument.Selection                                'Anchor selection
    sel.Clear

    'Set to x, y or z coordinate
    If sX = True Then
        coordIndex = 0
    ElseIf sY = True Then
        coordIndex = 1
    ElseIf sZ = True Then
        coordIndex = 2
    Else
        Exit Sub
    End If

    'Sort Points
    For lngCounter1 = 1 To pointCount
        For lngCounter2 = lngCounter1 + 1 To pointCount
        
            pointSelect(lngCounter1).GetCoordinates (coord)
            pointSelect(lngCounter2).GetCoordinates (coord2)
            
            If coord(coordIndex) < coord2(coordIndex) Then
                Set tempObj = pointSelect(lngCounter2)
                Set pointSelect(lngCounter2) = pointSelect(lngCounter1)
                Set pointSelect(lngCounter1) = tempObj
            End If
            
        Next lngCounter2
    Next lngCounter1
  
End Sub

'----------------------------------------------------
'
'   Sub to fix following error by removing points that are equal
'
'   Two successive points are geometrically identical.
'   This function does have a preformance penalty so if
'   you wish you can skip this sub and make sure that you check for this error
'   yoursel before running the macro
'
'
'-----------------------------------------------------

Sub RemoveSuccessivePoints()
    Dim sel As CATBaseDispatch                                              'Selection
    Dim coord(2) As Variant                                                 'First coord
    Dim coord2(2) As Variant                                                'Second Coord
    
    Dim Index As Integer                                                    'Index for loop
    Dim Index2 As Integer                                                   'Inside loop Index
    Dim Size As Integer                                                     'Number of Selection
    Dim rmvCount As Integer
    
    Set sel = CATIA.ActiveDocument.Selection                                'Anchor selection
    
    Size = sel.Count2                                                       'Save sive of selection
    rmvCount = 0                                                            'Amount of items removed

    For Index = 1 To Size - 1
        If Index > Size - 1 - rmvCount Then                                 'Make sure to not over-run array due to removes
            Exit For
        End If
    
        sel.Item2(Index).Value.GetCoordinates (coord)                       'Get first coord
        
        For Index2 = Index + 1 To Size - 1
            If Index2 > Size - 1 - rmvCount Then                            'Make sure to not over-run array due to removess
                Exit For
            End If
        
            sel.Item2(Index2).Value.GetCoordinates (coord2)                  'Get second coord
    
            'If coordinates are within SUCCESIVEPOINTCHECK from each other remove from selection[text](https://github.com/KaiUR/PersonalProjects/blob/master/Catia%20V5%20MACROS/SplineOrPolyline.frm)
            If Abs(coord(0) - coord2(0)) < SUCCESIVEPOINTCHECK And _
            Abs(coord(1) - coord2(1)) < SUCCESIVEPOINTCHECK And Abs(coord(2) - coord2(2)) < SUCCESIVEPOINTCHECK Then
                sel.Remove (Index2)
                rmvCount = rmvCount + 1
            End If
               
        Next Index2
    Next Index

End Sub

