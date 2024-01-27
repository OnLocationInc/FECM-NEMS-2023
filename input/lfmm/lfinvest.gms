$onempty

Set DataFile(*) /
'.\input\parameters\param\investment\lfinvestment.xlsx' /;

Set GAMSFile(*) /
'K:\lfmm\input_data\20211124_invest\cre8invest.gms' /;

Set DateTime(*) /
'11/30/21_13:31:02' /;

Set INVEST_SET(*) sets used only by investment code /
'BldRiskClass', 
'BldStep', 
'CapExpYr', 
'InvParam', 
'LrnPhase', 
'LrnSpeed', 
'LrnParam', 
'NFBaseYr', 
'ProcessRisk' /;

Set BldRiskClass(*) /
'AvgRiskPet', 
'HighRiskPet', 
'NonPet' /;

Set BldStep(*) /
'STEP01', 
'STEO02', 
'STEP03' /;

Set InvParam(*) /
'NFBaseYr' Nelson-Farr base year, 
'PCTENV' HomeOffice and Contractor fees, 
'PCTCNTG' Contractor and Owners Contingency, 
'PCTLND' Land, 
'PCTSPECL' Prepaid Royalties License and Start-up costs, 
'PCTWC' Working Capital, 
'STAFF_FAC' Supervisory and other Staffing, 
'OH_FAC' Benefits and other overhead, 
'INS_FAC' Yearly Insurance fraction of P and E, 
'TAX_FAC' Local Tax Rate fraction of P and E, 
'MAINT_FAC' Yearly Maintenance fraction of P and E, 
'OTH_FAC' Yearly Supplies OH Env fraction of P and E, 
'OSBLFAC' Ratio OSBL to ISBL, 
'BLDYRS' Construction Period in years, 
'PRJLIFE' Project Life in years, 
'PRJINFL' NOT USED Inflation Rate During Construction, 
'PRJSDECOM' 'Salvage Value Less Decommission (MM $)', 
'BEQ_OPR' equity beta opr decision, 
'EMRP_OPR' EMRP opr decision, 
'EQUITY_OPR' NOT USED - equity opr decision, 
'BEQ_BLD' equity beta� build decision, 
'EMRP_BLD' NOT USED - EMRP build decision, 
'EQUITY_BLD' equity build decision /;

Set LrnPhase(*) /
'Phase2', 
'Phase3' /;

Set LrnSpeed(*) /
'Fast', 
'Slow' /;

Set LrnParam(*) /
'A', 
'B', 
'F', 
'K', 
'M' /;

Parameter CapExpISBL(*) /
'ACU' 38695, 
'AET' 78375, 
'ALK' 37600, 
'ARP' 16709, 
'BPU' 641469, 
'BSA' 10500, 
'BTL' 835866, 
'C4I' 15830, 
'CBL' 1822476, 
'CBLCCS' 1828629, 
'CGN' 24583, 
'CLE' 266712, 
'CPL' 38695, 
'CTL' 1914198, 
'CTLCCS' 2009908, 
'DC4' 10500, 
'DC5' 10500, 
'DDA' 36057, 
'DDS' 26647, 
'EDHNEW' 65735, 
'EDMNEW' 65735, 
'EDHCCS' 69022, 
'EDMCCS' 69022, 
'FBD' 12589, 
'FCC' 140710, 
'FDS' 87944, 
'FGS' 9674, 
'FUM' 141, 
'GDS' 36057, 
'GDT' 31265, 
'GTL' 1607926, 
'H2PNEW' 48369, 
'H2PCCS' 2418450, 
'H2R' 8355, 
'HCD' 171491, 
'KRD' 143700, 
'KWG' 7036, 
'LNS' 9674, 
'LUB' 48369, 
'NCE' 338716, 
'NDS' 14900, 
'PHI' 10500, 
'RCR' 64600, 
'RGN' 1, 
'RSR' 50000, 
'SDA' 21600, 
'SEW' 130000, 
'SGP' 1, 
'STG' 24624, 
'SUL' 14071, 
'TRI' 25000, 
'UGP' 1, 
'VCU' 32539, 
'IBA' 32868, 
'LTE' 32640, 
'CSU' 100084 /;

Parameter CapExpLabor(*) /
'ACU' 727, 
'AET' 18609, 
'ALK' 812, 
'ARP' 218, 
'BPU' 46524, 
'BSA' 605, 
'BTL' 46524, 
'C4I' 727, 
'CBL' 35597, 
'CBLCCS' 35597, 
'CGN' 627, 
'CLE' 31016, 
'CPL' 218, 
'CTL' 124063.333333333, 
'CTLCCS' 124063.333333333, 
'DC4' 605, 
'DC5' 605, 
'DDA' 605, 
'DDS' 218, 
'EDHNEW' 10935, 
'EDMNEW' 10935, 
'EDHCCS' 10935, 
'EDMCCS' 10935, 
'FBD' 10856, 
'FCC' 800, 
'FDS' 218, 
'FUM' 9, 
'GDS' 218, 
'GDT' 18609, 
'GTL' 103386, 
'H2PNEW' 97, 
'H2PCCS' 97, 
'H2R' 97, 
'HCD' 727, 
'KRD' 3306, 
'KWG' 363, 
'LUB' 727, 
'NDS' 661, 
'PHI' 605, 
'RCR' 937, 
'RGN' 1, 
'RSR' 800, 
'SDA' 992, 
'SGP' 1, 
'STG' 563, 
'SUL' 363, 
'TRI' 605, 
'UGP' 1, 
'VCU' 218, 
'CSU' 363.5 /;

Parameter CapExpSize(*) /
'ACU' 100, 
'AET' 3.4, 
'ALK' 10, 
'ARP' 10, 
'BPU' 4.68, 
'BSA' 10, 
'BTL' 5.1, 
'C4I' 3, 
'CBL' 30, 
'CBLCCS' 30, 
'CGN' 1000, 
'CLE' 3.74, 
'CPL' 10, 
'CTL' 20.4, 
'CTLCCS' 20.4, 
'DC4' 10, 
'DC5' 10, 
'DDA' 25, 
'DDS' 30, 
'EDHNEW' 6.8, 
'EDMNEW' 6.8, 
'EDHCCS' 6.8, 
'EDMCCS' 6.8, 
'FBD' 1.2, 
'FCC' 40, 
'FDS' 40, 
'FGS' 20, 
'FUM' 1, 
'GDS' 25, 
'GDT' 1.995, 
'GTL' 20.4, 
'H2PNEW' 3.05, 
'H2PCCS' 3.05, 
'H2R' 2.04, 
'HCD' 40, 
'KRD' 25, 
'KWG' 1200, 
'LNS' 20, 
'LUB' 6, 
'NCE' 3.143, 
'NDS' 25, 
'PHI' 10, 
'RCR' 35, 
'RGN' 100, 
'RSR' 35, 
'SDA' 10, 
'SEW' 6.523, 
'SGP' 100, 
'STG' 600, 
'SUL' 0.2, 
'TRI' 10, 
'UGP' 100, 
'VCU' 55, 
'IBA' 5.871, 
'LTE' 100, 
'CSU' 50 /;

Set CapExpYr(*) /
'2008' /;

Set NFBaseYr(*) /
'1993' /;

Parameter NFInvest(*) /
'1993' 1310.8, 
'2008' 2251.4, 
'1990' 1225.7, 
'1991' 1252.9, 
'1992' 1277.3, 
'1994' 1349.7, 
'1995' 1392.1, 
'1996' 1418.9, 
'1997' 1449.2, 
'1998' 1477.6, 
'1999' 1497.2, 
'2000' 1542.7, 
'2001' 1579.7, 
'2002' 1642.2, 
'2003' 1710.4, 
'2004' 1833.6, 
'2005' 1918.8, 
'2006' 2008.1, 
'2007' 2106.7, 
'1981' 903.8, 
'1982' 976.9, 
'1983' 1025.8, 
'1984' 1061, 
'1985' 1074.4, 
'1986' 1089.9, 
'1987' 1121.5, 
'1988' 1164.5, 
'1989' 1195.9 /;

