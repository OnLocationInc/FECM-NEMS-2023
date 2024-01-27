
* gdx=test.gdx --dir=./ --ForceAllOn=-1

* Allows a set to be empty
$onempty
* Allows a set to get filled with multiple statements, e.g starts out empty and gets fileld in later
$onmulti

scalar MMcfdToMMTyr conversion factor for millions cubic feet per day (mmcfd) to million tonnnes (mmt) per year /49/;

* NOTE: GDP deflators go back to base of 1987 and as of 4/16/12 existing EOR plays go back to 1981

Set      numbers              number set to get right order                          /1*100/
         th                   t master plus historical                               /1981*2100/
         tm(th)               t master - all possible years needed                   /2011*2100/
         tf(tm)               t financing - all cash flow years                      /2012*2100/
         t_emm(tf)            t for emm output                                       /2015*2050/
;

Sets     tb(tm)               t plus the year before t starts (for GDP calaculation)  /2011*2050/
         t(t_emm)             time horizon of the model                               /2015*2050/
         tp(t_emm)            EOR production project years                            /2015*2050/
         tstart(tm)           time horizon start year                                 /2022/
         tend(tm)             time horizon end year                                   /2050/

         Fueltype             potential fuel types
                                / 37 pseqcoal, 38 coal, 50 gas, 60 CTL, 61 CBL, 62 EDHCCS, 63 EDMCCS, 64 CO2RET,66 H2PCCS, 67 CO2H2RET, 68 CO2NGPRET /

         PlantType            Categories of CCS capture sources
                                / 1 Coal-Existing,
                                  2 Coal-New,
                                  3 Gas-Existing,
                                  4 Gas-New       /

         plant                All capture sites (EPlant+NPlant+CapEthanol+Cement)
         CapPower(plant)      Existing power plants + new power plants (EPlant+NPlant+Ethplant+H2plant+NGPplant+Cement)

         EPlant(CapPower)     existing coal fired powerplants
         NPlant(CapPower)     Potential new IGCC slots

         source               Existing capture units + new units /H1*H1000/
         N_IGRP(source)       new IGCC builds
         PS_IGRP(N_IGRP)      Pseudo sources to be used if ForceAll is on so that every fuel region has at least one source
         E_IGRP(source)       Active existing coal fired generators from NEMS
         EG_IGRP(source)      Active existing gas fired generators from NEMS
         ESource(source)      Existing coal fired generators
         ECPT                 ECP plant types
         E_ECPT(source,ECPT)  ECP plant type-source mapping

         SourceGoal(source,PlantType)       map source to PlantType

         transship            transshipment sites
         diameter             pipe diameter sizes

         InjSal               Saline Injection sites
         InjEOR               EOR Injection sites
         InjPseudo(InjEOR)    EOR Pseudo-injection sites for NEMS integration
         INJ_TERMINALS        Injection transportation terminals
         REGION_EMM           EMM regions
         REGION_OGSM          OGSM regions

         SourceType                      CO2 source types / GEN, ETH, AMM, CEM, NGP, NAT, HYD, NEW, DAC /
         UnitTypeGen(source,SourceType)  source-type mapping
         UnitType(source,SourceType)     source-type mapping

         FuelRegion                      Max number of combined fuel regions census-gas-coal-carbon from NEMS
                                         / 01_MAXNFR*24_MAXNFR /

         FuelReg                         Set of EMM fuel regions for GAMS

*         M8                              Generic set used for OGSM regions / 1_M8*8_M8 /
         M2                              Generic set used for planned vs unplanned power CO2 demand
         M3                              Fuel types /1_M3*3_M3/
         M4                              Generic set / 1_M4*4_M4 /
         M8                              Generic set used for OGSM regions
         M13
         MNUMYR                          NEMS model years / 2015_MNUMYR*2050_MNUMYR /
         MNUMYR_t_emm(MNUMYR,t_emm)      Map MNUMYR to t_emm /set.MNUMYR:set.t_emm/

         MNUMCR                          NEMS census divisions
         CensusRegion                          /1*11/
         HMM_Source(source)

         TERM_OGSM(INJ_TERMINALS,REGION_OGSM)    Map terminal nodes to OGSM regions
         TERM_FuelRegion(INJ_TERMINALS,FuelReg)  Map terminal nodes to fuel regions

         source_att           column headers for source properties
         tCost_att
         tCost_set
         sink_att
         sink_att2            Updated sink attributes
         NewPlant_att
         ProgramGoal_att
         HookupFee_att                  Hookup Fee parameters
         Dist_Miles
         Saline_Constants_att
         Saline_Coeffs_att
         EthProps_att        Ethanol site parameters
         H2Props_att         H2 site parameters
         NGPProps_att        NGP site parameters
         DACProps_att        DAC pseudo site parameters
         Exs_CemProps_att    Existing cement site parameters
         New_CemProps_att    New cement site parameters
*Ethanol plants
         EthPlant(CapPower)     Existing ethanol plants
         Ethsource(source)      Existing ethanol plants sites
*H2 plants
         H2plant(CapPower)      Existing hydrogen plants
         H2source(source)       Existing hydrogen plants sites
*NGP plants
         NGPPlant(CapPower)     Existing NGP facilities
         NGPsource(source)      Existing NGP facility sites
*DAC plants
         DACPlant(CapPower)     Existing DAC facilities
         DACsource(source)      Existing DAC facility sites
* Existing Cement plants
         Cem_Plant_exs(CapPower)     Existing cement sites
         Cem_Source_exs(source)      Existing cement kilns
* Existing kilns that retrofit
         I_IGRP(source)              Retrofit kilns
*New Cement plants
         Cem_Plant_new(CapPower)     New cement sites
         Cem_Source_new(source)      New cement kilns
         plttype(plant,SourceType)   Plant and Source Type mapping
         HookType                 / Sink, Hub/
;

$gdxin %dir%/input/CTSinput.gdx
$loadm source=Esource source=PS_IGRP  source=Ethsource  source = H2source source = NGPsource source = DACsource source=Cem_Source_exs source=Cem_Source_new
$load  ESource, Ethsource, H2source, NGPsource, DACsource, Cem_Source_exs, Cem_Source_new
$loadm plant=EPlant plant=NPlant  plant=EthPlant plant = H2plant plant = NGPplant plant = DACplant plant=Cem_Plant_exs plant=Cem_Plant_new
$loadm CapPower=EPlant CapPower=NPlant CapPower=EthPlant CapPower = H2plant CapPower = NGPplant  CapPower = DACplant CapPower=Cem_Plant_exs CapPower=Cem_Plant_new
$load  EPlant, NPlant, EthPlant, H2plant, NGPplant, DACplant, Cem_Plant_exs, Cem_Plant_new
$loadm NPlant=Cem_Plant_new
$load  ECPT, E_ECPT
$loadm InjEOR=InjPseudo
$load  transship, InjSal, InjPseudo, diameter, dist_miles, Saline_Constants_att, Saline_Coeffs_att, HookupFee_att
$load  NewPlant_att, ProgramGoal_att, sink_att, sink_att2, source_att, tCost_att, tCost_set, EthProps_att,H2Props_att,NGPProps_att,DACProps_att, Exs_CemProps_att, New_CemProps_att
$load  REGION_EMM, REGION_OGSM
$load INJ_TERMINALS, FuelReg, TERM_OGSM, TERM_FuelRegion
$load UnitTypeGen
$loadm N_IGRP=PS_IGRP
$load  PS_IGRP

$gdxin %dir%/CTSSavR.gdx
$loadm source=N_IGRP source=PMMOUT_L_IGRP
$loadm N_IGRP=N_IGRP N_IGRP=PMMOUT_L_IGRP
$load  M2, M8, M13, E_IGRP, EG_IGRP
$load I_IGRP=INDOUT_I_IGRP
$load MNUMCR
$gdxin
HMM_Source(source)=yes;
HMM_Source(Esource)=no;
HMM_Source(N_IGRP)=no;
HMM_Source(Ethsource)=no;
HMM_Source(H2source)=no;
HMM_Source(NGPsource)=no;
HMM_Source(DACsource)=no;
HMM_Source(Cem_Source_exs)=no;
HMM_Source(Cem_Source_new)=no;
* Map new and existing plants to source type
plttype(EthPlant,'ETH')=yes;
plttype(H2plant,'HYD')=yes;
plttype(NGPplant,'NGP')=yes;
plttype(DACPlant,'DAC')=yes;
plttype(Cem_Plant_exs,'CEM')=yes;
plttype(NPlant,'NEW')=yes;
plttype(EPlant,'GEN')=yes;

* build supersets
Sets             Inj             All injection sites                             /set.InjSal, set.InjEOR /

                 AllNode         All nodes in the transportation network         /set.plant, set.transship, set.INJ_TERMINALS/
                 FromNode        All nodes capable of moving CO2                 /set.plant, set.transship/
                 ToNode          All nodes capable of receiving CO2              /set.transship, set.INJ_TERMINALS/;

Set              link(FromNode,ToNode,diameter)
                 link_input(FromNode,ToNode,diameter)
                 source_EMM(source,Region_EMM)  Map All Sources to EMM Region
                 SITE_STO_SAL_REGION_EMM(Inj,REGION_EMM)

                 INJ_TDIST(Inj,INJ_TERMINALS)                    Injection terminal to site mapping
                 INJ_EMM(Inj,REGION_EMM)                         Map EOR sites to EMM regions
                 INJ_OGSM(Inj,REGION_OGSM)                       Map EOR sites to OGSM regions

                 M8_to_REGION_OGSM(M8,REGION_OGSM)      Map NEMS OGSM index to CTUS OGSM index
                                                        / 1_M8.1
                                                          2_M8.2
                                                          3_M8.3
                                                          4_M8.4
                                                          5_M8.5
                                                          6_M8.6
                                                          7_M8.7
                                                          8_M8.8 /

                 E_RG(source,FuelReg)             Fuel regions - existing CTS source mapping
                 E_OR(source,REGION_OGSM)         OGSM regions - existing CTS source mapping

                 FuelRegion_2_FuelReg(FuelRegion,FuelReg)  Map NEMS fuel region indicies to GAMS fuel region indicies
                                                            / set.FuelRegion:set.FuelReg /

                M4_to_PlantType(M4,PlantType)     Map generic M4 set to PlantType set
                                                  / set.M4:set.PlantType /

                 MNUMCR_CenDiv(MNUMCR,CensusRegion)      Map MNUMYR to t_emm /set.MNUMCR:set.CensusRegion/
;

Parameter        RetroBase(source)                existing power plant retrofit capital costs (MM 87$ USD?)
                 CapCostVar(source)               existing power plant variable capture costs ($pertonne)

                 EOR_CO2Purch(Inj,th,tm)          CO2 purchased (million tonnes)in project year tm if project started in year th

                 LinkDist(FromNode,ToNode)
                 LinkDistExs(FromNode,ToNode)

                 SinkProps(InjSal, sink_att)
                 SinkProps2(InjSal, sink_att2)    New sink properties
                 NewPlantProps(CapPower, NewPlant_att)     New power site properties
                 New_CemProps(CapPower,New_CemProps_att)   New cement site properties
                 SourceProps(source, CapPower, source_att) Power site properties
                 EthProps(source, CapPower, EthProps_att) Ethanol site locations
                 H2Props(source, CapPower, H2Props_att)   H2 site locations
                 NGPProps(source, CapPower, NGPProps_att) NGP site locations
                 DACProps(CapPower, source, DACProps_att) DAC psuedo site locations
                 Exs_CemProps(CapPower, source, Exs_CemProps_att) Existing cement site properties
                 ProgramGoal(tf, PlantType, ProgramGoal_att)
                 HookupFee(diameter,HookType,HookupFee_att) Hookup fee parameter values
                 Tcosts(tCost_set, tCost_att)
                 PipeMax(diameter)

                 SALProjLimit(t)                        Limit on the number of saline sites that can be brought on by year
                 RetrofitLimit(t)                       Limit on the number of powerplant retrofits per year nationally

                 PS_RG(source)                          Pseudo source fuel regions
                 PS_OR(source)                          Pseudo source OGSM regions

                 FuelReg2OGSMDist(FuelReg,REGION_OGSM)  Centroid distances from fuel regions to OGSM regions for initial cost matrix
                 FuelReg2OGSMCost(FuelReg,REGION_OGSM)  Costs from fuel regions to OGSM regions for initial cost matrix

                 OGSM2OGSMDist(REGION_OGSM,REGION_OGSM)     Centroid distances between OGSM regions for initial cost matrix
                 CompPwr_Price(tf)                      Replacement power cost in 2012$ per MWh
                 PumpNumTbl(diameter,dist_miles)

                 Saline_Constants(Saline_Constants_att) Parameters for saline cost equations
                 Saline_Coeffs(Saline_Coeffs_att)
                 N_TYPE(source,SourceType)              New CTS build source type
;

$gdxin %dir%/input/CTSinput.gdx
$load LinkDist
$loadm link_input=link
$load RetroBase, CapCostVar, ProgramGoal, SinkProps, SinkProps2, NewPlantProps, SourceProps, EthProps,H2Props,NGPProps,DACProps, Exs_CemProps, New_CemProps
$load Tcosts, PipeMax, PumpNumTbl, Saline_Constants, Saline_Coeffs, HookupFee
$load INJ_TDIST, INJ_EMM, INJ_OGSM
$load E_RG, E_OR, PS_RG, PS_OR, FuelReg2OGSMDist, OGSM2OGSMDist
$gdxin

$gdxin %dir%/input/CTSinput.gdx
$loadm LinkDist=RouteDist

