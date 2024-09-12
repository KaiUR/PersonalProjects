Attribute VB_Name = "Create_ISM_OSM_STP"
Option Explicit

    '----------------------------------------------------------------
    '   Macro: Create_ISM_OSM_STP.bas
    '   Version: 1.0
    '   Code: CATIA VBA
    '   Purpose: Macro to extract ISM and OSM srfaces and save them as stp files
    '           Output files will be over ritten if they already exist
    '   Author: Kai-Uwe Rathjen
    '   Date: 12.09.24
    '----------------------------------------------------------------
    '
    '   Change:
    '
    '
    '----------------------------------------------------------------
    
Sub CATMain()
    CATIA.StatusBar = "Create_ISM_OSM_STP.bas, Version 1.0"    'Update Status Bar text
    
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
    Dim Status As String                                'Status of User selectin
    
    Dim Index As Integer                                'Index for loops
    
    Dim hybridBodiesCurrent As HybridBodies              'Collectin o top level geomet
    Dim hybridBodyNew As HybridBody                     'New geometric set
    
    Dim ISMExtract As HybridShapeExtract                'Extract for ISM
    Dim OSMExtract As HybridShapeExtract                'Extract for OSM
    Dim RefISM As Reference                             'ISM Reference
    Dim RefOSM As Reference                             'OSM Reference
    Dim Wzk3D As CATBaseDispatch                        'hybridshapefactory anchor
    
    Dim hybridBodySelect As HybridBody                  'Selected Geometric set
    
    Dim rootPath As String                              'Path of current document
    Dim rootName As String                               'Name Of original Partfile
    
    '----------------------------------------------------------------
    'Open Current Document
    '----------------------------------------------------------------
    Set PartDocumentCurrent = CATIA.ActiveDocument      'Current Open Document Anchor

    If (Right(PartDocumentCurrent.Name, (Len(PartDocumentCurrent.Name) - InStrRev(PartDocumentCurrent.Name, "."))) = "CATProduct") Then
        Dim Error As Integer
        Error = MsgBox("This Script only works with .CATPart Files" & vbNewLine & "Please Open a .CATPart to use this script or Open part in new window", vbCritical)
        Exit Sub
    End If

    Set partCurrent = PartDocumentCurrent.Part          'Current Open Part Anchor
    rootPath = PartDocumentCurrent.path                  'Get path of original part
    rootName = PartDocumentCurrent.Name                  'Get Name of Part
    rootName = Left(rootName, Len(rootName) - Len(".CATPart"))  'Remove file extention

    Set sel = PartDocumentCurrent.Selection             'Set up user selection
    sel.Clear                                           'Clear Selection
    
    '----------------------------------------------------------------
    'Get User selection
    '----------------------------------------------------------------
    InputObjectType(0) = "Face"                               'Set input type to face
    'Get user selected ISM
    Status = sel.SelectElement2(InputObjectType, "Select Face for ISM", False)
    
    If (Status = "Cancel") Then                                 'If User cancels or presses Esc, Exit Macro
        Exit Sub
    End If
    
    If (sel.Count2 < 1) Then                                    'If no Selection Exit Macro
        Exit Sub
    End If
    Set RefISM = sel.Item(1).Reference                                       'Save object representing ISM
    sel.Clear                                                   'Clear selection
    
    'Get user selected ISM
    Status = sel.SelectElement2(InputObjectType, "Select Face for OSM", False)
    
    If (Status = "Cancel") Then                                 'If User cancels or presses Esc, Exit Macro
        Exit Sub
    End If
    
    If (sel.Count2 < 1) Then                                    'If no Selection Exit Macro
        Exit Sub
    End If
    Set RefOSM = sel.Item(1).Reference                                       'Save object representing OSM
    sel.Clear
    
    '----------------------------------------------------------------
    'Create New Geo Set
    '----------------------------------------------------------------
    Set hybridBodiesCurrent = partCurrent.HybridBodies              'Get geometric set collection for current part
    Set hybridBodyNew = hybridBodiesCurrent.Add()                         'Add new Geometric set
    
    hybridBodyNew.Name = "OSM_ISM_SURFACES"                         'Rename new Geometric set
    partCurrent.InWorkObject = hybridBodyNew                        'Make new geo set in work object
    
    '----------------------------------------------------------------
    'Create Extracts
    '----------------------------------------------------------------
    Set Wzk3D = partCurrent.HybridShapeFactory                           'Anchor hybridshapefactory for use
    
    Set ISMExtract = Wzk3D.AddNewExtract(RefISM)                        'Create Extract
    Set OSMExtract = Wzk3D.AddNewExtract(RefOSM)                        'Create Extract
    
    ISMExtract.PropagationType = 2                                      'Set Propagation type to tangent
    OSMExtract.PropagationType = 2                                      'Set Propagation type to tangent
    
    ISMExtract.ComplementaryExtract = False                             'Set Comp extract to false
    OSMExtract.ComplementaryExtract = False                             'Set Comp extract to false
    
    ISMExtract.IsFederated = False                                      'Set federated to false
    OSMExtract.IsFederated = False                                      'Set federated to false
    
    hybridBodyNew.AppendHybridShape ISMExtract                        'Add ISM Extract to geo set
    hybridBodyNew.AppendHybridShape OSMExtract                        'Add ISM Extract to geo set
    
    hybridBodyNew.HybridShapes.Item(1).Name = "ISM_Extract"             'Rename extract for ISM
    hybridBodyNew.HybridShapes.Item(2).Name = "OSM_Extract"             'Rename Extract for OSM
    
    partCurrent.Update                                                  'Update Part
    
    '----------------------------------------------------------------
    'Create Datum
    '----------------------------------------------------------------
    sel.Search "(Name =ISM_Extract+ Name =OSM_Extract),all"             'Select the extracts

    sel.Copy                                                              'Copy Selection
    sel.Clear                                                              'Clear selection
    
    sel.Search "(NAME =OSM_ISM_SURFACES), All"                               'Select Geo Set
    sel.PasteSpecial ("CATPrtResultWithOutLink")                         'Paste from clipboard as result without links
    
    sel.Clear                                                           'Clear Selection
    
    hybridBodyNew.HybridShapes.Item(3).Name = "ISM"                             'Rename ISM Datum
    hybridBodyNew.HybridShapes.Item(4).Name = "OSM"                             'Rename OSM Datum
    
    sel.Search "(Name =ISM_Extract+ Name =OSM_Extract),all"             'Select the extracts
    sel.Delete                                                          'Delete Extracts
    
    sel.Search "(NAME =ISM),all"                                        'Select ISM
    sel.Copy                                                            'Copy Selection
    sel.Clear                                                           'Clear Selection
    
    '----------------------------------------------------------------
    ' Disable user prompts and confirmantions
    '----------------------------------------------------------------
    CATIA.RefreshDisplay = False
    CATIA.DisplayFileAlerts = False
    
    '----------------------------------------------------------------
    'Create new file for ISM
    '----------------------------------------------------------------
    Set PartDocumentNew = CATIA.Documents.Add("Part")                       'Create new part
    Set partNew = PartDocumentNew.Part                                      'Anchor Part
    
    Set selNew = PartDocumentNew.Selection                                  'Anchor Selection
    selNew.Search "(NAME =Geometrical Set.1)"                               'Select auto created geo set
    
    Set hybridBodySelect = selNew.Item2(1).Value                                      'Anchor feo set
    hybridBodySelect.Name = "ISM_SURFACE"                                   'Rename Geometric Set
    
    selNew.PasteSpecial ("CATPrtResultWithOutLink")                          'Paste ISM
    selNew.Clear                                                            'Clear Selection
    
    'PartDocumentNew.SaveAs rootPath & "\" & rootName & "_ISM" & ".stp"     'Save new part
    PartDocumentNew.ExportData rootPath & "\" & rootName & "_ISM", "stp"    'Export to step
    
    PartDocumentNew.Close                                               'Close new part
    
    '----------------------------------------------------------------
    'Create new file for OSM
    '----------------------------------------------------------------
    sel.Search "(NAME =OSM),all"                                        'Select OSM
    sel.Copy                                                            'Copy Selection
    sel.Clear                                                           'Clear Selection
    
    Set PartDocumentNew = CATIA.Documents.Add("Part")                       'Create new part
    Set partNew = PartDocumentNew.Part                                      'Anchor Part
    
    Set selNew = PartDocumentNew.Selection                                  'Anchor Selection
    selNew.Search "(NAME =Geometrical Set.1)"                               'Select auto created geo set
    
    Set hybridBodySelect = selNew.Item2(1).Value                                      'Anchor feo set
    hybridBodySelect.Name = "OSM_SURFACE"                                   'Rename Geometric Set
    
    selNew.PasteSpecial ("CATPrtResultWithOutLink")                          'Paste OSM
    selNew.Clear                                                            'Clear Selection
    
    'PartDocumentNew.SaveAs rootPath & "\" & rootName & "_OSM" & ".CATPart"     'Save new part
    PartDocumentNew.ExportData rootPath & "\" & rootName & "_OSM", "stp"    'Export to step
    
    PartDocumentNew.Close                                               'Close new part
    
    '----------------------------------------------------------------
    'Delete Constuction
    '----------------------------------------------------------------
    sel.Search "(NAME =OSM_ISM_SURFACES),all"                           'Select geo set
    sel.Delete                                                          'Delete Geo Set
    
    '----------------------------------------------------------------
    ' Turn on user alerts and prompts again
    '----------------------------------------------------------------
    CATIA.RefreshDisplay = True
    CATIA.DisplayFileAlerts = True
    
End Sub