Parameter NFLabor(*) /
'1993' 286.2, 
'2008' 237.9, 
'1990' 270.5, 
'1991' 280.8, 
'1992' 281.1, 
'1994' 286, 
'1995' 263.2, 
'1996' 241.1, 
'1997' 241.9, 
'1998' 241, 
'1999' 239.8, 
'2000' 248.8, 
'2001' 221.1, 
'2002' 211.2, 
'2003' 200.8, 
'2004' 191.8, 
'2005' 201.9, 
'2006' 204.2, 
'2007' 215.8, 
'1981' 271.9, 
'1982' 321.8, 
'1983' 334.5, 
'1984' 308, 
'1985' 293.4, 
'1986' 259.4, 
'1987' 253.5, 
'1988' 260.8, 
'1989' 257.4 /;

Parameter NFOper(*) /
'1993' 416.9, 
'2008' 1045.1, 
'1990' 456, 
'1991' 418.6, 
'1992' 415.1, 
'1994' 431.4, 
'1995' 437, 
'1996' 462.3, 
'1997' 459.1, 
'1998' 419.2, 
'1999' 439.1, 
'2000' 553.7, 
'2001' 520.6, 
'2002' 513.7, 
'2003' 557.2, 
'2004' 638.1, 
'2005' 787.2, 
'2006' 870.7, 
'2007' 872.6, 
'1981' 562.2, 
'1982' 557.2, 
'1983' 565.5, 
'1984' 584.2, 
'1985' 551.7, 
'1986' 430.8, 
'1987' 435.6, 
'1988' 405.3, 
'1989' 429.1 /;

Parameter AFInitPlants(*) /
'BPU' 3, 
'BTL' 3, 
'CBL' 1, 
'CBLCCS' 1, 
'CLE' 3, 
'CTL' 1, 
'CTLCCS' 1, 
'FBD' 3, 
'GTL' 1, 
'HCD' 1, 
'KRD' 1, 
'NCE' 3, 
'SDA' 1, 
'IBA' 1, 
'CSU' 1 /;

Parameter AFGrowthRate(*) /
'BPU' 0.2, 
'BTL' 0.2, 
'CBL' 0.05, 
'CBLCCS' 0.05, 
'CLE' 0.2, 
'CTL' 0.05, 
'CTLCCS' 0.05, 
'FBD' 0.02, 
'GTL' 0.05, 
'HCD' 0.08, 
'KRD' 0.08, 
'NCE' 0.2, 
'SDA' 0.08, 
'IBA' 0.8, 
'CSU' 0.05 /;

Parameter AFCapMult(*,*) /
'BPU'.'STEP01' 1, 
'BPU'.'STEP03' 0.15, 
'BPU'.'STEP02' 0.15, 
'BTL'.'STEP01' 1, 
'BTL'.'STEP03' 0.15, 
'BTL'.'STEP02' 0.3, 
'CBL'.'STEP01' 1, 
'CBL'.'STEP03' 0.15, 
'CBL'.'STEP02' 0.3, 
'CBLCCS'.'STEP01' 1, 
'CBLCCS'.'STEP03' 0.15, 
'CBLCCS'.'STEP02' 0.3, 
'CLE'.'STEP01' 1, 
'CLE'.'STEP03' 0.15, 
'CLE'.'STEP02' 0.3, 
'CTL'.'STEP01' 0.33, 
'CTL'.'STEP03' 0.05, 
'CTL'.'STEP02' 0.1, 
'CTLCCS'.'STEP01' 0.33, 
'CTLCCS'.'STEP03' 0.05, 
'CTLCCS'.'STEP02' 0.1, 
'FBD'.'STEP01' 1, 
'FBD'.'STEP03' 0.05, 
'FBD'.'STEP02' 0.15, 
'GTL'.'STEP01' 0.33, 
'GTL'.'STEP03' 0.05, 
'GTL'.'STEP02' 0.1, 
'HCD'.'STEP01' 1, 
'HCD'.'STEP03' 0.25, 
'HCD'.'STEP02' 0.05, 
'KRD'.'STEP01' 1, 
'KRD'.'STEP03' 0.25, 
'KRD'.'STEP02' 0.05, 
'NCE'.'STEP01' 1, 
'NCE'.'STEP03' 0.15, 
'NCE'.'STEP02' 0.3, 
'SDA'.'STEP01' 1, 
'SDA'.'STEP03' 0.25, 
'SDA'.'STEP02' 0.05, 
'IBA'.'STEP01' 1, 
'IBA'.'STEP03' 0.15, 
'IBA'.'STEP02' 0.3, 
'CSU'.'STEP01' 1, 
'CSU'.'STEP03' 0.15, 
'CSU'.'STEP02' 0.3 /;

Parameter AFCostMult(*,*) /
'BPU'.'STEP01' 1, 
'BPU'.'STEP03' 5, 
'BPU'.'STEP02' 1.5, 
'BTL'.'STEP01' 1, 
'BTL'.'STEP03' 5, 
'BTL'.'STEP02' 1.5, 
'CBL'.'STEP01' 1, 
'CBL'.'STEP03' 5, 
'CBL'.'STEP02' 1.5, 
'CBLCCS'.'STEP01' 1, 
'CBLCCS'.'STEP03' 5, 
'CBLCCS'.'STEP02' 1.5, 
'CLE'.'STEP01' 1, 
'CLE'.'STEP03' 5, 
'CLE'.'STEP02' 1.5, 
'CTL'.'STEP01' 1, 
'CTL'.'STEP03' 5, 
'CTL'.'STEP02' 1.5, 
'CTLCCS'.'STEP01' 1, 
'CTLCCS'.'STEP03' 5, 
'CTLCCS'.'STEP02' 1.5, 
'FBD'.'STEP01' 1, 
'FBD'.'STEP03' 5, 
'FBD'.'STEP02' 1.5, 
'GTL'.'STEP01' 1, 
'GTL'.'STEP03' 5, 
'GTL'.'STEP02' 1.5, 
'HCD'.'STEP01' 1, 
'HCD'.'STEP03' 5, 
'HCD'.'STEP02' 1.5, 
'KRD'.'STEP01' 1, 
'KRD'.'STEP03' 5, 
'KRD'.'STEP02' 1.5, 
'NCE'.'STEP01' 1, 
'NCE'.'STEP03' 5, 
'NCE'.'STEP02' 1.5, 
'SDA'.'STEP01' 1, 
'SDA'.'STEP03' 5, 
'SDA'.'STEP02' 1.5, 
'IBA'.'STEP01' 1, 
'IBA'.'STEP03' 5, 
'IBA'.'STEP02' 1.5, 
'CSU'.'STEP01' 1, 
'CSU'.'STEP03' 5, 
'CSU'.'STEP02' 1.5 /;

