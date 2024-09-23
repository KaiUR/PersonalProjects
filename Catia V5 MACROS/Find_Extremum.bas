Attribute VB_Name = "Find_Extremum"
Option Explicit

    '----------------------------------------------------------------
    '   Macro: Find_Extremum.bas
    '   Version: 1.0
    '   Code: CATIA VBA
    '   Release:   V5R32
    '   Purpose: Macro to fin extremities
    '   Author: Kai-Uwe Rathjen
    '   Date: 23.09.24
    '----------------------------------------------------------------
    '
    '   Change:
    '
    '
    '----------------------------------------------------------------
    
Public Type iPct
    X As Double
    Y As Double
    Z As Double
End Type

Sub CATMain()
    CATIA.StatusBar = "Find_Extremum.bas, Version 1.0"              'Update Status Bar text
    
    'On Error Resume Next
    
    '----------------------------------------------------------------
    'Defenitions
    '----------------------------------------------------------------
    Const GEOSETNAME = "Extremum_Points"                                    'Name of geo set
    Const GSMMax = 1
    Const GSMMin = 0
    
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
    Dim Wzk3D As CATBaseDispatch                                            'HybridShapeFactoy
    Dim point As HybridShapePointCoord                                      'New point by coordinate
    
    Dim InputObjectType(0) As Variant                                       'iFilter for user input
    Dim Status As String                                                    'Status of User selectin
    
    Dim curvesSelect() As AnyObject                                         'Array of curves selected
    Dim curveCount As Integer                                               'Numbe rof curve selected
    Dim directionSelect As Reference                                        'Selected direction
    
    Dim pointEx As HybridShapeExtremum                                      'Extremum Point
    Dim refCurve As Reference                                               'Reference Curve
    Dim sDirection As HybridShapeDirection                                  'Direction
    
    
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
    InputObjectType(0) = "MonoDimInfinite"                          'Set input type to curves
    'Get Input from User, get selections untill user acepts
    '
    '   Get curves
    '
    Status = sel.SelectElement3(InputObjectType, "Select curves", False, CATMultiSelTriggWhenUserValidatesSelection, False)
    
    If (Status = "Cancel") Then                                     'If User cancels or presses Esc, Exit Macro
        Exit Sub
    End If
    
    If sel.Count2 = 0 Then                                          'If no selection, exit
        Exit Sub
    End If
    
    curveCount = sel.Count2
    ReDim curvesSelect(curveCount)
    For Index = 1 To curveCount
        Set curvesSelect(Index) = sel.Item2(Index).Value
    Next Index
    sel.Clear
    
    '----------------------------------------------------------------
    'Make Selection
    '----------------------------------------------------------------
    InputObjectType(0) = "AnyObject"                          'Set input type to curves
    'Get Input from User, get selections untill user acepts
    '
    '   Get direction
    '
    Status = sel.SelectElement3(InputObjectType, "Select diretcion", False, CATMultiSelTriggWhenUserValidatesSelection, False)
    
    If (Status = "Cancel") Then                                     'If User cancels or presses Esc, Exit Macro
        Exit Sub
    End If
    
    If sel.Count2 = 0 Then                                          'If no selection, exit
        Exit Sub
    End If
    
    Set directionSelect = sel.Item2(1).Reference
    
    '----------------------------------------------------------------
    ' Create new set to create points
    '----------------------------------------------------------------
    Set geoSet = oPart.HybridBodies.Add                                     'Add set for result
    geoSet.Name = GEOSETNAME                                                'Rename result set
    
    Set Wzk3D = oPart.HybridShapeFactory                                    'Anchor hybridshapefactory for use
    
    '----------------------------------------------------------------
    ' Cycle through selection and crete points
    '----------------------------------------------------------------
    Set sDirection = Wzk3D.AddNewDirection(directionSelect)
    
    For Index = 1 To curveCount
        Set refCurve = oPart.CreateReferenceFromObject(curvesSelect(Index))
        
        Set pointEx = Wzk3D.AddNewExtremum(refCurve, sDirection, GSMMax)
        geoSet.AppendHybridShape pointEx
        
        Set pointEx = Wzk3D.AddNewExtremum(refCurve, sDirection, GSMMin)
        geoSet.AppendHybridShape pointEx
    Next Index
    
    oPart.Update                                                            'Update part

End Sub
