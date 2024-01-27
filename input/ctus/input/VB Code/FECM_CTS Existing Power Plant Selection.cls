VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_CTS Existing Power Plant Selection"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
' Capture Site Selection Form
' W.B. Rocheleau (brocheleau@onlocationinc.com)

Option Compare Database
Option Explicit
'Private Sub btn_SelectPowerPlants_Click()
'
'End Sub
Private Sub btn_SelectPowerPlants_Click()
    Dim sMinCap As Double, sMaxHR As Double, sOldestVin As Double

    If IsNull(Me.cbx_aeoVersion.Value) Then
        MsgBox "Please select an AEO plant file vintage."
    ElseIf IsNull(Me.txf_minUCap) = False And (IsNumeric(Me.txf_minUCap) = False Or Me.txf_minUCap < 0) Then
        MsgBox "Please enter a positive real number for the minimum unit capacity."
    ElseIf IsNull(Me.txf_maxUHeatRate) = False And (IsNumeric(Me.txf_maxUHeatRate) = False Or Me.txf_maxUHeatRate < 0) Then
        MsgBox "Please enter a positive real number for the maximum unit heat rate."
    ElseIf IsNull(Me.txf_maxUAge) = False And (IsNumeric(Me.txf_maxUAge) = False Or Me.txf_maxUAge < 0) Then
        MsgBox "Please enter a positive integer for the oldest vintage year."
    Else
        sMinCap = -1
        If IsNull(Me.txf_minUCap) = False Then sMinCap = Me.txf_minUCap
        sMaxHR = -1
        If IsNull(Me.txf_maxUHeatRate) = False Then sMaxHR = Me.txf_maxUHeatRate
        sOldestVin = -1
        If IsNull(Me.txf_maxUAge) = False Then sOldestVin = Me.txf_maxUAge
        
        SelectCaptureSites "Pltf860_" + Me.cbx_aeoVersion.Value, sMinCap, sMaxHR, sOldestVin
        MsgBox "Done selecting  selecting power plants."
    End If
End Sub

