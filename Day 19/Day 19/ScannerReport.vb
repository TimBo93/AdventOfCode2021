Imports System.Collections.ObjectModel
Imports SharpDX

Public Class ScannerReport

    Public ReadOnly Property Positions As ReadOnlyCollection(Of Vector4)

    Public ReadOnly Property ScannerNumber As Integer

    Public Sub New(scannerNumber As Integer, positions As List(Of Vector4))
        Me.Positions = positions.AsReadOnly
        Me.ScannerNumber = scannerNumber
    End Sub
End Class
