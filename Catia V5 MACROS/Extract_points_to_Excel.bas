
Sub CATMain()
    '----------------------------------------------------------------
    '   Macro: Extract_points_to_Excel.bas
    '   Version: 1.0
    '   Code: CATIA VBA
    '   Release:   V5R32
    '   Purpose: This macro is used for *** parts to fetch the points out
    '       of the measurable points geometric set and put them into an excel file.
    '       The normals and trim normals are also calculated.
    '       All measurements and tolerances need to be filled in manually. Zeors will be
    '       placed where they need to be entred.
    '       All zeros for coordinates or normals can indicate an error, try isolating the points, lines
    '       an curves. This script will always work on explicit elements(Isolated). Also check that the
    '       corresponding components exist.
    '   Author: Kai-Uwe Rathjen
    '   Date: 18.06.24
    '----------------------------------------------------------------
    '
    '   Change:
    '
    '
    '----------------------------------------------------------------
    CATIA.StatusBar = "Extract_points_to_Excel.bas, Version 1.0"    'Update Status Bar text

    'Skip errors
    '---------------------------------------------------------------
    On Error Resume Next

    '----------------------------------------------------------------
    'Open Current CATIA Document
    '---------------------------------------------------------------
    Dim OpenDocument As Document
    Set OpenDocument = CATIA.ActiveDocument
    
    Dim pt As Part
    Set pt = OpenDocument.Part
    
    '----------------------------------------------------------------
    'Open Excel Document
    '----------------------------------------------------------------
    Set objexcel = CreateObject("Excel.Application")
    objexcel.Visible = True
    Set objWorkbook = objexcel.workbooks.Add()
    Set objsheet1 = objWorkbook.Sheets.Item(1)
    objsheet1.Name = "Points_Coordinates"
        
    '----------------------------------------------------------------
    'Create Headings for Excel Sheet
    '----------------------------------------------------------------
    objsheet1.Cells(1, 1) = "Identifier"
    objsheet1.Cells(1, 2) = "type"
    objsheet1.Cells(1, 3) = "Name"
    objsheet1.Cells(1, 4) = "Point Level"
    objsheet1.Cells(1, 5) = "coord-x"
    objsheet1.Cells(1, 6) = "coord-y"
    objsheet1.Cells(1, 7) = "coord-z"
    objsheet1.Cells(1, 8) = "normal-x"
    objsheet1.Cells(1, 9) = "normal-y"
    objsheet1.Cells(1, 10) = "normal-z"
    objsheet1.Cells(1, 11) = "trimming-x"
    objsheet1.Cells(1, 12) = "trimming-y"
    objsheet1.Cells(1, 13) = "trimming-z"
    objsheet1.Cells(1, 14) = "dir-x"
    objsheet1.Cells(1, 15) = "dir-y"
    objsheet1.Cells(1, 16) = "dir-z"
    objsheet1.Cells(1, 17) = "length"
    objsheet1.Cells(1, 18) = "width"
    objsheet1.Cells(1, 19) = "radius"
    objsheet1.Cells(1, 20) = "tol-x-lower"
    objsheet1.Cells(1, 21) = "tol-x-upper"
    objsheet1.Cells(1, 22) = "tol-y-lower"
    objsheet1.Cells(1, 23) = "tol-y-upper"
    objsheet1.Cells(1, 24) = "tol-z-lower"
    objsheet1.Cells(1, 25) = "tol-z-upper"
    objsheet1.Cells(1, 26) = "tol-normal-lower"
    objsheet1.Cells(1, 27) = "tol-normal-upper"
    objsheet1.Cells(1, 28) = "tol-trim-lower"
    objsheet1.Cells(1, 29) = "tol-trim-upper"
    objsheet1.Cells(1, 30) = "tol-length-lower"
    objsheet1.Cells(1, 31) = "tol-length-upper"
    objsheet1.Cells(1, 32) = "tol-width-lower"
    objsheet1.Cells(1, 33) = "tol-width-upper"
    objsheet1.Cells(1, 34) = "tol-diameter-lower"
    objsheet1.Cells(1, 35) = "tol-diameter-upper"
    
    '----------------------------------------------------------------
    'Walk tree
    '----------------------------------------------------------------
    Set SetList = pt.HybridBodies
    ListCount = SetList.count
    
    OpenDocument.Selection.search "(CATGmoSearch.Line + CATGmoSearch.Curve),all"
    
    For SetListIndex = 1 To ListCount
    
        Set currentSet = SetList.Item(SetListIndex)
        Dim ActiveName As String
        ActiveName = currentSet.Name
    
        '----------------------------------------------------------------
        'Find Measuring Points
        '----------------------------------------------------------------
        If StrComp(ActiveName, "Measuring Points", vbTextCompare) = 0 Then
            
            Set Lvl2Points = currentSet.HybridBodies
            Lvl2PointsCount = Lvl2Points.count
            
            rowCount = 2
            
                '----------------------------------------------------------------
                'Cycle through Measuring points
                '----------------------------------------------------------------
                For Lvl2PointsIndex = 1 To Lvl2PointsCount
                        
                    Set currentPointSet = Lvl2Points.Item(Lvl2PointsIndex)
                    Dim ActivePointSetName As String
                    ActivePointSetName = currentPointSet.Name
                               
                    '----------------------------------------------------------------
                    'Find Lvl  Points
                    '----------------------------------------------------------------
                    If InStr(1, ActivePointSetName, "LEVEL", vbTextCompare) > 0 Then
                        
                        Set workingSet = currentPointSet.HybridBodies
                        workingCount = workingSet.count
                        
                        For Index = 1 To workingCount
                            Set current = workingSet.Item(Index)
                            Dim workingName As String
                            workingName = current.Name
                        
                            
                            Set PointsSetsToMeasure = current.HybridShapes
                            pointsSetsToMeasureCount = PointsSetsToMeasure.count
                            
                            '----------------------------------------------------------------
                            'Cycle through all points
                            '----------------------------------------------------------------
                            For ToMeasureIndex = 1 To pointsSetsToMeasureCount
                                Set PointsSetsToMeasureSet = PointsSetsToMeasure.Item(ToMeasureIndex)
                                Dim ToMeasureName As String
                                ToMeasureName = PointsSetsToMeasureSet.Name
                                '----------------------------------------------------------------
                                'Make Sure is point
                                '----------------------------------------------------------------
                                If InStr(1, ToMeasureName, "Vector", vbTextCompare) > 0 Then
                                    GoTo SkipVector
                                End If
                                
                                '----------------------------------------------------------------
                                'Name
                                '----------------------------------------------------------------
                                objsheet1.Cells(rowCount, 3) = ToMeasureName
                                
                                '----------------------------------------------------------------
                                'Point Level
                                '----------------------------------------------------------------
                                If InStr(1, ActivePointSetName, "Level 1", vbTextCompare) <> 0 Then
                                    objsheet1.Cells(rowCount, 4) = "L1"
                                ElseIf InStr(1, ActivePointSetName, "Level 2", vbTextCompare) <> 0 Then
                                    objsheet1.Cells(rowCount, 4) = "L2"
                                ElseIf InStr(1, ActivePointSetName, "Level 3", vbTextCompare) <> 0 Then
                                    If InStr(1, workingName, "OP", vbTextCompare) <> 0 Then
                                        objsheet1.Cells(rowCount, 4) = "L3_" & workingName
                                    Else
                                        objsheet1.Cells(rowCount, 4) = "L3"
                                    End If
                                    
                                    If InStr(1, PointsSetsToMeasure.Item(ToMeasureIndex + 1).Name, "trimming", vbTextCompare) > 0 Then
                                        workingName = workingName & "trim"
                                    End If
                                ElseIf InStr(1, ActivePointSetName, "Level 4", vbTextCompare) <> 0 Then
                                    If InStr(1, workingName, "OP", vbTextCompare) <> 0 Then
                                        objsheet1.Cells(rowCount, 4) = "L4_" & workingName
                                    Else
                                        objsheet1.Cells(rowCount, 4) = "L4"
                                    End If
                                    
                                    If InStr(1, PointsSetsToMeasure.Item(ToMeasureIndex + 1).Name, "trimming", vbTextCompare) > 0 Then
                                        workingName = workingName & "trim"
                                    End If
                                Else
                                    objsheet1.Cells(rowCount, 4) = ActivePointSetName
                                End If
                                  
                                '----------------------------------------------------------------
                                'Identifiers
                                '----------------------------------------------------------------
                                If InStr(1, workingName, "hole", vbTextCompare) <> 0 Then
                                    objsheet1.Cells(rowCount, 1) = "HOL"
                                ElseIf InStr(1, workingName, "slot", vbTextCompare) <> 0 Then
                                    objsheet1.Cells(rowCount, 1) = "SLO"
                                ElseIf InStr(1, workingName, "trim", vbTextCompare) <> 0 Then
                                    objsheet1.Cells(rowCount, 1) = "EDG"
                                ElseIf InStr(1, workingName, "mating", vbTextCompare) <> 0 Then
                                    objsheet1.Cells(rowCount, 1) = "MAT"
                                Else
                                    objsheet1.Cells(rowCount, 1) = workingName
                                End If
        
                                If InStr(1, ToMeasureName, "NMT", vbTextCompare) <> 0 Then
                                    objsheet1.Cells(rowCount, 1) = "NON"
                                End If
                                
                                '----------------------------------------------------------------
                                'Type
                                '----------------------------------------------------------------
                                
                                If InStr(1, workingName, "hole", vbTextCompare) <> 0 Then
                                    objsheet1.Cells(rowCount, 2) = "inspection_circle"
                                ElseIf InStr(1, workingName, "slot", vbTextCompare) <> 0 Then
                                    objsheet1.Cells(rowCount, 2) = "inspection_circle"
                                ElseIf InStr(1, workingName, "trim", vbTextCompare) <> 0 Then
                                    objsheet1.Cells(rowCount, 2) = "inspection_edge_point"
                                ElseIf InStr(1, workingName, "mating", vbTextCompare) <> 0 Then
                                    objsheet1.Cells(rowCount, 2) = "inspection_surface_point"
                                Else
                                    objsheet1.Cells(rowCount, 2) = workingName
                                End If
                                                                
                                '----------------------------------------------------------------
                                'Get Coords
                                '----------------------------------------------------------------
                                ReDim coords(2)
                                
                                coords = Array(0, 0, 0)
                                
                                Set sel = OpenDocument.Selection

                                If StrComp(PointsSetsToMeasureSet.Type, "HybridShape") = 0 Then
                                    sel.Clear
                                    Set geo = pt.HybridBodies.Add()
                                    sel.Add PointsSetsToMeasureSet
                                    sel.Copy
                                    sel.Clear
                                    sel.Add geo
                                    sel.PasteSpecial ("CATPrtResultWithOutLink")
                                    sel.Clear
                                    
                                    geo.HybridShapes.Item(1).GetCoordinates (coords)
                                    sel.Add geo
                                    sel.Delete
                                
                                    OpenDocument.Selection.search "(CATGmoSearch.Line + CATGmoSearch.Curve),all"
                                Else
                                    PointsSetsToMeasureSet.GetCoordinates (coords)
                                End If
   
                                objsheet1.Cells(rowCount, 5) = Round(coords(0), 3)
                                objsheet1.Cells(rowCount, 6) = Round(coords(1), 3)
                                objsheet1.Cells(rowCount, 7) = Round(coords(2), 3)
                                
                                '----------------------------------------------------------------
                                'Get Normals
                                '----------------------------------------------------------------
                                ReDim normalCoords(2)
                                normalCoords = Array(0, 0, 0)
                                
                                For i = 1 To OpenDocument.Selection.count
    
                                    Set Selection = OpenDocument.Selection
                                    Set Element = Selection.Item(i)
                                    Set Line = Element.Value
                                    
                                    If StrComp(Line.Name, ToMeasureName & "_VECTOR", vbTextCompare) = 0 Then
                                        'Line.GetDirection (normalCoords)
                                        sel.Clear
                                        Set geo = pt.HybridBodies.Add()
                                        sel.Add Line
                                        sel.Copy
                                        sel.Clear
                                        sel.Add geo
                                        sel.PasteSpecial ("CATPrtResultWithOutLink")
                                        sel.Clear
                                        
                                        geo.HybridShapes.Item(1).GetDirection (normalCoords)
                                        sel.Add geo
                                        sel.Delete
                                    
                                        OpenDocument.Selection.search "(CATGmoSearch.Line + CATGmoSearch.Curve),all"
                                        
                                        GoTo EndNormal
                                    End If
                                Next
