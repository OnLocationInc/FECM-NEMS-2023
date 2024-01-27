
* gdx=test.gdx --dir=./ --ForceAllOn=-1

* Allows a set to be empty
$onempty
* Allows a set to get filled with multiple statements, e.g starts out empty and gets fileld in later
$onmulti

Set      th                   t master plus historical                               /1981*2100/
         tm(th)               t master - all possible years needed                   /2011*2100/
         tf(tm)               t financing - all cash flow years                      /2012*2100/
         t_emm(tf)            t for emm output                                       /2015*2080/
         t(t_emm)             time horizon of the model                              /2022*2080/
         t_sy(t)              Start Year
         EnergySource         potential energy sources
         ActiveEnergySource(EnergySource)   potential energy sources
         TechType                           Types of DAC Technologies
         DAC_Sites                          DAC sites
         DAC_Saline(DAC_Sites)              DAC at Saline Injection sites
         DAC_EOR(DAC_Sites)                 DAC at EOR Injection sites
         DAC_Pseudo(DAC_Sites)              DAC at Pseudo sites in EMM Fuel regions
         DAC_EOR_Sites(DAC_Sites)           DAC at EOR Injection sites
         REGION_EMM           EMM regions
         REGION_OGSM          OGSM regions
         M8                   Generic set used for OGSM regions
         M13                  Generic set used for OGSM EOR sources
         M15
         M4                   /1_M4*4_M4/
         MNUMNR               NEMS EMM Region
         MNUMNR_EMM(MNUMNR,REGION_EMM)        Map MNUMNR to EMM Regions
         MNUMYR               NEMS model years
         MNUMYR_t_emm(MNUMYR,t_emm)           Map MNUMYR to t_emm
         M8_to_REGION_OGSM(M8,REGION_OGSM)    Map NEMS OGSM index to CTUS OGSM index
         FuelRegion           Max number of combined fuel regions census-gas-coal-carbon from NEMS
         FuelReg              Set of EMM fuel regions for GAMS
         FuelRegion_2_FuelReg(FuelRegion,FuelReg)  Map NEMS fuel region indicies to GAMS fuel region indicies
         MNUMCR               NEMS census divisions / 01_MNUMCR*11_MNUMCR /
         MNUMCR_FuelRegion(MNUMCR,FuelRegion) Map Census regions to Fuel Regions
         DAC_FuelRegion(DAC_Sites,FuelReg)    Map DAC sites to fuel regions
         DAC_EMM(DAC_Sites,REGION_EMM)        Map DAC sites to EMM regions
         DAC_OGSM(DAC_EOR_Sites,REGION_OGSM)  Map DAC sites to OGSM regions
         DAC_Selection(DAC_Sites,t)           DAC sites activated each year
         DAC_Unselect(DAC_Sites,t)            DAC sites activated each year
         ;

$gdxin DAC\DACPrep.gdx
$load t_sy TechType DAC_Sites DAC_Saline DAC_EOR DAC_Pseudo REGION_EMM FuelReg DAC_FuelRegion DAC_EMM
$loadm DAC_EOR_Sites=DAC_EOR DAC_EOR_Sites=DAC_Pseudo
$load EnergySource ActiveEnergySource FuelRegion FuelRegion_2_FuelReg MNUMCR MNUMCR_FuelRegion
$load M8 M13 M15 MNUMNR MNUMNR_EMM MNUMYR MNUMYR_t_emm REGION_OGSM M8_to_REGION_OGSM DAC_OGSM

