Imports System.Data.SqlClient
Imports System.Data

Module Module1

   Sub Main()

      ShowOrgChart()

   End Sub

   
   Private Sub ShowOrgChart()

      Dim cnSQL As New SqlConnection("Server=SERVERNAMEHERE;Integrated Security=SSPI;" & _
                                     "Database=Northwind")
      Dim cmdSQL As New SqlCommand()
      Dim drSQL As SqlDataReader

      With cmdSQL
         .Connection = cnSQL
         .CommandText = "GetOrgChart"
         .CommandType = CommandType.StoredProcedure
      End With

      cnSQL.Open()
      drSQL = cmdSQL.ExecuteReader

      While drSQL.Read
         Console.WriteLine(Space(drSQL("EmpLevel")) & _
                            drSQL("FirstName") & _
                            drSQL("LastName"))

      End While

      drSQL.Close()
      cnSQL.Close()

   End Sub



End Module