EndNormal:
                                objsheet1.Cells(rowCount, 8) = Round(normalCoords(0), 3)
                                objsheet1.Cells(rowCount, 9) = Round(normalCoords(1), 3)
                                objsheet1.Cells(rowCount, 10) = Round(normalCoords(2), 3)
  
                                '----------------------------------------------------------------
                                'Get Trimmings
                                '----------------------------------------------------------------
                                If InStr(1, workingName, "trim", vbTextCompare) <> 0 Then
                                
                                    ReDim trimCoords(2)
                                    trimCoords = Array(0, 0, 0)
                                
                                    For i = 1 To OpenDocument.Selection.count
    
                                        Set Selection = OpenDocument.Selection
                                        Set Element = Selection.Item(i)
                                        Set Line = Element.Value
                                    
                                        If StrComp(Line.Name, ToMeasureName & "_VECTOR_TRIMMING", vbTextCompare) = 0 Then
                                            'Line.GetDirection (trimCoords)
                                            sel.Clear
                                            Set geo = pt.HybridBodies.Add()
                                            sel.Add Line
                                            sel.Copy
                                            sel.Clear
                                            sel.Add geo
                                            sel.PasteSpecial ("CATPrtResultWithOutLink")
                                            sel.Clear
                                            
                                            geo.HybridShapes.Item(1).GetDirection (trimCoords)
                                            sel.Add geo
                                            sel.Delete
                                        
                                            OpenDocument.Selection.search "(CATGmoSearch.Line + CATGmoSearch.Curve),all"
                                            
                                            GoTo EndTrim
                                        End If
                                    Next
