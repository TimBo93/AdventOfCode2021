Imports SharpDX

Public Class ScannerPivot
    Private ReadOnly perspective As Matrix

    Private Sub New(perspective As Matrix)
        Me.perspective = perspective
    End Sub

    Public ReadOnly Property Position As Vector3
        Get
            Return perspective.TranslationVector
        End Get
    End Property


    ''' <summary>
    ''' Creates a Scanner pivot which transforms the point relative to the scanner with its orientation to the absolute reference point.
    ''' </summary>
    ''' <param name="absoluteReferencePoint"></param>
    ''' <param name="pointRelativeToScanner"></param>
    ''' <param name="orientation"></param>
    ''' <returns></returns>
    Public Shared Function CreateScannerPivot(absoluteReferencePoint As Vector4, pointRelativeToScanner As Vector4, orientation As Matrix) As ScannerPivot
        Dim rotated = Vector4.Transform(pointRelativeToScanner, orientation)
        Dim distanceToAbsoluteReferencePoint = absoluteReferencePoint - rotated
        orientation.TranslationVector = CType(distanceToAbsoluteReferencePoint, Vector3)
        Return New ScannerPivot(orientation)
    End Function

    Public Function RealtiveToAbsolute(pointRelativeToScanner As Vector4) As Vector4
        Return Vector4.Transform(pointRelativeToScanner, perspective)
    End Function
End Class
