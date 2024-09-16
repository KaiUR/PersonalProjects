Attribute VB_Name = "Create_igs_ringline"
Option Explicit

    '----------------------------------------------------------------
    '   Macro: Create_igs_ringline.bas
    '   Version: 1.0
    '   Code: CATIA VBA
    '   Release:   V5R32
    '   Purpose: Macro to allow user to select a number of ringlines(Curves)
    '           and an axis system. The macro will then copy these to a new part.
    '           The curves will then be transformed to the absolute axis of the part.
    '           Then the ringlines including a single axis system will be saved as
    '           an Iges file.
    '           Output files will be over ritten if they already exist
    '   Author: Kai-Uwe Rathjen
    '   Date: 11.09.24
    '----------------------------------------------------------------
    '
    '   Change:
    '
    '
    '----------------------------------------------------------------
    
Sub CATMain()
    CATIA.StatusBar = "Create_igs_ringline.bas, Version 1.0"    'Update Status Bar text

    'On Error Resume Next

    '----------------------------------------------------------------
    'Declarations
    '----------------------------------------------------------------
    Dim PartDocumentCurrent As Document                 'Current Open Document
    Dim PartDocumentNew As Document                     'New Document
    Dim partCurrent As Part                             'Current Open part
    Dim partNew As Part                                 'New Open Part
    Dim sel As CATBaseDispatch                          'Selection to store user input
    Dim selNew As Selection                             'Seletion for new part
    Dim InputObjectType(0) As Variant                   'iFilter for user input
    Dim Status As String                                'Status of User Selection
    
    Dim ringLines() As CATBaseDispatch                  'Array for ringline cure objects
    Dim axisSystemName As String                        'Name of selected axis system
    Dim rCount As Integer                               'Number of Selected Ringlines
    
    Dim Index As Integer                                'Index for for loops
 
    Dim HBody As HybridBody                             'Varible to store current geometric set
    
    Dim Wzk3D As CATBaseDispatch                        'HybridShapeFactory
    Dim AS1 As axisSystem                               'Source Axis
    Dim AS2 As axisSystem                               'Destination Axis
    Dim RefAS1 As Reference                             'Source Axis Reference
    Dim RefAS2 As Reference                             'Destination axis Reference
    Dim RefRing() As Reference                          'Ring Line Refernces
    Dim Transformations() As HybridShapeAxisToAxis      'New AxisToAxis Objects
    
    Dim hybridBodies1 As HybridBodies                   'All geometric sets of new part
    Dim hybridBodyNew As HybridBody                     'New Geometric Set
    Dim rootPath As String                              'Path of current document

    Dim Error As Integer
    Dim PPRDocumentCurrent As PPRDocument                'PPR Document
    
    '----------------------------------------------------------------
    'Open Current Document
    '----------------------------------------------------------------
    Set PartDocumentCurrent = CATIA.ActiveDocument                  'Current Open Document Anchor

    'If cat product is open, get first part, if no part exit macro
    If (Right(PartDocumentCurrent.Name, (Len(PartDocumentCurrent.Name) - InStrRev(PartDocumentCurrent.Name, "."))) = "CATProduct") Then
        If (PartDocumentCurrent.Product.Products.Count < 1) Then
            Error = MsgBox("No Parts found" & vbNewLine & "Please Open a .CATPart to use this script or Open part in new window", vbCritical)
            Exit Sub
        End If
        Set partCurrent = PartDocumentCurrent.Product.Products.Item(1).ReferenceProduct.Parent.Part
    'If cat process is open, get first part, if no part exit macro
    ElseIf (Right(PartDocumentCurrent.Name, (Len(PartDocumentCurrent.Name) - InStrRev(PartDocumentCurrent.Name, "."))) = "CATProcess") Then
        Set PPRDocumentCurrent = PartDocumentCurrent.PPRDocument    'Anchor PPR Document
        If (PPRDocumentCurrent.Products.Count < 1) Then
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
    InputObjectType(0) = "MonoDimInfinite"                      'Set input type to curves
    'Get Input from User, get selections untill user acepts
    Status = sel.SelectElement3(InputObjectType, "Select the ringlines", False, CATMultiSelTriggWhenUserValidatesSelection, False)
    
    If (Status = "Cancel") Then                                 'If User cancels or presses Esc, Exit Macro
        Exit Sub
    End If
    
    ReDim ringLines(sel.Count)                                  'Dynamic allocation acording to user input
    rCount = sel.Count2                                         'The amount of selected items
    For Index = 1 To sel.Count2                                 'Cycle through all inputs
        Set ringLines(Index) = sel.Item2(Index).Value           'Save selections to array
    Next
    sel.Clear                                                   'Clear Selection
    
    InputObjectType(0) = "AxisSystem"                           'Set input type to Axis System
    'Get user selected axis system
    Status = sel.SelectElement2(InputObjectType, "Select the axis system", False)
    
    If (Status = "Cancel") Then                                 'If User cancels or presses Esc, Exit Macro
        Exit Sub
    End If
    
    If (sel.Count2 < 1) Then                                    'If no Selection Exit Macro
        Exit Sub
    End If
    axisSystemName = sel.Item(1).Value.Name                     'Save the name of the axis system
    
    For Index = 1 To rCount                                     'Add previous ringline selection to selection
        sel.Add ringLines(Index)
    Next
    
    '----------------------------------------------------------------
    'Copy to new Part
    '----------------------------------------------------------------
    sel.Copy                                                    'Copy Current selection
    sel.Clear                                                   'Clear Selection

    Set PartDocumentNew = CATIA.Documents.Add("Part")           'Create a new part
    Set partNew = PartDocumentNew.Part                          'New part Anchor
    Set selNew = PartDocumentNew.Selection                      'New Part Selection
    selNew.Search "(NAME=Geometrical Set.1),all"                'Select the geometric set, need to have option to auto create on new part
    
    partNew.Name = partCurrent.Name & "_RINGLINES"                       'Set New Part Name
    
    If selNew.Count2 = 0 Then
        Set hybridBodies1 = partNew.HybridBodies                        'Get geometric set collection for current part
        Set hybridBodyNew = hybridBodies1.Add()                         'Add new Geometric set
        hybridBodyNew.Name = "Geometrical Set.1"                         'Rename New Set
    End If
    
    
    Set HBody = selNew.Item(1).Value                            'Set Current geometric set
    
    selNew.PasteSpecial ("CATPrtResultWithOutLink")             'Paste all as result without link
    selNew.Clear                                                'Clear Selection

    '----------------------------------------------------------------
    'Axis To Axis
    '----------------------------------------------------------------
    Set Wzk3D = partNew.HybridShapeFactory                          'Anchor HybridShapeFactory for use
    
    Set AS1 = partNew.AxisSystems.Item(axisSystemName)              'Set AS1 to Source axis
    Set AS2 = partNew.AxisSystems.Item("Absolute Axis System")      'Set AS2 to Destination axis
    
    ReDim RefRing(rCount)                                           'Dynamicly allocate array
    
    selNew.Search "(CATGmoSearch.Curve),all"                        'Select all curves
        
    For Index = 1 To rCount                                         'Cycle through selection and create references
        Set RefRing(Index) = partNew.CreateReferenceFromObject(selNew.Item(Index).Value)
    Next
    
    Set RefAS1 = partNew.CreateReferenceFromObject(AS1)             'Create ref for axis 1
    Set RefAS2 = partNew.CreateReferenceFromObject(AS2)             'Create ref for axis 2
    
    ReDim Transformations(rCount)                                   'Dynamicly allocate array
    
    For Index = 1 To rCount                                         'Cycle through all objects
        Set Transformations(Index) = Wzk3D.AddNewAxisToAxis(RefRing(Index), RefAS1, RefAS2)     'Create Axis to axis transformation
        HBody.AppendHybridShape Transformations(Index)              'Add Axis to axis transformation to set
    Next
    
    partNew.Update                                                  'Update part
    
    '----------------------------------------------------------------
    'Create Datum
    '----------------------------------------------------------------
    selNew.Clear                                                    'Clear selection
    selNew.Search "(Name =*Axis to axis transformation*),all"       'Select all transformations
    selNew.Copy                                                     'Copy Selection
    selNew.Clear                                                    'Clear Selection
    
    Set hybridBodies1 = partNew.HybridBodies                        'Get geometric set collection for current part
    
    Set hybridBodyNew = hybridBodies1.Add()                         'Add new Geometric set
    hybridBodyNew.Name = "Geometrical Set.2"                         'Rename New Set
    
    selNew.Search "(NAME=Geometrical Set.2),all"                    'Select the new set
    selNew.PasteSpecial ("CATPrtResultWithOutLink")                 'Paste from clipboard as result without links
    selNew.Clear                                                    'Clear selection
    
    partNew.Update                                                  'Update part
    
    '----------------------------------------------------------------
    'Delete not needed curves and axis system
    '----------------------------------------------------------------
    selNew.Search "(NAME=Geometrical Set.1),all"                    'Select original geometric set
    selNew.Delete                                                   'Delete geometric set
    selNew.Clear                                                    'Clear selection
    
    hybridBodyNew.Name = "RingLines"                                'Rename New Geometric set
    
    selNew.Search "(Name=*Die*),all"                                'Select axis systme that was imported, "Die is always part of name"

    If selNew.Count <> 0 Then                                       'Check if axis exists
        selNew.Delete                                               'Delete Axis
        selNew.Clear                                                'Clear Selection
    End If
    
    '----------------------------------------------------------------
    ' Disable user prompts and confirmantions
    '----------------------------------------------------------------
    CATIA.RefreshDisplay = False
    CATIA.DisplayFileAlerts = False
    
    '----------------------------------------------------------------
    'Save File Prompt
    '----------------------------------------------------------------
    rootPath = PartDocumentCurrent.path                                'Get path of original part
    
    PartDocumentNew.ExportData rootPath & "\" & partCurrent.Name & "_Ringline", "igs"       'Export to iges
    
    PartDocumentNew.Close                                               'Close new part
    
    '----------------------------------------------------------------
    ' Turn on user alerts and prompts again
    '----------------------------------------------------------------
    CATIA.RefreshDisplay = True
    CATIA.DisplayFileAlerts = True
    
End Sub