Sets
                 Yr                             /Yr1,Yr2,Yr3,Yr4,Yr5,Yr6/
                 Prof                           /Prof1,Prof2,Prof3,Prof4,Prof5,prof6/
                 Pd                             /Pd1,Pd2,Pd3/
                 Comp                           /Comp1,Comp2,Comp3,Comp4,Comp5,Comp6/
                 CTUS                           /Capture,Transport,Storage,EOR,1,2,3,4,5,6,7,8/
*  CTUS categories: Capture, Transport, Storage, EOR, 1=InServiceYear 1, 2=InService 6, 3=InService 11, 4=Inservice 16,
*                                     5=InServiceYear 21, 6=InserviceYear 26, 7=For PreOperational Site Cost, 8=For 3 year recurring Operational Costs.
                 Comp2                          /Materials,Labor,Misc,ROW,OthPipeCC,Pumps/
;

Parameters       GDP(th)
                 CarbonPrice(t)                  Carbon credit $USD(1987) per kg
                 EMM_CL_CF(source,t)
                 ActiveConstrProfile(Yr,CTUS)

                 Escrate                         Escalation rate
                 EMRP                            Estimated Market Risk Premium
                 RFR                             Risk-free Rate
                 DebtRate                        Debt Rate

                 MACOUT_MC_RMCORPBAA(MNUMYR)     Corporate Baa Bond Rate from NEMS
                 MACOUT_MC_RMTCM10Y(MNUMYR)      10-Year Treasury Bond Rate from NEMS
                 MACOUT_MC_SP500(MNUMYR)         S&P 500 Index from NEMS

                 UEFPOUT_PELBS(MNUMCR,MNUMYR)    Marginal energy price of baseload generation (87 per MMBTU)

                 np(t)                           Number of periods left in model
                 GDPt(tf)                        proportion of GDP(tb-1) to GDP(tb)

                 N_RY(source)                    New CTS build retirement year
                 N_RG(source)                    New CTS build fuel region
                 N_OR(source)                    New CTS build OGSM region
                 N_CFR(source)                   New CTS build capacity factor
                 N_HRAT(source)                  New CTS build heatrate
                 N_CPTY(source)                  New CTS capacity
                 N_PTP(source)                   New CTS plant fuel type 37-partseqcoal 38-coal  50-gas
                 OGSMOUT_OGCO2PUR(M8,M13,MNUMYR) CO2 purchased by EOR in OGSM
                 OGSMOUT_OGCO2QEM(M8,MNUMYR)     CO2 purchased from EMM by EOR in OGSM
                 OGSMOUT_OGCO2QLF(M8,MNUMYR)     CO2 purchased from LFMM by EOR in OGSM
                 E_RY(E_IGRP)                    ECP existing unit retrofit year
                 E_PTP(E_IGRP)                   Plant types for existing coal fired generators
                 EG_RY(EG_IGRP)                  ECP existing IGCC unit retrofit year
                 EG_PTP(EG_IGRP)                 Plant types for existing gas fired generators

                 CF_NAT(M4,t)                    National average capacity factors by plant type calculated from EFD
*                Hydrogen capture by census region and fuel
                 H2CAPFUEL(M3,MNUMCR,MNUMYR)
                 H_CPTY_NEW(CensusRegion,t)
                 H_CPTY(source,t)
                 H_RG(source)
                 DACCapture(plant,t)             DAC builds at pseudo sites
                 OGSMOUT_OGCO2QDC(M8,MNUMYR)     DAC capture sent to EOR
                 DAC_Storage(InjSal,t)           DAC builds at saline sites
                 L_OPCAP(source,MNUMYR)          LFMM capture operates
                 L_CPTY(source,t)                LFMM capture operates
*                 Cement Data from NEMS
                 I_RY(source)                    Cement kiln retrofit year
                 I_CFR(source,MNUMYR)            Cement kiln capacity factor by year
                 I_CPTY(source)                  Cement kiln capacity
                 I_CFR_NEW(MNUMCR,MNUMYR,MNUMYR) Cement kiln capacity factor by year
                 I_CPTY_NEW(MNUMCR,MNUMYR)       Cement kiln capacity
                 I_PTP(source)                   Cement kiln type 70-existing 72-new
                 OGSMOUT_OGCO2QID(M8,MNUMYR)     CO2 purchased from Cement (IDM) by EOR in OGSM
                 CEM_CPTY_NEW(CensusRegion,t)          New cement capture capacity by year and census division
                 CEM_CFR(source,t)               Cement kiln capacity factor by year

                 RecurringDebt                   Repeated Investments                               /1/
                 TaxRate                         Tax Rate                                        /0.24/
                 Decl_rate                                                                       /2.00/
                 Conrate_adder                   Adder to Debtrate for Conrate                    /.02/
                 FRFr                            Discount Rate                                    /0.062/
                 FVannuity
                 Conrate                         Construction period borrowing costs
                 ProfiletoUse(CTUS)              User selection of construction profile /Capture     3, Transport    4, Storage    5, EOR     6, 1 5, 2 5, 3 5, 4 5, 6 5, 7 5, 8 5/
                 EquityFraction(CTUS)            EOR Equity Fraction                   /Capture   0.55, Transport 0.50, Storage 0.55, EOR  0.55, 1 0.55, 2 0.55, 3 0.55, 4 0.55, 5 0.55, 6 0.55, 7 0.55, 8 0.55/
                 DebtFraction(CTUS)              EOR Debt Fraction                     /Capture   0.45, Transport 0.50, Storage 0.45, EOR  0.45, 1 0.45, 2 0.45, 3 0.45, 4 0.45, 5 0.45, 6 0.45, 7 0.45, 8 0.45/
                 DebtLife(CTUS)                  CO2 Debt Life                         /Capture     10, Transport   15, Storage   15, EOR    10, 1 15, 2 15, 3 15, 4 15, 5 10, 6 5,  7 15, 8 3 /
                 TaxLife(CTUS)                   CO2 Tax Life                          /Capture     10, Transport   15, Storage   15, EOR    10, 1 5,  2 5,  3 5,  4 5,  5 5,  6 5,  7 15, 8 3/
                 EquipLife(CTUS)                 CO2  Equipment  Life                  /Capture     10, Transport   30, Storage   30, EOR    10, 1 30, 2 25, 3 20, 4 15, 5 10, 6 5,  7 30, 8 3/
                 Life(CTUS)                      Economic life                         /Capture     30, Transport   30, Storage   30, EOR    30, 1 30, 2 25, 3 20, 4 15, 5 10, 6 5,  7 30, 8 30/
                 PWF(CTUS)                       Present Worth Factor
                 Beta(CTUS)                      Beta                                  /Capture   1.74, Transport 1.74, Storage 1.74, EOR  1.74, 1 1.74, 2 1.74, 3 1.74, 4 1.74, 5 1.74, 6 1.74, 7 1.74, 8 1.74/
                 RPR(CTUS)                       Risk Premium Rate                     /Capture    0.0, Transport  0.0, Storage  0.0, EOR   0.0, 1 0.0, 2 0.0, 3 0.0, 4 0.0, 5 0.0, 6 0.0, 7 0.0, 8 0.0/
                 WACC(CTUS)                      NOMINAL Weighted-average Cost of Capital
                 RWACC(CTUS)                     REAL Weighted-average Cost of Capital

                 PV(CTUS,tf)                     Present Value
                 CRF(CTUS,t)                     Capital Recovery Factor
                 ANF(CTUS)                       Annualization Factor

                 EquityRate(CTUS)                CO2  NOMINAL Equity Interest Rate
                 NF(CTUS)                        Number of additional infusions of financing
                 AC(CTUS)                        Adjustment Coefficient
                 AF(CTUS)                        Adjustment Factor
                 MD(CTUS)                        Debt Multiplier
                 ME(CTUS)                        Equity Multiplier
                 CRF_2(CTUS)                     Capital Recovery Factor
                 PVDO(CTUS)                      Short cut for calculating the impact of making principle payments on debt outstanding
                 IEF(CTUS)                       Interest payments on debt
                 DPP(CTUS)                       Debt paid in Period
                 DDPP(CTUS)                      Discounted Debt Principal Payment
                 EQ(CTUS)                        Cash Out Flow from Equity
                 DEPf(CTUS)                      Discounted Depreciation Factor
                 FCRF(CTUS)                      Fixed Charge Rate Factor
                 CAF(CTUS)                       Capital Costs Adjustmnet Factor
                 CAF2(COMP2)                     Capital Costs Adjustmnet Factor for Transport by Component
                 NPV_INV(CTUS)                   Net Present Value of All Investment Related Expenses

                 A_(tf,CTUS)                     The following are temporary variables used to get to Taxdepr
                 B_(tf,CTUS)
                 C_(tf,CTUS)
                 D_(tf,CTUS)
                 E_(tf,CTUS)
                 F_(tf,CTUS)
                 G_(tf,CTUS)
                 H_(tf,CTUS)
                 I_(tf,CTUS)
                 J_(tf,CTUS)
                 K_(tf,CTUS)
                 L_(tf,CTUS)
                 AG_(tf,CTUS)
                 AH_(tf,CTUS)
                 Rem(tf,CTUS)
                 DDB(tf,CTUS)
                 SL(tf,CTUS)
                 VBD(tf,CTUS)

                 Taxdepr(tf,CTUS)
 ;

Table ConstrProfile(Yr,Prof)
           Prof1   Prof2   Prof3   Prof4   Prof5   Prof6
Yr1        1.00    0.25    0.25    0.10    0.03    0.01
Yr2        0.00    0.75    0.50    0.30    0.09    0.77
Yr3        0.00    0.00    0.25    0.40    0.30    0.05
Yr4        0.00    0.00    0.00    0.20    0.40    0.09
Yr5        0.00    0.00    0.00    0.00    0.18    0.01
Yr6        0.00    0.00    0.00    0.00    0.00    0.07

Table CapCostDist(Pd,Comp2)
           Materials Labor  Row   Misc OthPipeCC Pumps
Pd1        0.05       0.05  0.55  0.30    0.00    0.00
Pd2        0.40       0.40  0.30  0.35    0.30    0.40
Pd3        0.55       0.55  0.15  0.35    0.70    0.60

;


$gdxin %dir%/CTSSavR.gdx
$load GDP, CarbonPrice, EMM_CL_CF, N_RY, N_RG, N_CFR
$load N_HRAT, N_CPTY, N_PTP, OGSMOUT_OGCO2PUR, OGSMOUT_OGCO2QEM, OGSMOUT_OGCO2QLF
$load CF_NAT, MACOUT_MC_RMCORPBAA, MACOUT_MC_RMTCM10Y, MACOUT_MC_SP500, UEFPOUT_PELBS, E_RY, E_PTP, EG_RY, EG_PTP
$loadm N_RY = N_RY  N_RY = PMMOUT_L_RY
$loadm N_RG = N_RG  N_RG = PMMOUT_L_RG
$loadm N_CFR = N_CFR  N_CFR = PMMOUT_L_CFR
$loadm N_HRAT = N_HRAT  N_HRAT = PMMOUT_L_HRAT
$loadm N_CPTY = N_CPTY  N_CPTY = PMMOUT_L_CPTY L_OPCAP = PMMOUT_L_OPCAP
$loadm N_PTP = N_PTP  N_PTP = PMMOUT_L_PTP
$load I_RY = INDOUT_I_RY I_CFR = INDOUT_I_CFR I_CPTY = INDOUT_I_CPTY I_PTP = INDOUT_I_PTP
$load I_CFR_NEW = INDOUT_I_CFR_NEW I_CPTY_NEW = INDOUT_I_CPTY_NEW
$load H2CAPFUEL=HMMBLK_CO2CAPFUEL
$gdxin

H_CPTY_NEW(CensusRegion,t)$(CensusRegion.val le 9)
           = sum((M3,MNUMCR,MNUMYR)$(MNUMCR_CenDiv(MNUMCR,CensusRegion) and MNUMYR_t_emm(MNUMYR,t)),
                  H2CAPFUEL(M3,MNUMCR,MNUMYR));
* Initialize and assign DAC parameters
DACCapture(plant,t) = 0;
OGSMOUT_OGCO2QDC(M8,MNUMYR) = 0;
DAC_Storage(InjSal,t) = 0;
L_CPTY(source,t) = sum(MNUMYR$MNUMYR_t_emm(MNUMYR,t), L_OPCAP(source,MNUMYR));
* Check if DAC is running
$Ifi not %USEDAC% == 1 $goto NoDAC
$if not exist %dir%/DAC_TO_NEMS.gdx $goto SkipDAC
$gdxin %dir%/DAC_TO_NEMS.gdx
$loadm DACCapture = Q_DACsav OGSMOUT_OGCO2QDC = UECPOUT_DACtoEOR DAC_Storage = Q_DACsav
$gdxin
$label SkipDAC
$label NoDAC
OGSMOUT_OGCO2QID(M8,MNUMYR) = OGSMOUT_OGCO2PUR(M8,'05_M13',MNUMYR);
alias(t2,t);
alias(MNUMYR2,MNUMYR);
CEM_CPTY_NEW(CensusRegion,t) = 0;
loop(t2,
     CEM_CPTY_NEW(CensusRegion,t) = CEM_CPTY_NEW(CensusRegion,t) +
                              sum((MNUMCR,MNUMYR,MNUMYR2)$(MNUMCR_CenDiv(MNUMCR,CensusRegion) and MNUMYR_t_emm(MNUMYR2,t2) and MNUMYR_t_emm(MNUMYR,t)),
                                   max(0,I_CPTY_NEW(MNUMCR,MNUMYR2)-I_CPTY_NEW(MNUMCR,MNUMYR2-1))/1e6*I_CFR_NEW(MNUMCR,MNUMYR2,MNUMYR))
);
I_CPTY(Cem_Source_exs) = I_CPTY(Cem_Source_exs)/1e6;
CEM_CFR(source,t) = sum(MNUMYR$(MNUMYR_t_emm(MNUMYR,t)), I_CFR(source,MNUMYR));
*** Data has been imported. Now begin preparation for model parameters