Parameter StateTax(*,*) /
'1993'.'1_RefReg' 0.0932, 
'1993'.'2_RefReg' 0.0738, 
'1993'.'3_RefReg' 0.0738, 
'1993'.'4_RefReg' 0.0332, 
'1993'.'5_RefReg' 0.0332, 
'1993'.'6_RefReg' 0.0421, 
'1993'.'7_RefReg' 0.0676, 
'1993'.'8_RefReg' 0.0676, 
'1993'.'9_RefReg' 0.0932, 
'2008'.'1_RefReg' 0.0932, 
'2008'.'2_RefReg' 0.0738, 
'2008'.'3_RefReg' 0.0738, 
'2008'.'4_RefReg' 0.0332, 
'2008'.'5_RefReg' 0.0332, 
'2008'.'6_RefReg' 0.0421, 
'2008'.'7_RefReg' 0.0676, 
'2008'.'8_RefReg' 0.0676, 
'2008'.'9_RefReg' 0.0932, 
'1990'.'1_RefReg' 0.0932, 
'1990'.'2_RefReg' 0.0738, 
'1990'.'3_RefReg' 0.0738, 
'1990'.'4_RefReg' 0.0332, 
'1990'.'5_RefReg' 0.0332, 
'1990'.'6_RefReg' 0.0421, 
'1990'.'7_RefReg' 0.0676, 
'1990'.'8_RefReg' 0.0676, 
'1990'.'9_RefReg' 0.0932, 
'1991'.'1_RefReg' 0.0932, 
'1991'.'2_RefReg' 0.0738, 
'1991'.'3_RefReg' 0.0738, 
'1991'.'4_RefReg' 0.0332, 
'1991'.'5_RefReg' 0.0332, 
'1991'.'6_RefReg' 0.0421, 
'1991'.'7_RefReg' 0.0676, 
'1991'.'8_RefReg' 0.0676, 
'1991'.'9_RefReg' 0.0932, 
'1992'.'1_RefReg' 0.0932, 
'1992'.'2_RefReg' 0.0738, 
'1992'.'3_RefReg' 0.0738, 
'1992'.'4_RefReg' 0.0332, 
'1992'.'5_RefReg' 0.0332, 
'1992'.'6_RefReg' 0.0421, 
'1992'.'7_RefReg' 0.0676, 
'1992'.'8_RefReg' 0.0676, 
'1992'.'9_RefReg' 0.0932, 
'1994'.'1_RefReg' 0.0932, 
'1994'.'2_RefReg' 0.0738, 
'1994'.'3_RefReg' 0.0738, 
'1994'.'4_RefReg' 0.0332, 
'1994'.'5_RefReg' 0.0332, 
'1994'.'6_RefReg' 0.0421, 
'1994'.'7_RefReg' 0.0676, 
'1994'.'8_RefReg' 0.0676, 
'1994'.'9_RefReg' 0.0932, 
'1995'.'1_RefReg' 0.0932, 
'1995'.'2_RefReg' 0.0738, 
'1995'.'3_RefReg' 0.0738, 
'1995'.'4_RefReg' 0.0332, 
'1995'.'5_RefReg' 0.0332, 
'1995'.'6_RefReg' 0.0421, 
'1995'.'7_RefReg' 0.0676, 
'1995'.'8_RefReg' 0.0676, 
'1995'.'9_RefReg' 0.0932, 
'1996'.'1_RefReg' 0.0932, 
'1996'.'2_RefReg' 0.0738, 
'1996'.'3_RefReg' 0.0738, 
'1996'.'4_RefReg' 0.0332, 
'1996'.'5_RefReg' 0.0332, 
'1996'.'6_RefReg' 0.0421, 
'1996'.'7_RefReg' 0.0676, 
'1996'.'8_RefReg' 0.0676, 
'1996'.'9_RefReg' 0.0932, 
'1997'.'1_RefReg' 0.0932, 
'1997'.'2_RefReg' 0.0738, 
'1997'.'3_RefReg' 0.0738, 
'1997'.'4_RefReg' 0.0332, 
'1997'.'5_RefReg' 0.0332, 
'1997'.'6_RefReg' 0.0421, 
'1997'.'7_RefReg' 0.0676, 
'1997'.'8_RefReg' 0.0676, 
'1997'.'9_RefReg' 0.0932, 
'1998'.'1_RefReg' 0.0932, 
'1998'.'2_RefReg' 0.0738, 
'1998'.'3_RefReg' 0.0738, 
'1998'.'4_RefReg' 0.0332, 
'1998'.'5_RefReg' 0.0332, 
'1998'.'6_RefReg' 0.0421, 
'1998'.'7_RefReg' 0.0676, 
'1998'.'8_RefReg' 0.0676, 
'1998'.'9_RefReg' 0.0932, 
'1999'.'1_RefReg' 0.0932, 
'1999'.'2_RefReg' 0.0738, 
'1999'.'3_RefReg' 0.0738, 
'1999'.'4_RefReg' 0.0332, 
'1999'.'5_RefReg' 0.0332, 
'1999'.'6_RefReg' 0.0421, 
'1999'.'7_RefReg' 0.0676, 
'1999'.'8_RefReg' 0.0676, 
'1999'.'9_RefReg' 0.0932, 
'2000'.'1_RefReg' 0.0932, 
'2000'.'2_RefReg' 0.0738, 
'2000'.'3_RefReg' 0.0738, 
'2000'.'4_RefReg' 0.0332, 
'2000'.'5_RefReg' 0.0332, 
'2000'.'6_RefReg' 0.0421, 
'2000'.'7_RefReg' 0.0676, 
'2000'.'8_RefReg' 0.0676, 
'2000'.'9_RefReg' 0.0932, 
'2001'.'1_RefReg' 0.0932, 
'2001'.'2_RefReg' 0.0738, 
'2001'.'3_RefReg' 0.0738, 
'2001'.'4_RefReg' 0.0332, 
'2001'.'5_RefReg' 0.0332, 
'2001'.'6_RefReg' 0.0421, 
'2001'.'7_RefReg' 0.0676, 
'2001'.'8_RefReg' 0.0676, 
'2001'.'9_RefReg' 0.0932, 
'2002'.'1_RefReg' 0.0932, 
'2002'.'2_RefReg' 0.0738, 
'2002'.'3_RefReg' 0.0738, 
'2002'.'4_RefReg' 0.0332, 
'2002'.'5_RefReg' 0.0332, 
'2002'.'6_RefReg' 0.0421, 
'2002'.'7_RefReg' 0.0676, 
'2002'.'8_RefReg' 0.0676, 
'2002'.'9_RefReg' 0.0932, 
'2003'.'1_RefReg' 0.0932, 
'2003'.'2_RefReg' 0.0738, 
'2003'.'3_RefReg' 0.0738, 
'2003'.'4_RefReg' 0.0332, 
'2003'.'5_RefReg' 0.0332, 
'2003'.'6_RefReg' 0.0421, 
'2003'.'7_RefReg' 0.0676, 
'2003'.'8_RefReg' 0.0676, 
'2003'.'9_RefReg' 0.0932, 
'2004'.'1_RefReg' 0.0932, 
'2004'.'2_RefReg' 0.0738, 
'2004'.'3_RefReg' 0.0738, 
'2004'.'4_RefReg' 0.0332, 
'2004'.'5_RefReg' 0.0332, 
'2004'.'6_RefReg' 0.0421, 
'2004'.'7_RefReg' 0.0676, 
'2004'.'8_RefReg' 0.0676, 
'2004'.'9_RefReg' 0.0932, 
'2005'.'1_RefReg' 0.0932, 
'2005'.'2_RefReg' 0.0738, 
'2005'.'3_RefReg' 0.0738, 
'2005'.'4_RefReg' 0.0332, 
'2005'.'5_RefReg' 0.0332, 
'2005'.'6_RefReg' 0.0421, 
'2005'.'7_RefReg' 0.0676, 
'2005'.'8_RefReg' 0.0676, 
'2005'.'9_RefReg' 0.0932, 
'2006'.'1_RefReg' 0.0932, 
'2006'.'2_RefReg' 0.0738, 
'2006'.'3_RefReg' 0.0738, 
'2006'.'4_RefReg' 0.0332, 
'2006'.'5_RefReg' 0.0332, 
'2006'.'6_RefReg' 0.0421, 
'2006'.'7_RefReg' 0.0676, 
'2006'.'8_RefReg' 0.0676, 
'2006'.'9_RefReg' 0.0932, 
'2007'.'1_RefReg' 0.0932, 
'2007'.'2_RefReg' 0.0738, 
'2007'.'3_RefReg' 0.0738, 
'2007'.'4_RefReg' 0.0332, 
'2007'.'5_RefReg' 0.0332, 
'2007'.'6_RefReg' 0.0421, 
'2007'.'7_RefReg' 0.0676, 
'2007'.'8_RefReg' 0.0676, 
'2007'.'9_RefReg' 0.0932, 
'2009'.'1_RefReg' 0.0932, 
'2009'.'2_RefReg' 0.0738, 
'2009'.'3_RefReg' 0.0738, 
'2009'.'4_RefReg' 0.0332, 
'2009'.'5_RefReg' 0.0332, 
'2009'.'6_RefReg' 0.0421, 
'2009'.'7_RefReg' 0.0676, 
'2009'.'8_RefReg' 0.0676, 
'2009'.'9_RefReg' 0.0932, 
'2010'.'1_RefReg' 0.0932, 
'2010'.'2_RefReg' 0.0738, 
'2010'.'3_RefReg' 0.0738, 
'2010'.'4_RefReg' 0.0332, 
'2010'.'5_RefReg' 0.0332, 
'2010'.'6_RefReg' 0.0421, 
'2010'.'7_RefReg' 0.0676, 
'2010'.'8_RefReg' 0.0676, 
'2010'.'9_RefReg' 0.0932, 
'2011'.'1_RefReg' 0.0932, 
'2011'.'2_RefReg' 0.0738, 
'2011'.'3_RefReg' 0.0738, 
'2011'.'4_RefReg' 0.0332, 
'2011'.'5_RefReg' 0.0332, 
'2011'.'6_RefReg' 0.0421, 
'2011'.'7_RefReg' 0.0676, 
'2011'.'8_RefReg' 0.0676, 
'2011'.'9_RefReg' 0.0932, 
'2012'.'1_RefReg' 0.0932, 
'2012'.'2_RefReg' 0.0738, 
'2012'.'3_RefReg' 0.0738, 
'2012'.'4_RefReg' 0.0332, 
'2012'.'5_RefReg' 0.0332, 
'2012'.'6_RefReg' 0.0421, 
'2012'.'7_RefReg' 0.0676, 
'2012'.'8_RefReg' 0.0676, 
'2012'.'9_RefReg' 0.0932, 
'2013'.'1_RefReg' 0.0932, 
'2013'.'2_RefReg' 0.0738, 
'2013'.'3_RefReg' 0.0738, 
'2013'.'4_RefReg' 0.0332, 
'2013'.'5_RefReg' 0.0332, 
'2013'.'6_RefReg' 0.0421, 
'2013'.'7_RefReg' 0.0676, 
'2013'.'8_RefReg' 0.0676, 
'2013'.'9_RefReg' 0.0932, 
'2014'.'1_RefReg' 0.0932, 
'2014'.'2_RefReg' 0.0738, 
'2014'.'3_RefReg' 0.0738, 
'2014'.'4_RefReg' 0.0332, 
'2014'.'5_RefReg' 0.0332, 
'2014'.'6_RefReg' 0.0421, 
'2014'.'7_RefReg' 0.0676, 
'2014'.'8_RefReg' 0.0676, 
'2014'.'9_RefReg' 0.0932, 
'2015'.'1_RefReg' 0.0932, 
'2015'.'2_RefReg' 0.0738, 
'2015'.'3_RefReg' 0.0738, 
'2015'.'4_RefReg' 0.0332, 
'2015'.'5_RefReg' 0.0332, 
'2015'.'6_RefReg' 0.0421, 
'2015'.'7_RefReg' 0.0676, 
'2015'.'8_RefReg' 0.0676, 
'2015'.'9_RefReg' 0.0932, 
'2016'.'1_RefReg' 0.0932, 
'2016'.'2_RefReg' 0.0738, 
'2016'.'3_RefReg' 0.0738, 
'2016'.'4_RefReg' 0.0332, 
'2016'.'5_RefReg' 0.0332, 
'2016'.'6_RefReg' 0.0421, 
'2016'.'7_RefReg' 0.0676, 
'2016'.'8_RefReg' 0.0676, 
'2016'.'9_RefReg' 0.0932, 
'2017'.'1_RefReg' 0.0932, 
'2017'.'2_RefReg' 0.0738, 
'2017'.'3_RefReg' 0.0738, 
'2017'.'4_RefReg' 0.0332, 
'2017'.'5_RefReg' 0.0332, 
'2017'.'6_RefReg' 0.0421, 
'2017'.'7_RefReg' 0.0676, 
'2017'.'8_RefReg' 0.0676, 
'2017'.'9_RefReg' 0.0932, 
'2018'.'1_RefReg' 0.0932, 
'2018'.'2_RefReg' 0.0738, 
'2018'.'3_RefReg' 0.0738, 
'2018'.'4_RefReg' 0.0332, 
'2018'.'5_RefReg' 0.0332, 
'2018'.'6_RefReg' 0.0421, 
'2018'.'7_RefReg' 0.0676, 
'2018'.'8_RefReg' 0.0676, 
'2018'.'9_RefReg' 0.0932, 
'2019'.'1_RefReg' 0.0932, 
'2019'.'2_RefReg' 0.0738, 
'2019'.'3_RefReg' 0.0738, 
'2019'.'4_RefReg' 0.0332, 
'2019'.'5_RefReg' 0.0332, 
'2019'.'6_RefReg' 0.0421, 
'2019'.'7_RefReg' 0.0676, 
'2019'.'8_RefReg' 0.0676, 
'2019'.'9_RefReg' 0.0932, 
'2020'.'1_RefReg' 0.0932, 
'2020'.'2_RefReg' 0.0738, 
'2020'.'3_RefReg' 0.0738, 
'2020'.'4_RefReg' 0.0332, 
'2020'.'5_RefReg' 0.0332, 
'2020'.'6_RefReg' 0.0421, 
'2020'.'7_RefReg' 0.0676, 
'2020'.'8_RefReg' 0.0676, 
'2020'.'9_RefReg' 0.0932, 
'2021'.'1_RefReg' 0.0932, 
'2021'.'2_RefReg' 0.0738, 
'2021'.'3_RefReg' 0.0738, 
'2021'.'4_RefReg' 0.0332, 
'2021'.'5_RefReg' 0.0332, 
'2021'.'6_RefReg' 0.0421, 
'2021'.'7_RefReg' 0.0676, 
'2021'.'8_RefReg' 0.0676, 
'2021'.'9_RefReg' 0.0932, 
'2022'.'1_RefReg' 0.0932, 
'2022'.'2_RefReg' 0.0738, 
'2022'.'3_RefReg' 0.0738, 
'2022'.'4_RefReg' 0.0332, 
'2022'.'5_RefReg' 0.0332, 
'2022'.'6_RefReg' 0.0421, 
'2022'.'7_RefReg' 0.0676, 
'2022'.'8_RefReg' 0.0676, 
'2022'.'9_RefReg' 0.0932, 
'2023'.'1_RefReg' 0.0932, 
'2023'.'2_RefReg' 0.0738, 
'2023'.'3_RefReg' 0.0738, 
'2023'.'4_RefReg' 0.0332, 
'2023'.'5_RefReg' 0.0332, 
'2023'.'6_RefReg' 0.0421, 
'2023'.'7_RefReg' 0.0676, 
'2023'.'8_RefReg' 0.0676, 
'2023'.'9_RefReg' 0.0932, 
'2024'.'1_RefReg' 0.0932, 
'2024'.'2_RefReg' 0.0738, 
'2024'.'3_RefReg' 0.0738, 
'2024'.'4_RefReg' 0.0332, 
'2024'.'5_RefReg' 0.0332, 
'2024'.'6_RefReg' 0.0421, 
'2024'.'7_RefReg' 0.0676, 
'2024'.'8_RefReg' 0.0676, 
'2024'.'9_RefReg' 0.0932, 
'2025'.'1_RefReg' 0.0932, 
'2025'.'2_RefReg' 0.0738, 
'2025'.'3_RefReg' 0.0738, 
'2025'.'4_RefReg' 0.0332, 
'2025'.'5_RefReg' 0.0332, 
'2025'.'6_RefReg' 0.0421, 
'2025'.'7_RefReg' 0.0676, 
'2025'.'8_RefReg' 0.0676, 
'2025'.'9_RefReg' 0.0932, 
'2026'.'1_RefReg' 0.0932, 
'2026'.'2_RefReg' 0.0738, 
'2026'.'3_RefReg' 0.0738, 
'2026'.'4_RefReg' 0.0332, 
'2026'.'5_RefReg' 0.0332, 
'2026'.'6_RefReg' 0.0421, 
'2026'.'7_RefReg' 0.0676, 
'2026'.'8_RefReg' 0.0676, 
'2026'.'9_RefReg' 0.0932, 
'2027'.'1_RefReg' 0.0932, 
'2027'.'2_RefReg' 0.0738, 
'2027'.'3_RefReg' 0.0738, 
'2027'.'4_RefReg' 0.0332, 
'2027'.'5_RefReg' 0.0332, 
'2027'.'6_RefReg' 0.0421, 
'2027'.'7_RefReg' 0.0676, 
'2027'.'8_RefReg' 0.0676, 
'2027'.'9_RefReg' 0.0932, 
'2028'.'1_RefReg' 0.0932, 
'2028'.'2_RefReg' 0.0738, 
'2028'.'3_RefReg' 0.0738, 
'2028'.'4_RefReg' 0.0332, 
'2028'.'5_RefReg' 0.0332, 
'2028'.'6_RefReg' 0.0421, 
'2028'.'7_RefReg' 0.0676, 
'2028'.'8_RefReg' 0.0676, 
'2028'.'9_RefReg' 0.0932, 
'2029'.'1_RefReg' 0.0932, 
'2029'.'2_RefReg' 0.0738, 
'2029'.'3_RefReg' 0.0738, 
'2029'.'4_RefReg' 0.0332, 
'2029'.'5_RefReg' 0.0332, 
'2029'.'6_RefReg' 0.0421, 
'2029'.'7_RefReg' 0.0676, 
'2029'.'8_RefReg' 0.0676, 
'2029'.'9_RefReg' 0.0932, 
'2030'.'1_RefReg' 0.0932, 
'2030'.'2_RefReg' 0.0738, 
'2030'.'3_RefReg' 0.0738, 
'2030'.'4_RefReg' 0.0332, 
'2030'.'5_RefReg' 0.0332, 
'2030'.'6_RefReg' 0.0421, 
'2030'.'7_RefReg' 0.0676, 
'2030'.'8_RefReg' 0.0676, 
'2030'.'9_RefReg' 0.0932, 
'2031'.'1_RefReg' 0.0932, 
'2031'.'2_RefReg' 0.0738, 
'2031'.'3_RefReg' 0.0738, 
'2031'.'4_RefReg' 0.0332, 
'2031'.'5_RefReg' 0.0332, 
'2031'.'6_RefReg' 0.0421, 
'2031'.'7_RefReg' 0.0676, 
'2031'.'8_RefReg' 0.0676, 
'2031'.'9_RefReg' 0.0932, 
'2032'.'1_RefReg' 0.0932, 
'2032'.'2_RefReg' 0.0738, 
'2032'.'3_RefReg' 0.0738, 
'2032'.'4_RefReg' 0.0332, 
'2032'.'5_RefReg' 0.0332, 
'2032'.'6_RefReg' 0.0421, 
'2032'.'7_RefReg' 0.0676, 
'2032'.'8_RefReg' 0.0676, 
'2032'.'9_RefReg' 0.0932, 
'2033'.'1_RefReg' 0.0932, 
'2033'.'2_RefReg' 0.0738, 
'2033'.'3_RefReg' 0.0738, 
'2033'.'4_RefReg' 0.0332, 
'2033'.'5_RefReg' 0.0332, 
'2033'.'6_RefReg' 0.0421, 
'2033'.'7_RefReg' 0.0676, 
'2033'.'8_RefReg' 0.0676, 
'2033'.'9_RefReg' 0.0932, 
'2034'.'1_RefReg' 0.0932, 
'2034'.'2_RefReg' 0.0738, 
'2034'.'3_RefReg' 0.0738, 
'2034'.'4_RefReg' 0.0332, 
'2034'.'5_RefReg' 0.0332, 
'2034'.'6_RefReg' 0.0421, 
'2034'.'7_RefReg' 0.0676, 
'2034'.'8_RefReg' 0.0676, 
'2034'.'9_RefReg' 0.0932, 
'2035'.'1_RefReg' 0.0932, 
'2035'.'2_RefReg' 0.0738, 
'2035'.'3_RefReg' 0.0738, 
'2035'.'4_RefReg' 0.0332, 
'2035'.'5_RefReg' 0.0332, 
'2035'.'6_RefReg' 0.0421, 
'2035'.'7_RefReg' 0.0676, 
'2035'.'8_RefReg' 0.0676, 
'2035'.'9_RefReg' 0.0932, 
'2036'.'1_RefReg' 0.0932, 
'2036'.'2_RefReg' 0.0738, 
'2036'.'3_RefReg' 0.0738, 
'2036'.'4_RefReg' 0.0332, 
'2036'.'5_RefReg' 0.0332, 
'2036'.'6_RefReg' 0.0421, 
'2036'.'7_RefReg' 0.0676, 
'2036'.'8_RefReg' 0.0676, 
'2036'.'9_RefReg' 0.0932, 
'2037'.'1_RefReg' 0.0932, 
'2037'.'2_RefReg' 0.0738, 
'2037'.'3_RefReg' 0.0738, 
'2037'.'4_RefReg' 0.0332, 
'2037'.'5_RefReg' 0.0332, 
'2037'.'6_RefReg' 0.0421, 
'2037'.'7_RefReg' 0.0676, 
'2037'.'8_RefReg' 0.0676, 
'2037'.'9_RefReg' 0.0932, 
'2038'.'1_RefReg' 0.0932, 
'2038'.'2_RefReg' 0.0738, 
'2038'.'3_RefReg' 0.0738, 
'2038'.'4_RefReg' 0.0332, 
'2038'.'5_RefReg' 0.0332, 
'2038'.'6_RefReg' 0.0421, 
'2038'.'7_RefReg' 0.0676, 
'2038'.'8_RefReg' 0.0676, 
'2038'.'9_RefReg' 0.0932, 
'2039'.'1_RefReg' 0.0932, 
'2039'.'2_RefReg' 0.0738, 
'2039'.'3_RefReg' 0.0738, 
'2039'.'4_RefReg' 0.0332, 
'2039'.'5_RefReg' 0.0332, 
'2039'.'6_RefReg' 0.0421, 
'2039'.'7_RefReg' 0.0676, 
'2039'.'8_RefReg' 0.0676, 
'2039'.'9_RefReg' 0.0932, 
'2040'.'1_RefReg' 0.0932, 
'2040'.'2_RefReg' 0.0738, 
'2040'.'3_RefReg' 0.0738, 
'2040'.'4_RefReg' 0.0332, 
'2040'.'5_RefReg' 0.0332, 
'2040'.'6_RefReg' 0.0421, 
'2040'.'7_RefReg' 0.0676, 
'2040'.'8_RefReg' 0.0676, 
'2040'.'9_RefReg' 0.0932, 
'2041'.'1_RefReg' 0.0932, 
'2041'.'2_RefReg' 0.0738, 
'2041'.'3_RefReg' 0.0738, 
'2041'.'4_RefReg' 0.0332, 
'2041'.'5_RefReg' 0.0332, 
'2041'.'6_RefReg' 0.0421, 
'2041'.'7_RefReg' 0.0676, 
'2041'.'8_RefReg' 0.0676, 
'2041'.'9_RefReg' 0.0932, 
'2042'.'1_RefReg' 0.0932, 
'2042'.'2_RefReg' 0.0738, 
'2042'.'3_RefReg' 0.0738, 
'2042'.'4_RefReg' 0.0332, 
'2042'.'5_RefReg' 0.0332, 
'2042'.'6_RefReg' 0.0421, 
'2042'.'7_RefReg' 0.0676, 
'2042'.'8_RefReg' 0.0676, 
'2042'.'9_RefReg' 0.0932, 
'2043'.'1_RefReg' 0.0932, 
'2043'.'2_RefReg' 0.0738, 
'2043'.'3_RefReg' 0.0738, 
'2043'.'4_RefReg' 0.0332, 
'2043'.'5_RefReg' 0.0332, 
'2043'.'6_RefReg' 0.0421, 
'2043'.'7_RefReg' 0.0676, 
'2043'.'8_RefReg' 0.0676, 
'2043'.'9_RefReg' 0.0932, 
'2044'.'1_RefReg' 0.0932, 
'2044'.'2_RefReg' 0.0738, 
'2044'.'3_RefReg' 0.0738, 
'2044'.'4_RefReg' 0.0332, 
'2044'.'5_RefReg' 0.0332, 
'2044'.'6_RefReg' 0.0421, 
'2044'.'7_RefReg' 0.0676, 
'2044'.'8_RefReg' 0.0676, 
'2044'.'9_RefReg' 0.0932, 
'2045'.'1_RefReg' 0.0932, 
'2045'.'2_RefReg' 0.0738, 
'2045'.'3_RefReg' 0.0738, 
'2045'.'4_RefReg' 0.0332, 
'2045'.'5_RefReg' 0.0332, 
'2045'.'6_RefReg' 0.0421, 
'2045'.'7_RefReg' 0.0676, 
'2045'.'8_RefReg' 0.0676, 
'2045'.'9_RefReg' 0.0932, 
'2046'.'1_RefReg' 0.0932, 
'2046'.'2_RefReg' 0.0738, 
'2046'.'3_RefReg' 0.0738, 
'2046'.'4_RefReg' 0.0332, 
'2046'.'5_RefReg' 0.0332, 
'2046'.'6_RefReg' 0.0421, 
'2046'.'7_RefReg' 0.0676, 
'2046'.'8_RefReg' 0.0676, 
'2046'.'9_RefReg' 0.0932, 
'2047'.'1_RefReg' 0.0932, 
'2047'.'2_RefReg' 0.0738, 
'2047'.'3_RefReg' 0.0738, 
'2047'.'4_RefReg' 0.0332, 
'2047'.'5_RefReg' 0.0332, 
'2047'.'6_RefReg' 0.0421, 
'2047'.'7_RefReg' 0.0676, 
'2047'.'8_RefReg' 0.0676, 
'2047'.'9_RefReg' 0.0932, 
'2048'.'1_RefReg' 0.0932, 
'2048'.'2_RefReg' 0.0738, 
'2048'.'3_RefReg' 0.0738, 
'2048'.'4_RefReg' 0.0332, 
'2048'.'5_RefReg' 0.0332, 
'2048'.'6_RefReg' 0.0421, 
'2048'.'7_RefReg' 0.0676, 
'2048'.'8_RefReg' 0.0676, 
'2048'.'9_RefReg' 0.0932, 
'2049'.'1_RefReg' 0.0932, 
'2049'.'2_RefReg' 0.0738, 
'2049'.'3_RefReg' 0.0738, 
'2049'.'4_RefReg' 0.0332, 
'2049'.'5_RefReg' 0.0332, 
'2049'.'6_RefReg' 0.0421, 
'2049'.'7_RefReg' 0.0676, 
'2049'.'8_RefReg' 0.0676, 
'2049'.'9_RefReg' 0.0932, 
'2050'.'1_RefReg' 0.0932, 
'2050'.'2_RefReg' 0.0738, 
'2050'.'3_RefReg' 0.0738, 
'2050'.'4_RefReg' 0.0332, 
'2050'.'5_RefReg' 0.0332, 
'2050'.'6_RefReg' 0.0421, 
'2050'.'7_RefReg' 0.0676, 
'2050'.'8_RefReg' 0.0676, 
'2050'.'9_RefReg' 0.0932 /;

