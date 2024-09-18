Option Explicit

    '----------------------------------------------------------------
    '   Macro: Join_Explicit_No_Connect.bas
    '   Version: 1.0
    '   Code: CATIA VBA
    '   Release:   V5R32
    '   Purpose: Macro to join multiple un connected curves and isolates them
    '   Author: Kai-Uwe Rathjen
    '   Date: 13.09.24
    '----------------------------------------------------------------
    '
    '   Change:
    '
    '
    '----------------------------------------------------------------
    
Sub CATMain()
    CATIA.StatusBar = "Join_Explicit_No_Connect.bas, Version 1.0"    'Update Status Bar text
    
    'On Error GoTo myErrorHandler
    
    '----------------------------------------------------------------
    'Defenitions
    '----------------------------------------------------------------
    Const finalJoinName = "Join_Explicit"                           'name for result from macro
    
    '----------------------------------------------------------------
    'Declarations
    '----------------------------------------------------------------
    Dim PartDocumentCurrent As Document                             'Current Open Document
    Dim partCurrent As Part                                         'Current Open part
    Dim sel As CATBaseDispatch                                      'User Selection
    
    Dim InputObjectType(0) As Variant                               'iFilter for user input
    Dim Status As String                                            'Status of User selectin

    Dim Index As Integer                                            'Index for loops
    Dim cCount As Integer                                           'Curves Count

    Dim joinCurves As HybridShapeAssemble                           'New Join
    Dim RefCurves() As Reference                                    'Curve references
    
    Dim Wzk3D As CATBaseDispatch                                    'hybridshapefactory anchor
    Dim geoSet As HybridBody                                        'Geomeetric set
    Dim searchName As String                                        'Name of item to search
    
    Dim hybridShapesCount As Integer                                'Number of items in set
    
    Dim Error As Integer
    Dim PPRDocumentCurrent As PPRDocument                           'PPR Document
    
    '----------------------------------------------------------------
    'Open Current Document
    '----------------------------------------------------------------
    Set PartDocumentCurrent = CATIA.ActiveDocument                  'Current Open Document Anchor

    'If cat product is open, get first part, if no part exit macro
    If (Right(PartDocumentCurrent.Name, (Len(PartDocumentCurrent.Name) - InStrRev(PartDocumentCurrent.Name, "."))) = "CATProduct") Then
        If (PartDocumentCurrent.Product.Products.count < 1) Then
            Error = MsgBox("No Parts found" & vbNewLine & "Please Open a .CATPart to use this script or Open part in new window", vbCritical)
            Exit Sub
        End If
        Set partCurrent = PartDocumentCurrent.Product.Products.Item(1).ReferenceProduct.Parent.Part
    'If cat process is open, get first part, if no part exit macro
    ElseIf (Right(PartDocumentCurrent.Name, (Len(PartDocumentCurrent.Name) - InStrRev(PartDocumentCurrent.Name, "."))) = "CATProcess") Then
        Set PPRDocumentCurrent = PartDocumentCurrent.PPRDocument    'Anchor PPR Document
        If (PPRDocumentCurrent.Products.count < 1) Then
            Error = MsgBox("No Products Found" & vbNewLine & "Please Open a .CATPart to use this script or Open part in new window", vbCritical)
            Exit Sub
        End If
        Set partCurrent = PPRDocumentCurrent.Products.Item(1).ReferenceProduct.Parent.Part
    Else
        Set partCurrent = PartDocumentCurrent.Part                   'Current Open Part Anchor
    End If

    Set sel = PartDocumentCurrent.Selection                         'Set up user selection
    sel.Clear                                                       'Clear Selection
    
    '----------------------------------------------------------------
    'Get User selection
    '
    ' "MonoDimInfinite"  = Topological 1-D entity which may be infinite
    '
    '
    'CATMultiSelTriggWhenUserValidatesSelection
    '   Multi-selection is supported (through a dedicated "Tools Palette" toolbar).
    '   The selection (through a trap for example) is triggered when the user validates the selection.
    '   The CTRL and SHIFT keys are supported.
    '
    '----------------------------------------------------------------
    InputObjectType(0) = "MonoDimInfinite"                          'Set input type to curves
    'Get Input from User, get selections untill user acepts
    Status = sel.SelectElement3(InputObjectType, "Select curves to join", False, CATMultiSelTriggWhenUserValidatesSelection, False)
    
    If (Status = "Cancel") Then                                     'If User cancels or presses Esc, Exit Macro
        Exit Sub
    End If
    
    If sel.Count2 < 2 Then                                          'At least two things need to be selected
        Error = MsgBox("You need to select at least two curves", vbCritical)
        sel.Clear
        Exit Sub
    End If
    
    ReDim RefCurves(sel.Count2)                                     'Dynamic allocation acording to user input
    cCount = sel.Count2                                             'The amount of selected items
    For Index = 1 To sel.Count2                                     'Cycle through all inputs
        Set RefCurves(Index) = sel.Item2(Index).Reference           'Save selections to array
    Next
    sel.Clear                                                       'Clear Selection
    
    '----------------------------------------------------------------
    'Create new join
    '----------------------------------------------------------------
    Set Wzk3D = partCurrent.HybridShapeFactory                      'Anchor hybridshapefactory for use
    
    Set joinCurves = Wzk3D.AddNewJoin(RefCurves(1), RefCurves(2))   'Create new hybridshape assemble feature
    
    If cCount > 2 Then
        For Index = 3 To cCount                                     'Cycle through rest of curves
            joinCurves.AddElement RefCurves(Index)                  'Add curves to join
        Next
    End If
    
    joinCurves.SetAngularTolerance (0.5)                            'Set angle tol
    joinCurves.SetAngularToleranceMode (False)                      'Turn off angle tol mode
    joinCurves.SetConnex (False)                                    'Turn off check connex
    joinCurves.SetDeviation (0.001)                                 'Set merge distance
    joinCurves.SetFederationPropagation (0)                         'Set to no
    joinCurves.SetHealingMode (False)                               'No Heal
    joinCurves.SetSimplify (False)                                  'No simplify
    joinCurves.SetSuppressMode (True)                               'True is only option
    joinCurves.SetTangencyContinuity (False)                        'No tangent continuity
    joinCurves.SetManifold (True)                                   'Check Manifold
    
    searchName = partCurrent.InWorkObject.Name                      'Get name of in work object
    Set geoSet = searchTreeGeo(searchName, partCurrent.HybridBodies) 'Search for in-Work GeoSet
    
    geoSet.AppendHybridShape joinCurves                             'Add join to set
    
    hybridShapesCount = geoSet.HybridShapes.count                   'Number of items in set
    
    partCurrent.Update                                              'Update Part
    
    '----------------------------------------------------------------
    'Create Datum
    '----------------------------------------------------------------
    sel.Add geoSet.HybridShapes.Item(hybridShapesCount)             'Select Temp Join
    sel.Copy                                                        'Copy
    sel.Clear                                                       'Clear Selection
    
    sel.Add geoSet                                                  'Select geoSet
    sel.PasteSpecial ("CATPrtResultWithOutLink")                    'Paste from clipboard as result without links
    sel.Clear                                                       'Clear selection
    
    hybridShapesCount = geoSet.HybridShapes.count                   'Number of items in set
    geoSet.HybridShapes.Item(hybridShapesCount).Name = setNameJoin(finalJoinName, partCurrent.HybridBodies)
    
    partCurrent.InWorkObject = geoSet.HybridShapes.Item(hybridShapesCount)
    sel.Clear                                                       'Clear Selection
    
    sel.Add geoSet.HybridShapes.Item(hybridShapesCount - 1)         'Select Temp Join
    sel.Delete                                                      'Delete Selection
    
    Exit Sub
    
