VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} SplineOrPolyline 
   Caption         =   "Spline or Polyline?"
   ClientHeight    =   1875
   ClientLeft      =   120
   ClientTop       =   465
   ClientWidth     =   4455
   OleObjectBlob   =   "SplineOrPolyline.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "SplineOrPolyline"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub CommandButton1_Click()
    Me.Hide
End Sub


Private Sub UserForm_Terminate()
    SplineOrPoliLineTerminated = True
End Sub