parameter GDP(t)
          Life(TechType)                    Economic life
          EquityRate(t_sy,TechType)         CO2  NOMINAL Equity Interest Rate
          DAC_Cost(t_sy,TechType,ActiveEnergySource,DAC_Sites)    DAC Cost by Site
          DAC_Cost_FR(FuelRegion,t_sy)      DAC Cost by Fuel Region
          SinkCapCost(DAC_Sites,t_sy)       Fixed cost(millions of dollars) to build a SINK
          WellCapCost(DAC_Sites,t_sy)       Cost (millions of dollars) to build a well at each SINK
          InjLimit(t_sy,DAC_Sites)          Maximum Injection rate in million tonnes at each SINK
          MaxSinks(t_sy,DAC_Sites)          Max number of saline wells per site per year
          MaxFormation(t_sy,DAC_Sites)      Max injection rate per formation per year before new site is constructed
          DAC_TnS_Costs(DAC_Sites,t_sy)     Transport & Storage cost at any DAC site
          DAC_OPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites)    DAC Operating Cost
          DAC_CAPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites)   DAC Capital Cost
          SiteCapped(t_sy,TechType,ActiveEnergySource,DAC_Sites)  Check for previously capitalized DAC Site
          DAC_NPV_SAL(DAC_Sites,t_sy)   NPV with Saline Credit for Annual re-evaulation
          DAC_NPV_EOR(DAC_Sites,t_sy)   NPV with EOR Credit for Annual re-evaulation
          npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t)   DAC Cost by Site with saline credit
          npv_EOR_Cost(DAC_Sites,TechType,ActiveEnergySource,t)   DAC Cost by EOR Site with EOR credit
          Q_DAC_Max(DAC_Sites,t)        Capture Limit at any DAC site
          PV(t,TechType)                Present value in a given year
          Credit_EOR(t)                 Yearly 45Q Credit for DAC to EOR
          Credit_Saline(t)              Yearly 45Q Credit for CCS to Saline
          Credit_CDR(t)                 Yearly 45Q Credit for CDR to Saline
          Credit_DAC(TechType,ActiveEnergySource,t)               Yearly Weighted 45Q Credit for DAC to Saline
          NPV_Credit_EOR(DAC_Sites,t)             Annual re-evaluation of Yearly 45Q Credit for DAC to EOR
          NPV_Credit_Saline(DAC_Sites,t)          Annual re-evaluation of Yearly 45Q Credit for CCS to Saline
          NPV_Credit_CDR(DAC_Sites,t)             Annual re-evaluation of Yearly 45Q Credit for CDR to Saline
          NPV_Credit_DAC(DAC_Sites,TechType,ActiveEnergySource,t) Annual re-evaluation of Weighted 45Q Credit for DAC to Saline
          DAC_EOR_Credit(t_sy,TechType)           Levelized 45Q Credit for DAC to EOR
          DAC_Saline_Credit(t_sy,TechType)        Levelized 45Q Credit for CCS to Saline
          DAC_CDR_Credit(t_sy,TechType)           Levelized 45Q Credit for CDR to Saline
          DAC_SAL_Credit(TechType,ActiveEnergySource,t_sy)        Levelized Weighted 45Q Credit for DAC to Saline
          DAC_45Q_VOL(DAC_Sites,t)      Captured CO2 getting 45Q credits by year
          DAC_45Q_EOR(DAC_Sites,t)      Captured CO2 to EOR getting 45Q credits by year
          DAC_45Q_SAL(DAC_Sites,t)      Captured CO2 to Saline getting 45Q credits by year
          CCS_45Q_SAL(DAC_Sites,t)      Captured DAC CCS to Saline getting 45Q credits by year
          ATM_45Q_SAL(DAC_Sites,t)      Captured DAC ATM to Saline getting 45Q credits by year
          P_CO2(t)                      CO2 price    /#t 700/
          REG_CO2_P(REGION_EMM,MNUMYR)  Regional CO2 Price
          DAC_REG_P(DAC_Sites,t)        Regional CO2 Price by DAC site
          MaxCap(t)                     National capacity addition limit per year      /#t 10/
          TotalCap(t)                   Total capacity limit per year /#t 2500/
          TotalEmissions(t)             Total emissions in last cycle
          El_Used(DAC_Sites,t)          DAC Electricity Usage by site
          NG_Used(DAC_Sites,t)          DAC NG Usage by site
          UECPOUT_DAC_ELC(MNUMNR,MNUMYR)        DAC Electricity Usage by EMM Region (billion kWh)
          DAC_ELC_FR(FuelRegion,MNUMYR)         DAC Electricity Usage by EMM Fuel Region
          UECPOUT_DAC_NGC(FuelRegion,MNUMYR)    DAC NG Usage by Fuel Region (trillion Btu)
          UECPOUT_DAC_ELC_CS(MNUMCR,MNUMYR)     DAC Electricity Usage by Census Region (billion kWh)
          UECPOUT_DAC_NGC_CS(MNUMCR,MNUMYR)     DAC NG Usage by Census Region (trillion Btu)
          UECPOUT_Q_NG_CCS(MNUMCR,MNUMYR)       Volume of DAC site output from NG CCS
          Q_el(t_sy,TechType,ActiveEnergySource)     Electricity Consumption
          Q_ng(t_sy,TechType,ActiveEnergySource)     NG Consumption
          CaptureRate(TechType,ActiveEnergySource)   Fraction of NG related emissions captured
          NG_CCSf(TechType,ActiveEnergySource)       Maximum fraction of NG CO2 emissions captured relative to DAC by site
          NG_CCSa(TechType,ActiveEnergySource)       Actual Fraction of NG CO2 emissions captured relative to DAC by site
          Q_DACbyTech(DAC_Sites,TechType,ActiveEnergySource,t)             DAC volumes captured by site per technology and year (Cumulative Reporting)
          Q_DACsav(DAC_Sites,t)             DAC volumes captured by site per year (Cumulative Reporting)
          Q_DACint(DAC_Sites,t)             Debug
          Q_EORsav(DAC_Sites,t)             DAC to EOR by site per year (Cumulative Reporting)
          Q_SALsav(DAC_Sites,t)             DAC to Saline by site per year (Cumulative Reporting)
          Q_NGCCSsav(DAC_Sites,t)           DAC volumes captured by site from NGCCS per year (Cumulative Reporting)
          UECPOUT_DACtoEOR(M8,MNUMYR)                DAC to EOR by OGSM Region per year (Cumulative Reporting)
          UECPOUT_DACtoSAL(FuelRegion,MNUMYR)        DAC to Saline by Fuel Region per year (Cumulative Reporting)
          Q_DAC_FR(FuelRegion,MNUMYR)       DAC volumes captured by fuel region
          Q_DAC_EMM(MNUMNR,MNUMYR)          DAC volumes captured by EMM region
          dQDAC_EMM(REGION_EMM,t)           Change in DAC volumes captured by EMM region from previous year
          P_el_PREV(t_emm,DAC_Sites)        Electricity Prices from last cycle
          P_ng_PREV(t_emm,DAC_Sites)        NG Prices from last cycle
          UECPOUT_Q_DAC_CS(MNUMCR,MNUMYR)   DAC volumes captured by census region (MMT CO2)
          PREV_Q_DAC_CS(MNUMYR)             DAC volumes captured nationally (MMT CO2) from the last cycle
          DAC_Curve_P(DAC_Sites,t)          DAC Curve Price
          UECPOUT_DAC_Pmin(MNUMYR)          DAC Curve Minimum Price
          UECPOUT_DAC_Pmax(MNUMYR)          DAC Curve Maximum Price
          UECPOUT_DAC_Slope(MNUMYR)         DAC Curve Slope
          Q_DACslp(DAC_Sites,t)             DAC volumes captured by site per year for max capture
          UECPOUT_P_EOR(M8,MNUMYR)          Price of DAC to EOR by OGSM Region per year ($ per ton CO2)
          P_OGSM(DAC_EOR_Sites,REGION_OGSM,TechType,ActiveEnergySource,t)      Price of DAC to EOR for OGSM
          UECPOUT_DAC_CO2_45Q(MNUMYR)       Captured CO2 eligible for 45Q Credits (MMT CO2)
          UECPOUT_DAC_EOR_45Q(MNUMYR)       Captured CO2 to EOR eligible for 45Q Credits (MMT CO2)
          UECPOUT_DAC_SAL_45Q(MNUMYR)       Captured CO2 to SAL eligible for 45Q Credits (MMT CO2)
          UECPOUT_CCS_SAL_45Q(MNUMYR)       Captured DAC CCS to SAL eligible for 45Q Credits (MMT CO2)
          UECPOUT_ATM_SAL_45Q(MNUMYR)       Captured DAC ATM to SAL eligible for 45Q Credits (MMT CO2)
          OGSMOUT_OGCO2QEM(M8,MNUMYR)       CO2 purchased from EMM by EOR in OGSM
          OGSMOUT_OGCO2QLF(M8,MNUMYR)       CO2 purchased from LFMM by EOR in OGSM
          OGSMOUT_OGCO2TAR(M8,M8)           CO2 Transport price from OGSM ($ per mmcf)
          OGSMOUT_OGCO2PRC(M8,M13,MNUMYR)   CO2 price ($ per mmcf)
          OGSMOUT_OGCO2PLF(M8,MNUMYR)       CO2 Price from LFMM ($ per mmcf)
          OGSMOUT_OGCO2PEM(M8,MNUMYR)       CO2 Price from EMM ($ per mmcf)
          OGSMOUT_OGCO2AVL(M8,M13,MNUMYR)   CO2 available (mmcf) by Price Bin
          OGSMOUT_OGCO2PUR2(M8,M13,MNUMYR)  CO2 Purchased at the EOR sites (mmcf)
          EMISSION_EMETAX(M15,MNUMYR)       CO2 Tax
          EMISSION_EMLIM(M4,MNUMYR)         CO2 Cap from previous cycle
          EMISSION_EMSOL(M4,MNUMYR)         CO2 Net emissions from previous cycle
          TCS45Q_I_45Q_LYR_NEW              End year of tax code section 45Q subsidy for new builds
          TCS45Q_I_45Q_DURATION             Tax code section 45Q subsidy duration
          TCS45Q_CCS_SALINE_45Q(MNUMYR)     45Q tax credit for saline injection
          TCS45Q_CCS_EOR_45Q(MNUMYR)        45Q tax credit for enhanced oil recovery
          TCS45Q_CCS_DAC_45Q(MNUMYR)        45Q tax credit for CDR (DAC)
          npv_EMM_Cost(M8,t)                EMM costs by OGSM region
          npv_LFMM_Cost(M8,t)               LFMM costs by OGSM region
          npv_CO2_Cost(M8,M13,t)            Natural CO2 costs by OGSM region
          largenum                          Used for unused technology costs /1e6/
          ;

$gdxin DAC\DACPrep.gdx
$load GDP Life EquityRate DAC_Cost SinkCapCost WellCapCost DAC_TnS_Costs InjLimit MaxSinks MaxFormation
$load Q_DAC_Max Credit_EOR Credit_Saline Credit_CDR DAC_Saline_Credit DAC_EOR_Credit DAC_CDR_Credit Q_el Q_ng DAC_Cost_FR REG_CO2_P
$load DAC_OPEX DAC_CAPEX P_el_PREV P_ng_PREV NG_CCSf CaptureRate

$gdxin NEMS_TO_DAC.gdx
$load OGSMOUT_OGCO2TAR OGSMOUT_OGCO2PRC OGSMOUT_OGCO2PLF OGSMOUT_OGCO2PEM
$load OGSMOUT_OGCO2QEM OGSMOUT_OGCO2QLF OGSMOUT_OGCO2AVL OGSMOUT_OGCO2PUR2
$load EMISSION_EMETAX EMISSION_EMLIM EMISSION_EMSOL
$load TCS45Q_I_45Q_LYR_NEW TCS45Q_I_45Q_DURATION TCS45Q_CCS_SALINE_45Q TCS45Q_CCS_EOR_45Q TCS45Q_CCS_DAC_45Q
$gdxin

*TCS45Q_CCS_DAC_45Q(MNUMYR) = TCS45Q_CCS_SALINE_45Q(MNUMYR);

***** Pricing Calculations *****

* Use this to activate CO2 tax in a particular year
*P_CO2(t)$(t.val<2026) = 0;

* Use this to ramp the CO2 cost by a fixed value per year
*P_CO2(t) = P_CO2(t) + (ord(t)-7)*5;