myErrorHandler:
    'Handle part update errors and manifold errors
    If StrComp("Method 'Update' of object 'Part' failed", Err.Description, vbTextCompare) = 0 Then
        Error = MsgBox("Method 'Update' of object 'Part' failed." & vbNewLine & vbNewLine & "This can be caused by a Manifold error.", vbCritical)
        
        sel.Clear
        sel.Add geoSet.HybridShapes.Item(hybridShapesCount)
        sel.Delete
        Exit Sub
    'All other errors
    Else
        Error = MsgBox(Err.Description, vbCritical)
        Exit Sub
    End If
End Sub

'----------------------------------------------------------------
' Function to search for geometric set name in top level, then if not found
' it will call a recursive function on all sub levels untill found. If not found
' a new set will be added
'----------------------------------------------------------------
Function searchTreeGeo(searchName As String, currentHybridBodies As HybridBodies) As HybridBody
    Dim Index As Integer                                            'Index for loop

    If currentHybridBodies.count = 0 Then                           'If no geometric sets
        Set searchTreeGeo = currentHybridBodies.Add()               'Add new set
        Exit Function                                               'Exit
    End If
    
    For Index = 1 To currentHybridBodies.count                      'For all geometric sets
        If StrComp(searchName, currentHybridBodies.Item(Index).Name, vbTextCompare) = 0 Then    'If set name = search
            Set searchTreeGeo = currentHybridBodies.Item(Index)     'Save set
            Exit Function                                           'Exit
        Else
            If currentHybridBodies.Item(Index).HybridBodies.count > 0 Then  'If Sub Sets exist
                Set searchTreeGeo = searchTreeGeoRecursive(searchName, currentHybridBodies.Item(Index).HybridBodies)    'Call recursive search
            End If
        End If
    Next
    
    If searchTreeGeo Is Nothing Then                                    'If not found
        Set searchTreeGeo = currentHybridBodies.Add()                   'Add new Set
    End If
