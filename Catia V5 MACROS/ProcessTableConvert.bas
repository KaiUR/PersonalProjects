Attribute VB_Name = "ProcessTableConvert"
Sub CATMain()
    '----------------------------------------------------------------
    '   Macro: ProcessTableConvert.bas
    '   Version: 1.0
    '   Code: CATIA VBA
    '   Release:   V5R32
    '   Purpose: This script is designed to read the parameters of nc programs
    '       and to pase them into an new excel sheet
    '   Author: Kai-Uwe Rathjen
    '   Date: 18.06.24
    '----------------------------------------------------------------
    '
    '   Change:
    '
    '
    '----------------------------------------------------------------
    '
    'Change the following values to change the colours for the cells
    ' 0 No Fill
    ' 1 Black
    ' 2 White
    ' 3 Red
    ' 4 Green
    ' 5 Blue
    ' 6 Yellow
    ' 7 Pink
    ' 8 Cyan
    ' 15 Light Gray
    ' 32 Royal Blue
    ' 42 Dark Cyan
    '
    '
    '----------------------------------------------------------------
    CATIA.StatusBar = "ProcessTableConvert.bas, Version 1.0"    'Update Status Bar text
    
    HeadingColour = 42
    RowColour = 34
    BorderColour = 3

    '----------------------------------------------------------------
    'Open CATIA Process
    '----------------------------------------------------------------
    Dim OpenDocument As Document
    Set OpenDocument = CATIA.ActiveDocument
    
    '----------------------------------------------------------------
    'Throw Error and exit if open document is not a CATPRocess
    '----------------------------------------------------------------
    If Not (Right(OpenDocument.Name, (Len(OpenDocument.Name) - InStrRev(OpenDocument.Name, "."))) = "CATProcess") Then
        Dim Error As Integer
        Error = MsgBox("This Script only works with .CATProcess Files" & vbNewLine & "Please Open a .CATProcess to use this script", vbCritical)
        Exit Sub
    End If
       
    Set OpenPPRDocument = OpenDocument.PPRDocument
    Set ProcessList = OpenPPRDocument.Processes
    
    NumberOfProcessList = ProcessList.Count
    
    '----------------------------------------------------------------
    'Open Excel Sheet
    '----------------------------------------------------------------
    Set Excel = CreateObject("Excel.Application")
    Excel.Visible = True

    Set workbooks = Excel.Application.workbooks
    Set Myworkbook = Excel.workbooks.Add
    Set objsheet1 = Excel.Sheets.Add
    
    'Clean up default sheet that is created
    Myworkbook.Sheets("Sheet1").Delete
    
    
    '----------------------------------------------------------------
    'Cycle through all processess
    '----------------------------------------------------------------
    For ProcessIndex = 1 To NumberOfProcessList
        
        Set Process = ProcessList.Item(ProcessIndex)
    
        Dim ActiveName As String
        ActiveName = Process.Name
        
    
        Set ActiveProcess = OpenDocument.GetItem(ActiveName)
        
    
        '----------------------------------------------------------------
        'Look for Physical Activities (Part Operations)
        '----------------------------------------------------------------
        If (ActiveProcess.IsSubTypeOf("PhysicalActivity")) Then
            Set ActiveChildren = ActiveProcess.ChildrenActivities
            Quantity = ActiveChildren.Count
            If Quantity <= 0 Then
            MsgBox "The Process does not contain any Part Operations." & vbNewLine & "You need to add programs to use this Script"
            Exit Sub
        End If
        
        '----------------------------------------------------------------
        'Look for Manufacturing Setups (Programms)
        '----------------------------------------------------------------
        For Index = 1 To Quantity

            Set CurrentSetup = ActiveChildren.Item(Index)
            If (CurrentSetup.IsSubTypeOf("ManufacturingSetup")) Then
            
                'Add Extra Sheet if needed
                If Index > 2 Then
                    Set objsheet1 = Excel.Sheets.Add
                End If
            
                objsheet1.Name = CurrentSetup.Name
                
                Set ProgramList = CurrentSetup.Programs
                NumberOfPrograms = ProgramList.Count
                
                'Exit script and give message if there is only one part operation and no programs
                If NumberOfPrograms < 1 And Index < 3 Then
                    Excel.DisplayAlerts = False
                    Excel.Quit
                    MsgBox "The Process does not contain any Programs." & vbNewLine & "You need to add programs to use this Script"
                    Exit Sub
                End If
                
                ' Skip if no programs but there are multiple part operations present
                ' Remove empty sheet
                If NumberOfPrograms < 1 Then
                    Myworkbook.Sheets(CurrentSetup.Name).Delete
                    GoTo Skip
                End If
                             
                Colum = 1
                Row = 2
    
                '----------------------------------------------------------------
                'Sheet Headings
                '----------------------------------------------------------------
                objsheet1.cells(Row, Colum) = "Program Name"
                objsheet1.cells(Row, Colum).Interior.ColorIndex = HeadingColour
                objsheet1.cells(Row, Colum + 1) = "Comment"
                objsheet1.cells(Row, Colum + 1).Interior.ColorIndex = HeadingColour
                objsheet1.cells(Row, Colum + 2) = "Tool"
                objsheet1.cells(Row, Colum + 2).Interior.ColorIndex = HeadingColour
                objsheet1.cells(Row, Colum + 3) = "Stepover"
                objsheet1.cells(Row, Colum + 3).Interior.ColorIndex = HeadingColour
                objsheet1.cells(Row, Colum + 4) = "MC Tolerance"
                objsheet1.cells(Row, Colum + 4).Interior.ColorIndex = HeadingColour
                objsheet1.cells(Row, Colum + 5) = "Depth of Cut"
                objsheet1.cells(Row, Colum + 5).Interior.ColorIndex = HeadingColour
                objsheet1.cells(Row, Colum + 6) = "Offset on Part"
                objsheet1.cells(Row, Colum + 6).Interior.ColorIndex = HeadingColour
                objsheet1.cells(Row, Colum + 7) = "Offset on Check"
                objsheet1.cells(Row, Colum + 7).Interior.ColorIndex = HeadingColour
                objsheet1.cells(Row, Colum + 8) = "Depth of cut by level for Multi-Pass"
                objsheet1.cells(Row, Colum + 8).Interior.ColorIndex = HeadingColour
    
                Row = Row + 1
            
            
                '----------------------------------------------------------------
                'Read Programs
                '----------------------------------------------------------------
                'Rename Current Sheet

                
                For ProgramElement = 1 To NumberOfPrograms
                    Set CurrentProgram = ProgramList.GetElement(ProgramElement)
                            
                    ProgramName = CurrentProgram.Name
                            
                    Set ActivityList = CurrentProgram.Activities
                    NumberOfActivity = ActivityList.Count
                    If (NumberOfActivity = 0) Then
                        'Empty Program Names
                        objsheet1.cells(Row, Colum) = ProgramName
                    Else
                        'Non Empty Program Name
                        objsheet1.cells(Row, Colum) = ProgramName
                        objsheet1.cells(Row, Colum).Interior.ColorIndex = RowColour
                                
                        For Index2 = 1 To NumberOfActivity
                            Set CurrentActivity = ActivityList.GetElement(Index2)
                            ActivityType = CurrentActivity.Type
                                
                            If (ActivityType = "ToolChange") Then
                                '----------------------------------------------------------------
                                'Tool name
                                'Convert tool number to tool name
                                '----------------------------------------------------------------
                                Set CurrentTool = CurrentActivity.Tool
                                ToolNumber = CurrentTool.ToolNumber
                                Dim ToolName As Variant
                                        
                                Select Case ToolNumber
                                    Case 1
                                        '50BN
                                        objsheet1.cells(Row, Colum + 2) = "T1 50 BN"
                                                
                                    Case 2
                                        '32BN
                                        objsheet1.cells(Row, Colum + 2) = "T2 32 BN"
                                                
                                    Case 3
                                        '20BN
                                        objsheet1.cells(Row, Colum + 2) = "T3 20 BN"
                                                      
                                    Case 4
                                        '16BN
                                        objsheet1.cells(Row, Colum + 2) = "T4 16 BN"
                                                
                                    Case 5
                                        '12BN
                                        objsheet1.cells(Row, Colum + 2) = "T5 12 BN"
                                                
                                    Case 6
                                        '10BN
                                        objsheet1.cells(Row, Colum + 2) = "T6 10 BN"
                                                
                                    Case 7
                                        '8BN
                                        objsheet1.cells(Row, Colum + 2) = "T7 8 BN"
                                                
                                    Case 8
                                        '6BN
                                        objsheet1.cells(Row, Colum + 2) = "T8 6 BN"
                                                
                                    Case 9
                                        '4BN
                                        objsheet1.cells(Row, Colum + 2) = "T9 4 BN"
                                                
                                    Case 10
                                        '63 Depo r8
                                        objsheet1.cells(Row, Colum + 2) = "T11 63 DEPO R8"
                                                
                                    Case 11
                                        '80 Depo r8
                                        objsheet1.cells(Row, Colum + 2) = "T10 80 DEPO R8"
                                                
                                    Case 16
                                        '32 Depo r8
                                        objsheet1.cells(Row, Colum + 2) = "T16 32 DEPO R8"
                                                
                                    Case 17
                                        '50 Depo r8
                                        objsheet1.cells(Row, Colum + 2) = "T17 50 DEPO R8"
                                                
                                    Case Else
                                        'tool not found
                                        objsheet1.cells(Row, Colum + 2) = "Unlisted Tool"
                                            
                                End Select
                                objsheet1.cells(Row, Colum + 2).Interior.ColorIndex = RowColour
                                        
                                'Program Comment
                                ProgramComment = CurrentProgram.Description
                                objsheet1.cells(Row, Colum + 1) = ProgramComment
                                objsheet1.cells(Row, Colum + 1).Interior.ColorIndex = RowColour
                                        
                                'Go to machining operation
                                Set NextActivity = ActivityList.GetElement(Index2 + 1)
                                    
                                Set NextActivityParameters = NextActivity.Parameters
                                NumberOfNextActivityParametes = NextActivityParameters.Count
                                    
                                'Cycle through parameters
                                For Index3 = 1 To NumberOfNextActivityParametes
                                    Set CurrentParameter = NextActivityParameters.Item(Index3)
                                            
                                    If CurrentParameter.Name Like "*" & "Maximum distance" & "*" Then
                                        ' Maximum Distance parameter
                                        objsheet1.cells(Row, Colum + 3) = CurrentParameter.ValueAsString
                                        objsheet1.cells(Row, Colum + 3).Interior.ColorIndex = RowColour
                                        
                                    End If
                                        
                                    If CurrentParameter.Name Like "*" & "Machining tolerance" & "*" Then
                                        ' Machining tolerance parameter
                                        objsheet1.cells(Row, Colum + 4) = CurrentParameter.ValueAsString
                                        objsheet1.cells(Row, Colum + 4).Interior.ColorIndex = RowColour
                                        
                                    End If
                                        
                                    If CurrentParameter.Name Like "*" & "Maximum depth of cut" & "*" Then
                                        ' Maximum depth of cut parameter
                                        objsheet1.cells(Row, Colum + 5) = CurrentParameter.ValueAsString
                                        
                                    End If
                                    objsheet1.cells(Row, Colum + 5).Interior.ColorIndex = RowColour
                                            
                                    If CurrentParameter.Name Like "*" & "Offset on part" & "*" Then
                                        ' Offset on part parameter
                                        objsheet1.cells(Row, Colum + 6) = CurrentParameter.ValueAsString
                                        objsheet1.cells(Row, Colum + 6).Interior.ColorIndex = RowColour
                                        
                                    End If
                                        
                                    If CurrentParameter.Name Like "*" & "Offset on check" & "*" Then
                                        ' Offset on check parameter
                                        objsheet1.cells(Row, Colum + 7) = CurrentParameter.ValueAsString
                                        objsheet1.cells(Row, Colum + 7).Interior.ColorIndex = RowColour
                                        
                                    End If
                                    
                                    If CurrentParameter.Name Like "*" & "Depth of cut by level for Multi-Pass" & "*" Then
                                        ' Depth of cut by level for Multi-Pass parameter
                                        objsheet1.cells(Row, Colum + 8) = CurrentParameter.ValueAsString
                                        
                                    End If
                                    objsheet1.cells(Row, Colum + 8).Interior.ColorIndex = RowColour

                                Next
                            End If
                        Next
                    End If

                    Row = Row + 1
                    

                                         