* Map capture units to locations
Set  unitplt(source,plant)         Unit-Capture site mapping
     Nunitplt(source,CapPower)     New unit-plant combos to add to unitplt later
     Eunitplt(source,CapPower)     Existing unit-plant mapping
*     NPlantEx(CapPower)            executed new igcc builds
;

*** FORCED CAPTURE AT ALL SITES ---- When set to 1, force all sources to retrofit
*** Set up data for pseudo sources for fuel regions that currently have no coal plants to retrofit
$Ifi %ForceAllOn% == -1 $goto next5

* Turn off unplanned builds from NEMS
  N_RG(N_IGRP)$(not PS_IGRP(N_IGRP))   = 0 ;
  N_PTP(N_IGRP)$(not PS_IGRP(N_IGRP))  = 0 ;
  N_HRAT(N_IGRP)$(not PS_IGRP(N_IGRP)) = 0 ;
  N_CPTY(N_IGRP)$(not PS_IGRP(N_IGRP)) = 0 ;
  N_CFR(N_IGRP)$(not PS_IGRP(N_IGRP))  = 0 ;
  N_RY(N_IGRP)$(not PS_IGRP(N_IGRP))   = 0 ;
  E_RY(E_IGRP)=2051;
  EG_RY(EG_IGRP)=2051;

* Create pseudo unplanned builds in fuel regions that have no existing plants to retrofit
  loop((FuelReg,PS_IGRP)$(FuelReg.val=PS_RG(PS_IGRP)),
    N_RG(PS_IGRP)   = PS_RG(PS_IGRP) ;

* Put a 500 MW coal plant in each fuel region
    N_PTP(PS_IGRP)  = 38 ;
    N_HRAT(PS_IGRP) = 11000 ;
    N_CPTY(PS_IGRP) = 500 ;
    N_CFR(PS_IGRP)  = 0.87 ;
    N_RY(PS_IGRP)   = 2012 ;
  );
$label next5


* Map new power generation units to new plant sites
Scalar DONE, outerCount ;
set unassigned(source)   New generating units that have not been assigned to a new plant site ;

unassigned(HMM_Source)        = yes ;
H_CPTY(HMM_Source,t) = 0;
loop(CensusRegion,
loop(t,
  outerCount = H_CPTY_NEW(CensusRegion,t);
  loop(HMM_Source$unassigned(HMM_Source),
       if( (outerCount gt 0),
             H_CPTY(HMM_Source,t) = min(1,outerCount);
             if(N_RY(HMM_Source) = 0,
                N_RY(HMM_Source) = t.val;
             );
             N_PTP(HMM_Source)=66;
             H_RG(HMM_Source)=CensusRegion.val;
          outerCount = max(0,outerCount - min(1,outerCount));
       );
  );
);
             unassigned(HMM_Source)$(sum(t,H_CPTY(HMM_Source,t)) gt 0)=no;
);
Nunitplt(source,NPlant)   = no ;
unassigned(source)        = no ;
unassigned(N_IGRP)        = not sum(NPlant, Nunitplt(N_IGRP,NPlant)) ;
outerCount                = 1 ;

while(sum(unassigned(N_IGRP), 1)>0 and outerCount<=50,

*  Assign unplanned builds and pseudo sources to plant locations
   Loop(source$(N_IGRP(source) and unassigned(source) and (N_CPTY(source)>0)
   and (N_PTP(source)<>64) and (N_PTP(source)<>67) and (N_PTP(source)<>68)),
     DONE = -1 ;
     Loop(Nplant$(DONE = -1),
       If(((NewPlantProps(Nplant,'FuelRegion') EQ N_RG(source)) and (NewPlantProps(Nplant,'TotalCap') <= 500*outerCount)),
         If(NewPlantProps(Nplant,'iGRP') = -1,
            NewPlantProps(Nplant,'iGRP') = 1 ;
         else
            NewPlantProps(Nplant,'iGRP') = NewPlantProps(Nplant,'iGRP') + 1 ;
         );
         Nunitplt(source, Nplant) = yes;
         if (N_PTP(source)<62,
         NewPlantProps(Nplant,'TotalCap') = NewPlantProps(Nplant,'TotalCap') + N_CPTY(source) ;
         else
*           New ethanol units
            NewPlantProps(Nplant,'TotalCap') = NewPlantProps(Nplant,'TotalCap') + 500*(N_CPTY(source)/3.4) ;
         );
         if (N_PTP(source) le 60, plttype(Nplant,'NEW') = no;
         plttype(Nplant,'GEN') = yes;
         elseif (N_PTP(source) eq 62 or N_PTP(source) eq 63), plttype(Nplant,'NEW') = no;
         plttype(Nplant,'ETH') = yes;
         elseif N_PTP(source) eq 66,  plttype(Nplant,'NEW') = no;
         plttype(Nplant,'HYD') = yes;
         );
         DONE = 1 ;
       );
     );
   );

   unassigned(N_IGRP) = not sum(NPlant, Nunitplt(N_IGRP,NPlant)) ;
*  Assign unplanned hydrogen builds to plant locations
   Loop(source$(HMM_Source(source) and unassigned(source) and sum(t,H_CPTY(source,t)>0)),
     DONE = -1 ;
     Loop(Nplant$(DONE = -1),
       If(((NewPlantProps(Nplant,'CensusRegion') EQ H_RG(source)) and (NewPlantProps(Nplant,'TotalCap') <= 9)),
         If(NewPlantProps(Nplant,'iGRP') = -1,
            NewPlantProps(Nplant,'iGRP') = 1 ;
         else
            NewPlantProps(Nplant,'iGRP') = NewPlantProps(Nplant,'iGRP') + 1 ;
         );
         N_RG(source)=NewPlantProps(Nplant,'FuelRegion');
         Nunitplt(source, Nplant) = yes;
*           New hydrogen units
         NewPlantProps(Nplant,'TotalCap') = NewPlantProps(Nplant,'TotalCap') + smax(t,H_CPTY(source,t)) ;
         if (N_PTP(source) eq 66,  plttype(Nplant,'NEW') = no;
         plttype(Nplant,'HYD') = yes;
         );
         DONE = 1 ;
       );
     );
   );
   unassigned(HMM_Source) = not sum(NPlant, Nunitplt(HMM_Source,NPlant)) ;
   outerCount = outerCount + 1 ;
);

Eunitplt(source,CapPower) = sum(source_att,SourceProps(source, CapPower, source_att)) +
                            sum(EthProps_att, EthProps(source, CapPower, EthProps_att)) +
                            sum(H2Props_att,  H2Props(source, CapPower, H2Props_att))+
                            sum(NGPProps_att, NGPProps(source, CapPower, NGPProps_att))+
                            sum(DACProps_att, DACProps(CapPower, source, DACProps_att))  +
                            sum(Exs_CemProps_att, Exs_CemProps(CapPower, source, Exs_CemProps_att));
E_RG(Cem_Source_exs,FuelReg)$(sum(Cem_Plant_exs,Exs_CemProps(Cem_Plant_exs, Cem_Source_exs, 'FuelRegion') eq FuelReg.val)) = yes;
E_OR(Cem_Source_exs,REGION_OGSM)$(sum(Cem_Plant_exs,Exs_CemProps(Cem_Plant_exs, Cem_Source_exs, 'OGSM_Region') eq REGION_OGSM.val)) = yes;

parameter C_CPTY(Cem_Plant_new)
          C_RY(Cem_Plant_new)
          C_CFR_NEW(Cem_Plant_new,t);
C_RY(Cem_Plant_new) = 0;
loop(t,
loop(CensusRegion$CEM_CPTY_NEW(CensusRegion,t),
  outerCount = CEM_CPTY_NEW(CensusRegion,t);
  loop(Cem_Plant_new,
       if( (New_CemProps(Cem_Plant_new,'CensusRegion') EQ CensusRegion.val and outerCount gt 0),
*          if(New_CemProps(Cem_Plant_new,'iGRP') = -1,
             New_CemProps(Cem_Plant_new,'iGRP') = ceil(min(New_CemProps(Cem_Plant_new,'TOTAL_CO2'),outerCount*2));
             C_CPTY(Cem_Plant_new) = min(New_CemProps(Cem_Plant_new,'TOTAL_CO2')*0.5,outerCount);
             if(C_RY(Cem_Plant_new) = 0,
                C_RY(Cem_Plant_new) = t.val;
             );
             C_CFR_NEW(Cem_Plant_new,t)$(t.val ge C_RY(Cem_Plant_new)) = C_CPTY(Cem_Plant_new);
*          );
          plttype(Cem_Plant_new,'NEW') = no;
          plttype(Cem_Plant_new,'CEM') = yes;
          outerCount = max(0,outerCount - min(New_CemProps(Cem_Plant_new,'TOTAL_CO2')*0.5,outerCount));
       );
  );
);
);
*C_CFR_NEW(Cem_Plant_new,t)$(t.val ge C_RY(Cem_Plant_new) and C_RY(Cem_Plant_new)) = 1;
scalar innerCount;
Nunitplt(Cem_Source_new,Cem_Plant_new)   = no ;
unassigned(Cem_Source_new)        = no ;
unassigned(Cem_Source_new)        = not sum(Cem_Plant_new, Nunitplt(Cem_Source_new,Cem_Plant_new)) ;
loop(Cem_Plant_new$(New_CemProps(Cem_Plant_new,'iGRP') gt 0),
     DONE = -1;
     outerCount = New_CemProps(Cem_Plant_new,'iGRP');
     innerCount = C_CPTY(Cem_Plant_new);
     loop(Cem_Source_new$(not Nunitplt(Cem_Source_new,Cem_Plant_new) and outerCount gt 0 and unassigned(Cem_Source_new)),
          Nunitplt(Cem_Source_new,Cem_Plant_new) = yes;
*          N_CPTY(Cem_Source_new) = min(0.5,innerCount);
          N_RY(Cem_Source_new) = C_RY(Cem_Plant_new);
          N_TYPE(Cem_Source_new,'CEM') = yes;
          N_RG(Cem_Source_new) = New_CemProps(Cem_Plant_new, 'FuelRegion');
          innerCount = max(0,innerCount - 0.5);
          outerCount = outerCount - 1;
          unassigned(Cem_Source_new) = not Nunitplt(Cem_Source_new,Cem_Plant_new) ;
     );
);
*  Now pull it all into unitplt
unitplt(source,CapPower)              = nunitplt(source,CapPower)+ eunitplt(source,CapPower);

* Set up source-type mapping for reporting
UnitType(source,SourceType)           = UnitTypeGen(source,SourceType) ;
UnitType(source,'GEN') = yes ;
UnitType(Ethsource,'GEN') = no;
UnitType(Ethsource,'ETH') = yes;
UnitType(H2source,'GEN') = no;
UnitType(H2source,'HYD') = yes;
UnitType(NGPsource,'GEN') = no;
UnitType(NGPsource,'NGP') = yes;
UnitType(DACsource,'GEN') = no;
UnitType(DACsource,'DAC') = yes;
UnitType(Cem_Source_exs,'GEN') = no;
UnitType(Cem_Source_exs,'CEM') = yes;
UnitType(Cem_Source_new,'GEN') = no;
UnitType(Cem_Source_new,'CEM') = yes;
N_TYPE(N_IGRP,'GEN') = yes;
N_TYPE(EthSource,'GEN')$N_IGRP(EthSource) = no;
N_TYPE(EthSource,'ETH')$N_IGRP(EthSource) = yes;
N_TYPE(H2Source,'GEN')$N_IGRP(H2Source) = no;
N_TYPE(H2Source,'HYD')$N_IGRP(H2Source) = yes;
N_TYPE(NGPSource,'GEN')$N_IGRP(NGPSource) = no;
N_TYPE(NGPSource,'NGP')$N_IGRP(NGPSource) = yes;
N_OR(source) = sum(Nplant$unitplt(source,Nplant), NewPlantProps(Nplant,'OGSM_Region'));
N_OR(Cem_Source_new) = sum(Cem_Plant_new$unitplt(Cem_Source_new,Cem_Plant_new), New_CemProps(Cem_Plant_new,'OGSM_Region'));

* Set up set which maps source to PlantType for ProgramGoals
SourceGoal(source,PlantType)              = no;
SourceGoal(ESource,'1')$(not E_ECPT(Esource,'EC')) = yes ;
SourceGoal(N_IGRP,'2')$(N_PTP(N_IGRP)=37) = yes ;
SourceGoal(N_IGRP,'2')$(N_PTP(N_IGRP)=38) = yes ;
SourceGoal(ESource,'3')$(E_ECPT(Esource,'EC')) = yes ;
SourceGoal(N_IGRP,'4')$(N_PTP(N_IGRP)=50) = yes ;

*Set CapPower plants used this run;
*NPlantEx(CapPower) = yes$(NewPlantProps(CapPower,'iGRP') ne -1);

Scalar   RND  nummber of decimals to round  /5/ ;