* Use this to deactivate CO2 tax in a particular year
*P_CO2(t)$(t.val>2032) = 0;

* National Limit ramps
loop(t$(t.val>2022), MaxCap(t) = MaxCap(t-1)*1.5;
);

DAC_REG_P(DAC_Sites,t) = 0;
$Ifi not %InNEMS% == 1 $goto next1
P_CO2(t) = sum(MNUMYR$MNUMYR_t_emm(MNUMYR,t), EMISSION_EMETAX('01_M15',MNUMYR)*12/44*GDP(t)*1000);
DAC_REG_P(DAC_Sites,t) = sum((REGION_EMM,MNUMYR)$(MNUMYR_t_emm(MNUMYR,t) and DAC_EMM(DAC_Sites,REGION_EMM)),
                         REG_CO2_P(REGION_EMM,MNUMYR));
$label next1

alias(M8,M8_2);

***** Start Optimization Routine *****

Variables        NPV                  Objective Function
                 Q_DAC(DAC_Sites,TechType,ActiveEnergySource,t)           million tonnes of CO2 DAC captured at each site in time t
                 NewSinks(DAC_Sites,TechType,ActiveEnergySource,t_sy)     Fractional quantity of new sinks at each site in time t
                 Q_EOR(DAC_Sites,TechType,ActiveEnergySource,t)           million tonnes of CO2 DAC to EOR at each site in time t
                 Q_EMM(M8,t)           million tonnes of CO2 EMM to EOR in each OGSM region in time t
                 Q_LFMM(M8,t)          million tonnes of CO2 LFMM to EOR in each OGSM region in time t
                 Q_CO2(M8,M13,t)       million tonnes of Natural CO2 to EOR in each OGSM region in time t
                 Q_TRA(M8,M8,t)        million tonnes of Natural CO2 transported between OGSM regions in time t
                 EORCostDAC(t)         Cost of DAC CO2 to EOR
                 EORCostEMM(t)         Cost of EMM CO2 to EOR
                 EORCostLFMM(t)        Cost of LFMM CO2 to EOR
                 EORCostCO2(t)         Cost of Natural CO2 to EOR
                 EORCostTRA(t)         Cost of transporting Natural CO2 between OGSM regions
                 ;

Positive Variable Q_DAC, Q_EOR, Q_EMM, Q_LFMM, Q_CO2, Q_TRA
                  ;

$gdxin DAC\DACModel.gdx
$load Q_DACsav Q_EORsav Q_SALsav El_Used NG_Used DAC_45Q_VOL DAC_45Q_EOR Q_NGCCSsav
$loadm DAC_Selection DAC_Unselect PREV_Q_DAC_CS TotalEmissions Q_DAC_EMM

$if not exist DAC\LastCycle.gdx $goto CycleOne
$gdxin DAC\LastCycle.gdx
$load PREV_Q_DAC_CS TotalEmissions
$label CycleOne

* Deactivate future site activations (can only go forward in time)
loop(t_sy,
DAC_Selection(DAC_Sites,t)$(t.val ge t_sy.val)=no;
DAC_Unselect(DAC_Sites,t)$(t.val ge t_sy.val)=no;
);

* Remove capture volumes for deactivated sites
Q_DACsav(DAC_Sites,t)$(not DAC_Selection(DAC_Sites,t)) = 0;
Q_EORsav(DAC_Sites,t)$(not DAC_Selection(DAC_Sites,t)) = 0;
Q_SALsav(DAC_Sites,t)$(not DAC_Selection(DAC_Sites,t)) = 0;
El_Used(DAC_Sites,t)$(not DAC_Selection(DAC_Sites,t)) = 0;
NG_Used(DAC_Sites,t)$(not DAC_Selection(DAC_Sites,t)) = 0;
Q_NGCCSsav(DAC_Sites,t)$(not DAC_Selection(DAC_Sites,t)) = 0;
DAC_45Q_VOL(DAC_Sites,t)$(not DAC_Selection(DAC_Sites,t)) = 0;
DAC_45Q_EOR(DAC_Sites,t)$(not DAC_Selection(DAC_Sites,t)) = 0;

parameter countl(DAC_Sites);
countl(DAC_Sites) = 0;
* Restore capture volumes for previously activated sites
loop(t,
Q_DACsav(DAC_Sites,t)$(Q_DACsav(DAC_Sites,t) eq 0 and not DAC_Unselect(DAC_Sites,t)) = Q_DACsav(DAC_Sites,t) + Q_DACsav(DAC_Sites,t-1);
Q_EORsav(DAC_Sites,t)$(Q_EORsav(DAC_Sites,t) eq 0 and not DAC_Unselect(DAC_Sites,t)) = min(Q_DAC_Max(DAC_Sites,t),Q_EORsav(DAC_Sites,t) + Q_EORsav(DAC_Sites,t-1));
Q_SALsav(DAC_Sites,t)$(Q_SALsav(DAC_Sites,t) eq 0 and not DAC_Unselect(DAC_Sites,t)) = Q_SALsav(DAC_Sites,t) + Q_SALsav(DAC_Sites,t-1);
El_Used(DAC_Sites,t)$(El_Used(DAC_Sites,t) eq 0 and not DAC_Unselect(DAC_Sites,t)) = El_Used(DAC_Sites,t) + El_Used(DAC_Sites,t-1);
NG_Used(DAC_Sites,t)$(NG_Used(DAC_Sites,t) eq 0 and not DAC_Unselect(DAC_Sites,t)) = NG_Used(DAC_Sites,t) + NG_Used(DAC_Sites,t-1);
Q_NGCCSsav(DAC_Sites,t)$(Q_NGCCSsav(DAC_Sites,t) eq 0 and not DAC_Unselect(DAC_Sites,t)) = Q_NGCCSsav(DAC_Sites,t) + Q_NGCCSsav(DAC_Sites,t-1);
DAC_45Q_VOL(DAC_Sites,t)$(DAC_45Q_VOL(DAC_Sites,t) eq 0 and countl(DAC_Sites) le TCS45Q_I_45Q_DURATION-1) = DAC_45Q_VOL(DAC_Sites,t) + DAC_45Q_VOL(DAC_Sites,t-1);
DAC_45Q_EOR(DAC_Sites,t)$(DAC_45Q_VOL(DAC_Sites,t) eq 0 and countl(DAC_Sites) le TCS45Q_I_45Q_DURATION-1) = DAC_45Q_EOR(DAC_Sites,t) + DAC_45Q_EOR(DAC_Sites,t-1);
countl(DAC_Sites)$(DAC_45Q_VOL(DAC_Sites,t) > 0) = countl(DAC_Sites) + 1;
);

*NG_CCSf(TechType,ActiveEnergySource) = sum(t_sy,Q_ng(t_sy,TechType,ActiveEnergySource)) * 14.47/1000 * 44/12;
NG_CCSa(TechType,ActiveEnergySource) = NG_CCSf(TechType,ActiveEnergySource) * CaptureRate(TechType,ActiveEnergySource);

* Remove capture volumes for sites with negative operating NPV going forward
NPV_Credit_EOR(DAC_Sites,t)$(DAC_45Q_VOL(DAC_Sites,t) gt 0) = sum((MNUMYR,t_sy)$(MNUMYR_t_emm(MNUMYR,t)), TCS45Q_CCS_EOR_45Q(MNUMYR)) * GDP(t);
NPV_Credit_Saline(DAC_Sites,t)$(DAC_45Q_VOL(DAC_Sites,t) gt 0) = sum((MNUMYR,t_sy)$(MNUMYR_t_emm(MNUMYR,t)), TCS45Q_CCS_SALINE_45Q(MNUMYR)) * GDP(t);
NPV_Credit_CDR(DAC_Sites,t)$(DAC_45Q_VOL(DAC_Sites,t) gt 0) = sum((MNUMYR,t_sy)$(MNUMYR_t_emm(MNUMYR,t)), TCS45Q_CCS_DAC_45Q(MNUMYR)) * GDP(t);
NPV_Credit_DAC(DAC_Sites,TechType,ActiveEnergySource,t) = (NPV_Credit_Saline(DAC_Sites,t) * NG_CCSa(TechType,ActiveEnergySource) + NPV_Credit_CDR(DAC_Sites,t))
               / (1 + NG_CCSa(TechType,ActiveEnergySource));
