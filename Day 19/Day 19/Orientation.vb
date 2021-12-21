Imports SharpDX

Public Class Orientation
    Private Shared Iterator Function GetAllDirections() As IEnumerable(Of Vector3)
        Yield Vector3.Left
        Yield Vector3.Up
        Yield Vector3.ForwardRH
    End Function

    Private Shared Iterator Function GetAllDirectionsForwardAndBackward() As IEnumerable(Of Vector3)
        For Each direction In GetAllDirections()
            Yield direction
            Yield -direction
        Next
    End Function

    Public Shared Iterator Function GetAllOrientations() As IEnumerable(Of Matrix)
        For Each directionTo In GetAllDirectionsForwardAndBackward()
            For Each directionUp In GetAllDirectionsForwardAndBackward()
                If ((directionTo * directionUp) = Vector3.Zero) Then
                    Yield Matrix.LookAtRH(Vector3.Zero, directionTo, directionUp)
                End If
            Next
        Next
    End Function
End Class