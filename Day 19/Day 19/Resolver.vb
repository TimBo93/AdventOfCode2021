Imports System.Collections.ObjectModel
Imports SharpDX

Public Class Resolver

    Private ReadOnly allOrientations As ReadOnlyCollection(Of Matrix)

    Public Sub New()
        allOrientations = Orientation.GetAllOrientations.ToList.AsReadOnly
    End Sub

    Public Function TryResolve(reference As KnownScannerPosition, scannerReport As ScannerReport) As KnownScannerPosition
        ' assume each orientation
        For Each orientation In allOrientations

            ' map each of the report positions
            For Each reportPosition In scannerReport.Positions

                ' onto each position of the reference
                For Each referencePosition In reference.absolutePositions

                    ' create scannerPivot
                    Dim sp = ScannerPivot.CreateScannerPivot(referencePosition, reportPosition, orientation)

                    ' check if we have luck with the assumed orientation and offset
                    Dim count = scannerReport.Positions.Where(Function(pos2check)
                                                                  Return reference.absolutePositions.Contains(sp.RealtiveToAbsolute(pos2check))
                                                              End Function).Count()

                    If (count >= 12) Then
                        Return New KnownScannerPosition(scannerReport, sp)
                    End If
                Next
            Next
        Next

        Return Nothing
    End Function

End Class