'Skip lable for empty part operations
Skip:
                Next
                
                '----------------------------------------------------------------
                'Formatting Heading
                '----------------------------------------------------------------
                With objsheet1.Range("A2:I2").Font
                    .Name = "Century"
                    .FontStyle = "Bold"
                    .Size = 18
                    .Superscript = True
                End With
    
                objsheet1.Range("A2:H2").HorizontalAlignment = -4108
    
                '----------------------------------------------------------------
                'Add Borders to Sheet
                '----------------------------------------------------------------
                With objsheet1.Range("A1:I" & Row - 1).Borders
                    .LineStyle = xlContinuous
                    .Color = BorderColour
                End With
                    
                '----------------------------------------------------------------
                'Logs and Other formatting
                '----------------------------------------------------------------
                LogoHeightAuto = 60
                LogoWidthAuto = 50
                LogoWidthMagna = 25
                LogoHeightMagna = 30
                
                objsheet1.Range("A1:I1").Merge Across:=True
                objsheet1.cells(1, 1) = "Program Parameters" & vbNewLine & objsheet1.Name & vbNewLine & OpenDocument.Name
                
                With objsheet1.cells(1, 1).Font
                    .Name = "Century"
                    .FontStyle = "Bold"
                    .Size = 12
                    .ColorIndex = 11
                    .Superscript = True
                End With
                
                objsheet1.cells(1, 1).HorizontalAlignment = -4108
                objsheet1.cells(1, 1).VerticalAlignment = -4160
                
                objsheet1.Rows(1).RowHeight = LogoHeightAuto + 2
                
                'Check if files exist
                Dim strAutoPath As String
                Dim strMagnaPath As String
                strAutoPath = "N:\23 - Templates\13_Miscellaneous\Autolaunch logo.JPG"
                strMagnaPath = "N:\23 - Templates\13_Miscellaneous\Magna logo.JPG"
                
                Dim strFileExisitsAuto As String
                Dim strFileExisitsMagna As String
                
                strFileExisitsAuto = Dir(strAutoPath)
                strFileExisitsMagna = Dir(strMagnaPath)
                
                If strFileExisitsAuto = "" Then
                    GoTo SkipAuto
                End If
                If strFileExisitsMagna = "" Then
                    GoTo SkipAuto
                End If
                
                'Autolaunch Logo
                With objsheet1.Pictures.Insert("N:\23 - Templates\13_Miscellaneous\Autolaunch logo.JPG")
                    With .ShapeRange
                        .LockAspectRatio = msoTrue
                        .Width = LogoWidthAuto
                        .Height = LogoHeightAuto
                    End With
                    .Left = 1
                    .Top = 1
                    .Placement = 1
                    .PrintObject = True
                End With
                