EndTrim:
                                    objsheet1.Cells(rowCount, 11) = Round(trimCoords(0), 3)
                                    objsheet1.Cells(rowCount, 12) = Round(trimCoords(1), 3)
                                    objsheet1.Cells(rowCount, 13) = Round(trimCoords(2), 3)
                                End If
                                
                                '----------------------------------------------------------------
                                'Get Dir
                                '
                                '
                                ' Make sure that a line for the direction exists with the name
                                ' and ending with "_DIR"
                                '
                                '----------------------------------------------------------------
                                 If InStr(1, workingName, "slot", vbTextCompare) <> 0 Then
                                
                                    ReDim slotCoords(2)
                                    slotCoords = Array(0, 0, 0)
                                
                                    For i = 1 To OpenDocument.Selection.count
    
                                        Set Selection = OpenDocument.Selection
                                        Set Element = Selection.Item(i)
                                        Set Line = Element.Value
                                    
                                        If StrComp(Line.Name, ToMeasureName & "_DIR", vbTextCompare) = 0 Then
                                            'Line.GetDirection (slotCoords)
                                            sel.Clear
                                            Set geo = pt.HybridBodies.Add()
                                            sel.Add Line
                                            sel.Copy
                                            sel.Clear
                                            sel.Add geo
                                            sel.PasteSpecial ("CATPrtResultWithOutLink")
                                            sel.Clear
                                            
                                            geo.HybridShapes.Item(1).GetDirection (slotCoords)
                                            sel.Add geo
                                            sel.Delete
                                        
                                            OpenDocument.Selection.search "(CATGmoSearch.Line + CATGmoSearch.Curve),all"
                                            
                                            GoTo EndSlot
                                        End If
                                    Next