*DAC_NPV_SAL(DAC_Sites,t_sy) = P_CO2(t_sy) - (sum((TechType,ActiveEnergySource), DAC_OPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites))
*                                + DAC_TnS_Costs(DAC_Sites,t_sy) - NPV_Credit_Saline(DAC_Sites,t_sy));
DAC_NPV_SAL(DAC_Sites,t_sy) = P_CO2(t_sy) - (smin((TechType,ActiveEnergySource), DAC_OPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites)
                                - NPV_Credit_DAC(DAC_Sites,TechType,ActiveEnergySource,t_sy)) + DAC_TnS_Costs(DAC_Sites,t_sy));
DAC_NPV_EOR(DAC_Sites,t_sy) = P_CO2(t_sy) - (smin((TechType,ActiveEnergySource), DAC_OPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites))
                                + DAC_TnS_Costs(DAC_Sites,t_sy) - NPV_Credit_EOR(DAC_Sites,t_sy));

$Ifi not %CheckOM% == 1 $goto next2
loop(t_sy,
Q_EORsav(DAC_Sites,t)$(t.val ge t_sy.val and DAC_NPV_EOR(DAC_Sites,t_sy) < 0 and DAC_45Q_VOL(DAC_Sites,t) eq 0) = 0;
Q_SALsav(DAC_Sites,t)$(t.val ge t_sy.val and DAC_NPV_SAL(DAC_Sites,t_sy) < 0 and DAC_45Q_VOL(DAC_Sites,t) eq 0) = 0;
DAC_Unselect(DAC_Sites,t)$(t.val ge t_sy.val and DAC_NPV_SAL(DAC_Sites,t_sy) < 0 and DAC_45Q_VOL(DAC_Sites,t) eq 0) = yes;
);
Q_DACsav(DAC_Sites,t) = Q_EORsav(DAC_Sites,t) + Q_SALsav(DAC_Sites,t);
El_Used(DAC_Sites,t)$(Q_DACsav(DAC_Sites,t) eq 0) = 0;
NG_Used(DAC_Sites,t)$(Q_DACsav(DAC_Sites,t) eq 0) = 0;
Q_NGCCSsav(DAC_Sites,t)$(Q_DACsav(DAC_Sites,t) eq 0) = 0;
Q_DACint(DAC_Sites,t) = Q_DACsav(DAC_Sites,t);
$label next2

* Total Cap based on estimated emissions from other sectors
TotalCap(t) = max(0, TotalEmissions(t) - sum(MNUMYR$MNUMYR_t_emm(MNUMYR,t), EMISSION_EMLIM('1_M4',MNUMYR)*44/12));
MaxCap(t) = max(0,min(MaxCap(t),(TotalCap(t) - sum(DAC_Sites, Q_DACsav(DAC_Sites,t-1)))*1.0));

dQDAC_EMM(REGION_EMM,t_sy) = sum((MNUMNR,MNUMYR)$(MNUMYR_t_emm(MNUMYR,t_sy) and MNUMNR_EMM(MNUMNR,REGION_EMM)),
                             max(0, Q_DAC_EMM(MNUMNR,MNUMYR-1)*1.1));
dQDAC_EMM(REGION_EMM,t_sy)$(dQDAC_EMM(REGION_EMM,t_sy) eq 0) = min(100,MaxCap(t_sy));

PV(t,TechType) = sum(t_sy$(t.val ge t_sy.val),1/POWER(1 + EquityRate(t_sy,TechType),t.val-t_sy.val));

* Present value of all costs
Credit_DAC(TechType,ActiveEnergySource,t) = (Credit_Saline(t) * NG_CCSa(TechType,ActiveEnergySource) + Credit_CDR(t)) / (1+NG_CCSa(TechType,ActiveEnergySource));
DAC_SAL_Credit(TechType,ActiveEnergySource,t_sy) = (DAC_Saline_Credit(t_sy,TechType) * NG_CCSa(TechType,ActiveEnergySource) + DAC_CDR_Credit(t_sy,TechType))
               / (1+NG_CCSa(TechType,ActiveEnergySource));
*npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t)
*             = sum(t_sy, (DAC_Cost(t_sy,TechType,ActiveEnergySource,DAC_Sites) + DAC_TnS_Costs(DAC_Sites,t_sy)
*               - DAC_Saline_Credit(t_sy))/GDP(t_sy))*GDP(t)*PV(t);
npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t)
             = sum(t_sy, (DAC_Cost(t_sy,TechType,ActiveEnergySource,DAC_Sites) + DAC_TnS_Costs(DAC_Sites,t_sy)
               - DAC_SAL_Credit(TechType,ActiveEnergySource,t_sy))/GDP(t_sy))*GDP(t)*PV(t,TechType);
npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t)$(sum(t_sy,DAC_Cost(t_sy,TechType,ActiveEnergySource,DAC_Sites)) eq 0) = largenum;
npv_EOR_Cost(DAC_EOR_Sites,TechType,ActiveEnergySource,t)
             = sum(t_sy, (DAC_Cost(t_sy,TechType,ActiveEnergySource,DAC_EOR_Sites) + DAC_TnS_Costs(DAC_EOR_Sites,t_sy)
               - DAC_EOR_Credit(t_sy,TechType))/GDP(t_sy))*GDP(t)*PV(t,TechType);
npv_EOR_Cost(DAC_EOR_Sites,TechType,ActiveEnergySource,t)$(sum(t_sy,DAC_Cost(t_sy,TechType,ActiveEnergySource,DAC_EOR_Sites)) eq 0) = largenum;
npv_EMM_Cost(M8,t) = sum(MNUMYR$MNUMYR_t_emm(MNUMYR,t), OGSMOUT_OGCO2PEM(M8,MNUMYR))*GDP(t)*smin(TechType,PV(t,TechType));
npv_LFMM_Cost(M8,t) = sum(MNUMYR$MNUMYR_t_emm(MNUMYR,t), OGSMOUT_OGCO2PLF(M8,MNUMYR))*GDP(t)*smin(TechType,PV(t,TechType));
npv_CO2_Cost(M8,M13,t) = sum(MNUMYR$MNUMYR_t_emm(MNUMYR,t), OGSMOUT_OGCO2PRC(M8,M13,MNUMYR))*GDP(t)*smin(TechType,PV(t,TechType));

* Start DAC Hubs and subsidy calculations (IIJA)
set       Subs_Start(t)  Start year for DAC Hub subsidies /2022/
          Subs_End(t)    End year for DAC Hub subsidies /2026/
          DAC_Hubs(DAC_Sites)         DAC Sites with lowest cost
          DAC_Hubs_Used(DAC_Sites,t)  DAC hubs used
          ;

parameter DAC_BaseCap(t_emm,TechType,EnergySource) DAC capital costs per tonne
          DAC_Hubs_EMM(DAC_Sites,REGION_EMM,t)     Map DAC hubs to EMM regions
          npv_EMM_ord(REGION_EMM)           Site order by NPV based on EMM regions
          Site_Order(DAC_Sites)             Site order by NPV
          Region_Order(REGION_EMM)          EMM region order based on cheapest site
          Subs_Rem(t)                       Remaining Subsidy by year
          Hubs_Rem(t)                       Remaining Hubs by year
          Subs_Used(DAC_Sites,t)            Subsidy used by each hub
          Max_Subs_Used(DAC_Sites,t)        Maximum subsidy available to each hub
          ;

loop((t,Subs_Start)$(t.val lt Subs_Start.val),
         Subs_Rem(t) = 0;
         Hubs_Rem(t) = 0;
         );

$gdxin DAC\DACModel.gdx
$loadm Subs_Rem Hubs_Rem DAC_Hubs_Used

$gdxin DAC\DACPrep.gdx
$load DAC_BaseCap