End Function

'----------------------------------------------------------------
' Recursive function to search for geometric set
'----------------------------------------------------------------
Function searchTreeGeoRecursive(searchName As String, currentHybridBodies As HybridBodies) As HybridBody
    Dim Index As Integer                                               'Index for loops

    For Index = 1 To currentHybridBodies.count                          'For all sets
        If StrComp(searchName, currentHybridBodies.Item(Index).Name, vbTextCompare) = 0 Then    'If found
            Set searchTreeGeoRecursive = currentHybridBodies.Item(Index)  'Save set
            Exit Function                                               'Exit
        Else
            If currentHybridBodies.Item(Index).HybridBodies.count > 0 Then  'If sub sets exist
                Set searchTreeGeoRecursive = searchTreeGeoRecursive(searchName, currentHybridBodies.Item(Index).HybridBodies)   'Call resursive this function
            End If
        End If
    Next
End Function

'----------------------------------------------------------------
' Function to search for all instnces of results from this macro.
'
' Will check top level geometric sets first, then recursivly go through lower levels
'----------------------------------------------------------------
Function setNameJoin(finalJoinName As String, currentHybridBodies As HybridBodies) As String
    Dim Index As Integer                                            'Index for loop
    Dim IndexShapes As Integer                                       'Index for loop
    Dim count As Integer                                            'Counts instances
    
    count = 1                                                       'Initilise count

    
    For Index = 1 To currentHybridBodies.count                      'For all geometric sets
        If currentHybridBodies.Item(Index).HybridShapes.count > 0 Then  'If elements exist
            For IndexShapes = 1 To currentHybridBodies.Item(Index).HybridShapes.count   'Loop all elements
                If InStr(1, currentHybridBodies.Item(Index).HybridShapes.Item(IndexShapes).Name, finalJoinName, vbTextCompare) <> 0 Then 'if found
                    count = count + 1                               'Increment count
                End If
            Next
        Else
            If currentHybridBodies.Item(Index).HybridBodies.count > 0 Then  'If geo sets exist
                count = count + setNameJoinRecursive(finalJoinName, currentHybridBodies.Item(Index).HybridBodies)   'Call recursive function
            End If
        End If
    Next
    
    setNameJoin = finalJoinName & "." & count                             'Set name
End Function

'----------------------------------------------------------------
' Recursive Function to search for all instnces of results from this macro.
'
'----------------------------------------------------------------
Function setNameJoinRecursive(finalJoinName As String, currentHybridBodies As HybridBodies) As String
    Dim Index As Integer                                                'Index for loop
    Dim IndexShapes As Integer                                          'Index for loop
    Dim count As Integer                                                'Counts instances
    
    count = 0                                                           'Initilise count
    
    For Index = 1 To currentHybridBodies.count                          'For all geometric sets
        If currentHybridBodies.Item(Index).HybridShapes.count > 0 Then  'If elements exist
            For IndexShapes = 1 To currentHybridBodies.Item(Index).HybridShapes.count   'Loop all elements
                If InStr(1, currentHybridBodies.Item(Index).HybridShapes.Item(IndexShapes).Name, finalJoinName, vbTextCompare) <> 0 Then   'If found
                    count = count + 1                                   'Increment Count
                End If
            Next
        Else
            If currentHybridBodies.Item(Index).HybridBodies.count > 0 Then  'If geo sets exist
                count = count + setNameJoinRecursive(finalJoinName, currentHybridBodies.Item(Index).HybridBodies)   'call this function on sets
            End If
        End If
    Next
    setNameJoinRecursive = count                                        'Set Counter
End Function
