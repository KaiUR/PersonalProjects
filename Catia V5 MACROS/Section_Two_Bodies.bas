Attribute VB_Name = "Section_Two_Bodies"
Option Explicit

    '----------------------------------------------------------------
    '   Macro: Section_Two_Bodies.bas
    '   Version: 1.0
    '   Code: CATIA VBA
    '   Release:   V5R32
    '   Purpose: Macro to select a curve and two bodies to create section
    '   Author: Kai-Uwe Rathjen
    '   Date: 19.09.24
    '----------------------------------------------------------------
    '
    '   Change:
    '
    '
    '----------------------------------------------------------------
    
Sub CATMain()
    CATIA.StatusBar = "Section_Two_Bodies.bas, Version 1.0"         'Update Status Bar text
    
    On Error Resume Next
    
    '----------------------------------------------------------------
    'Defenitions
    '----------------------------------------------------------------
    Const GEOSETNAME = "Section_Macro"                              'Name of geo set
    Const RESULTNAME = "Section"                                    'Name of results
    
    '----------------------------------------------------------------
    'Declarations
    '----------------------------------------------------------------
    Dim oDocument As Document                                       'Current Open Document
    Dim newPart As Part                                             'Current Open part
    Dim oldPart As Part
    Dim sel As CATBaseDispatch                                      'User Selection

    Dim Index As Integer                                            'Index for loops
    Dim Error As Integer
    Dim Msg As Integer                                              'Message status
    
    Dim InputObjectType(0) As Variant                               'iFilter for user input
    Dim Status As String                                            'Status of User selectin
    Dim Wzk3D As CATBaseDispatch                                    'hybridshapefactory anchor
    Dim geoSet As HybridBody                                        'Geomeetric set
    
    Dim refCurve As Reference                                         'Curve/edge reference
    Dim oldSolid As AnyObject                                       'Old Solid
    Dim newSolid As AnyObject                                       'New Solid
    Dim refOldSolid As Reference                                    'ref to old solid
    Dim refNewSolid As Reference                                    'ref to new solid
    
    Dim extractCurve As HybridShapeExtract                          'Extracted Edge
    Dim refExtractCurve As Reference                                'Reference of extracted edge
    Dim normalPlane As HybridShapePlaneNormal                       'New plane normal to curve
    Dim refNormalPlane As Reference                                 'Ref to normal plane
    Dim pointOnCurve As HybridShapePointOnCurve                     'Point on Curve
    Dim refPointOnCurve As Reference                                'Ref to point on curve
    
    Dim oldIntersect As HybridShapeIntersection                     'Intersection of old solid
    Dim newIntersect As HybridShapeIntersection                     'Intersection of new solid
    
    Dim geoSetResult As HybridBody                                  'Geoset for result of macro
    
    Dim SelvisProperties As VisPropertySet                          'Visual Properties
    
    Dim tempBody As Body                                            'Temp Body for copy

    '----------------------------------------------------------------
    'Open Current Document
    '----------------------------------------------------------------
    Set oDocument = CATIA.ActiveDocument                  'Current Open Document Anchor

    'If cat product is open, get first part, if no part exit macro
    If (Right(oDocument.Name, (Len(oDocument.Name) - InStrRev(oDocument.Name, "."))) = "CATProduct") = 0 Then
        Error = MsgBox("No Product" & vbNewLine & "Please Open a .CATProduct to use this script.", vbCritical)
        Exit Sub
    ElseIf oDocument.Product.Products.count < 2 Then
        Error = MsgBox("No Parts" & vbNewLine & "Please Open a .CATProduct with at least two parts to use this script.", vbCritical)
        Exit Sub
    End If

    Set sel = oDocument.Selection                                   'Set up user selection
    sel.Clear                                                       'Clear Selection

    Select Case CATIA.GetWorkbenchId                                'Get current workbench
        Case "Assembly"                                             'If assembly or dmucheck, all ok
            GoTo skipSelect
        Case "DMUCheck"
            GoTo skipSelect
        Case Else
            CATIA.StartWorkbench ("Assembly")                          'Otherwise start assembly workbench
    End Select