****  Read in user-defined parameter settings
$gdxin %dir%RunDefn.gdx
Parameter  RunDefn  Settings for this run - set to -1(Off) or 1(On)in CTS_script.gms ;
$load RunDefn
If( RunDefn('ProgramGoals')= -1,
      ProgramGoal(tf,PlantType,ProgramGoal_Att) = 1 ;
);
If( RunDefn('ECP_Retrofits')= 1,
      ProgramGoal(tf,PlantType,'FixedAdjC') = 1 ;
      ProgramGoal(tf,PlantType,'VarAdjC') = 1  ;
);

* Set future program goals to the 2050 values if year is greater than 2050
ProgramGoal(tf,PlantType,ProgramGoal_Att)$(tf.val>2050) = ProgramGoal('2050',PlantType,ProgramGoal_Att) ;

* !!! do we need a bigger GDP vector to go out over the bigger years? !!!
GDPt(tf) = sum(tb$(tb.val = tf.val), GDP(tb)/GDP(tb-1));
np(t)   = Card(t) - ord(t) + 1;

parameter sp500rate(t);
*sp500rate(t)      = sum(MNUMYR$(MNUMYR_t_emm(MNUMYR,t) and (MACOUT_MC_SP500(MNUMYR-1)>0)),
*                      (MACOUT_MC_SP500(MNUMYR)/MACOUT_MC_SP500(MNUMYR-1)) - 1 ) ;
*sp500rate('2012') = 0.0872 ;

* Hard-coded return on market rate
sp500rate(t)      = 0.08 ;

* Average growth rate of S&P 500 index over model time horizon
EMRP = sum(t, sp500rate(t) ) / card(t) ;

* Average 10-Yr Treasury bond rate over the model time horizon
RFR  = sum((MNUMYR,t)$MNUMYR_t_emm(MNUMYR,t), MACOUT_MC_RMTCM10Y(MNUMYR)) / card(t) / 100 ;

* Average Corporate Baa bond rate over the model time horizon
DebtRate = sum((MNUMYR,t)$MNUMYR_t_emm(MNUMYR,t), MACOUT_MC_RMCORPBAA(MNUMYR)) / card(t) / 100 ;

  EquityRate(CTUS)   = RFR + Beta(CTUS)*(EMRP-RFR) ;
* NOMINAL Weighted-Average Cost of Capital
  WACC(CTUS)   = EquityFraction(CTUS)*EquityRate(CTUS) + DebtFraction(CTUS)*DebtRate*(1 - TaxRate) + RPR(CTUS) ;
* Take the average adjusted discount rate over all time periods in the model to get REAL WACC
  RWACC(CTUS) = sum(t,((1+WACC(CTUS))/ GDPt(t)) - 1)/card(t);

* Capture Cost - PV and Amortization Calculations
PV(CTUS,tf) = 1/POWER((1+RWACC(CTUS)),ord(tf)-1);
CRF(CTUS,t) = (1-POWER(1+RWACC(CTUS),-np(t)))/RWACC(CTUS);
ANF(CTUS)    = RWACC(CTUS) / (1-POWER((1+RWACC(CTUS)),-Life(CTUS)) );

FVAnnuity =   (POWER((1+FRFr) ,LIFE("Storage") )-1)/FRFr ;
PWF(CTUS) = Power(1+EquityRate(CTUS),-(1-1));
PWF("2") = Power(1+EquityRate("2"),-(6-1));
PWF("3") = Power(1+EquityRate("3"),-(11-1));
PWF("4") = Power(1+EquityRate("4"),-(16-1));
PWF("5") = Power(1+EquityRate("5"),-(21-1));
PWF("6") = Power(1+EquityRate("6"),-(26-1));


Loop (CTUS,
  If( ProfiletoUse(CTUS)= 1,
    ActiveConstrProfile(Yr,CTUS) = ConstrProfile(Yr,'Prof1') ;
  Elseif  ProfiletoUse(CTUS)= 2,
    ActiveConstrProfile(Yr,CTUS) = ConstrProfile(Yr,'Prof2') ;
  Elseif  ProfiletoUse(CTUS)= 3,
    ActiveConstrProfile(Yr,CTUS) = ConstrProfile(Yr,'Prof3') ;
  Elseif  ProfiletoUse(CTUS)= 4,
    ActiveConstrProfile(Yr,CTUS) = ConstrProfile(Yr,'Prof4') ;
  Elseif  ProfiletoUse(CTUS)= 5,
    ActiveConstrProfile(Yr,CTUS) = ConstrProfile(Yr,'Prof5') ;
  Elseif  ProfiletoUse(CTUS)= 6,
    ActiveConstrProfile(Yr,CTUS) = ConstrProfile(Yr,'Prof6') ;
  );
);

Escrate = sum(t, GDPt(t) ) / card(t) ;
Conrate = Debtrate + Conrate_adder;
Loop(CTUS,
  NF(CTUS)$(mod(Life(CTUS),EquipLife(CTUS))=0)   = max((Life(CTUS)/EquipLife(CTUS))-1,0) ;
  AC(CTUS)    = (POWER(1+EquityRate(CTUS),EquipLife(CTUS))) -1  ;
  AF(CTUS)$((EquipLife(CTUS) < 30) and (AC(CTUS) > 0)) = (1-POWER(1+AC(CTUS),-NF(CTUS)))/AC(CTUS)  ;
  MD(CTUS)    = (AF(CTUS)+1)$(RecurringDebt = 1)  + 1$(RecurringDebt <>1);
  If (RecurringDebt = 1,
    ME(CTUS)    = (AF(CTUS)+1);
  Else
    ME(CTUS) $(EquityFraction(CTUS)>0)   = (AF(CTUS) + EquityFraction(CTUS)) / EquityFraction(CTUS);
  );
  Loop(tf,
    K_(tf,CTUS) = Life(CTUS)-ord(tf)+1;
    B_(tf,CTUS) = ord(tf);
    If (K_(tf,CTUS)>0,
      E_(tf,CTUS) = EquipLife(CTUS) $( mod(B_(tf,CTUS),EquipLife(CTUS))=0) + mod(B_(tf,CTUS),EquipLife(CTUS)) $( mod(B_(tf,CTUS),EquipLife(CTUS))<>0);
    );
    AG_(tf,CTUS)$(E_(tf,CTUS)=1) =1;
    AH_("2012",CTUS) = DebtFraction(CTUS);
    AH_(tf,CTUS)$( (RecurringDebt = 1) and (AG_(tf,CTUS) = 1) ) = DebtFraction(CTUS);
    A_(tf,CTUS)$(AH_(tf,CTUS)>0) = DebtLife(CTUS);
    C_("2012",CTUS)=A_("2012",CTUS);
    If (ord(tf)>1,
          C_(tf,CTUS)$(C_(tf-1,CTUS)-1+A_(tf,CTUS)>=0 )=C_(tf-1,CTUS)-1;
    );
    If ( Mod(B_(tf,CTUS)-1,EquipLife(CTUS))=0,
       D_(tf,CTUS) = EquipLife(CTUS);
    Else
       D_(tf,CTUS) = D_(tf-1,CTUS)-1;
    );
    If (K_(tf,CTUS)>0,
        If(E_(tf,CTUS)=1,
          F_(tf,CTUS)=1/EquipLife(CTUS);
        Else
          F_(tf,CTUS) = F_(tf-1,CTUS);
        );
    );
    If (Mod(B_(tf,CTUS)-1,EquipLife(CTUS))=0,
           H_(tf,CTUS)$(D_(tf,CTUS)=EquipLife(CTUS)) = TaxLife(CTUS);
    Else
        If (E_(tf-1,CTUS)>TaxLife(CTUS),
             H_(tf,CTUS) = 0;
        Else
             H_(tf,CTUS) = H_(tf-1,CTUS)-1;
         );
    );
    G_(tf,CTUS)=0$(E_(tf,CTUS)>TaxLife(CTUS))  +  TaxLife(CTUS)-H_(tf,CTUS)+1$(E_(tf,CTUS)<=TaxLife(CTUS));
    DDB(tf,CTUS)=0;
    If (H_(tf,CTUS)>0,
      If(G_(tf,CTUS)=1,
        Rem(tf,CTUS) =1;
      Else
        Rem(tf,CTUS) = Rem(tf-1,CTUS)-DDB(tf-1,CTUS)  ;
      );
      DDB(tf,CTUS) = Rem(tf,CTUS) * (1/Taxlife(CTUS))*Decl_rate ;
      SL(tf,CTUS)$(C_(tf,CTUS)>0)=Rem(tf,CTUS)/C_(tf,CTUS);
      If (DDB(tf,CTUS)>=SL(tf,CTUS),
        VBD(tf,CTUS) = DDB(tf,CTUS);
      Else
        VBD(tf,CTUS) = VBD(tf-1,CTUS);
      );
     );
      TaxDepr(tf,CTUS)$(K_(tf,CTUS)>0  ) = VBD(tf,CTUS);
  );
  DPP(CTUS)  = (1/DebtLife(CTUS))*DebtFraction(CTUS);
  DDPP(CTUS)  = ((1-(POWER(1+EquityRate(CTUS),-DebtLife(CTUS))))/EquityRate(CTUS))*DPP(CTUS) * MD(CTUS);
  DEPF(CTUS)  = sum(tf, TaxDepr(tf,CTUS) / POWER((1+EquityRate(CTUS)),ord(tf)) ) ;
  PVDO(CTUS)  = (1-((1-(POWER(1+EquityRate(CTUS),-DebtLife(CTUS))))/(DebtLife(CTUS)*EquityRate(CTUS)))) *(1/EquityRate(CTUS)) * MD(CTUS);
  IEF(CTUS)   =   PVDO(CTUS) * DebtRate * DebtFraction(CTUS);
  EQ(CTUS)    = EquityFraction(CTUS) * ME(CTUS);
  NPV_INV(CTUS) = EQ(CTUS)/(1-TaxRate)+IEF(CTUS)-(TaxRate/(1-TaxRate))*DEPF(CTUS)+DDPP(CTUS)/(1-TaxRate);
  CRF_2(CTUS) = 1/((1-(1/POWER(1+EquityRate(CTUS),Life(CTUS)) ))/EquityRate(CTUS));
  FCRF(CTUS)  = CRF_2(CTUS) * NPV_INV(CTUS);
  CAF(CTUS) =  sum(Yr, ActiveConstrProfile(Yr,CTUS)  * POWER(Escrate,ord(Yr)-1)   * POWER(1+Conrate,ProfileToUse(CTUS)-ord(Yr)+1) );
);
  CAF2(COMP2) = sum(Pd, CapCostDist(Pd,COMP2)        * POWER(Escrate,ord(Pd)-1)   * POWER(1+Conrate,ord(Comp2)        -ord(Pd)+1) );
***  Capture Site data and cost calculations***

Parameter
*Model Parameters
       SrcCapCost(source,t)           Fixed cost (millions of dollars) to retrofit a SOURCE
       CaptureCost(source,t)          Variable cost per tonne (dollars) to capture at each SOURCE
       CaptureMax(source,t)           Maximum (millions tonnes) captured annually at SOURCE

*Working Parameters
       ElectricOut(source,t)          Electricity output MWh per Yr
       CapFactor(source,t)            Capacity Factor-indicates retirements and new build coming on line
       CO2RATE(source)                Sequestration rate by source
       RCO2(Fueltype)                 sequestration rate by fuel type (updated)
                                 /    37    .3
                                      38    .95
                                      50    .95
                                      60    .9
                                      61    .9      /
       CarbonContent(source)          Carbon content by source
       FuelCarbon(Fueltype)        Carbon content based on fuel type - lbs C02 per MM BTU
                                 /    37    205.3
                                      38    205.3
                                      50    117.08
                                      60    69.84
                                      61    31.26      / ;
;

* Fill in SourceProps for new builds,
SourceProps(unitplt(source,CapPower),'SCAP')$NPlant(CapPower)      = ROUND(N_CPTY(source),2);
SourceProps(unitplt(source,CapPower),'HeatRate')$NPlant(CapPower)  = N_HRAT(source);
SourceProps(unitplt(source,CapPower),'R_CO2')$NPlant(CapPower)     = .90 ;

CapFactor(source,t)  = sum((M4,PlantType)$(SourceGoal(source,PlantType) and M4_to_PlantType(M4,PlantType)), CF_NAT(M4,t) ) ;
CapFactor(PS_IGRP,t) = 0.75 ;
* CTL
CapFactor(N_IGRP,t)$(N_PTP(N_IGRP)=60 or N_PTP(N_IGRP)=61) = N_CFR(N_IGRP) ;

* Convert PELBS from 87$/mmbtu to 2012$/MWH
CompPwr_Price(t) = sum(MNUMYR$MNUMYR_t_emm(MNUMYR,t), UEFPOUT_PELBS('11_MNUMCR',MNUMYR) ) * 3.41414 * GDP('2012') ;

***  Capture Cost calculations***

*Electric Output (MWh / Year) = Capacity Factor * (Summer Capacity (MW)) * (365.25 days / 1 year) * (24 hours/day)
ElectricOut(source,t) = CapFactor(source,t) * sum(unitplt(source,CapPower),SourceProps(source,CapPower,'SCAP')) * 365.25 * 24;

* Map carbon content value to each source
CarbonContent(Esource)$(not E_ECPT(Esource,'EC')) = FuelCarbon('38');
CarbonContent(Esource)$E_ECPT(Esource,'EC')       = FuelCarbon('50');
CarbonContent(N_IGRP)  = sum(fueltype$(fueltype.val=N_PTP(N_IGRP)),FuelCarbon(fueltype));