Parameter FedTax(*) /
'1993' 0.35, 
'2008' 0.35, 
'1990' 0.35, 
'1991' 0.35, 
'1992' 0.35, 
'1994' 0.35, 
'1995' 0.35, 
'1996' 0.35, 
'1997' 0.35, 
'1998' 0.35, 
'1999' 0.35, 
'2000' 0.35, 
'2001' 0.35, 
'2002' 0.35, 
'2003' 0.35, 
'2004' 0.35, 
'2005' 0.35, 
'2006' 0.35, 
'2007' 0.35, 
'2009' 0.35, 
'2010' 0.35, 
'2011' 0.35, 
'2012' 0.35, 
'2013' 0.35, 
'2014' 0.35, 
'2015' 0.35, 
'2016' 0.35, 
'2017' 0.35, 
'2018' 0.21, 
'2019' 0.21, 
'2020' 0.21, 
'2021' 0.21, 
'2022' 0.21, 
'2023' 0.21, 
'2024' 0.21, 
'2025' 0.21, 
'2026' 0.21, 
'2027' 0.21, 
'2028' 0.21, 
'2029' 0.21, 
'2030' 0.21, 
'2031' 0.21, 
'2032' 0.21, 
'2033' 0.21, 
'2034' 0.21, 
'2035' 0.21, 
'2036' 0.21, 
'2037' 0.21, 
'2038' 0.21, 
'2039' 0.21, 
'2040' 0.21, 
'2041' 0.21, 
'2042' 0.21, 
'2043' 0.21, 
'2044' 0.21, 
'2045' 0.21, 
'2046' 0.21, 
'2047' 0.21, 
'2048' 0.21, 
'2049' 0.21, 
'2050' 0.21 /;

