Imports SharpDX

Public Class KnownScannerPosition
    Public ReadOnly absolutePositions As IReadOnlyCollection(Of Vector4)

    Public ReadOnly scannerNumber As Integer

    Public ReadOnly scannerPosition As Vector3

    Public Sub New(report As ScannerReport, pivot As ScannerPivot)
        scannerNumber = report.ScannerNumber

        absolutePositions = report.Positions.Select(Function(pos As Vector4) As Vector4
                                                        Return pivot.RealtiveToAbsolute(pos)
                                                    End Function).ToList().AsReadOnly()

        scannerPosition = pivot.Position
    End Sub
End Class