* Map sequestration value to each source.  All existing sources are coal
CO2RATE(source)                       = RCO2('38');
CO2RATE(Esource)$E_ECPT(Esource,'EC') = RCO2('50');
CO2RATE(N_IGRP)                       = sum(fueltype$(fueltype.val=N_PTP(N_IGRP)),RCO2(fueltype));

*Capture Max (MMT CO2 / Year) = Electric Output (MWh / Year) * Heat Rate (BTU/kWh) * 1000 kWh / 1 MWh) * Carbon Content (C02/MM BTU)* (1 tonne / 2204 lbs.) * (1 MM BTU / 10^6 BTU)
*CaptureMax(source,t)     =  ROUND(CarbonContent(source) * sum(unitplt(source,CapPower),SourceProps(source,CapPower,'HeatRate')) / 2204000 * ElectricOut(source,t) * sum(unitplt(source,CapPower),SourceProps(source,CapPower,'R_CO2')) / 1000000,RND);
CaptureMax(source,t)$(not EthSource(source) and not H2source(source) and not NGPsource(source)  and not DACsource(source) and not Cem_Source_exs(source))
           = ROUND(CarbonContent(source) * sum(unitplt(source,CapPower),SourceProps(source,CapPower,'HeatRate')) / 2204000 * ElectricOut(source,t) * sum(unitplt(source,CapPower),CO2RATE(source) ) / 1000000,RND);
* Capture Max (MMT CO2 / Year) = Ethanol Output (Bcf / Year) * 1000 (MMCf / BCF) / 365.25 (days/year) / (49 (MMcfd / MMTperyear))

$Ifi %ForceAllOn% == -1 $goto next7
CaptureMax(source,t)$(not N_IGRP(source)) = 0;
$label next7

$Ifi %ForceAllOn% == 1 $goto next6

* Ethanol retrofits
CaptureMax(EthSource,t)                                     = L_CPTY(EthSource,t) ;
* New ethanol with CCS
CaptureMax(N_IGRP,t)$(N_PTP(N_IGRP)=62 or N_PTP(N_IGRP)=63) = L_CPTY(N_IGRP,t) ;
* New Hydrogen retrofits
CaptureMax(H2Source,t)                                      = L_CPTY(H2Source,t) ;
* New Hydrogen with CCS
CaptureMax(N_IGRP,t)$(N_PTP(N_IGRP)=66)                     = L_CPTY(N_IGRP,t) ;
CaptureMax(HMM_Source,t)$(N_PTP(HMM_Source)=66)                     = H_CPTY(HMM_Source,t) ;
* New NGP retrofits
CaptureMax(NGPsource,t)                                     = L_CPTY(NGPSource,t) ;
* DAC facilities
CaptureMax(DACsource,t)                                     = sum(DACplant$unitplt(DACsource,DACplant),DACCapture(DACplant,t)) ;
* Cement CCS retrofits
CaptureMax(Cem_Source_exs,t)     = I_CPTY(Cem_Source_exs)*CEM_CFR(Cem_Source_exs,t) ;
* New Cement with CCS
CaptureMax(Cem_Source_new,t)     = sum(Cem_Plant_new$Nunitplt(Cem_Source_new,Cem_Plant_new), C_CFR_NEW(Cem_Plant_new,t)) ;

$label next6

* Match plant pipe sizes to actual capture capacity as indicated by CTSSavR.gdx
parameter TotalCapture(plant);
TotalCapture(plant) = smax(t, sum(source$unitplt(source,plant), CaptureMax(source,t)));

link(FromNode,ToNode,diameter) = link_input(FromNode,ToNode,diameter);
link(FromNode(plant),ToNode,diameter)$((LinkDist(FromNode,ToNode)>0) and TotalCapture(plant)>0) =
  TotalCapture(plant) <= PipeMax(diameter) and
  TotalCapture(plant) >= PipeMax(diameter-1) ;
link(FromNode(plant),ToNode,diameter)$(TotalCapture(plant)=0) = no ;

*** Begin narrowing down pipe options based on new transshipment hubs ***
set link_noplt(FromNode,ToNode,diameter)
    link_onehub(FromNode,ToNode,diameter)
    ;

parameter MinPltDist(FromNode)
          ToTransDist(FromNode,ToNode)
          MinSinkDist(ToNode)
          FromTransDist(FromNode,ToNode)
          ;

ToTransDist(FromNode,ToNode(transship)) = LinkDist(FromNode,ToNode);
FromTransDist(FromNode,ToNode(INJ_TERMINALS)) = LinkDist(FromNode,ToNode);
MinPltDist(FromNode) = smin(ToNode$(ToTransDist(FromNode,ToNode)>0),ToTransDist(FromNode,ToNode));
MinSinkDist(ToNode(INJ_TERMINALS)) = smin(FromNode(transship)$(FromTransDist(FromNode,ToNode)>0),FromTransDist(FromNode,ToNode));
link_noplt(FromNode,ToNode,diameter) = link(FromNode,ToNode,diameter);
link_noplt(FromNode(plant),ToNode,diameter) = no;

* Check if using grid hubs or equal area hubs
$Ifi %HubType% == 1 $goto EQHubs
link_noplt(FromNode,ToNode(INJ_TERMINALS),diameter)$(LinkDist(FromNode,ToNode) > MinSinkDist(ToNode)) = no;
$label EQHubs

* Use pipe filters
$Ifi %POPT% == 3 $goto next3
$Ifi %POPT% == 2 $goto next2
$Ifi %POPT% == 1 $goto next1

$label next1
* Check if using grid hubs or equal area hubs
$Ifi %HubType% == 1 $goto GrHubs
link_noplt(FromNode,ToNode,diameter)$(LinkDist(FromNode,ToNode) > 1.0*MinPltDist(FromNode)) = no;
$goto next3

$label GrHubs
link_noplt(FromNode,ToNode,diameter)$(LinkDist(FromNode,ToNode) > 1.0*MinPltDist(FromNode)) = no;

$goto next3

$label next2
*link_noplt(FromNode,ToNode,diameter)$(LinkDist(FromNode,ToNode) > 1.5*MinPltDist(FromNode)) = no;
*$goto next4
$label next3
*link_noplt(FromNode,ToNode,diameter)$(LinkDist(FromNode,ToNode) > 2.0*MinPltDist(FromNode)) = no;
*$label next4
link_onehub(FromNode,ToNode,diameter) = link(FromNode,ToNode,diameter);
*link_onehub(FromNode,ToNode(INJ_TERMINALS),diameter) = no;
link_onehub(FromNode(transship),ToNode,diameter) = no;
*link_onehub(FromNode,ToNode,diameter)$(ToTransDist(FromNode,ToNode) > MinPltDist(FromNode)) = no;
link_onehub(FromNode,ToNode,diameter)$(LinkDist(FromNode,ToNode) > MinPltDist(FromNode)) = no;
link_noplt(FromNode,ToNode(INJ_TERMINALS),diameter)$(LinkDist(FromNode,ToNode) > MinSinkDist(ToNode)) = no;
*link_noplt(FromNode(transship),ToNode,diameter)$(diameter.val<36) = no;
link(FromNode,ToNode,diameter) = link_onehub(FromNode,ToNode,diameter) + link_noplt(FromNode,ToNode,diameter);
*** End narrowing down pipe options based on new transshipment hubs ***

*Fixed Retrofit/NewBuild Cost  ($MM)
SrcCapCost(source,t)   = sum(PlantType$SourceGoal(source,PlantType),
   ROUND((RetroBase(source)+0.001) * (GDP('2012')/GDP('2011')) * PV("Capture",t)* FCRF("Capture")*CAF("Capture") * CRF("Capture",t)* ProgramGoal(t,PlantType,'FixedAdjC'),RND) );

* Adjust to 2012$
CapCostVar(source) = CapCostVar(source) * (GDP('2012')/GDP('2011')) ;

*Variable Capture Cost: apply program goals to base variable cost and add costs from parasitic load (assumes 75% capacity factor)
* Introduced power loss offset costs -- translated to $/tonne using assumptions specified above

* Moved power loss offset costs into fixed costs
CaptureCost(source,t)$(CaptureMax(source,t) > 0) = sum(PlantType$SourceGoal(source,PlantType),
  ROUND(PV("Capture",t) * CapCostVar(source) * ProgramGoal(t,PlantType,'VarAdjC') ,RND) );

CaptureCost(source,t)$(CaptureMax(source,t) = 0) = sum(PlantType$SourceGoal(source,PlantType),
  ROUND(PV("Capture",t) * CapCostVar(source) * ProgramGoal(t,PlantType,'VarAdjC') ,RND) );

***  Transportation Cost Calculations***
Parameter
*Model Parameters
      PipeCapCost(FromNode,ToNode,diameter,t)       Fixed cost (millions of dollars) to build a PIPE
      TransportCost(FromNode,ToNode,diameter,t)     Variable Transportation Cost
      PumpElecCost(FromNode,ToNode,diameter,t)        Cost of electricity purchased to run the pumps

*Working Parameters
      MatCost(FromNode,ToNode,diameter)             Material cost component of Transportation cost
      LaborCost(FromNode,ToNode,diameter)           Labor cost component of Transportation cost
      ROWCost(FromNode,ToNode,diameter)             Right-of-way cost component of Transportation cost
      MiscCost(FromNode,ToNode,diameter)            Misc cost component of Transportation cost
      PumpNum(FromNode,ToNode,diameter)             Number of Pumps
      P_Pwr(FromNode,ToNode,diameter)               Power required for each pump
      PumpCost(FromNode,ToNode,diameter)            Pump Capital Cost
      PumpEquip(FromNode,ToNode,diameter)           Annual fixed cost of pump equipment
      PumpElec(FromNode,ToNode,diameter)            Electricity needed to run all necessary pump

      Found
;

scalar testval ;
loop(Link(FromNode,ToNode,diameter),
  testval = Inf ;
  loop(dist_miles$(PumpNumTbl(diameter,dist_miles) and (dist_miles.val<=LinkDist(FromNode,ToNode))),

    if( abs(LinkDist(FromNode,ToNode) - dist_miles.val) <= testval,
      testval = dist_miles.val ;
      PumpNum(FromNode,ToNode,diameter) = PumpNumTbl(diameter,dist_miles) ;
    );

  );
);


MatCost(Link(FromNode,ToNode,diameter)) = Tcosts('Materials','Fixed')+Tcosts('Materials','Length')*LinkDist(FromNode,ToNode)*
                                          (Tcosts('Materials','DD')* diameter.val**2 + Tcosts('Materials','D')*diameter.val + Tcosts('Materials','Constant')) *
                                          Tcosts('Materials','Co2esc')*Tcosts('Co2adj','Constant') ;

LaborCost(Link(FromNode,ToNode,diameter)) =  Tcosts('Labor','Fixed')+Tcosts('Labor','Length')*LinkDist(FromNode,ToNode)*
                                          (Tcosts('Labor','DD')* diameter.val**2 + Tcosts('Labor','D')* diameter.val + Tcosts('Labor','Constant')) *
                                          Tcosts('Labor','Co2esc')*Tcosts('Co2adj','Constant') ;

ROWCost(Link(FromNode,ToNode,diameter))   = Tcosts('ROW','Fixed')+Tcosts('ROW','Length')*LinkDist(FromNode,ToNode)*
                                          (Tcosts('ROW','D')* diameter.val + Tcosts('ROW','Constant'))*
                                          Tcosts('ROW','Co2esc')*Tcosts('Co2adj','Constant');

MiscCost(Link(FromNode,ToNode,diameter))  = Tcosts('Misc','Fixed')+Tcosts('Misc','Length')*LinkDist(FromNode,ToNode)*
                                          (Tcosts('Misc','D')* diameter.val + Tcosts('Misc','Constant'))*
                                          Tcosts('Misc','Co2esc')*Tcosts('Co2adj','Constant') ;

P_Pwr(Link(FromNode,ToNode,diameter))     = Tcosts('Elec_Coeff','Constant')  *  Pipemax(diameter)  /  Tcosts('PipeCapacity','Constant')  /1000  ;

PumpCost(Link(FromNode,ToNode,diameter))  = Tcosts('PumpCapCC','Constant') * P_Pwr(FromNode,ToNode,diameter) + Tcosts('UnitPump','Constant') * PumpNum(FromNode,ToNode,diameter);

* Change costs for hub hookup pipes to hookup costs
MatCost(link_onehub(FromNode,ToNode,diameter))$(LinkDist(FromNode,ToNode) eq MinPltDist(FromNode))   = HookupFee(diameter,'Hub','MaterialCost');
LaborCost(link_onehub(FromNode,ToNode,diameter))$(LinkDist(FromNode,ToNode) eq MinPltDist(FromNode)) = HookupFee(diameter,'Hub','LaborCost');
ROWCost(link_onehub(FromNode,ToNode,diameter))$(LinkDist(FromNode,ToNode) eq MinPltDist(FromNode))   = HookupFee(diameter,'Hub','ROWCost');
MiscCost(link_onehub(FromNode,ToNode,diameter))$(LinkDist(FromNode,ToNode) eq MinPltDist(FromNode))  = HookupFee(diameter,'Hub','MiscCost');
PumpCost(link_onehub(FromNode,ToNode,diameter))$(LinkDist(FromNode,ToNode) eq MinPltDist(FromNode))  = HookupFee(diameter,'Hub','PumpCost');
* Change costs for sink hookup pipes to hookup costs
MatCost(link_onehub(FromNode,ToNode,diameter))$(LinkDist(FromNode,ToNode) < MinPltDist(FromNode))   = HookupFee(diameter,'Sink','MaterialCost');
LaborCost(link_onehub(FromNode,ToNode,diameter))$(LinkDist(FromNode,ToNode) < MinPltDist(FromNode)) = HookupFee(diameter,'Sink','LaborCost');
ROWCost(link_onehub(FromNode,ToNode,diameter))$(LinkDist(FromNode,ToNode) < MinPltDist(FromNode))   = HookupFee(diameter,'Sink','ROWCost');
MiscCost(link_onehub(FromNode,ToNode,diameter))$(LinkDist(FromNode,ToNode) < MinPltDist(FromNode))  = HookupFee(diameter,'Sink','MiscCost');
PumpCost(link_onehub(FromNode,ToNode,diameter))$(LinkDist(FromNode,ToNode) < MinPltDist(FromNode))  = HookupFee(diameter,'Sink','PumpCost');