Parameter LearningData(*,*,*,*) /
'BPU'.'Phase2'.'Fast'.'A' 0.708, 
'BPU'.'Phase2'.'Fast'.'B' 0.415, 
'BPU'.'Phase2'.'Fast'.'F' 0.25, 
'BPU'.'Phase2'.'Fast'.'K' 4, 
'BPU'.'Phase2'.'Fast'.'M' 0.33, 
'BPU'.'Phase2'.'Slow'.'A' 0.941, 
'BPU'.'Phase2'.'Slow'.'B' 0.152, 
'BPU'.'Phase2'.'Slow'.'F' 0.1, 
'BPU'.'Phase2'.'Slow'.'K' 4, 
'BPU'.'Phase2'.'Slow'.'M' 0.67, 
'BPU'.'Phase3'.'Fast'.'A' 0.285, 
'BPU'.'Phase3'.'Fast'.'B' 0.152, 
'BPU'.'Phase3'.'Fast'.'F' 0.1, 
'BPU'.'Phase3'.'Fast'.'K' 32, 
'BPU'.'Phase3'.'Fast'.'M' 0.33, 
'BPU'.'Phase3'.'Slow'.'A' 0.718, 
'BPU'.'Phase3'.'Slow'.'B' 0.074, 
'BPU'.'Phase3'.'Slow'.'F' 0.05, 
'BPU'.'Phase3'.'Slow'.'K' 32, 
'BPU'.'Phase3'.'Slow'.'M' 0.67, 
'BTL'.'Phase2'.'Fast'.'A' 0.211, 
'BTL'.'Phase2'.'Fast'.'B' 0.152, 
'BTL'.'Phase2'.'Fast'.'F' 0.1, 
'BTL'.'Phase2'.'Fast'.'K' 4, 
'BTL'.'Phase2'.'Fast'.'M' 0.15, 
'BTL'.'Phase2'.'Slow'.'A' 0.957, 
'BTL'.'Phase2'.'Slow'.'B' 0.0145, 
'BTL'.'Phase2'.'Slow'.'F' 0.01, 
'BTL'.'Phase2'.'Slow'.'K' 4, 
'BTL'.'Phase2'.'Slow'.'M' 0.85, 
'BTL'.'Phase3'.'Fast'.'A' 0.211, 
'BTL'.'Phase3'.'Fast'.'B' 0.152, 
'BTL'.'Phase3'.'Fast'.'F' 0.1, 
'BTL'.'Phase3'.'Fast'.'K' 32, 
'BTL'.'Phase3'.'Fast'.'M' 0.15, 
'BTL'.'Phase3'.'Slow'.'A' 0.957, 
'BTL'.'Phase3'.'Slow'.'B' 0.0145, 
'BTL'.'Phase3'.'Slow'.'F' 0.01, 
'BTL'.'Phase3'.'Slow'.'K' 32, 
'BTL'.'Phase3'.'Slow'.'M' 0.85, 
'CBL'.'Phase2'.'Fast'.'A' 0.281, 
'CBL'.'Phase2'.'Fast'.'B' 0.152, 
'CBL'.'Phase2'.'Fast'.'F' 0.1, 
'CBL'.'Phase2'.'Fast'.'K' 4, 
'CBL'.'Phase2'.'Fast'.'M' 0.2, 
'CBL'.'Phase2'.'Slow'.'A' 0.901, 
'CBL'.'Phase2'.'Slow'.'B' 0.0145, 
'CBL'.'Phase2'.'Slow'.'F' 0.01, 
'CBL'.'Phase2'.'Slow'.'K' 4, 
'CBL'.'Phase2'.'Slow'.'M' 0.8, 
'CBL'.'Phase3'.'Fast'.'A' 0.281, 
'CBL'.'Phase3'.'Fast'.'B' 0.152, 
'CBL'.'Phase3'.'Fast'.'F' 0.1, 
'CBL'.'Phase3'.'Fast'.'K' 32, 
'CBL'.'Phase3'.'Fast'.'M' 0.2, 
'CBL'.'Phase3'.'Slow'.'A' 0.901, 
'CBL'.'Phase3'.'Slow'.'B' 0.0145, 
'CBL'.'Phase3'.'Slow'.'F' 0.01, 
'CBL'.'Phase3'.'Slow'.'K' 32, 
'CBL'.'Phase3'.'Slow'.'M' 0.8, 
'CBLCCS'.'Phase2'.'Fast'.'A' 0.369, 
'CBLCCS'.'Phase2'.'Fast'.'B' 0.3219, 
'CBLCCS'.'Phase2'.'Fast'.'F' 0.2, 
'CBLCCS'.'Phase2'.'Fast'.'K' 4, 
'CBLCCS'.'Phase2'.'Fast'.'M' 0.2, 
'CBLCCS'.'Phase2'.'Slow'.'A' 1.124, 
'CBLCCS'.'Phase2'.'Slow'.'B' 0.152, 
'CBLCCS'.'Phase2'.'Slow'.'F' 0.1, 
'CBLCCS'.'Phase2'.'Slow'.'K' 4, 
'CBLCCS'.'Phase2'.'Slow'.'M' 0.8, 
'CBLCCS'.'Phase3'.'Fast'.'A' 0.205, 
'CBLCCS'.'Phase3'.'Fast'.'B' 0.152, 
'CBLCCS'.'Phase3'.'Fast'.'F' 0.1, 
'CBLCCS'.'Phase3'.'Fast'.'K' 32, 
'CBLCCS'.'Phase3'.'Fast'.'M' 0.2, 
'CBLCCS'.'Phase3'.'Slow'.'A' 0.698, 
'CBLCCS'.'Phase3'.'Slow'.'B' 0.0145, 
'CBLCCS'.'Phase3'.'Slow'.'F' 0.01, 
'CBLCCS'.'Phase3'.'Slow'.'K' 32, 
'CBLCCS'.'Phase3'.'Slow'.'M' 0.8, 
'CLE'.'Phase2'.'Fast'.'A' 0.708, 
'CLE'.'Phase2'.'Fast'.'B' 0.415, 
'CLE'.'Phase2'.'Fast'.'F' 0.25, 
'CLE'.'Phase2'.'Fast'.'K' 4, 
'CLE'.'Phase2'.'Fast'.'M' 0.33, 
'CLE'.'Phase2'.'Slow'.'A' 0.941, 
'CLE'.'Phase2'.'Slow'.'B' 0.152, 
'CLE'.'Phase2'.'Slow'.'F' 0.1, 
'CLE'.'Phase2'.'Slow'.'K' 4, 
'CLE'.'Phase2'.'Slow'.'M' 0.67, 
'CLE'.'Phase3'.'Fast'.'A' 0.285, 
'CLE'.'Phase3'.'Fast'.'B' 0.152, 
'CLE'.'Phase3'.'Fast'.'F' 0.1, 
'CLE'.'Phase3'.'Fast'.'K' 32, 
'CLE'.'Phase3'.'Fast'.'M' 0.33, 
'CLE'.'Phase3'.'Slow'.'A' 0.718, 
'CLE'.'Phase3'.'Slow'.'B' 0.074, 
'CLE'.'Phase3'.'Slow'.'F' 0.05, 
'CLE'.'Phase3'.'Slow'.'K' 32, 
'CLE'.'Phase3'.'Slow'.'M' 0.67, 
'CTL'.'Phase2'.'Fast'.'A' 0.211, 
'CTL'.'Phase2'.'Fast'.'B' 0.152, 
'CTL'.'Phase2'.'Fast'.'F' 0.1, 
'CTL'.'Phase2'.'Fast'.'K' 4, 
'CTL'.'Phase2'.'Fast'.'M' 0.15, 
'CTL'.'Phase2'.'Slow'.'A' 0.957, 
'CTL'.'Phase2'.'Slow'.'B' 0.0145, 
'CTL'.'Phase2'.'Slow'.'F' 0.01, 
'CTL'.'Phase2'.'Slow'.'K' 4, 
'CTL'.'Phase2'.'Slow'.'M' 0.85, 
'CTL'.'Phase3'.'Fast'.'A' 0.211, 
'CTL'.'Phase3'.'Fast'.'B' 0.152, 
'CTL'.'Phase3'.'Fast'.'F' 0.1, 
'CTL'.'Phase3'.'Fast'.'K' 32, 
'CTL'.'Phase3'.'Fast'.'M' 0.15, 
'CTL'.'Phase3'.'Slow'.'A' 0.957, 
'CTL'.'Phase3'.'Slow'.'B' 0.0145, 
'CTL'.'Phase3'.'Slow'.'F' 0.01, 
'CTL'.'Phase3'.'Slow'.'K' 32, 
'CTL'.'Phase3'.'Slow'.'M' 0.85, 
'CTLCCS'.'Phase2'.'Fast'.'A' 0.369, 
'CTLCCS'.'Phase2'.'Fast'.'B' 0.3219, 
'CTLCCS'.'Phase2'.'Fast'.'F' 0.2, 
'CTLCCS'.'Phase2'.'Fast'.'K' 4, 
'CTLCCS'.'Phase2'.'Fast'.'M' 0.2, 
'CTLCCS'.'Phase2'.'Slow'.'A' 1.124, 
'CTLCCS'.'Phase2'.'Slow'.'B' 0.152, 
'CTLCCS'.'Phase2'.'Slow'.'F' 0.1, 
'CTLCCS'.'Phase2'.'Slow'.'K' 4, 
'CTLCCS'.'Phase2'.'Slow'.'M' 0.8, 
'CTLCCS'.'Phase3'.'Fast'.'A' 0.205, 
'CTLCCS'.'Phase3'.'Fast'.'B' 0.152, 
'CTLCCS'.'Phase3'.'Fast'.'F' 0.1, 
'CTLCCS'.'Phase3'.'Fast'.'K' 32, 
'CTLCCS'.'Phase3'.'Fast'.'M' 0.2, 
'CTLCCS'.'Phase3'.'Slow'.'A' 0.698, 
'CTLCCS'.'Phase3'.'Slow'.'B' 0.0145, 
'CTLCCS'.'Phase3'.'Slow'.'F' 0.01, 
'CTLCCS'.'Phase3'.'Slow'.'K' 32, 
'CTLCCS'.'Phase3'.'Slow'.'M' 0.8, 
'GTL'.'Phase2'.'Fast'.'A' 0.14, 
'GTL'.'Phase2'.'Fast'.'B' 0.152, 
'GTL'.'Phase2'.'Fast'.'F' 0.1, 
'GTL'.'Phase2'.'Fast'.'K' 4, 
'GTL'.'Phase2'.'Fast'.'M' 0.1, 
'GTL'.'Phase2'.'Slow'.'A' 1.013, 
'GTL'.'Phase2'.'Slow'.'B' 0.0145, 
'GTL'.'Phase2'.'Slow'.'F' 0.01, 
'GTL'.'Phase2'.'Slow'.'K' 4, 
'GTL'.'Phase2'.'Slow'.'M' 0.9, 
'GTL'.'Phase3'.'Fast'.'A' 0.14, 
'GTL'.'Phase3'.'Fast'.'B' 0.152, 
'GTL'.'Phase3'.'Fast'.'F' 0.1, 
'GTL'.'Phase3'.'Fast'.'K' 32, 
'GTL'.'Phase3'.'Fast'.'M' 0.1, 
'GTL'.'Phase3'.'Slow'.'A' 1.013, 
'GTL'.'Phase3'.'Slow'.'B' 0.0145, 
'GTL'.'Phase3'.'Slow'.'F' 0.01, 
'GTL'.'Phase3'.'Slow'.'K' 32, 
'GTL'.'Phase3'.'Slow'.'M' 0.9 /;