loop(t_sy,
DAC_Hubs_Used(DAC_Sites,t)$(t.val ge t_sy.val)=no;
);
loop((t_sy,Subs_Start)$(t_sy.val eq Subs_Start.val),
   Subs_Rem(t)$(t.val ge Subs_Start.val) = 3500;
   Hubs_Rem(t)$(t.val ge Subs_Start.val) = 4;
   );
alias (DAC_Sites,j);
Site_Order(DAC_Sites) = sum((j,TechType,ActiveEnergySource,t_sy)$(npv_DAC_Cost(j,TechType,ActiveEnergySource,t_sy)
                lt npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t_sy)), 1);
Site_Order(DAC_EOR) = largenum;
loop(t, Site_Order(DAC_Sites)$DAC_Hubs_Used(DAC_Sites,t) = largenum);
npv_EMM_ord(REGION_EMM) = smin((DAC_Sites)$DAC_EMM(DAC_Sites,REGION_EMM), Site_Order(DAC_Sites));
alias (REGION_EMM,k);
Region_Order(REGION_EMM) = sum(k$(npv_EMM_ord(k) le npv_EMM_ord(REGION_EMM)), 1);
loop(REGION_EMM, DAC_Hubs_EMM(DAC_Sites,REGION_EMM,t_sy)$(DAC_EMM(DAC_Sites,REGION_EMM) and Site_Order(DAC_Sites) eq npv_EMM_ord(REGION_EMM)) = yes;);
DAC_Hubs_EMM(DAC_Sites,REGION_EMM,t_sy)$(Region_Order(REGION_EMM) gt Hubs_Rem(t_sy)) = no;
loop((REGION_EMM,t_sy), DAC_Hubs(DAC_Sites)$DAC_Hubs_EMM(DAC_Sites,REGION_EMM,t_sy) = yes);
*Subs_Used.up(DAC_Hubs,t_sy) = min(sum(Subs_End$(t_sy.val le Subs_End.val), Subs_Rem(t_sy)), sum((TechType,ActiveEnergySource,Subs_End)$(t_sy.val le Subs_End.val),
*          DAC_BaseCap(t_sy,TechType,ActiveEnergySource)*0.5));
Max_Subs_Used(DAC_Hubs,t_sy) = min(Subs_Rem(t_sy), sum((TechType,ActiveEnergySource), DAC_BaseCap(t_sy,TechType,ActiveEnergySource)*0.5));
npv_DAC_Cost(DAC_Hubs,TechType,ActiveEnergySource,t) = npv_DAC_Cost(DAC_Hubs,TechType,ActiveEnergySource,t)
             - sum(t_sy, DAC_CAPEX(t_sy,TechType,ActiveEnergySource,DAC_Hubs)*1.05*0.5/GDP(t_sy))*GDP(t)*PV(t,TechType);
* End DAC Hubs and subsidy calculations (IIJA)

* Set upper limits on DAC volumes and sinks per formation
Q_DAC.up(DAC_Sites,TechType,ActiveEnergySource,t) = max(0,sum(t_sy, Q_DAC_Max(DAC_Sites,t_sy) - Q_DACsav(DAC_Sites,t_sy)));
Q_DAC.up(DAC_Sites,TechType,ActiveEnergySource,t)$(npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t) ge largenum) = 0;
Q_EOR.up(DAC_Sites,TechType,ActiveEnergySource,t) = max(0,sum(t_sy, Q_DAC_Max(DAC_Sites,t_sy) - Q_EORsav(DAC_Sites,t_sy)));
Q_EOR.up(DAC_Saline,TechType,ActiveEnergySource,t) = 0;
Q_EOR.up(DAC_Sites,TechType,ActiveEnergySource,t)$(npv_EOR_Cost(DAC_Sites,TechType,ActiveEnergySource,t) ge largenum) = 0;
NewSinks.up(DAC_Sites,TechType,ActiveEnergySource,t_sy) = MaxSinks(t_sy,DAC_Sites);

* Set upper limits on CO2 to EOR based on demand
Q_EMM.up(M8,t) = max(0,sum(MNUMYR$(MNUMYR_t_emm(MNUMYR,t) and ord(M8)<8), OGSMOUT_OGCO2QEM(M8,MNUMYR)));
Q_LFMM.up(M8,t) = max(0,sum(MNUMYR$(MNUMYR_t_emm(MNUMYR,t) and ord(M8)<8), OGSMOUT_OGCO2QLF(M8,MNUMYR)));
Q_CO2.up(M8,M13,t) = max(0,sum(MNUMYR$(MNUMYR_t_emm(MNUMYR,t) and ord(M8)<8), OGSMOUT_OGCO2AVL(M8,M13,MNUMYR)));

Equations         NPV_Sum                     This is the objective function
                  MaxCapture(t)               Total capture is limited by national capacity addition limit
                  Max3000(t)                  Total capture is limited to 3000 to calculate the DAC curve
*                  MaxCapReg(REGION_EMM,t)     Total capture is limited by regional capacity addition limit
                  MaxStorage(DAC_EOR,TechType,EnergySource,t)       DAC at EOR sites must equal volume competitively satisfying the EOR demand at the site
                  MaxNewSinks(DAC_Saline,TechType,EnergySource,t)   Multiples of saline capital costs are required based on the capture volumes
                  MaxEOR(DAC_EOR_Sites,TechType,EnergySource,t)     DAC at EOR and generic sites going to EOR is limited by the total volume captured
                  EOR_Demand(M8,t)            EOR demand must be satisfy by all sources and by transfer of natural CO2 between OGSM regions
                  CO2_Transport(M8,t)         Natural CO2 transported from one OGSM region to all others must equal the CO2 produced in that region
                  SumTechEnergy(DAC_Sites,t)  Capture volumes over all technologies and energy sources is constrained by the capture limit
                  EOR_DAC(t)                  Calculate total cost of DAC CO2 to EOR
                  EOR_EMM(t)                  Calculate total cost of EMM CO2 to EOR
                  EOR_LFMM(t)                 Calculate total cost of LFMM CO2 to EOR
                  EOR_CO2(t)                  Calculate total cost of Natural CO2 to EOR
                  EOR_TRA(t)                  Calculate total cost of transporting Natural CO2 between OGSM regions
;

* This is the objective function
NPV_Sum..         NPV =E= sum((DAC_Sites,TechType,ActiveEnergySource,t,t_sy)$(t.val ge t_sy.val and t.val le t_sy.val + Life(TechType)),
                          Q_DAC(DAC_Sites,TechType,ActiveEnergySource,t) * ((P_CO2(t_sy)/GDP(t_sy)*GDP(t)*PV(t,TechType)
                          + DAC_REG_P(DAC_Sites,t_sy)/GDP(t_sy)*GDP(t)*PV(t,TechType)) - npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t))
                          - Q_EOR(DAC_Sites,TechType,ActiveEnergySource,t) * (Credit_DAC(TechType,ActiveEnergySource,t) - Credit_EOR(t))
*                          - Q_EOR(DAC_Sites,TechType,ActiveEnergySource,t) * (Credit_Saline(t) - Credit_EOR(t)))
                          - NewSinks(DAC_Sites,TechType,ActiveEnergySource,t_sy)*SinkCapCost(DAC_Sites,t_sy)/GDP(t_sy)*GDP(t)*PV(t,TechType))
                          - sum(t, EORCostDAC(t) + EORCostEMM(t) + EORCostLFMM(t) + EORCostCO2(t) + EORCostTRA(t))
                          ;

* Total capture is limited by national capacity addition limit
MaxCapture(t)..          sum((DAC_Sites,TechType,ActiveEnergySource), Q_DAC(DAC_Sites,TechType,ActiveEnergySource,t)) =L= sum(t_sy,MaxCap(t_sy));

* Total capture is limited by national capacity addition limit
Max3000(t)..          sum((DAC_Sites,TechType,ActiveEnergySource), Q_DAC(DAC_Sites,TechType,ActiveEnergySource,t)) =L= 3000;