*Fixed Transportation Cost ($MM)
PipeCapCost(Link(FromNode,ToNode,diameter),t)$(LinkDist(FromNode,ToNode)>0) =
  ROUND(((MatCost(link)*CAF2("Materials") + LaborCost(link)*CAF2("Labor")+ MiscCost(link)*CAF2("Misc")+ ROWCost(link)*CAF2("ROW") +
  Tcosts('OthPipeCC','Constant')*CAF2("OthPipeCC") + PumpCost(link)*CAF2("Pumps") )* PV("Transport",t)*  FCRF("Transport") * CRF("Transport",t)/1000000),RND) * ProgramGoal(t,'1','FixedAdjT') ;


**** TEMP!!!  CCF correction to be removed when data is updated!!
*PipeCapCost(Link(FromNode,ToNode,diameter),t)$(LinkDist(FromNode,ToNode)>0) = FCF_T * PipeCapCost(FromNode,ToNode,diameter,t) ;

*Variable Transportation Cost
PumpEquip(Link(FromNode,ToNode,diameter)) =Tcosts('PumpPC','Constant')  * ( PumpCost(FromNode,ToNode,diameter) + Tcosts('OthPipeCC','Constant')  ) ;

PumpElec(Link(FromNode,ToNode,diameter)) = Tcosts('Elec_Coeff','Constant') *  Pipemax(diameter)  *8760 * PumpNum(FromNode,ToNode,diameter) / 1000;

PumpElecCost(Link(FromNode,ToNode,diameter),t) =   PumpElec(FromNode,ToNode,diameter) * CompPwr_Price(t) /1000 ;

TransportCost(Link(FromNode,ToNode,diameter),t) =
  ROUND( ( (Tcosts('Var','Length')* LinkDist(FromNode,ToNode)/PipeMax(diameter) + PumpEquip(FromNode,ToNode,diameter) + PumpElecCost(FromNode,ToNode,diameter,t) )* PV("Transport",t) )/1000000,RND ) * ProgramGoal(t,'1','VarAdjT') ;
* Change costs for hub and sink hookup pipes to hookup costs
TransportCost(link_onehub(FromNode,ToNode,diameter),t)$(LinkDist(FromNode,ToNode) eq MinPltDist(FromNode))   =
  ROUND( ( HookupFee(diameter,'Hub','TransportCost') * PV("Transport",t) ),RND ) * ProgramGoal(t,'1','VarAdjT') ;
TransportCost(link_onehub(FromNode,ToNode,diameter),t)$(LinkDist(FromNode,ToNode) < MinPltDist(FromNode))    =
  ROUND( ( HookupFee(diameter,'Sink','TransportCost') * PV("Transport",t) ),RND ) * ProgramGoal(t,'1','VarAdjT') ;

* Check if using grid hubs or equal area hubs
$Ifi not %HubType% == 1 $goto OneSink

MatCost(link_noplt(FromNode,ToNode(INJ_TERMINALS),diameter))$(LinkDist(FromNode,ToNode) eq MinSinkDist(ToNode))   = HookupFee(diameter,'Sink','MaterialCost');
LaborCost(link_noplt(FromNode,ToNode(INJ_TERMINALS),diameter))$(LinkDist(FromNode,ToNode) eq MinSinkDist(ToNode)) = HookupFee(diameter,'Sink','LaborCost');
ROWCost(link_noplt(FromNode,ToNode(INJ_TERMINALS),diameter))$(LinkDist(FromNode,ToNode) eq MinSinkDist(ToNode))   = HookupFee(diameter,'Sink','ROWCost');
MiscCost(link_noplt(FromNode,ToNode(INJ_TERMINALS),diameter))$(LinkDist(FromNode,ToNode) eq MinSinkDist(ToNode))  = HookupFee(diameter,'Sink','MiscCost');
PumpCost(link_noplt(FromNode,ToNode(INJ_TERMINALS),diameter))$(LinkDist(FromNode,ToNode) eq MinSinkDist(ToNode))  = HookupFee(diameter,'Sink','PumpCost');

TransportCost(link_noplt(FromNode,ToNode(INJ_TERMINALS),diameter),t)$(LinkDist(FromNode,ToNode) eq MinSinkDist(ToNode))    =
  ROUND( ( HookupFee(diameter,'Sink','TransportCost') * PV("Transport",t) ),RND ) * ProgramGoal(t,'1','VarAdjT') ;

$label OneSink

link_noplt(FromNode(transship),ToNode,diameter)$(diameter.val<36) = no;
link(FromNode,ToNode,diameter) = link_onehub(FromNode,ToNode,diameter) + link_noplt(FromNode,ToNode,diameter);

*** Transportation Cost Calculations for initial [fuel region-OGSM region] cost matrix ***
Parameter
*Model Parameters
      PipeCapCostInit(FuelReg,REGION_OGSM)         Fixed cost ($ per ton) to build a PIPE
      TransportCostInit(FuelReg,REGION_OGSM)       Variable Transportation Cost ($ per ton)
      PumpElecCostInit(FuelReg,REGION_OGSM)
*Working Parameters
      MatCostInit(FuelReg,REGION_OGSM)             Material cost component of Transportation cost
      LaborCostInit(FuelReg,REGION_OGSM)           Labor cost component of Transportation cost
      ROWCostInit(FuelReg,REGION_OGSM)             Right-of-way cost component of Transportation cost
      MiscCostInit(FuelReg,REGION_OGSM)            Misc cost component of Transportation cost
      PumpNumInit(FuelReg,REGION_OGSM)
      P_PwrInit(FuelReg,REGION_OGSM)
      PumpCostInit(FuelReg,REGION_OGSM)
      PumpEquipInit(FuelReg,REGION_OGSM)
      PumpElecInit(FuelReg,REGION_OGSM)
      Found
;
 scalar testval ;
* Assume the carbon output of a new gas plant which would require a 12 inch pipe
loop((FuelReg,REGION_OGSM,diameter)$(diameter.val = 12),
  testval = Inf ;
  loop(dist_miles$(PumpNumTbl("12",dist_miles) and (dist_miles.val<=FuelReg2OGSMDist(FuelReg,REGION_OGSM))),

    if( abs(FuelReg2OGSMDist(FuelReg,REGION_OGSM) - dist_miles.val) <= testval,
      testval = dist_miles.val ;
      PumpNumInit(FuelReg,REGION_OGSM) = PumpNumTbl("12",dist_miles) ;
    );
  );


  MatCostInit(FuelReg,REGION_OGSM)   = Tcosts('Materials','Fixed')+Tcosts('Materials','Length')*FuelReg2OGSMDist(FuelReg,REGION_OGSM)*
                                          (Tcosts('Materials','DD')* diameter.val**2 + Tcosts('Materials','D')*diameter.val + Tcosts('Materials','Constant')) *
                                          Tcosts('Materials','Co2esc')*Tcosts('Co2adj','Constant') ;

  LaborCostInit(FuelReg,REGION_OGSM) =  Tcosts('Labor','Fixed')+Tcosts('Labor','Length')*FuelReg2OGSMDist(FuelReg,REGION_OGSM)*
                                          (Tcosts('Labor','DD')* diameter.val**2 + Tcosts('Labor','D')* diameter.val + Tcosts('Labor','Constant')) *
                                          Tcosts('Labor','Co2esc')*Tcosts('Co2adj','Constant') ;

  ROWCostInit(FuelReg,REGION_OGSM)   = Tcosts('ROW','Fixed')+Tcosts('ROW','Length')*FuelReg2OGSMDist(FuelReg,REGION_OGSM)*
                                          (Tcosts('ROW','D')* diameter.val + Tcosts('ROW','Constant'))*
                                          Tcosts('ROW','Co2esc')*Tcosts('Co2adj','Constant') ;

  MiscCostInit(FuelReg,REGION_OGSM)  = Tcosts('Misc','Fixed')+Tcosts('Misc','Length')*FuelReg2OGSMDist(FuelReg,REGION_OGSM)*
                                          (Tcosts('Misc','D')* diameter.val + Tcosts('Misc','Constant'))*
                                          Tcosts('Misc','Co2esc')*Tcosts('Co2adj','Constant') ;

  P_PwrInit(FuelReg,REGION_OGSM)       = Tcosts('Elec_Coeff','Constant')  *  Pipemax("12")  /  Tcosts('PipeCapacity','Constant')  /1000  ;

  PumpCostInit(FuelReg,REGION_OGSM)  = Tcosts('PumpCapCC','Constant') * P_PwrInit(FuelReg,REGION_OGSM) + Tcosts('UnitPump','Constant') * PumpNumInit(FuelReg,REGION_OGSM) ;

*Fixed Transportation Cost ($/ton)
* Assume the carbon output of a new gas plant = 1.18 MMT/yr
  PipeCapCostInit(FuelReg,REGION_OGSM) =
    ROUND(((MatCostInit(FuelReg,REGION_OGSM)*CAF2("Materials") + LaborCostInit(FuelReg,REGION_OGSM)*CAF2("Labor") + MiscCostInit(FuelReg,REGION_OGSM)*CAF2("Misc") +
    ROWCostInit(FuelReg,REGION_OGSM)*CAF2("ROW") +  Tcosts('OthPipeCC','Constant')*CAF2("OthPipeCC")   +  PumpCostInit(FuelReg,REGION_OGSM)*CAF2("Pumps")    ) *
    FCRF("Transport") / 1000000),RND) / 1.18 ;

**** TEMP!!!  CCF correction to be removed when data is updated!!
*  PipeCapCostInit(FuelReg,REGION_OGSM) = FCF_T * PipeCapCostInit(FuelReg,REGION_OGSM) ;

*Variable Transportation Cost ($/ton)
  PumpEquipInit(FuelReg,REGION_OGSM) =Tcosts('PumpPC','Constant')  * ( PumpCostInit(FuelReg,REGION_OGSM) + Tcosts('OthPipeCC','Constant')  ) ;

  PumpElecInit(FuelReg,REGION_OGSM) = Tcosts('Elec_Coeff','Constant') *  Pipemax("12")  *8760 * PumpNumInit(FuelReg,REGION_OGSM)/ 1000;

  PumpElecCostInit(FuelReg,REGION_OGSM) =   PumpElecInit(FuelReg,REGION_OGSM) * CompPwr_Price("2012") /1000 ;

  TransportCostInit(FuelReg,REGION_OGSM) =
    ROUND( (((Tcosts('Var','Length')* FuelReg2OGSMDist(FuelReg,REGION_OGSM)/PipeMax("12"))) + PumpEquipInit(FuelReg,REGION_OGSM)+ PumpElecCostInit(FuelReg,REGION_OGSM))/1000000,RND ) ;
);

*** Transportation Cost Calculations for initial [OGSM region-OGSM region] cost matrix ***
  alias (REGION_OGSM,REGION_OGSM2);
Parameter
*Model Parameters
      PipeCapCostInitOR(REGION_OGSM,REGION_OGSM)         Fixed cost ($ per ton) to build a PIPE
      TransportCostInitOR(REGION_OGSM,REGION_OGSM)       Variable Transportation Cost ($ per ton)
      PumpElecCostInitOR(REGION_OGSM,REGION_OGSM)
*Working Parameters
      MatCostInitOR(REGION_OGSM,REGION_OGSM)             Material cost component of Transportation cost
      LaborCostInitOR(REGION_OGSM,REGION_OGSM)           Labor cost component of Transportation cost
      ROWCostInitOR(REGION_OGSM,REGION_OGSM)             Right-of-way cost component of Transportation cost
      MiscCostInitOR(REGION_OGSM,REGION_OGSM)            Misc cost component of Transportation cost
      PumpNumInitOR(REGION_OGSM,REGION_OGSM)
      P_PwrInitOR(REGION_OGSM,REGION_OGSM)
      PumpCostInitOR(REGION_OGSM,REGION_OGSM)
      PumpEquipInitOR(REGION_OGSM,REGION_OGSM)
      PumpElecInitOR(REGION_OGSM,REGION_OGSM)
;
 scalar testval ;
