Attribute VB_Name = "Parameter_example"
Option Explicit

Sub CATMain()
    Dim oDocument As Document                               'Document Anchor
    Dim oPart As Part                                       'Part Anchor
    
    Dim aParam As Parameters                                'Collection of all parameters
    Dim Param As Parameter                                  'Current parameter
    Dim Index As Integer                                    'index
    

    Set oDocument = CATIA.ActiveDocument                    'Anchor document
    Set oPart = oDocument.Part                              'Anchor part

    Set aParam = oPart.Parameters                           'Get parameters
    
    For Index = 1 To aParam.count                           'Loop for all parameters
        Set Param = aParam.Item(Index)                      'Get current Parameter
    
        Debug.Print Param.Name                              'Name/Path of Param
        Debug.Print TypeName(Param)                         'Prints the parameter type to Intermediate window
        Debug.Print "Renamed: " & Param.Renamed             'True if varible was renamed, otherwise false
        Debug.Print TypeName(Param.Context)                 'Prints where the parameter is located. part, product, drawing
        Debug.Print "Hidden: " & Param.Hidden               'True if hidden, outerwise false
        Debug.Print "True Par: " & Param.IsTrueParameter    'True if Real, dimetion, or string; False if isolated point, curve or surface
        Debug.Print "Read only: " & Param.ReadOnly          'True if read only
        
        Select Case Param.UserAccessMode                     'Get acess mode
            Case 0                                                          'Read Only
                Debug.Print "Read only parameter (cannot be destroyed)."
            Case 1                                                          'Read/Write
                Debug.Print "Read/write parameter (cannot be destroyed)."
            Case 2                                                          'User Parameter
                Debug.Print "User parameter (can be read, written and destroyed)."
            Case Else
                Debug.Print "Error getting User acess mode"
        End Select
        
        Debug.Print vbNewLine
        
    Next

End Sub

'---------------------------------------
'
' I ran this on a random part.
' Results for types:
'
'   Parameter
'   RealParam
'   StrParam
'   Length
'   ListParameter
'   IntParam
