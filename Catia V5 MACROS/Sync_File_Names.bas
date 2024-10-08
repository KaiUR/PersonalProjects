Attribute VB_Name = "Sync_File_Names"
Option Explicit

Sub CATMain()
    '----------------------------------------------------------------
    '   Macro: Sync_File_Names.bas
    '   Version: 1.0
    '   Code: CATIA VBA
    '   Release:   V5R32
    '   Purpose: This script is designed to syncronise all filenames with
    '           the relevent part numbers
    '
    '           Duplicates will be deleted, and old version of renamed file
    '
    '           Folder structure will be preserved
    '   Author: Kai-Uwe Rathjen
    '   Date: 18.06.24
    '----------------------------------------------------------------
    '
    '   Change:
    '
    '
    '----------------------------------------------------------------
    CATIA.StatusBar = "Sync_File_Names.bas, Version 1.0"    'Update Status Bar text
    
    '----------------------------------------------------------------
    'Declarations
    '----------------------------------------------------------------
    Dim ProductDocument1 As Document
    
    Dim Error As Integer
    
    Dim docPath As String
    Dim rootPath As String
    Dim newSave As Integer
    Dim newDocPath As String
    
    Dim objShell As Object
    Dim objFolder As Object
    Dim objFolderItem As Object
    
    Dim Index As Integer
    
    Dim oDoc1 As Document
    Dim oDoc2 As Document
    Dim oProduct1 As Product
    Dim oPart1 As Part
    
    '----------------------------------------------------------------
    'Open Current Document
    '----------------------------------------------------------------
    Set ProductDocument1 = CATIA.ActiveDocument

    docPath = ProductDocument1.path
    rootPath = ProductDocument1.path
    
    '----------------------------------------------------------------
    ' Check to see if a CATProduct is open, closes script if not
    '----------------------------------------------------------------
    If Not (Right(ProductDocument1.Name, (Len(ProductDocument1.Name) - InStrRev(ProductDocument1.Name, "."))) = "CATProduct") Then
        Error = MsgBox("This Script only works with .CATProduct Files" & vbNewLine & "Please Open a .CATProduct to use this script", vbCritical)
        Exit Sub
    End If
    
    '----------------------------------------------------------------
    ' Check to see if the active document is saved, if not exit the script
    '----------------------------------------------------------------
    If docPath = "" Then
        Error = MsgBox("You must save all files first before you can use this script", vbCritical)
        Exit Sub
    End If
    
    '----------------------------------------------------------------
    ' Ask if you want to save in a new location
    '----------------------------------------------------------------
    newSave = MsgBox("Do you want to save in a new location?", vbQuestion + vbYesNo)
    
    If newSave = vbYes Then
        docPath = ""
    End If
    
    '----------------------------------------------------------------
    ' Ask user to define new save location
    '----------------------------------------------------------------
    If docPath = "" Then
        
        '----------------------------------------------------------------
        ' Open Brows folder prompt
        '----------------------------------------------------------------
        Const WINDOW_HANDLE = 0
        Const NO_OPTIONS = &H1
        Const File_Path = 17
        Set objShell = CreateObject("Shell.Application")
        
        Set objFolder = objShell.BrowseForFolder _
        (WINDOW_HANDLE, "File Save Location:", NO_OPTIONS, File_Path)
        
        If objFolder Is Nothing Then
            Error = MsgBox("Script Cancelled", vbCritical)
            Exit Sub
        End If
        
        Set objFolderItem = objFolder.Self
        docPath = objFolderItem.path
        
    End If

    '----------------------------------------------------------------
    ' Disable user prompts and confirmantions
    '----------------------------------------------------------------
    CATIA.RefreshDisplay = False
    CATIA.DisplayFileAlerts = False

    '----------------------------------------------------------------
    ' Select all parts and products
    '----------------------------------------------------------------
    Dim sel As Selection
    Set sel = ProductDocument1.Selection
    sel.Search "CATAsmSearch.Product,all"
    
    '----------------------------------------------------------------
    ' Iterate through all parts and products
    '----------------------------------------------------------------
    For Index = 1 To sel.Count
    
        '----------------------------------------------------------------
        ' Process Products
        '----------------------------------------------------------------
        If Right(sel.Item(Index).LeafProduct.ReferenceProduct.Parent.Name, 7) = "Product" Then
            Set oDoc1 = sel.Item(Index).LeafProduct.ReferenceProduct.Parent
            Set oProduct1 = oDoc1.Product
            
            '----------------------------------------------------------------
            ' Remove Products with old name
            '----------------------------------------------------------------
            If newSave = vbNo Then
                newDocPath = oDoc1.path
                
                If oDoc1.Name <> oProduct1.PartNumber & ".CATProduct" Then
                    Kill docPath & "\" & oDoc1.Name
                End If
            End If
            
            '----------------------------------------------------------------
            ' New Save location for products, preserving folder structure
            '----------------------------------------------------------------
            If newSave = vbYes Then
                newDocPath = docPath & Trim(Replace(rootPath, oDoc1.path, "", 1, 1))
                If Dir$(newDocPath, vbDirectory) = vbNullString Then
                    MkDir newDocPath
                End If
            End If
            
            '----------------------------------------------------------------
            ' Save product
            '----------------------------------------------------------------
            oDoc1.SaveAs newDocPath & "\" & oProduct1.PartNumber & ".CATProduct"
        End If
        
        '----------------------------------------------------------------
        ' Process Parts
        '----------------------------------------------------------------
        If Right(sel.Item(Index).LeafProduct.ReferenceProduct.Parent.Name, 4) = "Part" Then
            Set oDoc2 = sel.Item(Index).LeafProduct.ReferenceProduct.Parent
            Set oPart1 = oDoc2.Product
            
            '----------------------------------------------------------------
            ' Remove parts with old name
            '----------------------------------------------------------------
            If newSave = vbNo Then
                newDocPath = oDoc2.path
                
                If oDoc2.Name <> oPart1.PartNumber & ".CATPart" Then
                    Kill oDoc2.path & "\" & oDoc2.Name
                End If
            End If
            
            
            '----------------------------------------------------------------
            ' New Save location for parts, preserving folder structure
            '----------------------------------------------------------------
            If newSave = vbYes Then
                newDocPath = docPath & Trim(Replace(oDoc2.path, rootPath, "", 1, 1))
                
                If Dir$(newDocPath, vbDirectory) = vbNullString Then
                    MkDir newDocPath
                End If
            End If
            
            '----------------------------------------------------------------
            ' Save parts
            '----------------------------------------------------------------
            oDoc2.SaveAs newDocPath & "\" & oPart1.PartNumber & ".CATPart"
        End If
        
    Next
    
    '----------------------------------------------------------------
    ' Save root product
    '----------------------------------------------------------------
    ProductDocument1.Save
    
    '----------------------------------------------------------------
    ' Turn on user alerts and prompts again
    '----------------------------------------------------------------
    CATIA.RefreshDisplay = True
    CATIA.DisplayFileAlerts = True
    
    '----------------------------------------------------------------
    ' Tell user everything finished
    '----------------------------------------------------------------
    MsgBox "Sync Completed", , "SYNC COMPLETED"
    
End Sub
