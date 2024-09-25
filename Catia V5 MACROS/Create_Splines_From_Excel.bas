Attribute VB_Name = "Create_Splines_From_Excel"
Option Explicit

    '----------------------------------------------------------------
    '   Macro: Create_Splines_From_Excel.bas
    '   Version: 1.0
    '   Code: CATIA VBA
    '   Release:   V5R32
    '   Purpose: Macro to import points into and create splines CATIA
    '   Author: Kai-Uwe Rathjen
    '   Date: 25.09.24
    '----------------------------------------------------------------
    '
    '   Change:
    '
    '
    '----------------------------------------------------------------
    
Sub CATMain()
    CATIA.StatusBar = "Create_Splines_From_Excel.bas, Version 1.0"          'Update Status Bar text
    
    'On Error Resume Next
    
    '----------------------------------------------------------------
    'Defenitions
    '----------------------------------------------------------------
    Const GEOSETNAME = "Spline_Import"                                      'Name of geo set
    Const msoFileDialogOpen = 1                                             'Open File
    
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
    
    Dim dPathExcel As String                                                'Path to excel file
    Dim oExcel As Object                                                    'Excel object
    Dim oWorkbooks As Object                                                'Collection of workbooks
    Dim oWorkbook As Object                                                 'Open workbook
    Dim oSheet As Object                                                    'Open sheet
    
    Dim geoSet As HybridBody                                                'Current geometric set
    Dim Wzk3D As CATBaseDispatch                                            'HybridShapeFactoy
    Dim point As HybridShapePointCoord                                      'New point by coordinate
    Dim pointRef As Reference                                               'Reference to point
    Dim newSpline As HybridShapeSpline                                      'New spline created
    
    Dim xCoord As Double                                                    'X coord
    Dim yCoord As Double                                                    'Y coord
    Dim zCoord As Double                                                    'Z coord
    
    Dim row As Integer                                                      'Row count
    
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
    ' Get location for excel file
    '----------------------------------------------------------------
    dPathExcel = ""                                                         'Initilise path
        
    '----------------------------------------------------------------
    ' Open Brows file prompt
    '----------------------------------------------------------------
    Set oExcel = CreateObject("Excel.Application")                          'New Excel window
    
    With oExcel.Application.FileDialog(msoFileDialogOpen)                   'File dialog window
        .AllowMultiSelect = False
        .Show
 
        If .SelectedItems.count < 1 Then
            Error = MsgBox("Nothing selected", vbCritical)
            Exit Sub
        End If
        dPathExcel = .SelectedItems(1)                                      'Save path
    End With

    Set oWorkbooks = oExcel.workbooks.Open(dPathExcel, ReadOnly:=True)      'Open excel file
    Set oWorkbook = oExcel.workbooks.Item(1)                                'Current Workbook
    Set oSheet = oWorkbook.Sheets.Item(1)                                   'Get first sheet
    oSheet.Activate
    
    '----------------------------------------------------------------
    ' Create new set to create points
    '----------------------------------------------------------------
    Set geoSet = oPart.HybridBodies.Add                                     'Add set for result
    geoSet.Name = GEOSETNAME                                                'Rename result set
    
    Set Wzk3D = oPart.HybridShapeFactory                                    'Anchor hybridshapefactory for use
    Set newSpline = Wzk3D.AddNewSpline                                      'Add new Spline
    
    newSpline.SetSplineType (0)                                             'Cubic spline (0) or WilsonFowler (1)
    newSpline.SetClosing (0)                                                'Not closed
    
    '----------------------------------------------------------------
    ' Cycle excel sheet and add new point
    '----------------------------------------------------------------
    row = 1                                                                 'First row
    While oSheet.cells(row, 1) <> ""
        If IsNumeric(oSheet.cells(row, 1)) Then                             'If number save coord
            xCoord = oSheet.cells(row, 1)
        Else
            GoTo endLoop                                                    'Else skip row
        End If
        If IsNumeric(oSheet.cells(row, 2)) Then                             'If number save coord
            yCoord = oSheet.cells(row, 2)
        Else
            GoTo endLoop                                                    'Else skip row
        End If
        If IsNumeric(oSheet.cells(row, 3)) Then                             'If number save coord
            yCoord = oSheet.cells(row, 3)
        Else
            GoTo endLoop                                                    'Else skip row
        End If
        
        Set point = Wzk3D.AddNewPointCoord(xCoord, yCoord, zCoord)          'Create new point
        geoSet.AppendHybridShape point                                      'Add new point to set
         
        If oSheet.cells(row, 4) <> "" Then                                  'If name exists
            geoSet.HybridShapes.Item(geoSet.HybridShapes.count).Name _
            = oSheet.cells(row, 4)                                          'Rename point
        End If

        Set pointRef = oPart.CreateReferenceFromObject(point)
        newSpline.AddPointWithConstraintExplicit pointRef, Nothing, -1#, 1, Nothing, 0#
        
endLoop:
        row = row + 1                                                       'Increment row count
    Wend
    
    geoSet.AppendHybridShape newSpline
    
    oPart.Update                                                            'Update part
    
    oWorkbooks.Close                                                        'Close excel

End Sub