Parameter MoreLearningData(*,*) /
'BPU'.'Optimism' 0.2, 
'BPU'.'Contingency' 1.1, 
'BTL'.'Optimism' 0.2, 
'BTL'.'Contingency' 1.1, 
'CBL'.'Optimism' 0.2, 
'CBL'.'Contingency' 1.1, 
'CBLCCS'.'Optimism' 0.2, 
'CBLCCS'.'Contingency' 1.1, 
'CLE'.'Optimism' 0.2, 
'CLE'.'Contingency' 1.1, 
'CTL'.'Optimism' 0.15, 
'CTL'.'Contingency' 1.1, 
'CTLCCS'.'Optimism' 0.15, 
'CTLCCS'.'Contingency' 1.1, 
'GTL'.'Optimism' 0.1, 
'GTL'.'Contingency' 1.1 /;

Parameter InvLoc(*) /
'1_RefReg' 1.16, 
'2_RefReg' 1, 
'3_RefReg' 1, 
'4_RefReg' 1, 
'5_RefReg' 1, 
'6_RefReg' 1.08, 
'7_RefReg' 1.15, 
'8_RefReg' 1.15, 
'9_RefReg' 1.16 /;

Parameter LaborLoc(*) /
'1_RefReg' 1.11, 
'2_RefReg' 0.98, 
'3_RefReg' 0.98, 
'4_RefReg' 1, 
'5_RefReg' 1, 
'6_RefReg' 1.07, 
'7_RefReg' 1.06, 
'8_RefReg' 1.06, 
'9_RefReg' 1.11 /;

