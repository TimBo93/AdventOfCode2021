Imports System.IO
Imports SharpDX

Public Class FileReader
    Public Iterator Function ReadFile() As IEnumerable(Of ScannerReport)
        Using fileStream = File.OpenRead("input.txt")
            Using textReader = New StreamReader(fileStream)
                Dim currentScannerNumber As Integer = -1
                Dim currentScannerPositions As List(Of Vector4) = Nothing
                While (Not textReader.EndOfStream)
                    Dim line = textReader.ReadLine
                    If (line.Contains("---")) Then
                        If (currentScannerNumber >= 0) Then
                            Yield New ScannerReport(currentScannerNumber, currentScannerPositions)
                        End If

                        currentScannerNumber = Integer.Parse(line.Replace("--- scanner ", "").Replace(" ---", ""))
                        currentScannerPositions = New List(Of Vector4)
                    Else
                        Dim splits = line.Split(",")
                        If (splits.Length = 3) Then
                            Dim pos As New Vector4(New Vector3(Integer.Parse(splits(0)), Integer.Parse(splits(1)), Integer.Parse(splits(2))), 1)
                            currentScannerPositions.Add(pos)
                        End If
                    End If
                End While
                Yield New ScannerReport(currentScannerNumber, currentScannerPositions)
            End Using
        End Using
    End Function
End Class