Private Sub SelectCaptureSites(pltfN As String, minCap As Double, maxHR As Double, oldestVin As Double)
    Dim rs As Recordset, sql As String
    Dim rs2 As DAO.Recordset, VarCost As Double, CapCost As Double
    Dim RetVal As Variant, Cur_Count As Integer
    Dim co2Out As Double
    
    CurrentDb.Execute "DELETE * FROM SITE_CAPTURE_GEN_EXS"         ' remove all entries from the current capturesite table
    
    Dim sqlSS As String
    sqlSS = "SELECT First(Pltf860_aeo12.PNM) AS PLANT_NAME, First(Pltf860_aeo12.NOPER) AS EMM_REGION, Pltf860_aeo12.PID AS PLANT_CODE, First(Pltf860_aeo12.STATE) as STATE, First(Pltf860_aeo12.LAT) as LAT, First(Pltf860_aeo12.LON) as LON, First(Pltf860_aeo12.UID) as UID, Pltf860_aeo12.IGRP AS IGRP, First(Pltf860_aeo12.ECP) AS ECPT, "
    sqlSS = sqlSS & Chr(13) & "Sum(Pltf860_aeo12.SUMCAP) AS SUM_CAP, First(Pltf860_aeo12.HEATRATE) AS HEATRATE, First(Pltf860_aeo12.CF) AS CF, First(ECP.CO2_RED), First(Pltf860_aeo12.SYR) AS SYR, First(FUEL_REGION_TO_STATE.FuelRegion) AS FuelRegion, First(ECP.GROUP)"
    sqlSS = sqlSS & Chr(13) & "FROM (Pltf860_aeo12 INNER JOIN ECP ON Pltf860_aeo12.ECP = ECP.ACRONYM) INNER JOIN FUEL_REGION_TO_STATE ON Pltf860_aeo12.STATE = FUEL_REGION_TO_STATE.State"
    sqlSS = sqlSS & Chr(13) & "WHERE (((Pltf860_aeo12.RYR) >= 2021))"
    sqlSS = sqlSS & Chr(13) & "GROUP BY Pltf860_aeo12.PID, Pltf860_aeo12.IGRP"
    sqlSS = sqlSS & Chr(13) & "HAVING (((First(Pltf860_aeo12.PNM)) Is Not Null) AND ((First(Pltf860_aeo12.LAT)) <> 0) AND ((First(Pltf860_aeo12.LON)) <> 0) AND ((First(Pltf860_aeo12.HEATRATE)) Is Not Null) AND ((First(Pltf860_aeo12.SYR))<2099) AND ((First(ECP.GROUP))='coal' Or (First(ECP.GROUP))='gascc') AND ((First(Pltf860_aeo12.VIN))<>6));"
  
    sql = Replace(sqlSS, "Pltf860_aeo12", pltfN)
    Set rs = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)   ' grab the record set
    rs.MoveLast
    RetVal = SysCmd(acSysCmdInitMeter, "Populating capture sites...", rs.RecordCount)
    rs.MoveFirst
    Cur_Count = 0
    Do While Not rs.EOF
        Cur_Count = Cur_Count + 1
        RetVal = SysCmd(acSysCmdUpdateMeter, Cur_Count)
        If (rs![SUM_CAP] > minCap Or minCap = -1) And (rs![HEATRATE] < maxHR Or maxHR = -1) And (rs![SYR] > oldestVin Or oldestVin = -1) Then
            ' now grab the NETL capture costs or calculate them if unavailable
            sql = "SELECT CC, VarCost FROM NETL_CAPTURE_COSTS_RAW WHERE [EIA Plt Code] = " & rs![PLANT_CODE] & " AND [Unit Id] = '" & rs![UID] & "'"
            Set rs2 = CurrentDb.OpenRecordset(sql, dbOpenSnapshot)
            If rs2.EOF And rs2.BOF Then
                'no records are available, calculate with the hags formula
                If rs![SUM_CAP] > 100 Then
                    CapCost = (-278.6 * Log(rs![SUM_CAP]) + 2872) * (rs![SUM_CAP] / 1000)
                Else
                    CapCost = (-686.2 * Log(rs![SUM_CAP]) + 5509.2) * (rs![SUM_CAP] / 1000)
                End If
                VarCost = 10
            Else
                VarCost = rs2![VarCost]
                CapCost = rs2![CC]
            End If
            If rs![ECPT] = "EC" Then
              co2Out = 117.08 * (rs![SUM_CAP] / 2204000 * 365 * 24 * rs![HEATRATE] / 1000000)
            Else
              co2Out = 203.5 * (rs![SUM_CAP] / 2204000 * 365 * 24 * rs![HEATRATE] / 1000000)
            End If
            sql = "INSERT INTO SITE_CAPTURE_GEN_EXS (PLANT_NAME, PLANT_CODE, SITE_NAME, EMM_REGION, FuelRegion, STATE, LAT, LON, UNIT_ID, IGRP, ECPT, SCAP, HeatRate, CF, R_CO2, CO2_EMIS, CAP_COST, VAR_COST, SOURCE_TYPE) VALUES "
            sql = sql + "('" + Clean(rs![PLANT_NAME]) + "'," + CStr(rs![PLANT_CODE]) + ",'CAP_GEN_P" & CStr(rs![PLANT_CODE]) & "','" & CStr(rs![EMM_REGION]) & "','" & CStr(rs![FuelRegion]) & "','" & rs![STATE] + "'," + CStr(rs![LAT])
            sql = sql + "," + CStr(rs![LON] * -1) + ",'" + rs![UID] + "'," + CStr(rs![iGRP]) + ",'" + rs![ECPT] + "'," + CStr(rs![SUM_CAP]) + "," + CStr(rs![HEATRATE]) + "," + CStr(rs![CF]) + ",0.9," + CStr(co2Out)
            sql = sql + "," + CStr(CapCost) + "," + CStr(VarCost) + ", 'GEN')"
            CurrentDb.Execute sql
        End If
        rs.MoveNext
    Loop
    rs.Close
    RetVal = SysCmd(acSysCmdRemoveMeter)
End Sub

Public Function Clean(InString As String) As String
'-- Returns only printable characters from InString
   Dim X As Integer
   For X = 1 To Len(InString)
      If Asc(Mid(InString, X, 1)) > 31 And Asc(Mid(InString, X, 1)) < 127 And Mid(InString, X, 1) <> "'" Then
         Clean = Clean & Mid(InString, X, 1)
      End If
   Next X
End Function