Parameter InvFactors(*,*) /
'PCTENV'.'AvgRiskPet' 0.1, 
'PCTENV'.'HighRiskPet' 0.1, 
'PCTENV'.'NonPet' 0.1, 
'PCTCNTG'.'AvgRiskPet' 0.05, 
'PCTCNTG'.'HighRiskPet' 0.05, 
'PCTCNTG'.'NonPet' 0.1, 
'PCTLND'.'NonPet' 0.04, 
'PCTSPECL'.'AvgRiskPet' 0.05, 
'PCTSPECL'.'HighRiskPet' 0.05, 
'PCTSPECL'.'NonPet' 0.05, 
'PCTWC'.'AvgRiskPet' 0.1, 
'PCTWC'.'HighRiskPet' 0.1, 
'PCTWC'.'NonPet' 0.1, 
'STAFF_FAC'.'AvgRiskPet' 0.55, 
'STAFF_FAC'.'HighRiskPet' 0.55, 
'STAFF_FAC'.'NonPet' 0.55, 
'OH_FAC'.'AvgRiskPet' 0.39, 
'OH_FAC'.'HighRiskPet' 0.39, 
'OH_FAC'.'NonPet' 0.39, 
'INS_FAC'.'AvgRiskPet' 0.005, 
'INS_FAC'.'HighRiskPet' 0.005, 
'INS_FAC'.'NonPet' 0.005, 
'TAX_FAC'.'AvgRiskPet' 0.01, 
'TAX_FAC'.'HighRiskPet' 0.01, 
'TAX_FAC'.'NonPet' 0.01, 
'MAINT_FAC'.'AvgRiskPet' 0.03, 
'MAINT_FAC'.'HighRiskPet' 0.03, 
'MAINT_FAC'.'NonPet' 0.03, 
'OTH_FAC'.'AvgRiskPet' 0.005, 
'OTH_FAC'.'HighRiskPet' 0.005, 
'OTH_FAC'.'NonPet' 0.005, 
'OSBLFAC'.'AvgRiskPet' 0.45, 
'OSBLFAC'.'HighRiskPet' 0.45, 
'BLDYRS'.'AvgRiskPet' 2, 
'BLDYRS'.'HighRiskPet' 2, 
'BLDYRS'.'NonPet' 4, 
'PRJLIFE'.'AvgRiskPet' 20, 
'PRJLIFE'.'HighRiskPet' 20, 
'PRJLIFE'.'NonPet' 20, 
'BEQ_OPR'.'AvgRiskPet' 0.8, 
'BEQ_OPR'.'HighRiskPet' 1.8, 
'BEQ_OPR'.'NonPet' 1.8, 
'EMRP_OPR'.'AvgRiskPet' 0.068, 
'EMRP_OPR'.'HighRiskPet' 0.075, 
'EMRP_OPR'.'NonPet' 0.075, 
'EQUITY_OPR'.'AvgRiskPet' 0.6, 
'EQUITY_OPR'.'HighRiskPet' 0.6, 
'EQUITY_OPR'.'NonPet' 0.6, 
'BEQ_BLD'.'AvgRiskPet' 0.8, 
'BEQ_BLD'.'HighRiskPet' 1.8, 
'BEQ_BLD'.'NonPet' 1.8, 
'EMRP_BLD'.'AvgRiskPet' 0.0675, 
'EMRP_BLD'.'HighRiskPet' 0.075, 
'EMRP_BLD'.'NonPet' 0.075, 
'EQUITY_BLD'.'AvgRiskPet' 0.6, 
'EQUITY_BLD'.'HighRiskPet' 0.6, 
'EQUITY_BLD'.'NonPet' 0.6 /;

$offempty