skipSelect:
    '----------------------------------------------------------------
    'Make Selection
    '----------------------------------------------------------------
    InputObjectType(0) = "AnyObject"
    
    'Get Input from User, get selections untill user acepts
    '
    '   Get edge
    '
    Status = sel.SelectElement3(InputObjectType, "Select an edge", False, CATMultiSelTriggWhenUserValidatesSelection, False)
    
    If (Status = "Cancel") Then                                     'If User cancels or presses Esc, Exit Macro
        Exit Sub
    End If
    
    If sel.Count2 = 0 Then                                          'If no selection, exit
        Exit Sub
    End If
    
    Set refCurve = sel.Item2(1).Reference                                 'Save referece
    If (Left(refCurve.Name, InStr(1, refCurve.Name, ":") - 1) = "Selection_REdge") = 0 And TypeName(sel.Item2(1).Value) <> "MonoDimFeatEdge" Then  'If not edge selected
        Error = MsgBox("You must select an edge.", vbCritical)
        sel.Clear
        Exit Sub
    End If
    sel.Clear                                                           'Clear selection
    
    'Get Input from User, get selections untill user acepts
    '
    '   Get old condition Solid
    '
    InputObjectType(0) = "Solid"
    Status = sel.SelectElement3(InputObjectType, "Select old condition solid", False, CATMultiSelTriggWhenUserValidatesSelection, False)
    
    If (Status = "Cancel") Then                                     'If User cancels or presses Esc, Exit Macro
        Exit Sub
    End If
    
    If sel.Count2 = 0 Then                                          'If no selection, exit
        Exit Sub
    End If
    
    Set oldSolid = sel.Item2(1).Value                                'Save referece
    sel.Clear                                                       'Clear selection
    If TypeName(oldSolid) <> "Solid" Then                           'If not solid
        Error = MsgBox("You must select a solid.", vbCritical)
        Exit Sub
    End If
    
    'Get Input from User, get selections untill user acepts
    '
    '   Get new condition Solid
    '
    Status = sel.SelectElement3(InputObjectType, "Select new condition solid", False, CATMultiSelTriggWhenUserValidatesSelection, False)
    
    If (Status = "Cancel") Then                                     'If User cancels or presses Esc, Exit Macro
        Exit Sub
    End If
    
    If sel.Count2 = 0 Then                                          'If no selection, exit
        Exit Sub
    End If
    
    Set newSolid = sel.Item2(1).Value                                'Save referece
    sel.Clear                                                       'Clear selection
    If TypeName(newSolid) <> "Solid" Then                           'If not solid
        Error = MsgBox("You must select a solid.", vbCritical)
        Exit Sub
    End If
    
    'Get Input from User, get selections untill user acepts
    '
    '   Get old condition Part
    '
    InputObjectType(0) = "Part"
    Status = sel.SelectElement3(InputObjectType, "Select Old Condition Part", False, CATMultiSelTriggWhenUserValidatesSelection, False)
    
    If (Status = "Cancel") Then                                     'If User cancels or presses Esc, Exit Macro
        Exit Sub
    End If
    
    If sel.Count2 = 0 Then                                          'If no selection, exit
        Exit Sub
    End If
    
    If TypeName(sel.Item2(1).Value) <> "Part" Then                           'If not part
        Error = MsgBox("You must select a Part.", vbCritical)
        Exit Sub
    End If
    
    Set oldPart = sel.Item2(1).Value                                  'Save referece
    sel.Clear                                                       'Clear selection
    
    
    
    'Get Input from User, get selections untill user acepts
    '
    '   Get new condition
    '
    Status = sel.SelectElement3(InputObjectType, "Select New Condition Part", False, CATMultiSelTriggWhenUserValidatesSelection, False)
    
    If (Status = "Cancel") Then                                     'If User cancels or presses Esc, Exit Macro
        Exit Sub
    End If
    
    If sel.Count2 = 0 Then                                          'If no selection, exit
        Exit Sub
    End If
    
    If TypeName(sel.Item2(1).Value) <> "Part" Then                           'If not part
        Error = MsgBox("You must select a Part.", vbCritical)
        Exit Sub
    End If
    
    Set newPart = sel.Item2(1).Value                                  'Save referece
    sel.Clear                                                       'Clear selection
        
    '----------------------------------------------------------------
    'Create Plane
    '----------------------------------------------------------------
    Set Wzk3D = newPart.HybridShapeFactory                            'Anchor hybridshapefactory
    
    'Create extract for curve
    Set extractCurve = Wzk3D.AddNewExtract(refCurve)                        'Create new extract from edge
    
    extractCurve.PropagationType = 3                                      'No Propagation
    
    Set geoSet = newPart.HybridBodies.Add                             'Add New Geoset
    geoSet.Name = GEOSETNAME                                        'Rename Set
    
    geoSet.AppendHybridShape extractCurve                                 'Add Extract
    
    'Create point on curve
    Set refExtractCurve = newPart.CreateReferenceFromObject(geoSet.HybridShapes.Item(1))  'Created reference from extract
    Set pointOnCurve = Wzk3D.AddNewPointOnCurveFromPercent(refExtractCurve, 0.5, False)  'Create point on curve
    geoSet.AppendHybridShape pointOnCurve                                       'Add point to set

    'Create Plane
    Set refPointOnCurve = newPart.CreateReferenceFromObject(geoSet.HybridShapes.Item(2))      'Create reference from point
    
    Set normalPlane = Wzk3D.AddNewPlaneNormal(refExtractCurve, refPointOnCurve)              'Create new plane on curve
    
    geoSet.AppendHybridShape normalPlane                                 'Add plane to set
    
    Set refNormalPlane = newPart.CreateReferenceFromObject(geoSet.HybridShapes.Item(3))
     
    newPart.Update                                                       'Update Part
    
    '----------------------------------------------------------------
    'Create Section
    '----------------------------------------------------------------
    sel.Add oldSolid                                                        'Select old solid
    sel.Copy                                                                'Copy to clipboard
    sel.Clear                                                               'Clear Selection
    
    Set tempBody = newPart.Bodies.Add                                      'Add body for paste
    sel.Add tempBody                                                       'Select body
    sel.PasteSpecial ("CATPrtResultWithOutLink")                            'Paste solid
    sel.Clear                                                                'Clear Selection
    
    Set refOldSolid = newPart.CreateReferenceFromObject(tempBody.Shapes.Item(1))
    Set oldIntersect = Wzk3D.AddNewIntersection(refNormalPlane, refOldSolid)
    oldIntersect.ExtendMode = 0                                         'No extend for either
    
    Set refNewSolid = newPart.CreateReferenceFromObject(newSolid)
    Set newIntersect = Wzk3D.AddNewIntersection(refNormalPlane, refNewSolid)
    newIntersect.ExtendMode = 0                                         'No extend for either
    
    geoSet.AppendHybridShape oldIntersect                               'Add intersect 1 to set
    geoSet.AppendHybridShape newIntersect                               'Add intersect 2 to set

    newPart.Update
    '----------------------------------------------------------------
    'Results
    '----------------------------------------------------------------
    Set geoSetResult = newPart.HybridBodies.Add                     'Add result Set
    geoSetResult.Name = RESULTNAME                                  'Rename Set
    
    sel.Add geoSet.HybridShapes.Item(4)                             'Select intersect 1
    sel.Add geoSet.HybridShapes.Item(5)                             'Select intersect 2
    sel.Copy
    sel.Clear
    sel.Add geoSetResult
    sel.PasteSpecial ("CATPrtResultWithOutLink")                    'Paste from clipboard as result without links
    sel.Clear
    
    For Index = 1 To geoSetResult.HybridShapes.count / 2            'Select first half
        sel.Add geoSetResult.HybridShapes.Item(Index)
        geoSetResult.HybridShapes.Item(Index).Name = "Old_" & RESULTNAME & "." & Index  'Rename items
    Next
    Set SelvisProperties = sel.visProperties                        'get properties
    SelvisProperties.SetRealColor 0, 255, 0, 1                      'Change to green
    sel.Clear
    
    For Index = (geoSetResult.HybridShapes.count / 2) + 1 To geoSetResult.HybridShapes.count    'Get other half
        sel.Add geoSetResult.HybridShapes.Item(Index)
        geoSetResult.HybridShapes.Item(Index).Name = "New_" & RESULTNAME & "." & Index
    Next
    Set SelvisProperties = sel.visProperties
    SelvisProperties.SetRealColor 255, 0, 0, 1                      'Change to red
    sel.Clear
    
    sel.Add tempBody                                                'select copied solid in body
    sel.Add geoSet                                                  'Select geo set
    sel.Delete                                                      'Delete
    
    newPart.Update                                                  'Update part
    
End Sub