* Total capture is limited by regional capacity addition limit
*MaxCapReg(REGION_EMM,t)..          sum((DAC_Sites,TechType,ActiveEnergySource)$DAC_EMM(DAC_Sites,REGION_EMM),
*                                   Q_DAC(DAC_Sites,TechType,ActiveEnergySource,t)) =L= sum(t_sy, dQDAC_EMM(REGION_EMM,t_sy));

* DAC at EOR sites must equal volume competitively satisfying the EOR demand at the site (not applied to generic sites)
MaxStorage(DAC_EOR,TechType,ActiveEnergySource,t)..          Q_DAC(DAC_EOR,TechType,ActiveEnergySource,t) =E= Q_EOR(DAC_EOR,TechType,ActiveEnergySource,t);

* Multiples of saline capital costs are required based on the capture volumes
MaxNewSinks(DAC_Saline,TechType,ActiveEnergySource,t)..    Q_DAC(DAC_Saline,TechType,ActiveEnergySource,t)
                               =L= sum(t_sy, NewSinks(DAC_Saline,TechType,ActiveEnergySource,t_sy)*MaxFormation(t_sy,DAC_Saline));

* DAC at EOR and generic sites going to EOR is limited by the total volume captured
MaxEOR(DAC_EOR_Sites,TechType,ActiveEnergySource,t)..     Q_DAC(DAC_EOR_Sites,TechType,ActiveEnergySource,t) =G= Q_EOR(DAC_EOR_Sites,TechType,ActiveEnergySource,t);

* EOR demand must be satisfy by all sources and by transfer of natural CO2 between OGSM regions
EOR_Demand(M8,t)..   sum((REGION_OGSM,DAC_EOR_Sites,TechType,ActiveEnergySource)$(M8_to_REGION_OGSM(M8,REGION_OGSM) and DAC_OGSM(DAC_EOR_Sites,REGION_OGSM)),
                     Q_EOR(DAC_EOR_Sites,TechType,ActiveEnergySource,t)) + (Q_EMM(M8,t) + Q_LFMM(M8,t) + sum(M13,Q_CO2(M8,M13,t)) + sum(M8_2$(ord(M8_2)<8),Q_TRA(M8_2,M8,t)))/18000
                             =E= sum((M13,MNUMYR,t_sy)$(MNUMYR_t_emm(MNUMYR,t) and t.val>=t_sy.val and ord(M8)<8), OGSMOUT_OGCO2PUR2(M8,M13,MNUMYR)/18000);

* Natural CO2 transported from one OGSM region to all others must equal the CO2 produced in that region
CO2_Transport(M8,t)..  sum(M13,Q_CO2(M8,M13,t)) =E= sum(M8_2$(ord(M8_2)<8), Q_TRA(M8,M8_2,t));

* Capture volumes over all technologies and energy sources is constrained by the capture limit
SumTechEnergy(DAC_Sites,t)..  sum((TechType,ActiveEnergySource), Q_DAC(DAC_Sites,TechType,ActiveEnergySource,t))
                                  =L= sum(t_sy, Q_DAC_Max(DAC_Sites,t_sy));

* Calculate total cost of DAC CO2 to EOR
EOR_DAC(t)..      EORCostDAC(t) =E= sum((DAC_EOR_Sites,TechType,ActiveEnergySource),
                             Q_EOR(DAC_EOR_Sites,TechType,ActiveEnergySource,t) * npv_EOR_Cost(DAC_EOR_Sites,TechType,ActiveEnergySource,t));

* Calculate total cost of EMM CO2 to EOR
EOR_EMM(t)..      EORCostEMM(t) =E= sum(M8$(ord(M8)<8), Q_EMM(M8,t) * npv_EMM_Cost(M8,t))/1e6;

* Calculate total cost of LFMM CO2 to EOR
EOR_LFMM(t)..     EORCostLFMM(t) =E= sum(M8$(ord(M8)<8), Q_LFMM(M8,t) * npv_LFMM_Cost(M8,t))/1e6;

* Calculate total cost of Natural CO2 to EOR
EOR_CO2(t)..      EORCostCO2(t) =E= sum((M8,M13)$(ord(M8)<8), Q_CO2(M8,M13,t) * npv_CO2_Cost(M8,M13,t))/1e6;

* Calculate total cost of transporting Natural CO2 between OGSM regions
EOR_TRA(t)..      EORCostTRA(t) =E= sum((M8,M8_2)$(ord(M8)<8), Q_TRA(M8,M8_2,t) * (OGSMOUT_OGCO2TAR(M8,M8_2)))/1e6;

* Model definition
Model DAC /all/;

* Start Model to generate DAC build slope for EPM
Model DACSlope /DAC - MaxCapture/;

option limrow = 0;
option limcol = 0;
option sysout = on;
dacslope.solprint=0;

npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t_sy)
             = npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t_sy)*(0.95**((t_sy.val-2020)/30));

Solve DACSlope maximizing NPV using lp;

npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t_sy)
             = npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t_sy)/(0.95**((t_sy.val-2020)/30));

Q_DACslp(DAC_Sites,t) = sum((TechType,ActiveEnergySource), Q_DAC.l(DAC_Sites,TechType,ActiveEnergySource,t));
DAC_Curve_P(DAC_Sites,t_sy)$(Q_DACslp(DAC_Sites,t_sy)>0)
            = smin((TechType,ActiveEnergySource), npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t_sy)
*            + NG_CCSa(TechType,ActiveEnergySource) /(1+NG_CCSa(TechType,ActiveEnergySource))*P_CO2(t_sy)*PV(t_sy)
              + NewSinks.l(DAC_Sites,TechType,ActiveEnergySource,t_sy) * SinkCapCost(DAC_Sites,t_sy) * PV(t_sy,TechType)
              / Q_DACslp(DAC_Sites,t_sy)) / GDP(t_sy) / 1000*44/12;
UECPOUT_DAC_Pmin(MNUMYR) = sum(t_sy$MNUMYR_t_emm(MNUMYR,t_sy), smin(DAC_Sites$(DAC_Curve_P(DAC_Sites,t_sy)>0), DAC_Curve_P(DAC_Sites,t_sy)));
UECPOUT_DAC_Pmin(MNUMYR) = max(0,UECPOUT_DAC_Pmin(MNUMYR));
UECPOUT_DAC_Pmax(MNUMYR) = sum(t_sy$MNUMYR_t_emm(MNUMYR,t_sy), smax(DAC_Sites$(DAC_Curve_P(DAC_Sites,t_sy)>0), DAC_Curve_P(DAC_Sites,t_sy)));
UECPOUT_DAC_Pmax(MNUMYR) = min(UECPOUT_DAC_Pmax(MNUMYR),EMISSION_EMETAX('03_M15',MNUMYR));
if(sum(t_sy, smax(DAC_Sites$(DAC_Curve_P(DAC_Sites,t_sy)>0), DAC_Curve_P(DAC_Sites,t_sy))
                            - smin(DAC_Sites$(DAC_Curve_P(DAC_Sites,t_sy)>0), DAC_Curve_P(DAC_Sites,t_sy))) > 0,
   UECPOUT_DAC_Slope(MNUMYR)
   = sum(t_sy$MNUMYR_t_emm(MNUMYR,t_sy), sum(DAC_Sites, Q_DACslp(DAC_Sites,t_sy)) /
                            (smax(DAC_Sites$(DAC_Curve_P(DAC_Sites,t_sy)>0), DAC_Curve_P(DAC_Sites,t_sy))
                            - smin(DAC_Sites$(DAC_Curve_P(DAC_Sites,t_sy)>0), DAC_Curve_P(DAC_Sites,t_sy))));
);

option limrow = 0;
option limcol = 0;
option sysout = on;
dac.solprint=0;

* Reset DAC builds
Q_DAC.l(DAC_Sites,TechType,ActiveEnergySource,t) = 0;
Q_DAC.up(DAC_Hubs,TechType,ActiveEnergySource,t) = min(1, Q_DAC.up(DAC_Hubs,TechType,ActiveEnergySource,t));