EndSlot:
                                    objsheet1.Cells(rowCount, 14) = slotCoords(0)
                                    objsheet1.Cells(rowCount, 15) = slotCoords(1)
                                    objsheet1.Cells(rowCount, 16) = slotCoords(2)
                                End If
                                
                                '----------------------------------------------------------------
                                'Get Length and Width, sets values to zero for user to fill in
                                '----------------------------------------------------------------
                                 If InStr(1, workingName, "slot", vbTextCompare) <> 0 Then
        
                                    objsheet1.Cells(rowCount, 17) = 0
                                    objsheet1.Cells(rowCount, 18) = 0
                                End If

                                '----------------------------------------------------------------
                                'Get Radius, sets values to zero for user to fill in
                                '----------------------------------------------------------------
                                
                                If InStr(1, workingName, "hole", vbTextCompare) <> 0 Then
                                                       
                                                       
                                    objsheet1.Cells(rowCount, 19) = 0
                                End If
                                
                                '----------------------------------------------------------------
                                'Get Tol Hole/Slot Len/Width Dia, sets values to zero for user to fill in
                                '----------------------------------------------------------------
                                
                                If InStr(1, workingName, "hole", vbTextCompare) <> 0 Then
                                
                                    objsheet1.Cells(rowCount, 20) = 0
                                    objsheet1.Cells(rowCount, 21) = 0
                                    objsheet1.Cells(rowCount, 22) = 0
                                    objsheet1.Cells(rowCount, 23) = 0
                                    objsheet1.Cells(rowCount, 24) = 0
                                    objsheet1.Cells(rowCount, 25) = 0
                                    
                                    objsheet1.Cells(rowCount, 34) = 0
                                    objsheet1.Cells(rowCount, 35) = 0
                                End If
                                
                                If InStr(1, workingName, "slot", vbTextCompare) <> 0 Then
                                
                                    objsheet1.Cells(rowCount, 20) = 0
                                    objsheet1.Cells(rowCount, 21) = 0
                                    objsheet1.Cells(rowCount, 22) = 0
                                    objsheet1.Cells(rowCount, 23) = 0
                                    objsheet1.Cells(rowCount, 24) = 0
                                    objsheet1.Cells(rowCount, 25) = 0
                                    
                                    objsheet1.Cells(rowCount, 30) = 0
                                    objsheet1.Cells(rowCount, 31) = 0
                                    objsheet1.Cells(rowCount, 32) = 0
                                    objsheet1.Cells(rowCount, 33) = 0
                                End If
                                
                                '----------------------------------------------------------------
                                'Get Tol Normal, sets values to zero for user to fill in
                                '----------------------------------------------------------------
                                If InStr(1, workingName, "mating", vbTextCompare) <> 0 Then
                                
                                    objsheet1.Cells(rowCount, 26) = 0
                                    objsheet1.Cells(rowCount, 27) = 0
                                End If
                                
                                '----------------------------------------------------------------
                                'Get Tol Trim, sets values to zero for user to fill in
                                '----------------------------------------------------------------
                                If InStr(1, workingName, "trim", vbTextCompare) <> 0 Then
                                
                                    objsheet1.Cells(rowCount, 28) = 0
                                    objsheet1.Cells(rowCount, 29) = 0
                                End If
                                
                                
                                '----------------------------------------------------------------
                                'Increment row count
                                '----------------------------------------------------------------
                                rowCount = rowCount + 1
SkipVector:
                                
                                If rowCount > 30 Then Exit Sub     'For Testing / Debuging
                            Next
                        Next
                    End If
                Next
        End If
    Next
    
    
    '----------------------------------------------------------------
    'Clear rowcount
    '----------------------------------------------------------------
    Set Selection = OpenDocument.Selection
    Selection.Clear
End Sub