* Assume the carbon output of a new gas plant which would require a 12 inch pipe
loop((REGION_OGSM,REGION_OGSM2,diameter)$(diameter.val = 12),
  testval = Inf ;
  loop(dist_miles$(PumpNumTbl("12",dist_miles) and (dist_miles.val<=OGSM2OGSMDist(REGION_OGSM,REGION_OGSM2))),
    if( abs(OGSM2OGSMDist(REGION_OGSM,REGION_OGSM2) - dist_miles.val) <= testval,
      testval = dist_miles.val ;
      PumpNumInitOR(REGION_OGSM,REGION_OGSM2) = PumpNumTbl("12",dist_miles) ;
    );
  );
  MatCostInitOR(REGION_OGSM,REGION_OGSM2)   = Tcosts('Materials','Fixed')+Tcosts('Materials','Length')*OGSM2OGSMDist(REGION_OGSM,REGION_OGSM2)*
                                          (Tcosts('Materials','DD')* diameter.val**2 + Tcosts('Materials','D')*diameter.val + Tcosts('Materials','Constant')) *
                                          Tcosts('Materials','Co2esc')*Tcosts('Co2adj','Constant') ;
  LaborCostInitOR(REGION_OGSM,REGION_OGSM2) =  Tcosts('Labor','Fixed')+Tcosts('Labor','Length')*OGSM2OGSMDist(REGION_OGSM,REGION_OGSM2)*
                                          (Tcosts('Labor','DD')* diameter.val**2 + Tcosts('Labor','D')* diameter.val + Tcosts('Labor','Constant')) *
                                          Tcosts('Labor','Co2esc')*Tcosts('Co2adj','Constant') ;
  ROWCostInitOR(REGION_OGSM,REGION_OGSM2)   = Tcosts('ROW','Fixed')+Tcosts('ROW','Length')*OGSM2OGSMDist(REGION_OGSM,REGION_OGSM2)*
                                          (Tcosts('ROW','D')* diameter.val + Tcosts('ROW','Constant'))*
                                          Tcosts('ROW','Co2esc')*Tcosts('Co2adj','Constant') ;
  MiscCostInitOR(REGION_OGSM,REGION_OGSM2)  = Tcosts('Misc','Fixed')+Tcosts('Misc','Length')*OGSM2OGSMDist(REGION_OGSM,REGION_OGSM2)*
                                          (Tcosts('Misc','D')* diameter.val + Tcosts('Misc','Constant'))*
                                          Tcosts('Misc','Co2esc')*Tcosts('Co2adj','Constant') ;
  P_PwrInitOR(REGION_OGSM,REGION_OGSM2)       = Tcosts('Elec_Coeff','Constant')  *  Pipemax("12")  /  Tcosts('PipeCapacity','Constant')  /1000  ;
  PumpCostInitOR(REGION_OGSM,REGION_OGSM2)  = Tcosts('PumpCapCC','Constant') * P_PwrInitOR(REGION_OGSM,REGION_OGSM2) + Tcosts('UnitPump','Constant') * PumpNumInitOR(REGION_OGSM,REGION_OGSM2) ;
*Fixed Transportation Cost ($/ton)
* Assume the carbon output of a new gas plant = 1.18 MMT/yr
  PipeCapCostInitOR(REGION_OGSM,REGION_OGSM2) =
    ROUND(((MatCostInitOR(REGION_OGSM,REGION_OGSM2)*CAF2("Materials") + LaborCostInitOR(REGION_OGSM,REGION_OGSM2)*CAF2("Labor") + MiscCostInitOR(REGION_OGSM,REGION_OGSM2)*CAF2("Misc") +
    ROWCostInitOR(REGION_OGSM,REGION_OGSM2)*CAF2("ROW") +  Tcosts('OthPipeCC','Constant')*CAF2("OthPipeCC")   +  PumpCostInitOR(REGION_OGSM,REGION_OGSM2)*CAF2("Pumps")    ) *
    FCRF("Transport") / 1000000),RND) / 1.18 ;
**** TEMP!!!  CCF correction to be removed when data is updated!!
*  PipeCapCostInit(REGION_OGSM,REGION_OGSM) = FCF_T * PipeCapCostInit(REGION_OGSM,REGION_OGSM) ;
*Variable Transportation Cost ($/ton)
  PumpEquipInitOR(REGION_OGSM,REGION_OGSM2) =Tcosts('PumpPC','Constant')  * ( PumpCostInitOR(REGION_OGSM,REGION_OGSM2) + Tcosts('OthPipeCC','Constant')  ) ;
  PumpElecInitOR(REGION_OGSM,REGION_OGSM2) = Tcosts('Elec_Coeff','Constant') *  Pipemax("12")  *8760 * PumpNumInitOR(REGION_OGSM,REGION_OGSM2)/ 1000;
  PumpElecCostInitOR(REGION_OGSM,REGION_OGSM2) =   PumpElecInitOR(REGION_OGSM,REGION_OGSM2) * CompPwr_Price("2012") /1000 ;
  TransportCostInitOR(REGION_OGSM,REGION_OGSM2) =
    ROUND( (((Tcosts('Var','Length')* OGSM2OGSMDist(REGION_OGSM,REGION_OGSM2)/PipeMax("12"))) + PumpEquipInitOR(REGION_OGSM,REGION_OGSM2)+ PumpElecCostInitOR(REGION_OGSM,REGION_OGSM2))/1000000,RND ) ;
);

* Fill OnePipeNodes with the nodes where only one outgoing pipe is allowed, could be Transship and/or plants, or a specific list
Set
OnePipeNodes          Incidence of nodes where only one outgoing pipe is allowed ;

OnePipeNodes(CapPower)   = yes;
OnePipeNodes(transship)  = no;

*************** New Saline Model Calculations ****************
parameters
         SinkCapCost(Inj,t)                Fixed cost(millions of dollars) to build a SINK
         InjectCost(Inj,t)                 Variable cost (O&M) per tonne ($) for CO2 injection
         WellCapCost(Inj,t)                Cost (millions of dollars) to build a well at each SINK
         WellMax(Inj)                      Maximum (millions tonnes) injected annually at a well for each SINK
         InjectCap(Inj)                    Total cummmulative capacity in million tonnes at each SINK
         CarbonOffset(t)                   Variable offset per tonne (dollars)on CO2 credited when injected
         CarbonPriceTM(th)                 Carbon Price in $USD per tonne referenced by tm instead of t
         WellDepth(Inj)                    Well Depth in Meters - Used to impose limit on annual meters of drilling allowed

*  P_Coeff(InjSal)               Plume Coefficent
*  GenCC(InjSal)                 Gen capital cost
  INJPipeCapCost(InjSal)        Injection pipe capital cost
*  PreOpCC(InjSal)               Pre-operational capital cost
  NW_PreOp(InjSal)              Non-well-dependent costs
  WDepCC(InjSal)                Well-dependent costs ($ per well)
*  PADepCC(InjSal)               Plume area dependent costs
  OP3YRCC(InjSal)               3-year repeating capital costs (Operations)
  OP5YRCC(InjSal)               5-year recurring costs
  OpExPerWell(InjSal)           Operating expenses in $ per well
  OpExPerTon(InjSal)            Operating expenses in $ per ton
*  FINRESP(InjSal)               Financial responsibility
  WellDepFinResp(InjSal)        Well-dependent financial responsibility ($ per well)
  TonDepFinResp(InjSal)         Ton-dependent financial responsibility ($ per ton)
*  TOP5YRCC(InjSal)
;

*Begin new calculations for NETL deliverable*
*OnLocation Inc 2019FEB**
***OPEX PER TONNE***
***site-level parameters for intermediate calculations***
parameters
         SIC(InjSal)     site-independent costs
         CO2T(InjSal)    CO2-dependent cost per ton
         CPRM(InjSal)    Cost per reserve monitoring well
         CPWPA(InjSal)   Cost per well plume area
         CPPA(InjSal)    Cost per year plume area;
***OPEX PER WELL***
***site-level parameters for intermediate calculations***
parameters
         DCMW(InjSal)    costs for dual-completion monitoring wells
         CMW(InjSal)     costs for monitoring wells
         CPIW(InjSal)    costs per injection well per year
         DCPIJW(InjSal)  direct costs per injection well
         DCPMJW(InjSal)  additional direct cost for monitoring well
         DCPMJW_SUB1(InjSal) subcalc 1 for DCPMJW
         DCPMJW_SUB2(InjSal) subcalc 2 for DCPMJW
         OpExPerWell_Old(InjSal);
* Non-well-dependent site costs
parameters
         SISU(InjSal)            Site-specific setup costs millions of 2011 $
         PreopPlume(InjSal)
         PreopSeismic(InjSal)
         FFPRE(t)                financial factor that accounts for impact of taxes associated w equity investment on the carrying cost
         FFPRE2
*         CRF_30                  capital recovery factor 30 years
         FCRF_1530               fixed charge rate 15 year tax life 30 year project life
         NW_PreOpOld(InjSal)
         SinkCapCostOld(Inj,t)
         np1
         np2
         np3
         CRF25
         CRF30
         CRF31
         CRF5;
*************************  Saline site operational period calcualtions ***************************************************************
parameters
         Financial_Factor_1      financial factor for seismic costs assumed to be in five yr intervals
         Financial_Factor_2      financial factor for monitoring well cost expenditures assumed in 7 yr intervals
         FCRF_5_5                fixed charge rate five years tax rate five year recovery
         FCRF_5_7                fixed charge rate five years tax rate seven year recovery
         OP5YRCC_SUB1(InjSal)
         OP5YRCC_SUB2(InjSal)
         Annual_Tonnes(InjSal)
         InjectCostOld(Inj,t)
         RecurCap(InjSal)
         FCRF_5_5_1      FCRF assuming 5 yr tax life 5 yr recovery
         FF3             Annual capital carrying charge sasuming 5 yr tax life 5 yr recovery occurring every 5 yrs;
alias(t1,t);
FCRF_1530 = 0.1118;
FCRF_5_5=0.2744;
FCRF_5_7=0.2005;
FCRF_5_5_1=0.2585;
*capital recovery factors used in this section
CRF30=sum(t1$(card(t1)-ord(t1) eq 30), CRF('Storage',t1));
CRF31=sum(t1$(card(t1)-ord(t1) eq 31), CRF('Storage',t1));
CRF25=sum(t1$(card(t1)-ord(t1) eq 25), CRF('Storage',t1));
CRF5=sum(t1$(card(t1)-ord(t1) eq 5), CRF('Storage',t1));
execute_unload 'CRFS' FCRF_1530 FCRF_5_5 FCRF_5_7 FCRF_5_5_1 CRF30 CRF31 CRF25 CRF5;
***OPEX PER TON***
**Intermediate calcs **
*Site-Independent Costs
SIC(InjSal) = Saline_Constants('SIC')/SinkProps2(InjSal,'Tonnes');
*CO2 Dependent Costs (costs per tonne)
CO2T(InjSal) = Saline_Constants('CO2T');
*Cost per reserve monitoring well
CPRM(InjSal) = SinkProps2(InjSal,'RESMWell_ETUC') * Saline_Coeffs('CPRMult') / (SinkProps2(InjSal,'Tonnes') * 1e6);
*Cost per well plume area
CPWPA(InjSal) = (SinkProps2(InjSal,'wellPA_ETUC') * 6 / 30) / (SinkProps2(InjSal,'Tonnes') * 1e6);
*Cost per year plume area
CPPA(InjSal) = (SinkProps2(InjSal,'W_PlumeR_ETUC') + SinkProps2(InjSal,'PlumeR_ETUC')) / (SinkProps2(InjSal,'Tonnes') * 1e6);
** Final Opex calc **
*OpExPerTon_Old(InjSal) = OpExPerTon(InjSal);
OpExPerTon(InjSal) =     SIC(InjSal) + CO2T(InjSal) +
                         (CPRM(InjSal) + CPWPA(InjSal) + CPPA(InjSal));
***OPEX PER WELL***
**Intermediate calcs**
*dual-completion monitoring well costs per injection well
DCMW(InjSal) = SinkProps2(InjSal,'DCMW_AC') / SinkProps2(InjSal,'I_Wells');
* monitoring well costs per injection well: Avg monitoring wells * (avg mon. well cst + ann OM per foot * depth)
CMW(InjSal) = SinkProps2(InjSal,'M_Wells') / 2 * (Saline_Constants('AWC') + Saline_Coeffs('CPF1') * SinkProps2(InjSal,'MW_Depth')) / SinkProps2(InjSal,'I_Wells');
* injection well costs per well per year
CPIW(InjSal) = Saline_Constants('CPIW');
* direct costs per injection well: injection well depth * ann. inj. well cost/ft + fixed inj. well cost + (last yr cost/ft*depth + last yr fixed)/(30 yrs)
DCPIJW(InjSal) = (SinkProps2(InjSal,'Inj_depth') * Saline_Coeffs('CPF2') + Saline_Coeffs('FCPW1'))
                 + (SinkProps2(InjSal,'Inj_depth') * Saline_Coeffs('CPF3') + Saline_Coeffs('FCPW2')) / 30;
*additional direct costs per injection well:  (added monitoring well cst/ft*depth+monitoring well fixed)*(mon. wells) + (depth*5yr mon. well cst+5-yr fixed)*(mon. wells)
DCPMJW_SUB1(InjSal) = (SinkProps2(InjSal,'Inj_depth') * Saline_Coeffs('CPF4')+Saline_Coeffs('FCPMW1')) * (SinkProps2(InjSal,'DCM_Wells')/2+1);
DCPMJW_SUB2(InjSal) = (SinkProps2(InjSal,'Inj_depth') * Saline_Coeffs('CPF5')+Saline_Coeffs('FCPMW2')) * (SinkProps2(InjSal,'DCM_Wells')/2+1) * 30/6;
DCPMJW(InjSal) = (DCPMJW_SUB1(InjSal) + DCPMJW_SUB2(InjSal) / 30) / SinkProps2(InjSal,'I_Wells');
**Final Opex per well calc**
*OpExPerWell_Old(InjSal) = OpExPerWell(InjSal);
OpExPerWell(InjSal) = DCMW(InjSal) + CMW(InjSal) + CPIW(InjSal) + DCPIJW(InjSal) + DCPMJW(InjSal);
OpExPerWell(InjSal) = OpExPerWell(InjSal) / 1e6;
*output
execute_unload "salineom.gdx" InjSal,SIC,CO2T,CPRM,CPWPA,CPPA,DCMW,CMW,CPIW,DCPIJW,DCPMJW,DCPMJW_SUB1,DCPMJW_SUB2,
                              SinkProps2,Saline_Coeffs,Saline_Constants OpExPerTon OpExPerWell_Old OpExPerWell;