*loop(t,
*SiteCapped(t_sy,TechType,ActiveEnergySource,DAC_Sites)$DAC_Selection(DAC_Sites,t) = 1;
*);
*npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t) = npv_DAC_Cost(DAC_Sites,TechType,ActiveEnergySource,t) -
*             sum(t_sy$(t.val ge t_sy.val), DAC_CAPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites)
*                 * SiteCapped(t_sy,TechType,ActiveEnergySource,DAC_Sites) / GDP(t_sy)) * GDP(t) * PV(t);
*npv_EOR_Cost(DAC_EOR_Sites,TechType,ActiveEnergySource,t) = npv_EOR_Cost(DAC_EOR_Sites,TechType,ActiveEnergySource,t) -
*             sum(t_sy$(t.val ge t_sy.val), DAC_CAPEX(t_sy,TechType,ActiveEnergySource,DAC_EOR_Sites)
*                 * SiteCapped(t_sy,TechType,ActiveEnergySource,DAC_EOR_Sites) / GDP(t_sy)) * GDP(t) * PV(t);

Solve DAC maximizing NPV using lp;

***** Post Optimization Reporting *****

* Market sharing
parameter QDAC_marg(DAC_Sites,TechType,ActiveEnergySource,t_sy) Marginal cost at each site
          QDAC_mars(t_sy)     Cumulative marginal cost for market sharing
          TotalDAC(t_sy)      Total DAC builds in the current year
;

loop(t_sy,
TotalDAC(t_sy) = sum((DAC_Sites,TechType,ActiveEnergySource)$(not DAC_Hubs(DAC_Sites)),Q_DAC.l(DAC_Sites,TechType,ActiveEnergySource,t_sy));
QDAC_marg(DAC_Saline,TechType,ActiveEnergySource,t_sy)$(Q_DAC.m(DAC_Saline,TechType,ActiveEnergySource,t_sy) ge -6 and not DAC_Hubs(DAC_Saline) and
          Q_DAC.up(DAC_Saline,TechType,ActiveEnergySource,t_sy) gt 0) = 6 + Q_DAC.m(DAC_Saline,TechType,ActiveEnergySource,t_sy);
QDAC_mars(t_sy) = sum((DAC_Sites,TechType,ActiveEnergySource), QDAC_marg(DAC_Sites,TechType,ActiveEnergySource,t_sy));
Q_DAC.l(DAC_Sites,TechType,ActiveEnergySource,t)$(t.val ge t_sy.val and t.val le t_sy.val + Life(TechType) and QDAC_mars(t_sy) ne 0 and not DAC_Hubs(DAC_Sites))
      = min(Q_DAC.up(DAC_Sites,TechType,ActiveEnergySource,t_sy), QDAC_marg(DAC_Sites,TechType,ActiveEnergySource,t_sy) * TotalDAC(t_sy) / QDAC_mars(t_sy));
);

* Fuel consumption reporting
El_Used(DAC_Sites,t) = sum((TechType,ActiveEnergySource), Q_DAC.l(DAC_Sites,TechType,ActiveEnergySource,t) / (1 + NG_CCSa(TechType,ActiveEnergySource))
                       * sum(t_sy,Q_el(t_sy,TechType,ActiveEnergySource))) + El_Used(DAC_Sites,t);
NG_Used(DAC_Sites,t) = sum((TechType,ActiveEnergySource), Q_DAC.l(DAC_Sites,TechType,ActiveEnergySource,t) / (1 + NG_CCSa(TechType,ActiveEnergySource))
                       * sum(t_sy,Q_ng(t_sy,TechType,ActiveEnergySource))) + NG_Used(DAC_Sites,t);
UECPOUT_DAC_ELC(MNUMNR,MNUMYR) = sum((DAC_Sites,REGION_EMM,t)$(MNUMYR_t_emm(MNUMYR,t) and DAC_EMM(DAC_Sites,REGION_EMM)
                         and MNUMNR_EMM(MNUMNR,REGION_EMM)), El_Used(DAC_Sites,t));
DAC_ELC_FR(FuelRegion,MNUMYR) = sum((DAC_Sites,FuelReg,t)$(MNUMYR_t_emm(MNUMYR,t) and DAC_FuelRegion(DAC_Sites,FuelReg)
                         and FuelRegion_2_FuelReg(FuelRegion,FuelReg)), El_Used(DAC_Sites,t));
UECPOUT_DAC_NGC(FuelRegion,MNUMYR) = sum((DAC_Sites,FuelReg,t)$(MNUMYR_t_emm(MNUMYR,t) and DAC_FuelRegion(DAC_Sites,FuelReg)
                         and FuelRegion_2_FuelReg(FuelRegion,FuelReg)), NG_Used(DAC_Sites,t));
UECPOUT_DAC_ELC_CS(MNUMCR,MNUMYR) = sum(FuelRegion$MNUMCR_FuelRegion(MNUMCR,FuelRegion), DAC_ELC_FR(FuelRegion,MNUMYR));
UECPOUT_DAC_NGC_CS(MNUMCR,MNUMYR) = sum(FuelRegion$MNUMCR_FuelRegion(MNUMCR,FuelRegion), UECPOUT_DAC_NGC(FuelRegion,MNUMYR));
UECPOUT_DAC_ELC_CS('11_United_States',MNUMYR) = sum(MNUMCR, UECPOUT_DAC_ELC_CS(MNUMCR,MNUMYR));
UECPOUT_DAC_NGC_CS('11_United_States',MNUMYR) = sum(MNUMCR, UECPOUT_DAC_NGC_CS(MNUMCR,MNUMYR));

* Reporting DAC builds by region and 45Q credits
DAC_Selection(DAC_Sites,t_sy)$(sum((TechType,ActiveEnergySource), Q_DAC.l(DAC_Sites,TechType,ActiveEnergySource,t_sy))>0) = yes;
DAC_Unselect(DAC_Sites,t_sy)$(sum((TechType,ActiveEnergySource), Q_DAC.l(DAC_Sites,TechType,ActiveEnergySource,t_sy))>0) = no;
DAC_45Q_VOL(DAC_Sites,t) = sum((TechType,ActiveEnergySource,t_sy)$(t.val ge t_sy.val and t.val lt t_sy.val + TCS45Q_I_45Q_DURATION
                           and t_sy.val le TCS45Q_I_45Q_LYR_NEW),
                           Q_DAC.l(DAC_Sites,TechType,ActiveEnergySource,t_sy)) + DAC_45Q_VOL(DAC_Sites,t);
Q_DACsav(DAC_Sites,t) = sum((TechType,ActiveEnergySource), Q_DAC.l(DAC_Sites,TechType,ActiveEnergySource,t)) + Q_DACsav(DAC_Sites,t);

Q_DAC_FR(FuelRegion,MNUMYR) = sum((DAC_Sites,FuelReg,t)$(MNUMYR_t_emm(MNUMYR,t)  and DAC_FuelRegion(DAC_Sites,FuelReg)
                              and FuelRegion_2_FuelReg(FuelRegion,FuelReg)),  Q_DACsav(DAC_Sites,t));
Q_DAC_EMM(MNUMNR,MNUMYR) = sum((DAC_Sites,REGION_EMM,t)$(MNUMYR_t_emm(MNUMYR,t)  and DAC_EMM(DAC_Sites,REGION_EMM)
                              and MNUMNR_EMM(MNUMNR,REGION_EMM)),  Q_DACsav(DAC_Sites,t));
UECPOUT_Q_DAC_CS(MNUMCR,MNUMYR) = sum(FuelRegion$MNUMCR_FuelRegion(MNUMCR,FuelRegion), Q_DAC_FR(FuelRegion,MNUMYR));
UECPOUT_Q_DAC_CS('11_United_States',MNUMYR) = sum(MNUMCR, UECPOUT_Q_DAC_CS(MNUMCR,MNUMYR));

