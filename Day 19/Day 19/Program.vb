Imports System
Imports SharpDX

Module Program
    Sub Main(args As String())
        Dim fileReader As New FileReader()

        Dim scannerReports = fileReader.ReadFile().ToList
        Dim knownPositions As New List(Of KnownScannerPosition)

        ' assume scanner 0 is at 0|0|0 looking with identity matrix:
        Dim firstReport = scannerReports(0)
        scannerReports.RemoveAt(0)
        knownPositions.Add(New KnownScannerPosition(firstReport, ScannerPivot.CreateScannerPivot(Vector4.Zero, Vector4.Zero, Matrix.Identity)))

        Dim resolver As New Resolver

        Dim t As New HashSet(Of (Integer, Integer))

        While (scannerReports.Count > 0)
            For scannerReportIndex = 0 To scannerReports.Count - 1
                Dim scannerReportToResolve = scannerReports(scannerReportIndex)

                For indexKnownPositions = 0 To knownPositions.Count - 1
                    Dim reference = knownPositions(indexKnownPositions)

                    ' it does not make sense to check 2 reports against eachother twice
                    If (t.Contains((scannerReportToResolve.ScannerNumber, reference.scannerNumber))) Then
                        Continue For
                    End If
                    t.Add((scannerReportToResolve.ScannerNumber, reference.scannerNumber))

                    Dim resolution = resolver.TryResolve(reference, scannerReportToResolve)

                    If (resolution IsNot Nothing) Then
                        Console.WriteLine($"JIHA successfully resolved report {scannerReportToResolve.ScannerNumber}")
                        knownPositions.Add(resolution)
                        scannerReports.Remove(scannerReportToResolve)
                        Continue While
                    End If
                Next
            Next
        End While

        Dim positionSet As New HashSet(Of Vector4)
        For Each knownPosition In knownPositions
            For Each absolute In knownPosition.absolutePositions
                positionSet.Add(absolute)
            Next
        Next

        Console.WriteLine($"Num Positions: {positionSet.Count}")

        Dim maxDistance As Integer = 0
        For Each kp1 In knownPositions
            For Each kp2 In knownPositions
                Dim sp1 = kp1.scannerPosition
                Dim sp2 = kp2.scannerPosition
                maxDistance = CInt(Math.Max(maxDistance, Math.Abs(sp1.X - sp2.X) + Math.Abs(sp1.Y - sp2.Y) + Math.Abs(sp1.Z - sp2.Z)))
            Next
        Next

        Console.WriteLine($"Max distance is: {maxDistance}")
        Console.ReadLine()
    End Sub
End Module
