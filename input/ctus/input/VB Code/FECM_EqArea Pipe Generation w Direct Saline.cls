VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_CTS Pipe Generation"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
' Pipe Option Heuristic Form

Option Compare Database
Option Explicit

Const PI = 3.1415926535897

Private Sub btn_GenPipes_Click()
    Dim tOptMin As Integer, tOptMax As Integer, cDirG As Integer
    Dim tDistMax As Double
    Dim tShip As Boolean
    
    ' validate the form data
    If IsNumeric(Me.txf_cOptMin.Value) = False Then
        MsgBox "Please enter a real integer for the minimum capture site options."
    ElseIf IsNumeric(Me.txf_cOptMax.Value) = False Then
        MsgBox "Please enter a real integer for the maximum capture site options."
    ElseIf IsNumeric(Me.txf_cDistMax.Value) = False Then
        MsgBox "Please enter a value for the maximum capture site option distance."
    Else
        If Me.frm_Transship = 2 Then
            tShip = False
            tOptMin = 0
            tOptMax = 0
            tDistMax = 0
            cDirG = 0
        ElseIf Me.frm_Transship = 1 Then
            tShip = True
        End If
        'MsgBox "EOR: " & Me.cbx_InclEORInjection.Value & Chr(13) & "ETHANOL: " & Me.cbx_InclEthanolPlants.Value & Chr(13) & "SALINE: " & Me.cbx_InclSalineInjection.Value
        ' run the pipe generation heuristic
        GeneratePipeOptions Me.txf_cOptMin.Value, Me.txf_cOptMax.Value, Me.txf_cDistMax, cDirG, tShip, tOptMin, tOptMax, tDistMax, CStr(Me.txf_DistMult.Value)
        MsgBox "Done executing pipe generation heuristic."
        DoCmd.Close
    End If
End Sub

Private Sub cbx_DefParam_Click()
    Dim i As Long
    Me.frm_Transship.Value = 1
    Me.txf_cOptMin = 1
    Me.txf_cOptMax = 3
    Me.txf_cDistMax = 500
    Me.txf_DistMult = "1.1"
    Me.cbx_InclEthanolPlants.Value = 0
    Me.cbx_InclExistingPowerPlants.Value = 1
    Me.cbx_InclUnplannedPowerPlants.Value = 1
    Me.cbx_InclAlt.Value = 0
    For i = 1 To 22
        CurrentDb.Execute "UPDATE PIPE_HEURISTIC_PARAMETERS SET CAP_MIN_OPT = " & CStr(Me.txf_cOptMin) & ", CAP_MAX_OPT = " & CStr(Me.txf_cOptMax) & " WHERE EMM_REGION = " & CStr(i)
    Next
End Sub

' sets the pipe generation parameters based on EMM region
Function setParameters(EMMRegIndex As Integer, cOptMin As Integer, cOptMax As Integer, cDistMax, sFactor As Double)
    Dim sql As String, rs As DAO.Recordset
    sql = "SELECT * FROM PIPE_HEURISTIC_PARAMETERS WHERE EMM_REGION = " & CStr(EMMRegIndex)
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    If Not rs.EOF Then
        cOptMin = rs![CAP_MIN_OPT]
        cOptMax = rs![CAP_MAX_OPT]
        cDistMax = rs![CAP_MAX_DIST]
'        cDirG = rs![CAP_DIR_GUARANTEE]
'        If rs![TRANSSHIP] = "yes" Then
'            tShip = True
'        Else
'            tShip = False
'        End If
'        tOptMin = rs![TRA_MIN_OPT]
'        tOptMax = rs![TRA_MAX_OPT]
'        tDistMax = rs![TRA_MAX_DIST]
    End If
End Function