*************************  Begin new Saline site pre-operational period calcualtions ***************************************************************
PreopPlume(InjSal) = SinkProps2(InjSal,'PreopPA') * Saline_Coeffs('PAM');
*
PreopSeismic(InjSal) = Saline_Coeffs('C3DS_N') * SinkProps2(InjSal,'PA_B');
SISU(InjSal) = SinkProps2(InjSal,'PreopSite') + PreopPlume(InjSal) + PreopSeismic(InjSal);
SISU(InjSal) = SISU(InjSal) / (1e6);
FFPRE2 = FCRF_1530;
*CRF30;
NW_PreOp(InjSal) = (Saline_Constants('SISU') + SISU(InjSal)) * FFPRE2;
*calculate WDepCC
WDepCC(InjSal) = (SinkProps2(InjSal,'StratT')+SinkProps2(InjSal,'PreopWell'))/SinkProps2(InjSal,'I_Wells')*FFPRE2;
WDepCC(InjSal) = WDepCC(InjSal)/1e6;
*output
execute_unload "salinepreop.gdx" InjSal,SISU,PreopPlume,PreopSeismic,
                              SinkProps2,Saline_Coeffs,Saline_Constants,
                              NW_PreOp FVAnnuity CRF PV FCRF WDepCC FFPRE2;
*************************  saline site operational period calcualtions ***************************************************************
Financial_Factor_1 = (FCRF_5_5)/POWER(1+EquityRate('Storage'),5)+1/(POWER(1+EquityRate('Storage'),31));
Financial_Factor_2 = FCRF_5_7;
*FF3
FF3 = (1 + POWER(1+EquityRate('Storage'),-5) + POWER(1+EquityRate('Storage'),-10) + POWER(1+EquityRate('Storage'),-20)) * (1+EquityRate('Storage'));
Annual_Tonnes(InjSal) = SinkProps2(InjSal,'Tonnes');
OP5YRCC_SUB1(InjSal) = Saline_Coeffs('C3DS_N') * SinkProps2(InjSal,'PA_B') / Saline_Constants('ADJ1') * Financial_Factor_1;
OP5YRCC_SUB2(InjSal) = SinkProps2(InjSal,'FiveETUC') * Financial_Factor_2;
OP5YRCC(InjSal) = ((OP5YRCC_SUB1(InjSal) +  OP5YRCC_SUB2(InjSal)) / (Annual_Tonnes(InjSal)*1e6));
RecurCap(InjSal) = SinkProps2(InjSal,'ThreeTRC')*FCRF_5_5_1/CRF5;
OP3YRCC(InjSal) = RecurCap(InjSal) / (Annual_Tonnes(InjSal)*1e6);
*note: check with Less on the use of FCRF_5_7 in this eqn:  follows the description that the costs occur every 7 yrs starting in the first yr
*output
execute_unload "salineoper.gdx" FF3 OP5YRCC OP3YRCC SinkProps SinkProps2 Saline_Coeffs Saline_Constants Financial_Factor_1 OP5YRCC_SUB1 OP5YRCC_SUB2 PV OP3YRCC Annual_Tonnes RecurCap CRF;
*************************  Begin new post-injection site care cost  calculations   ***************************************************************
*Overwrite Well DepFinResp
*parameters       WellDepFinRespOld(InjSal)
*                 WellCapCost_Old(Inj,t);
*WellDepFinRespOld(InjSal)=WellDepFinResp(InjSal);
WellDepFinResp(InjSal) = (SinkProps2(InjSal,'DiscPISC')/SinkProps2(InjSal,'I_Wells'))/FVannuity ;
WellDepFinResp(InjSal) =WellDepFinResp(InjSal)/1e6;
execute_unload "salinepostcare.gdx" WellDepFinResp WDepCC SinkProps SinkProps2 Saline_Coeffs Saline_Constants;
*************************  End new post-injection site care cost calculations   *******************************************************************
*** END New calculations for Saline***
INJPipeCapCost(InjSal) = Saline_Constants('PipeVar')*SinkProps(InjSal,'Plume_R')*0.333*(SinkProps(InjSal,'SiteMax_MMT')/30) ;

*NW_PreOp(InjSal)       = (Saline_Coeffs('PREOP_IND') + Saline_Coeffs('CStr_D')*SinkProps(InjSal,'Str_D') + Saline_Coeffs('CSdrill')*SinkProps(InjSal,'Sdrill') + Saline_Constants('Hvar') ) *FCRF("7") ;

*WDepCC(InjSal)         = (INJPipeCapCost(InjSal) + Saline_Coeffs('CINJ_W') + Saline_Coeffs('CINJ_W_D')*SinkProps(InjSal,'INJ_W_D') + Saline_Coeffs('CS_W')*SinkProps(InjSal,'Sdrill') )* FCRF("1") * CAF("Storage") ;

*OP3YRCC(InjSal)        = (Saline_Coeffs('CAS_ASM')*SinkProps(InjSal,'ASdrill') + Saline_Coeffs('CASD_ASMWell')*(SinkProps(InjSal,'Dtop')-150) + Saline_Coeffs('CASMWell') +
*                          Saline_Coeffs('CMWells_Rdrill')*SinkProps(InjSal,'Rdrill') + Saline_Coeffs('CMWells_Rdepth')*SinkProps(InjSal,'Rdepth') +
*                          Saline_Coeffs('CRdepth_Cdia_MWells_3R')*SinkProps(InjSal,'Rdepth')*Saline_Constants('Cdia') + Saline_Coeffs('CMWells'))*SinkProps(InjSal,'ASMWell') * FCRF("8") ;

*OP5YRCC(InjSal)        = ( Saline_Coeffs('C3DS_5YR')*SinkProps(InjSal,'S3D') + (Saline_Coeffs('5YR_Ind') + Saline_Coeffs('CASMWell_5R'))/(SinkProps(InjSal,'SiteMax_MMT')/30) ) *
*                         ( FCRF("2")*PWF("2")+FCRF("3")*PWF("3")+FCRF("4")*PWF("4")+FCRF("5")*PWF("5")+FCRF("6")*PWF("6") ) ;

*OpExPerTon(InjSal)     = Saline_Coeffs('IND_Exp') + Saline_Coeffs('CDCMW')*SinkProps(InjSal,'DCMW') + Saline_Coeffs('CCO2') +
*                        (Saline_Coeffs('CMWellse') + Saline_Coeffs('CASMWelle'))*SinkProps(InjSal,'ASMWell') +
*                         Saline_Coeffs('CINJ_Re')*SinkProps(InjSal,'INJ_R') + Saline_Coeffs('CPAe')*SinkProps(InjSal,'PA') +
*                         Saline_Coeffs('CPlumeR')*SinkProps(InjSal,'Plume_R') ;

*OpExPerWell(InjSal)    = Saline_Coeffs('CINJ_We') + Saline_Coeffs('CINJ_W_De')*SinkProps(InjSal,'INJ_W_D') + Saline_Coeffs('CW_Plume')*SinkProps(InjSal,'Plume_R') ;

*WellDepFinResp(InjSal) = SinkProps(InjSal,'Fin_ind')/FVannuity ;

* Maximum (millions tonnes) injected annually at a well for saline formations
*WellMax(Inj(InjSal))   = ROUND(SinkProps(InjSal,'MaxWellInjRate')/1.5,RND) ;
*2019FEB18:  New WellMax calculation based on tonnes and I_Wells
WellMax(Inj(InjSal)) = ROUND(SinkProps2(InjSal,'Tonnes')/SinkProps2(InjSal,'I_Wells'),RND);

* Well Depth for Saline Formations in meters
WellDepth(Inj(InjSal)) = ROUND(SinkProps(InjSal,'Dtop')/3,RND)  ;

* Total cummmulative capacity in million tonnes at each saline formation less DAC builds at the site
InjectCap(Inj(InjSal)) = SinkProps(InjSal,'Capacity_MMT')*SinkProps(InjSal,'MaxUse') - sum(t, DAC_Storage(InjSal,t)) ;

* Add 1 to cover rounding error on EOR sites
InjectCap(Inj)  = ROUND(InjectCap(Inj)+ 1 ,0);

*Fixed New Injection Site Cost ($MM)
* Use PreOpCC in SinkCapCost (where 1 is now)    kmc
SinkCapCost(Inj(InjSal),t) = ( NW_PreOp(InjSal)
*+                               SinkProps(InjSal,'PADepCC')*FCRF("7")
                              ) * PV("Storage",t) * CAF("Storage") * CRF("Storage",t) * ProgramGoal(t,'1','FixedAdjS') ;

*Cost of a single well given the depth of this formation  ($MM)
WellCapCost(Inj(InjSal),t) = ( WDepCC(InjSal) * ProgramGoal(t,'1','FixedAdjS') +
                               OpExPerWell(InjSal) * ProgramGoal(t,'1','VarAdjS') +
                               WellDepFinResp(InjSal) * ProgramGoal('2035','1','FixedAdjS')
                              ) * PV("Storage",t) * CRF("Storage",t) ;

*Variable Injection Cost ($/tonne)
InjectCost(Inj(InjSal),t)    = ProgramGoal(t,'1','VarAdjS') * (OP3YRCC(InjSal) + OP5YRCC(InjSal) + OpExPerTon(InjSal)) * PV("Storage",t) ;


* Convert from 2011$ to 2012$
SinkCapCost(Inj(InjSal),t) = SinkCapCost(Inj,t) * (GDP('2012')/GDP('2011')) ;
WellCapCost(Inj(InjSal),t) = WellCapCost(Inj,t) * (GDP('2012')/GDP('2011')) ;
InjectCost(Inj(InjSal),t)  = InjectCost(Inj,t)  * (GDP('2012')/GDP('2011')) ;

* Carbon price per tonne of CO2, carbon conversion from $87/kg to current$/tonne = 12/44 * 1000 * GDP Deflator ($1987 -> $2012)
* (12/44) is the fraction of carbon mass out of the total CO2 molecule mass
* 1000 is the conversion from kg to metric tonne
* The storage PV is used in the CarbonOffset since it is applied real time in the model
* The eor PV is applied later for CarbonPriceTM since
* GDP deflator adjusts from $1987 into $2012 dollars
CarbonOffset(t)  = ROUND(12/44* 1000 * CarbonPrice(t) * (GDP('2012')/GDP('1987')) * PV("Capture",t), RND);
CarbonPriceTM(t) = ROUND(12/44* 1000 * CarbonPrice(t) * (GDP('2012')/GDP('1987')), RND);

*Loop ((tm,t)$(ord(tm) > Card(t)),
Loop (tm$(tm.val > 2050),
   CarbonPriceTM(tm)= ROUND(12/44* 1000 * CarbonPrice('2050') * (GDP('2012')/GDP('1987')),RND);
);

*** ZERO CARBON PRICE ---- When set to 1, set all carbon price or offset vectors to zero
If( RunDefn('ZeroCarbonPrice')= 1,
         CarbonPrice(t) = 0;
         CarbonPriceTM(tm) = 0;
         CarbonOffset(t) = 0;
);

* Set up the CO2 requirements for the pseudo-EOR nodes with CO2 purchase data from NEMS power plants
EOR_CO2Purch(Inj(InjPseudo),tstart,t_emm) =
  sum((M8,REGION_OGSM,MNUMYR)$(MNUMYR_t_emm(MNUMYR,t_emm) and INJ_OGSM(Inj,REGION_OGSM) and M8_to_REGION_OGSM(M8,REGION_OGSM) and ord(M8)<8),
    OGSMOUT_OGCO2QEM(M8,MNUMYR)/18000.0 ) +
  sum((M8,REGION_OGSM,MNUMYR)$(MNUMYR_t_emm(MNUMYR,t_emm) and INJ_OGSM(Inj,REGION_OGSM) and M8_to_REGION_OGSM(M8,REGION_OGSM) and ord(M8)<8),
    OGSMOUT_OGCO2QLF(M8,MNUMYR)/18000.0 ) +
  sum((M8,REGION_OGSM,MNUMYR)$(MNUMYR_t_emm(MNUMYR,t_emm) and INJ_OGSM(Inj,REGION_OGSM) and M8_to_REGION_OGSM(M8,REGION_OGSM) and ord(M8)<8),
    OGSMOUT_OGCO2QDC(M8,MNUMYR) ) +
  sum((M8,REGION_OGSM,MNUMYR)$(MNUMYR_t_emm(MNUMYR,t_emm) and INJ_OGSM(Inj,REGION_OGSM) and M8_to_REGION_OGSM(M8,REGION_OGSM) and ord(M8)<8),
    OGSMOUT_OGCO2QID(M8,MNUMYR)/18000.0 ) ;


* Export Model data to gdx file
Execute_Unload '%dir%CTUSModIN.gdx' ;

Parameter
  CO2_SupplyOverage(t)   Amount by which CO2 max supply from power plants exceeds demands from NEMS
;

CO2_SupplyOverage(t) = sum(E_IGRP, CaptureMax(E_IGRP,t)) + sum(EG_IGRP, CaptureMax(EG_IGRP,t)) + sum(N_IGRP, CaptureMax(N_IGRP,t))
                     - sum(Inj(InjPseudo), EOR_CO2Purch(Inj,'2012',t) ) ;