SkipAuto:
                
                'Magna Logo
                With objsheet1.Pictures.Insert("N:\23 - Templates\13_Miscellaneous\Magna logo.JPG")
                    With .ShapeRange
                        .LockAspectRatio = msoTrue
                        .Width = LogoWidthMagna
                        .Height = LogoHeightMagna
                    End With
                    .Left = objsheet1.Range("A1:I1").Width - LogoWidthMagna
                    .Top = 10
                    .Placement = 1
                    .PrintObject = True
                End With

SkipMagna:
                
                
                '----------------------------------------------------------------
                'Fit all columns to one page and make sheet landscape
                'Set print margins
                'Define Footer
                '----------------------------------------------------------------
                Excel.PrintCommunication = False
                With Myworkbook.Sheets(CurrentSetup.Name).PageSetup
                    .Orientation = 2
                    .FitToPagesWide = True
                    .FitToPagesTall = False
                    .LeftMargin = 30
                    .RightMargin = 30
                    .TopMargin = 40
                    .BottomMargin = 40
                    .HeaderMargin = 15
                    .FooterMargin = 15
                    .RightFooter = Format(Now(), "hh:mm") & " " & Format(Now(), "dd/mm/yy") & " " & "Page &P of &N"
                    .LeftFooter = OpenDocument.Name
                    .CenterFooter = objsheet1.Name
                End With
                Excel.PrintCommunication = True

                
    
                '----------------------------------------------------------------
                'Align all to top of Cells
                '----------------------------------------------------------------
                objsheet1.Range("A1:I" & Row - 1).VerticalAlignment = -4160
    
                '----------------------------------------------------------------
                'Column Widths, Auto set to min need to view all text
                '----------------------------------------------------------------
                objsheet1.Columns("A:I").EntireColumn.Autofit
                
            End If
        Next
        End If
    Next
    
    'Stop the do you want to save when closing excel
    Myworkbook.Saved = True
    
End Sub