Sub GeneratePipeOptions(cOptMin As Integer, cOptMax As Integer, cDistMax As Double, cDirG As Integer, tShip As Boolean, tOptMin As Integer, tOptMax As Integer, tDistMax As Double, sFactor As Double)
    Dim rsFrom As DAO.Recordset, rsTo As DAO.Recordset, rs As DAO.Recordset
    Dim sqlFrom As String, sqlTo As String, sqlIns As String, sql As String
    Dim tDist As Double, tmpCount As Integer, sOpt() As Integer
    Dim RetVal As Variant, Cur_Count As Integer, DMult As Double
    Dim HubOption As String
    DMult = sFactor
    HubOption = "SITE_TRANSSHIP_EQAREA"
    
    ' I. clear existing pipe tables and create the temp pipe container if it doesn't exist
    sqlIns = "DELETE FROM PIPE_DIST WHERE EXISTING <> 1"
    CurrentDb.Execute (sqlIns)
    sqlIns = "DELETE FROM PIPE_OPT WHERE EXISTING <> 1"
    CurrentDb.Execute (sqlIns)
    If ifTableExists("tmp_pipe_opt") = False Then
        sqlIns = "Create Table tmp_pipe_opt (FROM_NODE varchar(255), FROM_TYPE varchar(255), TO_NODE varchar(255), TO_TYPE varchar(255), DISTANCE float, SINK_TYPE varchar(255))"
        CurrentDb.Execute sqlIns
    End If
    
     ' II.G. Build direct pipe options from saline and EOR sites
    If Me.cbx_InclExistingPowerPlants.Value <> 0 Then
        sqlFrom = "SELECT SITE_NAME as PLANT_ID, LAT, LON FROM SITE_INJECTION_TERMINALS GROUP BY SITE_NAME, LAT, LON"
        Set rsFrom = CurrentDb.OpenRecordset(sqlFrom, dbOpenSnapshot)
        rsFrom.MoveLast
        RetVal = SysCmd(acSysCmdInitMeter, "Generating direct pipes from saline+EOR sites...", rsFrom.RecordCount)
        rsFrom.MoveFirst
        Cur_Count = 0
        Do While Not rsFrom.EOF
            Cur_Count = Cur_Count + 1
            RetVal = SysCmd(acSysCmdUpdateMeter, Cur_Count)
            sqlIns = "DELETE FROM tmp_pipe_opt"
            CurrentDb.Execute (sqlIns)
            ' set the regional pipe heuristic parameters
            setParameters 1, cOptMin, cOptMax, cDistMax, sFactor
            ' assess pipe options to saline storage sites
            If cOptMin > 0 Or cOptMax > 0 Then
                
                sqlTo = "SELECT T_NODE, LAT, LON, SINK_TYPE FROM SITE_INJECTION_TERMINALS"
                Set rsTo = CurrentDb.OpenRecordset(sqlTo, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                    sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![PLANT_ID]) + "','CAPSITE','" + rsTo![T_NODE] + "','INJSITE'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                    CurrentDb.Execute (sqlIns)
                    rsTo.MoveNext
                Loop
                rsTo.Close
                
                ' select assessed pipe options based on heuristic logic
                tmpCount = 0
                ' retrieve the pipe diameters for the option set of generating units at this site
                sqlIns = "SELECT DIAMETER FROM PIPE_DIAMETER_SET"
                
                Set rs = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rs.MoveLast
                ReDim sOpt(rs.RecordCount - 1)
                rs.MoveFirst
                Do While Not rs.EOF
                  sOpt(tmpCount) = rs!Diameter
                  tmpCount = tmpCount + 1
                  rs.MoveNext
                Loop
                
            End If
            
            ' Make sure there is at least one pipe to a transshipment node
            CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
            sqlTo = "SELECT SITE_NAME, LAT, LON, 'T' AS SINK_TYPE FROM SITE_TRANSSHIP"
            sql = Replace(sqlTo, "SITE_TRANSSHIP", HubOption)
            Set rsTo = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
            Do While Not rsTo.EOF
                tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![PLANT_ID]) + "','CAPSITE','" + rsTo![SITE_NAME] + "','TRANSSHIP'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                CurrentDb.Execute (sqlIns)
                rsTo.MoveNext
            Loop
            rsTo.Close
            
            sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
            Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
            rsTo.MoveFirst
            If Not rsTo.EOF Then
                ' insert the pipe distance and options
                AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
            End If
            rsTo.Close
            
            rsFrom.MoveNext
        Loop
        rsFrom.Close
        CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
        RetVal = SysCmd(acSysCmdRemoveMeter)
    End If
    
    ' II.A. Build direct pipe options from existing ETHANOL facilities
    If Me.cbx_InclExistingPowerPlants.Value <> 0 Then
        'sqlFrom = "SELECT SITE_NAME, LAT, LON, FuelRegion, Tot_CO2_Control FROM SITE_ETHANOL_GEN GROUP BY SITE_NAME, LAT, LON"
        sqlFrom = "SELECT SITE_NAME, LAT, LON, FuelRegion, Tot_CO2_Control FROM SITE_ETHANOL_GEN"
        Set rsFrom = CurrentDb.OpenRecordset(sqlFrom, dbOpenSnapshot)
        rsFrom.MoveLast
        RetVal = SysCmd(acSysCmdInitMeter, "Generating direct pipes from ethanol sites...", rsFrom.RecordCount)
        rsFrom.MoveFirst
        Cur_Count = 0
        Do While Not rsFrom.EOF
            Cur_Count = Cur_Count + 1
            RetVal = SysCmd(acSysCmdUpdateMeter, Cur_Count)
            sqlIns = "DELETE FROM tmp_pipe_opt"
            CurrentDb.Execute (sqlIns)
            ' set the regional pipe heuristic parameters
            setParameters 1, cOptMin, cOptMax, cDistMax, sFactor
            ' assess pipe options to saline storage sites
            If cOptMin > 0 Or cOptMax > 0 Then
                
                sqlTo = "SELECT T_NODE, LAT, LON, SINK_TYPE FROM SITE_INJECTION_TERMINALS"
                Set rsTo = CurrentDb.OpenRecordset(sqlTo, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                    sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![SITE_NAME]) + "','CAPSITE','" + rsTo![T_NODE] + "','INJSITE'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                    CurrentDb.Execute (sqlIns)
                    rsTo.MoveNext
                Loop
                rsTo.Close
                
                ' select assessed pipe options based on heuristic logic
                tmpCount = 0
                ' retrieve the pipe diameters for the option set of generating units at this site
                sqlIns = "SELECT DIAMETER FROM PIPE_DIAMETER_SET WHERE (LOWER_BOUND <= " + CStr(rsFrom![Tot_CO2_Control]) + " AND UPPER_BOUND > " + CStr(rsFrom![Tot_CO2_Control]) + ")"
                
                Set rs = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rs.MoveLast
                ReDim sOpt(rs.RecordCount - 1)
                rs.MoveFirst
                Do While Not rs.EOF
                  sOpt(tmpCount) = rs!Diameter
                  tmpCount = tmpCount + 1
                  rs.MoveNext
                Loop
                
                tmpCount = 0
                
                ' select direct pipes first
                If cDirG > 0 Then
                    sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt WHERE TO_TYPE = 'INJSITE' ORDER BY SINK_TYPE,DISTANCE ASC"
                    Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                    Do While Not rsTo.EOF
                        ' insert the pipe distance and options
                        AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                        ' remove the pipe option from our temp table to avoid double counting later
                        sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                        CurrentDb.Execute (sqlIns)
                        tmpCount = tmpCount + 1
                        rsTo.MoveNext
                        If tmpCount >= cDirG Then Exit Do
                    Loop
                    rsTo.Close
                End If
                
                ' First make sure there is at least one pipe to an EOR+Saline TNODE
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY SINK_TYPE,DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rsTo.MoveFirst
                If Not rsTo.EOF Then
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                End If
                rsTo.Close
                
                ' now select remaining pipes
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    If (tmpCount >= cOptMax) Or (tmpCount >= cOptMin And rsTo![Distance] > cDistMax) Then Exit Do
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                    rsTo.MoveNext
                Loop
                rsTo.Close
            End If
            
            ' Make sure there is at least one pipe to a transshipment node
            CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
            sqlTo = "SELECT SITE_NAME, LAT, LON, 'T' AS SINK_TYPE FROM SITE_TRANSSHIP"
            sql = Replace(sqlTo, "SITE_TRANSSHIP", HubOption)
            Set rsTo = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
            Do While Not rsTo.EOF
                tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![SITE_NAME]) + "','CAPSITE','" + rsTo![SITE_NAME] + "','TRANSSHIP'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                CurrentDb.Execute (sqlIns)
                rsTo.MoveNext
            Loop
            rsTo.Close
            
            sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
            Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
            rsTo.MoveFirst
            If Not rsTo.EOF Then
                ' insert the pipe distance and options
                AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
            End If
            rsTo.Close
            
            rsFrom.MoveNext
        Loop
        rsFrom.Close
        CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
        RetVal = SysCmd(acSysCmdRemoveMeter)
    End If
    
    ' II.B. Build direct pipe options from existing H2 facilities
    If Me.cbx_InclExistingPowerPlants.Value <> 0 Then
        'sqlFrom = "SELECT SITE_NAME, LAT, LON, FuelRegion, Tot_CO2_Control FROM SITE_ETHANOL_GEN GROUP BY SITE_NAME, LAT, LON"
        sqlFrom = "SELECT SITE_NAME, LAT, LON, FuelRegion, Tot_CO2_Control FROM SITE_H2_GEN"
        Set rsFrom = CurrentDb.OpenRecordset(sqlFrom, dbOpenSnapshot)
        rsFrom.MoveLast
        RetVal = SysCmd(acSysCmdInitMeter, "Generating direct pipes from hydrogen sites...", rsFrom.RecordCount)
        rsFrom.MoveFirst
        Cur_Count = 0
        Do While Not rsFrom.EOF
            Cur_Count = Cur_Count + 1
            RetVal = SysCmd(acSysCmdUpdateMeter, Cur_Count)
            sqlIns = "DELETE FROM tmp_pipe_opt"
            CurrentDb.Execute (sqlIns)
            ' set the regional pipe heuristic parameters
            setParameters 1, cOptMin, cOptMax, cDistMax, sFactor
            ' assess pipe options to saline storage sites
            If cOptMin > 0 Or cOptMax > 0 Then
                
                sqlTo = "SELECT T_NODE, LAT, LON, SINK_TYPE FROM SITE_INJECTION_TERMINALS"
                Set rsTo = CurrentDb.OpenRecordset(sqlTo, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                    sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![SITE_NAME]) + "','CAPSITE','" + rsTo![T_NODE] + "','INJSITE'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                    CurrentDb.Execute (sqlIns)
                    rsTo.MoveNext
                Loop
                rsTo.Close
                
                ' select assessed pipe options based on heuristic logic
                tmpCount = 0
                ' retrieve the pipe diameters for the option set of generating units at this site
                sqlIns = "SELECT DIAMETER FROM PIPE_DIAMETER_SET WHERE (LOWER_BOUND <= " + CStr(rsFrom![Tot_CO2_Control]) + " AND UPPER_BOUND > " + CStr(rsFrom![Tot_CO2_Control]) + ")"
                
                Set rs = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rs.MoveLast
                ReDim sOpt(rs.RecordCount - 1)
                rs.MoveFirst
                Do While Not rs.EOF
                  sOpt(tmpCount) = rs!Diameter
                  tmpCount = tmpCount + 1
                  rs.MoveNext
                Loop
                
                tmpCount = 0
                
                ' select direct pipes first
                If cDirG > 0 Then
                    sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt WHERE TO_TYPE = 'INJSITE' ORDER BY SINK_TYPE,DISTANCE ASC"
                    Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                    Do While Not rsTo.EOF
                        ' insert the pipe distance and options
                        AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                        ' remove the pipe option from our temp table to avoid double counting later
                        sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                        CurrentDb.Execute (sqlIns)
                        tmpCount = tmpCount + 1
                        rsTo.MoveNext
                        If tmpCount >= cDirG Then Exit Do
                    Loop
                    rsTo.Close
                End If
                
                ' First make sure there is at least one pipe to an EOR+Saline TNODE
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY SINK_TYPE,DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rsTo.MoveFirst
                If Not rsTo.EOF Then
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                End If
                rsTo.Close
                
                ' now select remaining pipes
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    If (tmpCount >= cOptMax) Or (tmpCount >= cOptMin And rsTo![Distance] > cDistMax) Then Exit Do
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                    rsTo.MoveNext
                Loop
                rsTo.Close
            End If
            
            ' Make sure there is at least one pipe to a transshipment node
            CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
            sqlTo = "SELECT SITE_NAME, LAT, LON, 'T' AS SINK_TYPE FROM SITE_TRANSSHIP"
            sql = Replace(sqlTo, "SITE_TRANSSHIP", HubOption)
            Set rsTo = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
            Do While Not rsTo.EOF
                tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![SITE_NAME]) + "','CAPSITE','" + rsTo![SITE_NAME] + "','TRANSSHIP'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                CurrentDb.Execute (sqlIns)
                rsTo.MoveNext
            Loop
            rsTo.Close
            
            sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
            Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
            rsTo.MoveFirst
            If Not rsTo.EOF Then
                ' insert the pipe distance and options
                AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
            End If
            rsTo.Close
            
            rsFrom.MoveNext
        Loop
        rsFrom.Close
        CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
        RetVal = SysCmd(acSysCmdRemoveMeter)
    End If
    
        ' II.C. Build direct pipe options from existing NGP facilities
    If Me.cbx_InclExistingPowerPlants.Value <> 0 Then
        'sqlFrom = "SELECT SITE_NAME, LAT, LON, FuelRegion, Tot_CO2_Control FROM SITE_ETHANOL_GEN GROUP BY SITE_NAME, LAT, LON"
        sqlFrom = "SELECT SITE_NAME, LAT, LON, FuelRegion, Tot_CO2_Control FROM SITE_NGP_GEN"
        Set rsFrom = CurrentDb.OpenRecordset(sqlFrom, dbOpenSnapshot)
        rsFrom.MoveLast
        RetVal = SysCmd(acSysCmdInitMeter, "Generating direct pipes from NGP sites...", rsFrom.RecordCount)
        rsFrom.MoveFirst
        Cur_Count = 0
        Do While Not rsFrom.EOF
            Cur_Count = Cur_Count + 1
            RetVal = SysCmd(acSysCmdUpdateMeter, Cur_Count)
            sqlIns = "DELETE FROM tmp_pipe_opt"
            CurrentDb.Execute (sqlIns)
            ' set the regional pipe heuristic parameters
            setParameters 1, cOptMin, cOptMax, cDistMax, sFactor
            ' assess pipe options to saline storage sites
            If cOptMin > 0 Or cOptMax > 0 Then
                
                sqlTo = "SELECT T_NODE, LAT, LON, SINK_TYPE FROM SITE_INJECTION_TERMINALS"
                Set rsTo = CurrentDb.OpenRecordset(sqlTo, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                    sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![SITE_NAME]) + "','CAPSITE','" + rsTo![T_NODE] + "','INJSITE'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                    CurrentDb.Execute (sqlIns)
                    rsTo.MoveNext
                Loop
                rsTo.Close
                
                ' select assessed pipe options based on heuristic logic
                tmpCount = 0
                ' retrieve the pipe diameters for the option set of generating units at this site
                sqlIns = "SELECT DIAMETER FROM PIPE_DIAMETER_SET WHERE (LOWER_BOUND <= " + CStr(rsFrom![Tot_CO2_Control]) + " AND UPPER_BOUND > " + CStr(rsFrom![Tot_CO2_Control]) + ")"
                
                Set rs = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rs.MoveLast
                ReDim sOpt(rs.RecordCount - 1)
                rs.MoveFirst
                Do While Not rs.EOF
                  sOpt(tmpCount) = rs!Diameter
                  tmpCount = tmpCount + 1
                  rs.MoveNext
                Loop
                
                tmpCount = 0
                
                ' select direct pipes first
                If cDirG > 0 Then
                    sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt WHERE TO_TYPE = 'INJSITE' ORDER BY SINK_TYPE,DISTANCE ASC"
                    Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                    Do While Not rsTo.EOF
                        ' insert the pipe distance and options
                        AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                        ' remove the pipe option from our temp table to avoid double counting later
                        sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                        CurrentDb.Execute (sqlIns)
                        tmpCount = tmpCount + 1
                        rsTo.MoveNext
                        If tmpCount >= cDirG Then Exit Do
                    Loop
                    rsTo.Close
                End If
                
                ' First make sure there is at least one pipe to an EOR+Saline TNODE
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY SINK_TYPE,DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rsTo.MoveFirst
                If Not rsTo.EOF Then
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                End If
                rsTo.Close
                
                ' now select remaining pipes
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    If (tmpCount >= cOptMax) Or (tmpCount >= cOptMin And rsTo![Distance] > cDistMax) Then Exit Do
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                    rsTo.MoveNext
                Loop
                rsTo.Close
            End If
            
            ' Make sure there is at least one pipe to a transshipment node
            CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
            sqlTo = "SELECT SITE_NAME, LAT, LON, 'T' AS SINK_TYPE FROM SITE_TRANSSHIP"
            sql = Replace(sqlTo, "SITE_TRANSSHIP", HubOption)
            Set rsTo = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
            Do While Not rsTo.EOF
                tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![SITE_NAME]) + "','CAPSITE','" + rsTo![SITE_NAME] + "','TRANSSHIP'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                CurrentDb.Execute (sqlIns)
                rsTo.MoveNext
            Loop
            rsTo.Close
            
            sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
            Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
            rsTo.MoveFirst
            If Not rsTo.EOF Then
                ' insert the pipe distance and options
                AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
            End If
            rsTo.Close
            
            rsFrom.MoveNext
        Loop
        rsFrom.Close
        CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
        RetVal = SysCmd(acSysCmdRemoveMeter)
    End If
    
        ' II.D. Build direct pipe options from generic DAC facilities
    If Me.cbx_InclExistingPowerPlants.Value <> 0 Then
        'sqlFrom = "SELECT SITE_NAME, LAT, LON, FuelRegion, Tot_CO2_Control FROM SITE_ETHANOL_GEN GROUP BY SITE_NAME, LAT, LON"
        sqlFrom = "SELECT SITE_NAME, LAT, LON, FuelRegion, TotalCap FROM SITE_DAC_FR_PSEUDO"
        Set rsFrom = CurrentDb.OpenRecordset(sqlFrom, dbOpenSnapshot)
        rsFrom.MoveLast
        RetVal = SysCmd(acSysCmdInitMeter, "Generating direct pipes from generic DAC sites...", rsFrom.RecordCount)
        rsFrom.MoveFirst
        Cur_Count = 0
        Do While Not rsFrom.EOF
            Cur_Count = Cur_Count + 1
            RetVal = SysCmd(acSysCmdUpdateMeter, Cur_Count)
            sqlIns = "DELETE FROM tmp_pipe_opt"
            CurrentDb.Execute (sqlIns)
            ' set the regional pipe heuristic parameters
            setParameters 1, cOptMin, cOptMax, cDistMax, sFactor
            ' assess pipe options to saline storage sites
            If cOptMin > 0 Or cOptMax > 0 Then
                
                sqlTo = "SELECT T_NODE, LAT, LON, SINK_TYPE FROM SITE_INJECTION_TERMINALS"
                Set rsTo = CurrentDb.OpenRecordset(sqlTo, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                    sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![SITE_NAME]) + "','CAPSITE','" + rsTo![T_NODE] + "','INJSITE'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                    CurrentDb.Execute (sqlIns)
                    rsTo.MoveNext
                Loop
                rsTo.Close
                
                ' select assessed pipe options based on heuristic logic
                tmpCount = 0
                ' retrieve the pipe diameters for the option set of generating units at this site
                sqlIns = "SELECT DIAMETER FROM PIPE_DIAMETER_SET WHERE (LOWER_BOUND <= " + CStr(rsFrom![TotalCap]) + " AND UPPER_BOUND > " + CStr(rsFrom![TotalCap]) + ")"
                
                Set rs = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rs.MoveLast
                ReDim sOpt(rs.RecordCount - 1)
                rs.MoveFirst
                Do While Not rs.EOF
                  sOpt(tmpCount) = rs!Diameter
                  tmpCount = tmpCount + 1
                  rs.MoveNext
                Loop
                
                tmpCount = 0
                
                ' select direct pipes first
                If cDirG > 0 Then
                    sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt WHERE TO_TYPE = 'INJSITE' ORDER BY SINK_TYPE,DISTANCE ASC"
                    Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                    Do While Not rsTo.EOF
                        ' insert the pipe distance and options
                        AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                        ' remove the pipe option from our temp table to avoid double counting later
                        sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                        CurrentDb.Execute (sqlIns)
                        tmpCount = tmpCount + 1
                        rsTo.MoveNext
                        If tmpCount >= cDirG Then Exit Do
                    Loop
                    rsTo.Close
                End If
                
                ' First make sure there is at least one pipe to an EOR+Saline TNODE
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY SINK_TYPE,DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rsTo.MoveFirst
                If Not rsTo.EOF Then
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                End If
                rsTo.Close
                
                ' now select remaining pipes
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    If (tmpCount >= cOptMax) Or (tmpCount >= cOptMin And rsTo![Distance] > cDistMax) Then Exit Do
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                    rsTo.MoveNext
                Loop
                rsTo.Close
            End If
            
            ' Make sure there is at least one pipe to a transshipment node
            CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
            sqlTo = "SELECT SITE_NAME, LAT, LON, 'T' AS SINK_TYPE FROM SITE_TRANSSHIP"
            sql = Replace(sqlTo, "SITE_TRANSSHIP", HubOption)
            Set rsTo = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
            Do While Not rsTo.EOF
                tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![SITE_NAME]) + "','CAPSITE','" + rsTo![SITE_NAME] + "','TRANSSHIP'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                CurrentDb.Execute (sqlIns)
                rsTo.MoveNext
            Loop
            rsTo.Close
            
            sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
            Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
            rsTo.MoveFirst
            If Not rsTo.EOF Then
                ' insert the pipe distance and options
                AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
            End If
            rsTo.Close
            
            rsFrom.MoveNext
        Loop
        rsFrom.Close
        CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
        RetVal = SysCmd(acSysCmdRemoveMeter)
    End If
    
    ' II.E. Build direct pipe options from existing CEMENT facilities
    If Me.cbx_InclExistingPowerPlants.Value <> 0 Then
        sqlFrom = "SELECT PLANT_ID, LAT, LON, sum(Tot_CO2_Control) as TOT_CO2 FROM SITE_CEMENT_COORDS GROUP BY PLANT_ID, LAT, LON"
        Set rsFrom = CurrentDb.OpenRecordset(sqlFrom, dbOpenSnapshot)
        rsFrom.MoveLast
        RetVal = SysCmd(acSysCmdInitMeter, "Generating direct pipes from existing cement sites...", rsFrom.RecordCount)
        rsFrom.MoveFirst
        Cur_Count = 0
        Do While Not rsFrom.EOF
            Cur_Count = Cur_Count + 1
            RetVal = SysCmd(acSysCmdUpdateMeter, Cur_Count)
            sqlIns = "DELETE FROM tmp_pipe_opt"
            CurrentDb.Execute (sqlIns)
            ' set the regional pipe heuristic parameters
            setParameters 1, cOptMin, cOptMax, cDistMax, sFactor
            ' assess pipe options to saline storage sites
            If cOptMin > 0 Or cOptMax > 0 Then
                
                sqlTo = "SELECT T_NODE, LAT, LON, SINK_TYPE FROM SITE_INJECTION_TERMINALS"
                Set rsTo = CurrentDb.OpenRecordset(sqlTo, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                    sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![PLANT_ID]) + "','CAPSITE','" + rsTo![T_NODE] + "','INJSITE'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                    CurrentDb.Execute (sqlIns)
                    rsTo.MoveNext
                Loop
                rsTo.Close
                
                ' select assessed pipe options based on heuristic logic
                tmpCount = 0
                ' retrieve the pipe diameters for the option set of generating units at this site
                sqlIns = "SELECT DIAMETER FROM PIPE_DIAMETER_SET WHERE (LOWER_BOUND <= " + CStr(rsFrom![TOT_CO2]) + " AND UPPER_BOUND > " + CStr(rsFrom![TOT_CO2]) + ")"
                
                Set rs = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rs.MoveLast
                ReDim sOpt(rs.RecordCount - 1)
                rs.MoveFirst
                Do While Not rs.EOF
                  sOpt(tmpCount) = rs!Diameter
                  tmpCount = tmpCount + 1
                  rs.MoveNext
                Loop
                
                tmpCount = 0
                
                ' select direct pipes first
                If cDirG > 0 Then
                    sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt WHERE TO_TYPE = 'INJSITE' ORDER BY SINK_TYPE,DISTANCE ASC"
                    Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                    Do While Not rsTo.EOF
                        ' insert the pipe distance and options
                        AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                        ' remove the pipe option from our temp table to avoid double counting later
                        sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                        CurrentDb.Execute (sqlIns)
                        tmpCount = tmpCount + 1
                        rsTo.MoveNext
                        If tmpCount >= cDirG Then Exit Do
                    Loop
                    rsTo.Close
                End If
                
                ' First make sure there is at least one pipe to an EOR+Saline TNODE
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY SINK_TYPE,DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rsTo.MoveFirst
                If Not rsTo.EOF Then
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                End If
                rsTo.Close
                
                ' now select remaining pipes
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    If (tmpCount >= cOptMax) Or (tmpCount >= cOptMin And rsTo![Distance] > cDistMax) Then Exit Do
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                    rsTo.MoveNext
                Loop
                rsTo.Close
            End If
            
            ' Make sure there is at least one pipe to a transshipment node
            CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
            sqlTo = "SELECT SITE_NAME, LAT, LON, 'T' AS SINK_TYPE FROM SITE_TRANSSHIP"
            sql = Replace(sqlTo, "SITE_TRANSSHIP", HubOption)
            Set rsTo = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
            Do While Not rsTo.EOF
                tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![PLANT_ID]) + "','CAPSITE','" + rsTo![SITE_NAME] + "','TRANSSHIP'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                CurrentDb.Execute (sqlIns)
                rsTo.MoveNext
            Loop
            rsTo.Close
            
            sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
            Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
            rsTo.MoveFirst
            If Not rsTo.EOF Then
                ' insert the pipe distance and options
                AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
            End If
            rsTo.Close
            
            rsFrom.MoveNext
        Loop
        rsFrom.Close
        CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
        RetVal = SysCmd(acSysCmdRemoveMeter)
    End If
    
     ' II.F. Build direct pipe options from new CEMENT facilities
    If Me.cbx_InclExistingPowerPlants.Value <> 0 Then
        sqlFrom = "SELECT PLANT_ID, LAT, LON, sum(TOTAL_CO2) as TOT_CO2 FROM CEMENT_NEW_FULL GROUP BY PLANT_ID, LAT, LON"
        Set rsFrom = CurrentDb.OpenRecordset(sqlFrom, dbOpenSnapshot)
        rsFrom.MoveLast
        RetVal = SysCmd(acSysCmdInitMeter, "Generating direct pipes from new cement sites...", rsFrom.RecordCount)
        rsFrom.MoveFirst
        Cur_Count = 0
        Do While Not rsFrom.EOF
            Cur_Count = Cur_Count + 1
            RetVal = SysCmd(acSysCmdUpdateMeter, Cur_Count)
            sqlIns = "DELETE FROM tmp_pipe_opt"
            CurrentDb.Execute (sqlIns)
            ' set the regional pipe heuristic parameters
            setParameters 1, cOptMin, cOptMax, cDistMax, sFactor
            ' assess pipe options to saline storage sites
            If cOptMin > 0 Or cOptMax > 0 Then
                
                sqlTo = "SELECT T_NODE, LAT, LON, SINK_TYPE FROM SITE_INJECTION_TERMINALS"
                Set rsTo = CurrentDb.OpenRecordset(sqlTo, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                    sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![PLANT_ID]) + "','CAPSITE','" + rsTo![T_NODE] + "','INJSITE'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                    CurrentDb.Execute (sqlIns)
                    rsTo.MoveNext
                Loop
                rsTo.Close
                
                ' select assessed pipe options based on heuristic logic
                tmpCount = 0
                ' retrieve the pipe diameters for the option set of generating units at this site
                sqlIns = "SELECT DIAMETER FROM PIPE_DIAMETER_SET WHERE (LOWER_BOUND <= " + CStr(rsFrom![TOT_CO2]) + " AND UPPER_BOUND > " + CStr(rsFrom![TOT_CO2]) + ")"
                
                Set rs = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rs.MoveLast
                ReDim sOpt(rs.RecordCount - 1)
                rs.MoveFirst
                Do While Not rs.EOF
                  sOpt(tmpCount) = rs!Diameter
                  tmpCount = tmpCount + 1
                  rs.MoveNext
                Loop
                
                tmpCount = 0
                
                ' select direct pipes first
                If cDirG > 0 Then
                    sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt WHERE TO_TYPE = 'INJSITE' ORDER BY SINK_TYPE,DISTANCE ASC"
                    Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                    Do While Not rsTo.EOF
                        ' insert the pipe distance and options
                        AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                        ' remove the pipe option from our temp table to avoid double counting later
                        sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                        CurrentDb.Execute (sqlIns)
                        tmpCount = tmpCount + 1
                        rsTo.MoveNext
                        If tmpCount >= cDirG Then Exit Do
                    Loop
                    rsTo.Close
                End If
                
                ' First make sure there is at least one pipe to an EOR+Saline TNODE
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY SINK_TYPE,DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rsTo.MoveFirst
                If Not rsTo.EOF Then
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                End If
                rsTo.Close
                
                ' now select remaining pipes
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    If (tmpCount >= cOptMax) Or (tmpCount >= cOptMin And rsTo![Distance] > cDistMax) Then Exit Do
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                    rsTo.MoveNext
                Loop
                rsTo.Close
            End If
            
            ' Make sure there is at least one pipe to a transshipment node
            CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
            sqlTo = "SELECT SITE_NAME, LAT, LON, 'T' AS SINK_TYPE FROM SITE_TRANSSHIP"
            sql = Replace(sqlTo, "SITE_TRANSSHIP", HubOption)
            Set rsTo = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
            Do While Not rsTo.EOF
                tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![PLANT_ID]) + "','CAPSITE','" + rsTo![SITE_NAME] + "','TRANSSHIP'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                CurrentDb.Execute (sqlIns)
                rsTo.MoveNext
            Loop
            rsTo.Close
            
            sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
            Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
            rsTo.MoveFirst
            If Not rsTo.EOF Then
                ' insert the pipe distance and options
                AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
            End If
            rsTo.Close
            
            rsFrom.MoveNext
        Loop
        rsFrom.Close
        CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
        RetVal = SysCmd(acSysCmdRemoveMeter)
    End If
    
         ' II. build direct pipe options from existing power generation facilities
    If Me.cbx_InclExistingPowerPlants.Value <> 0 Then
        sqlFrom = "SELECT SITE_NAME, LAT, LON, EMM_REGION FROM SITE_CAPTURE_GEN_EXS GROUP BY SITE_NAME, LAT, LON, EMM_REGION"
        Set rsFrom = CurrentDb.OpenRecordset(sqlFrom, dbOpenSnapshot)
        rsFrom.MoveLast
        RetVal = SysCmd(acSysCmdInitMeter, "Generating direct pipes from existing power sites...", rsFrom.RecordCount)
        rsFrom.MoveFirst
        Cur_Count = 0
        Do While Not rsFrom.EOF
            Cur_Count = Cur_Count + 1
            RetVal = SysCmd(acSysCmdUpdateMeter, Cur_Count)
            sqlIns = "DELETE FROM tmp_pipe_opt"
            CurrentDb.Execute (sqlIns)
            ' set the regional pipe heuristic parameters
            setParameters rsFrom![EMM_REGION], cOptMin, cOptMax, cDistMax, sFactor
            ' assess pipe options to saline storage sites
            If cOptMin > 0 Or cOptMax > 0 Then
                
                sqlTo = "SELECT T_NODE, LAT, LON, SINK_TYPE FROM SITE_INJECTION_TERMINALS"
                Set rsTo = CurrentDb.OpenRecordset(sqlTo, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                    sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![SITE_NAME]) + "','CAPSITE','" + rsTo![T_NODE] + "','INJSITE'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                    CurrentDb.Execute (sqlIns)
                    rsTo.MoveNext
                Loop
                rsTo.Close
                
                ' select assessed pipe options based on heuristic logic
                tmpCount = 0
                ' retrieve the pipe diameters for the option set of generating units at this site
                sOpt = GetPlantPipeSizes(rsFrom![SITE_NAME])
                ' select direct pipes first
                If cDirG > 0 Then
                    sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt WHERE TO_TYPE = 'INJSITE' ORDER BY SINK_TYPE,DISTANCE ASC"
                    Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                    Do While Not rsTo.EOF
                        ' insert the pipe distance and options
                        AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                        ' remove the pipe option from our temp table to avoid double counting later
                        sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                        CurrentDb.Execute (sqlIns)
                        tmpCount = tmpCount + 1
                        rsTo.MoveNext
                        If tmpCount >= cDirG Then Exit Do
                    Loop
                    rsTo.Close
                End If
                
                ' First make sure there is at least one pipe to an EOR+Saline TNODE
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY SINK_TYPE,DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                rsTo.MoveFirst
                If Not rsTo.EOF Then
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                End If
                rsTo.Close
                
                ' now select remaining pipes
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    If (tmpCount >= cOptMax) Or (tmpCount >= cOptMin And rsTo![Distance] > cDistMax) Then Exit Do
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    tmpCount = tmpCount + 1
                    rsTo.MoveNext
                Loop
                rsTo.Close
            End If
            
            ' Make sure there is at least one pipe to a transshipment node
            CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
            sqlTo = "SELECT SITE_NAME, LAT, LON, 'T' AS SINK_TYPE FROM SITE_TRANSSHIP"
            sql = Replace(sqlTo, "SITE_TRANSSHIP", HubOption)
            Set rsTo = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
            Do While Not rsTo.EOF
                tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![SITE_NAME]) + "','CAPSITE','" + rsTo![SITE_NAME] + "','TRANSSHIP'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                CurrentDb.Execute (sqlIns)
                rsTo.MoveNext
            Loop
            rsTo.Close
            
            sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
            Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
            rsTo.MoveFirst
            If Not rsTo.EOF Then
                ' insert the pipe distance and options
                AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
            End If
            rsTo.Close
            
            rsFrom.MoveNext
        Loop
        rsFrom.Close
        CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
        RetVal = SysCmd(acSysCmdRemoveMeter)
    End If
    
    ' III. build pipes from the new build power generation facilities
    If Me.cbx_InclUnplannedPowerPlants.Value <> 0 Then
        ReDim sOpt(2)
        sOpt(0) = 12
        sOpt(1) = 16
        sOpt(2) = 20
         sqlFrom = "SELECT SITE_NAME, FUELREGION, ORD, LAT, LON FROM SITE_CAPTURE_GEN_NEW"
        Set rsFrom = CurrentDb.OpenRecordset(sqlFrom, dbOpenSnapshot)
        rsFrom.MoveLast
        RetVal = SysCmd(acSysCmdInitMeter, "Generating pipes from new build sites...", rsFrom.RecordCount)
        rsFrom.MoveFirst
        Cur_Count = 0
        Do While Not rsFrom.EOF
            Cur_Count = Cur_Count + 1
            RetVal = SysCmd(acSysCmdUpdateMeter, Cur_Count)
            sqlIns = "DELETE FROM tmp_pipe_opt"
            CurrentDb.Execute (sqlIns)
            
            sqlTo = "SELECT T_NODE, LAT, LON, SINK_TYPE FROM SITE_INJECTION_TERMINALS"
            Set rsTo = CurrentDb.OpenRecordset(sqlTo, dbOpenSnapshot)
            Do While Not rsTo.EOF
                tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![SITE_NAME]) + "','CAPSITE','" + rsTo![T_NODE] + "','INJSITE'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                CurrentDb.Execute (sqlIns)
                rsTo.MoveNext
            Loop
            rsTo.Close
            
            ' select assessed pipe options based on heuristic logic
            tmpCount = 0
            ' select direct pipes first
            If cDirG > 0 Then
                sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt WHERE TO_TYPE = 'INJSITE' ORDER BY SINK_TYPE,DISTANCE ASC"
                Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    ' insert the pipe distance and options
                    AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                    ' remove the pipe option from our temp table to avoid double counting later
                    sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                    CurrentDb.Execute (sqlIns)
                    ' update the counters and exit if we've hit the heuristic parameters
                    tmpCount = tmpCount + 1
                    If tmpCount >= cDirG Then Exit Do
                    rsTo.MoveNext
                Loop
            End If
            
            ' First make sure there is at least one pipe to an EOR+Saline TNODE
            sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY SINK_TYPE,DISTANCE ASC"
            Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
            rsTo.MoveFirst
            If Not rsTo.EOF Then
                ' insert the pipe distance and options
                AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                ' remove the pipe option from our temp table to avoid double counting later
                sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                CurrentDb.Execute (sqlIns)
                tmpCount = tmpCount + 1
            End If
            rsTo.Close
            
            ' now select remaining pipes
            sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
            Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
            Do While Not rsTo.EOF
                ' exit if we've hit the heuristic parameters
                If (tmpCount >= cOptMax) Or (tmpCount >= cOptMin And rsTo![Distance] > cDistMax) Then Exit Do
                ' insert the pipe distance and options
                AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
                ' remove the pipe option from our temp table to avoid double counting later
                sqlIns = "DELETE FROM tmp_pipe_opt WHERE FROM_NODE='" + rsTo![FROM_NODE] + "' AND TO_NODE = '" + rsTo![TO_NODE] + "'"
                CurrentDb.Execute (sqlIns)
                ' update the counters
                tmpCount = tmpCount + 1
                rsTo.MoveNext
            Loop
            
            ' Make sure there is at least one pipe to a transshipment node
            CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
            sqlTo = "SELECT SITE_NAME, LAT, LON, 'T' AS SINK_TYPE FROM SITE_TRANSSHIP"
            sql = Replace(sqlTo, "SITE_TRANSSHIP", HubOption)
            Set rsTo = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
            Do While Not rsTo.EOF
                tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![SITE_NAME]) + "','CAPSITE','" + rsTo![SITE_NAME] + "','TRANSSHIP'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                CurrentDb.Execute (sqlIns)
                rsTo.MoveNext
            Loop
            rsTo.Close
            
            sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
            Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
            rsTo.MoveFirst
            If Not rsTo.EOF Then
                ' insert the pipe distance and options
                AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], rsTo![Distance], sOpt
            End If
            rsTo.Close
            
            rsFrom.MoveNext
        Loop
        rsFrom.Close
        CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
        RetVal = SysCmd(acSysCmdRemoveMeter)
    End If
    
    
    ' IV. build pipes from the transshipment points
    If tShip Then
        
        sqlFrom = "SELECT SITE_NAME, LAT, LON, DIST_RADIUS, COLL_RADIUS, SHIP_RADIUS FROM SITE_TRANSSHIP"
        sql = Replace(sqlFrom, "SITE_TRANSSHIP", HubOption)
        Set rsFrom = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
        rsFrom.MoveLast
        RetVal = SysCmd(acSysCmdInitMeter, "Generating pipes from transshipment points...", rsFrom.RecordCount)
        rsFrom.MoveFirst
        Cur_Count = 0
        Do While Not rsFrom.EOF
            Cur_Count = Cur_Count + 1
            RetVal = SysCmd(acSysCmdUpdateMeter, Cur_Count)
            sqlIns = "DELETE FROM tmp_pipe_opt"
            CurrentDb.Execute (sqlIns)
            
            ' A. create collection pipes if the collection radius is greater than 0
            If rsFrom![COLL_RADIUS] > 0 Then
            
                ' 1. create collection pipes from existing power plants if existing power plants are enabled
                If Me.cbx_InclExistingPowerPlants.Value <> 0 Then
                    sqlTo = "SELECT SITE_NAME, LAT, LON FROM SITE_CAPTURE_GEN_EXS GROUP BY SITE_NAME, LAT, LON"
                    Set rsTo = CurrentDb.OpenRecordset(sqlTo, dbOpenSnapshot)
                    Do While Not rsTo.EOF
                        tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                        If tDist <= rsFrom![COLL_RADIUS] Then
                            sOpt = GetPlantPipeSizes(rsTo![SITE_NAME])
                            AddPipes rsTo![SITE_NAME], rsFrom![SITE_NAME], tDist, sOpt
                        End If
                        rsTo.MoveNext
                    Loop
                    rsTo.Close
                End If
                
                ' 2. create collection pipes from new build power plants
                If Me.cbx_InclUnplannedPowerPlants.Value <> 0 Then
                    ReDim sOpt(1)
                    sOpt(0) = 16
                    sOpt(1) = 24
                    sqlTo = "SELECT SITE_NAME, LAT, LON FROM SITE_CAPTURE_GEN_NEW"
                    Set rsTo = CurrentDb.OpenRecordset(sqlTo, dbOpenSnapshot)
                    Do While Not rsTo.EOF
                        tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                        If tDist <= rsFrom![COLL_RADIUS] Then
                            AddPipes rsTo![SITE_NAME], rsFrom![SITE_NAME], tDist, sOpt
                        End If
                        rsTo.MoveNext
                    Loop
                    rsTo.Close
                End If
                
            End If
            
            ' B. create distribution pipes if the distribution radius is greater than 0
            If rsFrom![DIST_RADIUS] > 0 Then
                ReDim sOpt(3)
                sOpt(0) = 12
                sOpt(1) = 16
                sOpt(2) = 24
                sOpt(3) = 36
                sqlTo = "SELECT T_NODE, LAT, LON, EMM_REGION FROM SITE_INJECTION_TERMINALS"
                Set rsTo = CurrentDb.OpenRecordset(sqlTo, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                    If tDist <= rsFrom![DIST_RADIUS] Then
                        AddPipes rsFrom![SITE_NAME], rsTo![T_NODE], tDist, sOpt
                    End If
                    CurrentDb.Execute (sqlIns)
                    rsTo.MoveNext
                Loop
                rsTo.Close
            End If
            
            ' C. create collection to distribution shipment pipes if the shipment radius is greater than 0
            If rsFrom![SHIP_RADIUS] > 0 Then
                ReDim sOpt(3)
                sOpt(0) = 12
                sOpt(1) = 16
                sOpt(2) = 24
                sOpt(3) = 36
                sqlTo = "SELECT SITE_NAME, LAT, LON FROM SITE_TRANSSHIP WHERE SITE_NAME <> '" & rsFrom![SITE_NAME] & "'"
                sql = Replace(sqlTo, "SITE_TRANSSHIP", HubOption)
                Set rsTo = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
                Do While Not rsTo.EOF
                    tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                    If tDist <= rsFrom![SHIP_RADIUS] Then
                        AddPipes rsFrom![SITE_NAME], rsTo![SITE_NAME], tDist, sOpt
                    End If
                    rsTo.MoveNext
                Loop
                rsTo.Close
            End If
            
            ' D. Make sure there is at least one pipe to another transshipment node
            CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
            sqlTo = "SELECT SITE_NAME, LAT, LON, 'T' AS SINK_TYPE FROM SITE_TRANSSHIP WHERE SITE_NAME <> '" & rsFrom![SITE_NAME] & "'"
            sql = Replace(sqlTo, "SITE_TRANSSHIP", HubOption)
            Set rsTo = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
            Do While Not rsTo.EOF
                tDist = Node2NodeDist(rsFrom![LAT], rsFrom![LON], rsTo![LAT], rsTo![LON]) * DMult
                sqlIns = "INSERT INTO tmp_pipe_opt (FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE) VALUES ('" + CStr(rsFrom![SITE_NAME]) + "','CAPSITE','" + rsTo![SITE_NAME] + "','TRANSSHIP'," + CStr(tDist) + ",'" + rsTo![SINK_TYPE] + "')"
                CurrentDb.Execute (sqlIns)
                rsTo.MoveNext
            Loop
            rsTo.Close
            
            sqlIns = "SELECT FROM_NODE, FROM_TYPE, TO_NODE, TO_TYPE, DISTANCE, SINK_TYPE FROM tmp_pipe_opt ORDER BY DISTANCE ASC"
            Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
            rsTo.MoveFirst
            If Not rsTo.EOF Then
                ' insert the pipe distance and options
                AddPipes rsTo![FROM_NODE], rsTo![TO_NODE], tDist, sOpt
            End If
            rsTo.Close
            
            rsFrom.MoveNext
        Loop
        rsFrom.Close
        CurrentDb.Execute "DELETE FROM tmp_pipe_opt"
        RetVal = SysCmd(acSysCmdRemoveMeter)
    End If
  '  CurrentDb.Execute "DROP TABLE tmp_pipe_opt"
End Sub

Public Function CheckExist(FromNode As String, ToNode As String) As Boolean
    Dim sql As String
    Dim rs As DAO.Recordset
    sql = "SELECT * FROM PIPE_EXIST WHERE FROM_NODE = '" & FromNode & "' AND TO_NODE = '" & ToNode & "'"
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    If Not rs.EOF Then
        CheckExist = True
    Else
        CheckExist = False
    End If
    rs.Close
End Function

Public Function GetPlantPipeSizes(SiteName As String) As Integer()
    Dim sOpt() As Integer, sqlQry As String
    ReDim sOpt(0)
    Dim count As Integer
    Dim rsD As DAO.Recordset
    sqlQry = "SELECT PLANT_CODE, HeatRate, SCAP, R_CO2 FROM SITE_CAPTURE_GEN_EXS WHERE SITE_NAME = '" + SiteName + "'"
    Set rsD = CurrentDb.OpenRecordset(sqlQry, dbOpenSnapshot)
    Dim ArrSize As Integer
    ArrSize = rsD.RecordCount
    ReDim carbOut(0) As Double
    count = -1
    ' determine the co2 output for each unit
    Do While Not rsD.EOF
        count = count + 1
        ReDim Preserve carbOut(count)
    '    carbOut(count) = 205.3 * (rsD![SCAP] / 2204000 * 365 * 24 * rsD![HEATRATE] * rsD![R_CO2] * 0.75 / 1000000)
        carbOut(count) = 205.3 * (rsD![SCAP] / 2204000 * 365 * 24 * rsD![HEATRATE] * rsD![R_CO2] / 1000000)
        rsD.MoveNext
    Loop
    ' check all combinations of co2 output
    Dim testCO2R As Double
    Dim i As Integer, j As Integer
    AddPipeDiam carbOut(0), sOpt
    For i = 0 To UBound(carbOut)
        testCO2R = carbOut(i)
        If UBound(carbOut) > 0 Then ' assess the combinations of each unit's CO2 output
            For j = i + 1 To UBound(carbOut)
                testCO2R = testCO2R + carbOut(j)
                AddPipeDiam testCO2R, sOpt
            Next j
'        Else    ' just enter pipe diameter for the single unit
'            AddPipeDiam testCO2R, sOpt
        End If
    Next i
    GetPlantPipeSizes = sOpt
End Function

Public Function AddPipeDiam(CO2R As Double, eSOpt() As Integer)
    Dim sql As String, rs As Recordset
    sql = "SELECT DIAMETER FROM PIPE_DIAMETER_SET WHERE LOWER_BOUND <= " + CStr(CO2R) + " AND UPPER_BOUND > " + CStr(CO2R)
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
    If rs.RecordCount > 1 Then
        MsgBox "WARNING: you are getting two pipe options for a single CO2 Flow rate."
    Else
        Dim i As Integer, exists As Boolean
        exists = False
        ' check if this size is already available
        For i = 0 To UBound(eSOpt)
            If eSOpt(i) = rs![Diameter] Then exists = True
        Next i
        ' if this size has not been added, resize the array and add it
        If exists = False Then
            If eSOpt(UBound(eSOpt)) <> 0 Then ReDim Preserve eSOpt(UBound(eSOpt) + 1)
            eSOpt(UBound(eSOpt)) = rs![Diameter]
        End If
    End If
End Function

Public Function AddPipes(FromNode As String, ToNode As String, Distance As Double, SizeOpt() As Integer)
    Dim sqlIns As String
    Dim rsTo As DAO.Recordset
    Dim numRows As Boolean
           
    ' Make sure this is not a duplicate record
    sqlIns = "SELECT * FROM PIPE_DIST WHERE FROM_NODE='" + FromNode + "' AND TO_NODE='" + ToNode + "'"
    Set rsTo = CurrentDb.OpenRecordset(sqlIns, dbOpenSnapshot)
        
    If rsTo.EOF Then
        ' insert into the pipe distance table
        sqlIns = "INSERT INTO PIPE_DIST (FROM_NODE, TO_NODE, DISTANCE, EXISTING) VALUES('" + FromNode + "','" + ToNode + "'," + CStr(Distance) + ", 0)"
        CurrentDb.Execute (sqlIns)
        ' insert into the pipe option table
        Dim i As Integer
        For i = 0 To UBound(SizeOpt)
            sqlIns = "INSERT INTO PIPE_OPT (FROM_NODE, TO_NODE, DIAMETER, EXISTING) VALUES('" + FromNode + "','" + ToNode + "'," + CStr(SizeOpt(i)) + ", 0)"
            CurrentDb.Execute (sqlIns)
        Next i
    End If
    rsTo.Close

End Function

' take two latitude and longitude coordinates and calculate the straight line distance in miles using the earth's curvature
Public Function Node2NodeDist(lat1 As Double, lon1 As Double, lat2 As Double, lon2 As Double) As Double
    Dim earthRadius As Double, deltaLat As Double, deltaLon As Double
    Dim a As Double, c As Double
    earthRadius = 6371
    deltaLat = radians(lat2 - lat1)
    deltaLon = radians(lon2 - lon1)
    a = (Math.Sin(deltaLat / 2) * Math.Sin(deltaLat / 2)) + (Math.Cos(radians(lat1)) * Math.Cos(radians(lat2)) * Math.Sin(deltaLon / 2) * Math.Sin(deltaLon / 2))
    c = 2 * Atan2(Sqr(1 - a), Sqr(a))
    Node2NodeDist = earthRadius * c * 0.621371192 ' with conversion to miles
End Function

' return the radians value of the specified degrees
Public Function radians(inDeg As Double) As Double
    radians = inDeg * PI / 180
End Function

' return the atan2 value -- since not in vba and only included with excel
Public Function Atan2(ByVal X As Double, ByVal Y As Double) As Double
    If X = 0 And Y = 0 Then
    Atan2 = 0
    Else
    If X = 0 Then X = 0.00000000001
    Atan2 = Atn(Y / X) - PI * (X < 0)
    End If
End Function

Function ifTableExists(tableName As String) As Boolean
   Dim rs As Recordset, Db As Database ' DAO Vars

   'References: Microsoft Access 11.0 Object Library, Microsoft DAO 3.6 Object Library
   'Set references by Clicking Tools and Then References in the Code View window
   'Checks if Table exists in MS Access.
   'USAGE: ifTableExists("TABLENAME")

   On Error GoTo NoTable 'If there is no table capture the error.

   Set Db = CurrentDb()

   'If Table is there open it
   Set rs = Db.OpenRecordset("Select * from " & tableName & ";")
   ifTableExists = True
   rs.Close

ExitHere:
   Db.Close
   Set rs = Nothing
   Set Db = Nothing

   'Notify the user the process is complete.
   'MsgBox "Check for Table Complete"
   Exit Function

NoTable:
   'If table is not there close out and set function to false
   With Err
      'MsgBox "Error " & .Number & vbCrLf & .Description, _
            vbOKOnly Or vbCritical, "ifTableExists"
   End With
   ifTableExists = False
   Resume ExitHere

End Function



Private Sub Form_Open(Cancel As Integer)

    Dim i As Long
    Me.frm_Transship.Value = 1
    Me.txf_cOptMin = 1
    Me.txf_cOptMax = 3
    Me.txf_cDistMax = 500
    Me.txf_DistMult = "1.1"
    Me.cbx_InclExistingPowerPlants.Value = 1
    Me.cbx_InclUnplannedPowerPlants.Value = 1
    For i = 1 To 22
        CurrentDb.Execute "UPDATE PIPE_HEURISTIC_PARAMETERS SET CAP_MIN_OPT = " & CStr(Me.txf_cOptMin) & ", CAP_MAX_OPT = " & CStr(Me.txf_cOptMax) & " WHERE EMM_REGION = " & CStr(i)
    Next

End Sub
