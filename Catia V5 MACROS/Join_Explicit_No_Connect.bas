Attribute VB_Name = "Join_Explicit_No_Connect"
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
    
    'On Error Resume Next
    
    '----------------------------------------------------------------
    'Declarations
    '----------------------------------------------------------------
    Dim PartDocumentCurrent As Document                             'Current Open Document
    Dim PartDocumentNew As Document                                 'New Document
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
    
    '----------------------------------------------------------------
    'Open Current Document
    '----------------------------------------------------------------
    Set PartDocumentCurrent = CATIA.ActiveDocument                  'Current Open Document Anchor

    If (Right(PartDocumentCurrent.Name, (Len(PartDocumentCurrent.Name) - InStrRev(PartDocumentCurrent.Name, "."))) = "CATProduct") Then
        Error = MsgBox("This Script only works with .CATPart Files" & vbNewLine & "Please Open a .CATPart to use this script or Open part in new window", vbCritical)
        Exit Sub
    End If
    If (Right(PartDocumentCurrent.Name, (Len(PartDocumentCurrent.Name) - InStrRev(PartDocumentCurrent.Name, "."))) = "CATProcess") Then
        Error = MsgBox("This Script only works with .CATPart Files" & vbNewLine & "Please Open a .CATPart to use this script or Open part in new window", vbCritical)
        Exit Sub
    End If

    Set partCurrent = PartDocumentCurrent.Part                      'Current Open Part Anchor

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
            joinCurves.AddElement (RefCurves(Index))                'Add curves to join
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
    
    searchName = partCurrent.InWorkObject.Name                      'Get name of in work object
    
    If StrComp(searchName, partCurrent.Bodies.Item(1).Name) = 0 Then    'If body is inwork object create new geo set
        geoSet = partCurrent.HybridBodies.Add()                         'Add New set
    Else
        sel.Search "(NAME =" & searchName & "),all"                     'Search for in work object
    
        Set geoSet = sel.Item2(1).Value                                 'Anchor geo set
        sel.Clear                                                       'Clear Selection
    End If
    
    geoSet.AppendHybridShape joinCurves                             'Add join to set
    
    hybridShapesCount = geoSet.HybridShapes.Count                   'Number of items in set
    geoSet.HybridShapes.Item(hybridShapesCount).Name = "TEMP_JOIN"  'Rename Join
    
    partCurrent.Update                                              'Update Part
    
    '----------------------------------------------------------------
    'Create Datum
    '----------------------------------------------------------------
    sel.Search "(NAME =TEMP_JOIN),all"                              'Select temp_join
    sel.Copy                                                        'Copy
    sel.Clear                                                       'Clear Selection
    
    sel.Search "(NAME =" & geoSet.Name & "),all"                    'Select geoSet
    sel.PasteSpecial ("CATPrtResultWithOutLink")                    'Paste from clipboard as result without links
    sel.Clear                                                       'Clear selection
    
    hybridShapesCount = geoSet.HybridShapes.Count                   'Number of items in set
    sel.Search "(NAME =Join_Explicit.*),all"                         'Select all joins from this macro
    geoSet.HybridShapes.Item(hybridShapesCount).Name = "Join_Explicit." & sel.Count + 1 'Rename curve
    sel.Clear                                                       'Clear Selection
    
    sel.Search "(NAME =TEMP_JOIN),all"                              'Select temp_join
    sel.Delete                                                      'Delete Selection
    
End Sub

    

    