* DAC Hubs subsidies reporting for next year
Subs_Used(DAC_Hubs,t_sy) = min(Max_Subs_Used(DAC_Hubs,t_sy), sum((TechType,ActiveEnergySource,t),
          min(DAC_CAPEX(t_sy,TechType,ActiveEnergySource,DAC_Hubs)*1.05*0.5/GDP(t_sy),
          DAC_CAPEX(t_sy,TechType,ActiveEnergySource,DAC_Hubs)*1.05*0.5/GDP(t_sy)*Q_DACsav(DAC_Hubs,t_sy))*GDP(t)*PV(t,TechType)));
loop((DAC_Hubs,t_sy),
      Subs_Rem(t)$(t.val gt t_sy.val) = max(0, Subs_Rem(t) - Subs_Used(DAC_Hubs,t_sy));
      Hubs_Rem(t)$(t.val gt t_sy.val) = max(0, Hubs_Rem(t) - 1$Subs_Used(DAC_Hubs,t_sy));
      DAC_Hubs_Used(DAC_Hubs,t_sy)$Subs_Used(DAC_Hubs,t_sy) = yes;
);

* Reporting proportion of product from the site via NG CCS
Q_NGCCSsav(DAC_Sites,t) = sum((TechType,ActiveEnergySource), Q_DAC.l(DAC_Sites,TechType,ActiveEnergySource,t)
                          * NG_CCSa(TechType,ActiveEnergySource) / (1 + NG_CCSa(TechType,ActiveEnergySource)))
                          + Q_NGCCSsav(DAC_Sites,t);
UECPOUT_Q_NG_CCS(MNUMCR,MNUMYR) = sum((DAC_Sites,FuelReg,FuelRegion,t)$(MNUMYR_t_emm(MNUMYR,t)  and DAC_FuelRegion(DAC_Sites,FuelReg)
                                  and FuelRegion_2_FuelReg(FuelRegion,FuelReg) and MNUMCR_FuelRegion(MNUMCR,FuelRegion)),
                                  Q_NGCCSsav(DAC_Sites,t));
UECPOUT_Q_NG_CCS('11_United_States',MNUMYR) = sum(MNUMCR, UECPOUT_Q_NG_CCS(MNUMCR,MNUMYR));

* Report DAC trajectory for next cycle
loop(t_sy$(t_sy.val eq 2050),
PREV_Q_DAC_CS(MNUMYR) = UECPOUT_Q_DAC_CS('11_United_States',MNUMYR);
TotalEmissions(t) = sum(MNUMYR$MNUMYR_t_emm(MNUMYR,t),EMISSION_EMSOL('1_M4',MNUMYR)*44/12 + PREV_Q_DAC_CS(MNUMYR));
);

* DAC builds for EOR and Saline
Q_EORsav(DAC_Sites,t) = sum((TechType,ActiveEnergySource), Q_EOR.l(DAC_Sites,TechType,ActiveEnergySource,t)) + Q_EORsav(DAC_Sites,t);
UECPOUT_DACtoEOR(M8,MNUMYR) = sum((DAC_EOR_Sites,REGION_OGSM,t)$(MNUMYR_t_emm(MNUMYR,t) and DAC_OGSM(DAC_EOR_Sites,REGION_OGSM)
                      and M8_to_REGION_OGSM(M8,REGION_OGSM)), Q_EORsav(DAC_EOR_Sites,t));
UECPOUT_DACtoEOR('8_M8',MNUMYR) = sum(M8, UECPOUT_DACtoEOR(M8,MNUMYR));
DAC_45Q_EOR(DAC_Sites,t) = sum((TechType,ActiveEnergySource,t_sy)$(t.val ge t_sy.val and t.val lt t_sy.val + TCS45Q_I_45Q_DURATION),
                           Q_EOR.l(DAC_Sites,TechType,ActiveEnergySource,t_sy)) + DAC_45Q_EOR(DAC_Sites,t);

Q_SALsav(DAC_Sites,t) = Q_DACsav(DAC_Sites,t) - Q_EORsav(DAC_Sites,t);
UECPOUT_DACtoSAL(FuelRegion,MNUMYR) = sum((DAC_Sites,FuelReg,t)$(MNUMYR_t_emm(MNUMYR,t) and DAC_FuelRegion(DAC_Sites,FuelReg)
                         and FuelRegion_2_FuelReg(FuelRegion,FuelReg)),Q_SALsav(DAC_Sites,t));
UECPOUT_DACtoSAL('24_MAXNFR',MNUMYR) = sum(FuelRegion, UECPOUT_DACtoSAL(FuelRegion,MNUMYR));
DAC_45Q_SAL(DAC_Sites,t) = DAC_45Q_VOL(DAC_Sites,t) - DAC_45Q_EOR(DAC_Sites,t);
CCS_45Q_SAL(DAC_Sites,t) = sum((TechType,ActiveEnergySource), DAC_45Q_SAL(DAC_Sites,t)
                                * NG_CCSa(TechType,ActiveEnergySource) / (1 + NG_CCSa(TechType,ActiveEnergySource)));
ATM_45Q_SAL(DAC_Sites,t) = DAC_45Q_SAL(DAC_Sites,t) - CCS_45Q_SAL(DAC_Sites,t);

UECPOUT_DAC_CO2_45Q(MNUMYR) = sum((DAC_Sites,t)$MNUMYR_t_emm(MNUMYR,t), DAC_45Q_VOL(DAC_Sites,t));
UECPOUT_DAC_EOR_45Q(MNUMYR) = sum((DAC_Sites,t)$MNUMYR_t_emm(MNUMYR,t), DAC_45Q_EOR(DAC_Sites,t));
UECPOUT_DAC_SAL_45Q(MNUMYR) = sum((DAC_Sites,t)$MNUMYR_t_emm(MNUMYR,t), DAC_45Q_SAL(DAC_Sites,t));
UECPOUT_CCS_SAL_45Q(MNUMYR) = sum((DAC_Sites,t)$MNUMYR_t_emm(MNUMYR,t), CCS_45Q_SAL(DAC_Sites,t));
UECPOUT_ATM_SAL_45Q(MNUMYR) = sum((DAC_Sites,t)$MNUMYR_t_emm(MNUMYR,t), ATM_45Q_SAL(DAC_Sites,t));

* DAC price to OGSM for EOR
P_OGSM(DAC_EOR_Sites,REGION_OGSM,TechType,ActiveEnergySource,t) = largenum;
P_OGSM(DAC_EOR_Sites,REGION_OGSM,TechType,ActiveEnergySource,t)$DAC_OGSM(DAC_EOR_Sites,REGION_OGSM) = -Q_EOR.m(DAC_EOR_Sites,TechType,ActiveEnergySource,t)/GDP(t);
UECPOUT_P_EOR(M8,MNUMYR)$(ord(M8)<8) = sum((REGION_OGSM,t,t_sy)$(MNUMYR_t_emm(MNUMYR,t) and M8_to_REGION_OGSM(M8,REGION_OGSM)
      and t.val ge t_sy.val), smin((DAC_EOR_Sites,TechType,ActiveEnergySource), P_OGSM(DAC_EOR_Sites,REGION_OGSM,TechType,ActiveEnergySource,t)));

* Export Model data to gdx file
Execute_Unload 'DAC\DACModel.gdx' ;

* Export Model data to NEMS
Execute_unload 'DAC_TO_NEMS.gdx',
UECPOUT_DAC_ELC UECPOUT_DAC_ELC_CS UECPOUT_DAC_NGC UECPOUT_DAC_NGC_CS UECPOUT_Q_DAC_CS UECPOUT_Q_NG_CCS
UECPOUT_DAC_CO2_45Q UECPOUT_DACtoEOR UECPOUT_DAC_EOR_45Q UECPOUT_DACtoSAL UECPOUT_DAC_SAL_45Q UECPOUT_CCS_SAL_45Q
DAC_Selection Q_DACsav UECPOUT_P_EOR UECPOUT_DAC_Pmin UECPOUT_DAC_Pmax UECPOUT_DAC_Slope UECPOUT_ATM_SAL_45Q

* Export DAC and price trajectory for next cycle
Execute_Unload 'DAC\LastCycle.gdx',
PREV_Q_DAC_CS TotalEmissions P_el_PREV P_ng_PREV
;
