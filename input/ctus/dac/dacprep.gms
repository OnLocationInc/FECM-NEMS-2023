$set Input_File DAC\DAC_Inputs.gdx

* Allows a set to be empty
$onempty
* Allows a set to get filled with multiple statements, e.g starts out empty and gets fileld in later
$onmulti

Set      numbers              number set to get right order                          /1*100/
         th                   t master plus historical                               /1981*2100/
         tm(th)               t master - all possible years needed                   /2011*2100/
         tf(tm)               t financing - all cash flow years                      /2012*2100/
         t_emm(tf)            t for emm output                                       /2015*2080/
         t_sy(t_emm)          Start Year                                             /2050/
;

Sets     tb(tm)               t plus the year before t starts (for GDP calaculation)  /2011*2050/
         t(t_emm)             time horizon of the model                               /2015*2050/
         MNXYRS               LCFS years   / 2015_MNXYRS*2050_MNXYRS /
         LCFS_C               LCFS Categories
         EnergySource         potential energy sources
         ActiveEnergySource(EnergySource)   potential energy sources
         DAC                  Set for financial calculations / Storage 'Storage Site' /
         TechType(DAC)        Types of DAC Technologies
         DAC_Saline           DAC at Saline Injection sites
         DAC_EOR              DAC at EOR Injection sites
         DAC_Pseudo           DAC at Pseudo sites in EMM Fuel regions /DAC_Fuel_1*DAC_Fuel_23/
         DAC_Props_att        Headers for DAC constants
         REGION_EMM           EMM regions
         REGION_OGSM          OGSM regions
         FuelRegion           Max number of combined fuel regions census-gas-coal-carbon from NEMS
                                         / 01_MAXNFR*24_MAXNFR /
         FuelReg              Set of EMM fuel regions for GAMS
         M8                   Generic set used for OGSM regions
         M13
         M15
         MNUMYR               NEMS model years / 2015_MNUMYR*2050_MNUMYR /
         MNUMYR_t_emm(MNUMYR,t_emm)      Map MNUMYR to t_emm /set.MNUMYR:set.t_emm/

         MNUMCR               NEMS census divisions / 01_New_England
                                                02_Middle_Atlantic
                                                03_East_North_Central
                                                04_West_North_Central
                                                05_South_Atlantic
                                                06_East_South_Central
                                                07_West_South_Central
                                                08_Mountain
                                                09_Pacific
                                                11_United_States /
         MNUMY3               Years for GDP index / 2011_MNUMY3*2050_MNUMY3 /
         sink_att             column headers for sink properties
         sink_att2            column headers for sink properties 2
         ProgramGoal_att      Program Goals headers
         Saline_Constants_att column headers for saline constants
         Saline_Coeffs_att    column headers for saline coefficients
;

parameter NCNTRL_CURIYR       Current year
          NCNTRL_CURCALYR     Current NEMS year
                ;

$gdxin NEMS_TO_DAC.gdx
$load M8, M13, M15, NCNTRL_CURCALYR, NCNTRL_CURIYR
*$load LCFS_C
$gdxin

$gdxin %Input_File%
$loadm DAC=TechType
$load EnergySource TechType DAC_Props_att
$gdxin

$gdxin input\CTSinput.gdx
$loadm DAC_EOR=InjPseudo, DAC_Saline=InjSal
$load  Saline_Constants_att, Saline_Coeffs_att
$load  ProgramGoal_att, sink_att, sink_att2
$load  REGION_EMM, REGION_OGSM, FuelReg

$Ifi not %InNEMS% == 1 $goto next1
t_sy(t_emm) = no;
t_sy(t_emm)$(t_emm.val eq NCNTRL_CURCALYR) = yes;
$label next1

* build supersets
Sets    DAC_Sites            All DAC Facilities / set.DAC_Saline, set.DAC_EOR, set.DAC_Pseudo /

Set     DAC_OGSM(DAC_Sites,REGION_OGSM)    Map DAC sites to OGSM regions
        DAC_FuelRegion(DAC_Sites,FuelReg)  Map DAC sites to fuel regions
        DAC_EMM(DAC_Sites,REGION_EMM)      Map DAC sites to EMM regions
        FuelRegion_2_FuelReg(FuelRegion,FuelReg)  Map NEMS fuel region indicies to GAMS fuel region indicies
                                                            / set.FuelRegion:set.FuelReg /
        MNUMYR_MNXYRS(MNUMYR,MNXYRS)    Map MNUMYR to LCFS years /set.MNUMYR:set.MNXYRS/
        MNUMY3_tm(MNUMY3,tm)    Map MNUMY3 to model years /set.MNUMY3:set.tm/
        MNUMCR_FuelRegion(MNUMCR,FuelRegion) Map Census regions to Fuel Regions
                          / 01_New_England.01_MAXNFR,   02_Middle_Atlantic.02_MAXNFR,   02_Middle_Atlantic.03_MAXNFR,    03_East_North_Central.04_MAXNFR
                          03_East_North_Central.05_MAXNFR, 03_East_North_Central.06_MAXNFR, 04_West_North_Central.07_MAXNFR, 04_West_North_Central.08_MAXNFR
                          04_West_North_Central.09_MAXNFR, 05_South_Atlantic.10_MAXNFR,     05_South_Atlantic.11_MAXNFR,     05_South_Atlantic.12_MAXNFR
                          05_South_Atlantic.13_MAXNFR,     05_South_Atlantic.14_MAXNFR,     05_South_Atlantic.15_MAXNFR,     06_East_South_Central.16_MAXNFR
                          06_East_South_Central.17_MAXNFR, 07_West_South_Central.18_MAXNFR, 08_Mountain.19_MAXNFR,           08_Mountain.20_MAXNFR
                          08_Mountain.21_MAXNFR,           09_Pacific.22_MAXNFR,            09_Pacific.23_MAXNFR /

Parameter        SinkProps(DAC_Saline, sink_att)
                 SinkProps2(DAC_Saline, sink_att2)
                 ProgramGoal(tf, DAC, ProgramGoal_att)
                 Saline_Constants(Saline_Constants_att)   Parameters for saline cost equations
                 Saline_Coeffs(Saline_Coeffs_att)
                 DAC_Props(DAC,DAC_Props_att)  DAC constants
           ;

$gdxin input\CTSinput.gdx
$load ProgramGoal, SinkProps, SinkProps2, Saline_Constants, Saline_Coeffs
$loadm DAC_EMM = INJ_EMM DAC_OGSM=INJ_OGSM
$gdxin

$gdxin %Input_File%
$loadm DAC_EMM DAC_FuelRegion DAC_OGSM ActiveEnergySource DAC_Props
$gdxin

DAC_FuelRegion(DAC_Sites(DAC_Pseudo),FuelReg)$(ord(FuelReg)=ord(DAC_Pseudo))=yes;

Sets             Yr                             /Yr1,Yr2,Yr3,Yr4,Yr5,Yr6/
                 Prof                           /Prof1,Prof2,Prof3,Prof4,Prof5,Prof6/
                 M8_to_REGION_OGSM(M8,REGION_OGSM)      Map NEMS OGSM index to CTUS OGSM index
                                                        / 1_M8.1
                                                          2_M8.2
                                                          3_M8.3
                                                          4_M8.4
                                                          5_M8.5
                                                          6_M8.6
                                                          7_M8.7
                                                          8_M8.8 /
;

Parameters       GDP(th)
                 CarbonPrice(t)                  Carbon credit $USD(1987) per kg
                 ActiveConstrProfile(Yr,DAC)

                 Escrate                         Escalation rate
                 EMRP                            Estimated Market Risk Premium
                 RFR(t_emm)                      Risk-free Rate
                 DebtRate(t_emm)                 Debt Rate

                 MACOUT_MC_JPGDP(MNUMY3)         Chained price index-gross domestic product
                 MACOUT_MC_RMCORPBAA(MNUMYR)     Corporate Baa Bond Rate from NEMS
                 MACOUT_MC_RMTCM10Y(MNUMYR)      10-Year Treasury Bond Rate from NEMS
                 MACOUT_MC_SP500(MNUMYR)         S&P 500 Index from NEMS
                 LFMMOUT_LCFS_Offset_Prc(LCFS_C,MNXYRS) LCFS Offset Price
                 REG_CO2_P(REGION_EMM,MNUMYR)    Regional CO2 Price
                 GDPt(tf)                        proportion of GDP(tb-1) to GDP(tb)

                 RecurringDebt                   Repeated Investments                               /1/
                 TaxRate                         Tax Rate - updated                               /0.24/
                 Decl_rate                                                                       /2.00/
                 Conrate_adder                   Adder to Debtrate for Conrate                    /.02/
                 FRFr                            Discount Rate                                    /0.062/
                 FVannuity
                 Conrate(t_emm)                  Construction period borrowing costs
                 ProfiletoUse(DAC)               User selection of construction profile
                 EquityFraction(DAC)             EOR Equity Fraction
                 DebtFraction(DAC)               EOR Debt Fraction
                 DebtLife(DAC)                   CO2 Debt Life
                 TaxLife(DAC)                    CO2 Tax Life
                 EquipLife(DAC)                  CO2 Equipment  Life
                 Life(DAC)                       Economic life
                 Beta(DAC)                       Beta
                 CRF(t_emm,DAC)                  Capital Recovery Factor
                 EquityRate(t_emm,DAC)           CO2  NOMINAL Equity Interest Rate
                 PVDO(t_emm,DAC)                 Short cut for calculating the impact of making principle payments on debt outstanding
                 IEF(t_emm,DAC)                  Interest payments on debt
                 DPP(DAC)                        Debt paid in Period
                 DDPP(t_emm,DAC)                 Discounted Debt Principal Payment
                 EQ(DAC)                         Cash Out Flow from Equity
                 DEPf(t_emm,DAC)                 Discounted Depreciation Factor
                 FCRF(t_emm,DAC)                 Fixed Charge Rate Factor
                 CAF(t_emm,DAC)                  Capital Costs Adjustmnet Factor
                 NPV_INV(t_emm,DAC)              Net Present Value of All Investment Related Expenses

                 A_(tf,DAC)                      The following are temporary variables used to get to Taxdepr
                 B_(tf,DAC)
                 C_(tf,DAC)
                 D_(tf,DAC)
                 E_(tf,DAC)
                 F_(tf,DAC)
                 G_(tf,DAC)
                 H_(tf,DAC)
                 I_(tf,DAC)
                 J_(tf,DAC)
                 K_(tf,DAC)
                 L_(tf,DAC)
                 AG_(tf,DAC)
                 AH_(tf,DAC)
                 Rem(tf,DAC)
                 DDB(tf,DAC)
                 SL(tf,DAC)
                 VBD(tf,DAC)

                 Taxdepr(tf,DAC)                 Tax depreciation
 ;

Table ConstrProfile(Yr,Prof)
           Prof1   Prof2   Prof3   Prof4   Prof5   Prof6
Yr1        1.00    0.25    0.25    0.10    0.03    0.01
Yr2        0.00    0.75    0.50    0.30    0.09    0.77
Yr3        0.00    0.00    0.25    0.40    0.30    0.05
Yr4        0.00    0.00    0.00    0.20    0.40    0.09
Yr5        0.00    0.00    0.00    0.00    0.18    0.01
Yr6        0.00    0.00    0.00    0.00    0.00    0.07

;

$gdxin NEMS_TO_DAC.gdx
$load MACOUT_MC_RMCORPBAA MACOUT_MC_RMTCM10Y MACOUT_MC_SP500 MACOUT_MC_JPGDP
*$load LFMMOUT_LCFS_Offset_Prc
$gdxin

*REG_CO2_P('21',MNUMYR) = smax(LCFS_C, sum((MNXYRS,t_sy)$MNUMYR_MNXYRS(MNUMYR,MNXYRS),
*                               LFMMOUT_LCFS_Offset_Prc(LCFS_C,MNXYRS)*GDP(t_sy) ) );
*REG_CO2_P('22',MNUMYR) = smax(LCFS_C, sum((MNXYRS,t_sy)$MNUMYR_MNXYRS(MNUMYR,MNXYRS),
*                               LFMMOUT_LCFS_Offset_Prc(LCFS_C,MNXYRS)*GDP(t_sy) ) );

***** Begin Financial Calculations *****
ProfiletoUse(DAC) = DAC_Props(DAC,'ProfiletoUse');
EquityFraction(DAC) = DAC_Props(DAC,'EquityFraction');
DebtFraction(DAC) = DAC_Props(DAC,'DebtFraction');
DebtLife(DAC) = DAC_Props(DAC,'DebtLife');
TaxLife(DAC) = DAC_Props(DAC,'TaxLife');
EquipLife(DAC) = DAC_Props(DAC,'EquipLife');
Life(DAC) = DAC_Props(DAC,'Life');
Beta(DAC) = DAC_Props(DAC,'Beta');

* Set future program goals to the 2050 values if year is greater than 2050
ProgramGoal(tf,DAC,ProgramGoal_Att)$(tf.val>2050) = ProgramGoal('2050',DAC,ProgramGoal_Att) ;

GDP(tm) = sum(MNUMY3$MNUMY3_tm(MNUMY3,tm), MACOUT_MC_JPGDP(MNUMY3));
* Y-o-Y GDP change
GDPt(tf) = sum(tb$(tb.val = tf.val), GDP(tb)/GDP(tb-1));
loop(t_emm$(t_emm.val>2050),
     GDP(t_emm) = GDP(t_emm-1)*sum(tf$GDPt(tf), GDPt(tf))/sum(tf$GDPt(tf), 1);
);

parameter sp500rate(t);
*sp500rate(t)      = sum(MNUMYR$(MNUMYR_t_emm(MNUMYR,t) and (MACOUT_MC_SP500(MNUMYR-1)>0)),
*                      (MACOUT_MC_SP500(MNUMYR)/MACOUT_MC_SP500(MNUMYR-1)) - 1 ) ;
*sp500rate('2012') = 0.0872 ;

* Hard-coded return on market rate used
sp500rate(t)      = 0.08 ;

* Average growth rate of S&P 500 index over model time horizon
EMRP = sum(t, sp500rate(t) ) / card(t) ;

* Average 10-Yr Treasury bond rate in the start year
RFR(t_sy)  = sum(MNUMYR$MNUMYR_t_emm(MNUMYR,t_sy), MACOUT_MC_RMTCM10Y(MNUMYR)) / 100 ;

* Average Corporate Baa bond rate over the model time horizon
DebtRate(t_sy) = sum(MNUMYR$MNUMYR_t_emm(MNUMYR,t_sy), MACOUT_MC_RMCORPBAA(MNUMYR)) / 100 ;

EquityRate(t_sy,DAC)   = RFR(t_sy) + Beta(DAC)*(EMRP-RFR(t_sy)) ;

FVAnnuity =   (POWER((1+FRFr) ,LIFE('Storage') )-1)/FRFr ;

loop(DAC,
 If( ProfiletoUse(DAC)= 1,
     ActiveConstrProfile(Yr,DAC) = ConstrProfile(Yr,'Prof1') ;
   Elseif  ProfiletoUse(DAC)= 2,
     ActiveConstrProfile(Yr,DAC) = ConstrProfile(Yr,'Prof2') ;
   Elseif  ProfiletoUse(DAC)= 3,
     ActiveConstrProfile(Yr,DAC) = ConstrProfile(Yr,'Prof3') ;
   Elseif  ProfiletoUse(DAC)= 4,
     ActiveConstrProfile(Yr,DAC) = ConstrProfile(Yr,'Prof4') ;
   Elseif  ProfiletoUse(DAC)= 5,
     ActiveConstrProfile(Yr,DAC) = ConstrProfile(Yr,'Prof5') ;
   Elseif  ProfiletoUse(DAC)= 6,
     ActiveConstrProfile(Yr,DAC) = ConstrProfile(Yr,'Prof6') ;
 );
 Loop(tf,
    K_(tf,DAC) = Life(DAC)-ord(tf)+1;
    B_(tf,DAC) = ord(tf);
    If (K_(tf,DAC)>0,
      E_(tf,DAC) = EquipLife(DAC) $( mod(B_(tf,DAC),EquipLife(DAC))=0) + mod(B_(tf,DAC),EquipLife(DAC)) $( mod(B_(tf,DAC),EquipLife(DAC))<>0);
    );
    AG_(tf,DAC)$(E_(tf,DAC)=1) =1;
    AH_("2012",DAC) = DebtFraction(DAC);
    AH_(tf,DAC)$( (RecurringDebt = 1) and (AG_(tf,DAC) = 1) ) = DebtFraction(DAC);
    A_(tf,DAC)$(AH_(tf,DAC)>0) = DebtLife(DAC);
    C_("2012",DAC)=A_("2012",DAC);
    If (ord(tf)>1,
          C_(tf,DAC)$(C_(tf-1,DAC)-1+A_(tf,DAC)>=0 )=C_(tf-1,DAC)-1;
    );
    If ( Mod(B_(tf,DAC)-1,EquipLife(DAC))=0,
       D_(tf,DAC) = EquipLife(DAC);
    Else
       D_(tf,DAC) = D_(tf-1,DAC)-1;
    );
    If (K_(tf,DAC)>0,
        If(E_(tf,DAC)=1,
          F_(tf,DAC)=1/EquipLife(DAC);
        Else
          F_(tf,DAC) = F_(tf-1,DAC);
        );
    );
    If (Mod(B_(tf,DAC)-1,EquipLife(DAC))=0,
           H_(tf,DAC)$(D_(tf,DAC)=EquipLife(DAC)) = TaxLife(DAC);
    Else
        If (E_(tf-1,DAC)>TaxLife(DAC),
             H_(tf,DAC) = 0;
        Else
             H_(tf,DAC) = H_(tf-1,DAC)-1;
         );
    );
    G_(tf,DAC)=0$(E_(tf,DAC)>TaxLife(DAC))  +  TaxLife(DAC)-H_(tf,DAC)+1$(E_(tf,DAC)<=TaxLife(DAC));
    DDB(tf,DAC)=0;
    If (H_(tf,DAC)>0,
      If(G_(tf,DAC)=1,
        Rem(tf,DAC) =1;
      Else
        Rem(tf,DAC) = Rem(tf-1,DAC)-DDB(tf-1,DAC)  ;
      );
      DDB(tf,DAC) = Rem(tf,DAC) * (1/Taxlife(DAC))*Decl_rate ;
      SL(tf,DAC)$(C_(tf,DAC)>0)=Rem(tf,DAC)/C_(tf,DAC);
      If (DDB(tf,DAC)>=SL(tf,DAC),
        VBD(tf,DAC) = DDB(tf,DAC);
      Else
        VBD(tf,DAC) = VBD(tf-1,DAC);
      );
    );
    TaxDepr(tf,DAC)$(K_(tf,DAC)>0  ) = VBD(tf,DAC);
 );
);

  DPP(DAC)  = (1/DebtLife(DAC))*DebtFraction(DAC);
  DDPP(t_sy,DAC)  = ((1-(POWER(1+EquityRate(t_sy,DAC),-DebtLife(DAC))))/EquityRate(t_sy,DAC))*DPP(DAC);
  DEPF(t_sy,DAC)  = sum(tf, TaxDepr(tf,DAC) / POWER((1+EquityRate(t_sy,DAC)),ord(tf)) ) ;
  PVDO(t_sy,DAC)  = (1-((1-(POWER(1+EquityRate(t_sy,DAC),-DebtLife(DAC))))/(DebtLife(DAC)*EquityRate(t_sy,DAC)))) *(1/EquityRate(t_sy,DAC));
  IEF(t_sy,DAC)   =   PVDO(t_sy,DAC) * DebtRate(t_sy) * DebtFraction(DAC);
  EQ(DAC) = EquityFraction(DAC);
  NPV_INV(t_sy,DAC) = EQ(DAC)/(1-TaxRate)+IEF(t_sy,DAC)-(TaxRate/(1-TaxRate))*DEPF(t_sy,DAC)+DDPP(t_sy,DAC)/(1-TaxRate);
  CRF(t_sy,DAC) = 1/((1-(1/POWER(1+EquityRate(t_sy,DAC),Life(DAC)) ))/EquityRate(t_sy,DAC));
  FCRF(t_sy,DAC)  = CRF(t_sy,DAC) * NPV_INV(t_sy,DAC);
  Escrate(t_sy) = GDPt(t_sy)  ;
  Conrate(t_sy) = Debtrate(t_sy) + Conrate_adder;
  CAF(t_sy,DAC) =  sum(Yr, ActiveConstrProfile(Yr,DAC)  * POWER(Escrate(t_sy),ord(Yr)-1)   * POWER(1+Conrate(t_sy),ProfileToUse(DAC)-ord(Yr)+1) );

Parameter  DAC_BaseCap(t_emm,TechType,EnergySource) DAC capital costs per tonne
           Q_el(t_emm,TechType,EnergySource)    Electricity Consumption
           Q_ng(t_emm,TechType,EnergySource)    NG Consumption
           DAC_NGCCSf(t_emm,TechType,ActiveEnergySource)       Maximum fraction of NG CO2 emissions captured relative to DAC by technology and year
           NG_CCSf(TechType,ActiveEnergySource) Maximum fraction of NG CO2 emissions captured relative to DAC by technology
           CapFactor(TechType,EnergySource)     DAC Capacity Factor by technology
           CaptureRate(TechType,EnergySource)   Fraction of NG related emissions captured
           P_el(t_emm,DAC_Sites)                Electricity Prices
           P_ng(t_emm,DAC_Sites)                NG Prices
           P_el_PREV(t_emm,DAC_Sites)           Electricity Prices from last cycle
           P_ng_PREV(t_emm,DAC_Sites)           NG Prices from last cycle
           DAC_El_Cost(t_emm,TechType,ActiveEnergySource,DAC_Sites) DAC Electricity Cost
           DAC_NG_Cost(t_emm,TechType,ActiveEnergySource,DAC_Sites) DAC NG Cost
           DAC_OPEX(t_emm,TechType,ActiveEnergySource,DAC_Sites)    DAC Operating Cost
           DAC_CAPEX(t_emm,TechType,ActiveEnergySource,DAC_Sites)   DAC Capital Cost
           DAC_Cost(t_emm,TechType,ActiveEnergySource,DAC_Sites)    DAC Cost by Site
           DAC_Cost_FR(FuelRegion,t_emm)         DAC Cost by Fuel Region
           CAPEX_MULT(REGION_EMM)                Capex Multiplier by EMM Region /   1        0.926, 2        0.947, 3        1.029
                                                                  4        1.062,   5        1.072, 6        0.954, 7        1.093
                                                                  8        1.442,   9        1.060, 10       1.115, 11       0.973
                                                                  12       1.222,  13        1.018, 14       0.956, 15       0.964
                                                                  16       0.984,  17        0.963, 18       1.019, 19       0.971
                                                                  20       0.976,  21        1.215, 22       1.182, 23       1.058
                                                                  24       0.976,  25        1.037 /
           TCS45Q_I_45Q_SYR                     Start year of tax code section 45Q subsidy
           TCS45Q_I_45Q_LYR_NEW                 End year of tax code section 45Q subsidy for new builds
           TCS45Q_I_45Q_DURATION                Tax code section 45Q subsidy duration
;
Set        BasisYear(t_emm)                     /2020/
           MNUMNR                               Electricity Supply (NERC) Regions
           M15
           ;

Parameter TCS45Q_CCS_SALINE_45Q(MNUMYR)        45Q tax credit for saline injection
          TCS45Q_CCS_EOR_45Q(MNUMYR)           45Q tax credit for enhanced oil recovery
          TCS45Q_CCS_DAC_45Q(MNUMYR)           45Q tax credit for CDR (DAC)
          OGSMOUT_OGCO2PUR2(M8,M13,MNUMYR)     CO2 Purchased at the EOR sites (mmcf)
          EFPOUT_PELINNR(MNUMNR,MNUMYR)        Purchase Price by EMM Region
          UEFDOUT_UPGASPRC(MNUMNR,MNUMYR)      Average Fuel Price by EMM Region
          EMISSION_EMETAX(M15,MNUMYR)          Excise (Consumption) Tax by Fuel
          AB32_AB_ALLOW_P(MNUMYR)              Allowance Price in 87$ per tonne-C
          RGGI_RG_ALLOW_P(MNUMYR)              Allowance Price in 87$ per tonne-C
          Credit_EOR(t_emm)                    Yearly 45Q Credit for DAC to EOR
          Credit_Saline(t_emm)                 Yearly 45Q Credit for CCS to Saline
          Credit_CDR(t_emm)                    Yearly 45Q Credit for CDR to Saline
          DAC_EOR_Credit(t_emm,TechType)       Levelized 45Q Credit for DAC to EOR
          DAC_Saline_Credit(t_emm,TechType)    Levelized 45Q Credit for CCS to Saline
          DAC_CDR_Credit(t_emm,TechType)       Levelized 45Q Credit for CDR to Saline
          ;

$gdxin NEMS_TO_DAC.gdx
$load M15 MNUMNR
$load TCS45Q_I_45Q_SYR TCS45Q_I_45Q_LYR_NEW TCS45Q_I_45Q_DURATION TCS45Q_CCS_SALINE_45Q TCS45Q_CCS_EOR_45Q TCS45Q_CCS_DAC_45Q
$load EFPOUT_PELINNR UEFDOUT_UPGASPRC EMISSION_EMETAX AB32_AB_ALLOW_P RGGI_RG_ALLOW_P OGSMOUT_OGCO2PUR2
$gdxin

$gdxin %Input_File%
$load Q_EL Q_NG DAC_BaseCap DAC_NGCCSf
$gdxin

$gdxin DAC\DACPrep.gdx
$load P_el_PREV P_ng_PREV
$gdxin

$if not exist DAC\LastCycle.gdx $goto CycleOne
$gdxin DAC\LastCycle.gdx
$load P_el_PREV P_ng_PREV
$label CycleOne

Set   MNUMNR_EMM(MNUMNR,REGION_EMM)   Map MNUMNR to EMM Regions /set.MNUMNR:set.region_emm/
      ;

***** DAC energy and credit calculations *****

P_el(t_emm,DAC_Sites)=sum((REGION_EMM,MNUMNR,MNUMYR)$(MNUMYR_t_emm(MNUMYR,t_emm)
                      and MNUMNR_EMM(MNUMNR,REGION_EMM) and DAC_EMM(DAC_Sites,REGION_EMM)),
*                      min(100/GDP('2021'), EFPOUT_PELINNR(MNUMNR,MNUMYR))) * GDP(t_emm);
                      EFPOUT_PELINNR(MNUMNR,MNUMYR)) * GDP(t_emm);
P_ng(t_emm,DAC_Sites)=sum((REGION_EMM,MNUMNR,MNUMYR)$(MNUMYR_t_emm(MNUMYR,t_emm)
                      and MNUMNR_EMM(MNUMNR,REGION_EMM) and DAC_EMM(DAC_Sites,REGION_EMM)),
                      UEFDOUT_UPGASPRC(MNUMNR,MNUMYR)) * GDP(t_emm);

P_el(t_emm,DAC_Sites)$(t_emm.val>2050) = P_el('2050',DAC_Sites);
P_ng(t_emm,DAC_Sites)$(t_emm.val>2050) = P_ng('2050',DAC_Sites);

P_el(t_emm,DAC_Sites)=P_el(t_emm,DAC_Sites)*0.1 + P_el_PREV(t_emm,DAC_Sites)*0.9;
P_ng(t_emm,DAC_Sites)=P_ng(t_emm,DAC_Sites)*0.1 + P_ng_PREV(t_emm,DAC_Sites)*0.9;

loop(t_sy$(t_sy.val eq 2050),
P_el_PREV(t_emm,DAC_Sites) = P_el(t_emm,DAC_Sites);
P_ng_PREV(t_emm,DAC_Sites) = P_ng(t_emm,DAC_Sites);
);

CapFactor(TechType,ActiveEnergySource) = DAC_Props(TechType,'CapFactor');
CaptureRate(TechType,ActiveEnergySource) = DAC_Props(TechType,'CaptureRate');
NG_CCSf(TechType,ActiveEnergySource) = sum(t_sy, DAC_NGCCSf(t_sy,TechType,ActiveEnergySource));

Q_EL(t_emm,TechType,ActiveEnergySource)$(t_emm.val>2050) = Q_EL('2050',TechType,ActiveEnergySource);
Q_NG(t_emm,TechType,ActiveEnergySource)$(t_emm.val>2050) = Q_NG('2050',TechType,ActiveEnergySource);
DAC_BaseCap(t_emm,TechType,ActiveEnergySource)$(t_emm.val>2050) = DAC_BaseCap('2050',TechType,ActiveEnergySource);

*Q_el(t_sy,'1',ActiveEnergySource) = 366/1000;
DAC_El_Cost(t_sy,TechType,ActiveEnergySource,DAC_Sites)
            = Q_el(t_sy,TechType,ActiveEnergySource)
            * sum(t_emm$(t_emm.val>=t_sy.val and t_emm.val<=t_sy.val+Life(TechType)), P_el(t_emm,DAC_Sites) * POWER((1+EquityRate(t_sy,TechType)),t_sy.val-t_emm.val+1) )
            / sum(t_emm$(t_emm.val>=t_sy.val and t_emm.val<=t_sy.val+Life(TechType)), POWER((1+EquityRate(t_sy,TechType)),t_sy.val-t_emm.val+1) );
*Q_ng(t_sy,'1',ActiveEnergySource) = 5.25/0.94781712;
DAC_NG_Cost(t_sy,TechType,ActiveEnergySource,DAC_Sites)
            = Q_ng(t_sy,TechType,ActiveEnergySource)
            * sum(t_emm$(t_emm.val>=t_sy.val and t_emm.val<=t_sy.val+Life(TechType)), P_ng(t_emm,DAC_Sites) * POWER((1+EquityRate(t_sy,TechType)),t_sy.val-t_emm.val+1) )
            / sum(t_emm$(t_emm.val>=t_sy.val and t_emm.val<=t_sy.val+Life(TechType)), POWER((1+EquityRate(t_sy,TechType)),t_sy.val-t_emm.val+1) );
DAC_OPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites) = DAC_El_Cost(t_sy,TechType,ActiveEnergySource,DAC_Sites) + DAC_NG_Cost(t_sy,TechType,ActiveEnergySource,DAC_Sites);
*DAC_BaseCap(t_sy,'1',ActiveEnergySource) = 694 * (GDP(t_sy)/GDP('2018'));
DAC_CAPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites) = DAC_BaseCap(t_sy,TechType,ActiveEnergySource) * FCRF(t_sy,TechType) * CAF(t_sy,TechType) / CapFactor(TechType,ActiveEnergySource);
DAC_CAPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites) = DAC_CAPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites) * (GDP(t_sy)/sum(BasisYear, GDP(BasisYear)));
DAC_CAPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites) = sum(REGION_EMM$DAC_EMM(DAC_Sites,REGION_EMM), DAC_CAPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites) * CAPEX_MULT(REGION_EMM));
DAC_Cost(t_sy,TechType,ActiveEnergySource,DAC_Sites) = DAC_CAPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites)*1.05 + DAC_OPEX(t_sy,TechType,ActiveEnergySource,DAC_Sites);
DAC_Cost_FR(FuelRegion,t_sy) = smax(DAC_Sites, sum((TechType,ActiveEnergySource,FuelReg)$(DAC_FuelRegion(DAC_Sites,FuelReg)
                               and FuelRegion_2_FuelReg(FuelRegion,FuelReg)), DAC_Cost(t_sy,TechType,ActiveEnergySource,DAC_Sites)));

Credit_EOR(t_emm) = sum((MNUMYR,t_sy)$(MNUMYR_t_emm(MNUMYR,t_emm) and t_sy.val le TCS45Q_I_45Q_LYR_NEW
                and t_emm.val ge t_sy.val and t_emm.val lt (t_sy.val + TCS45Q_I_45Q_DURATION)), TCS45Q_CCS_EOR_45Q(MNUMYR)) * GDP(t_emm);
Credit_Saline(t_emm) = sum((MNUMYR,t_sy)$(MNUMYR_t_emm(MNUMYR,t_emm) and t_sy.val le TCS45Q_I_45Q_LYR_NEW
                and t_emm.val ge t_sy.val and t_emm.val lt (t_sy.val + TCS45Q_I_45Q_DURATION)), TCS45Q_CCS_SALINE_45Q(MNUMYR)) * GDP(t_emm);
Credit_CDR(t_emm) = sum((MNUMYR,t_sy)$(MNUMYR_t_emm(MNUMYR,t_emm) and t_sy.val le TCS45Q_I_45Q_LYR_NEW
                and t_emm.val ge t_sy.val and t_emm.val lt (t_sy.val + TCS45Q_I_45Q_DURATION)), TCS45Q_CCS_DAC_45Q(MNUMYR)) * GDP(t_emm);
DAC_EOR_Credit(t_sy,TechType) = sum(t_emm$(t_emm.val>=t_sy.val and t_emm.val<=t_sy.val+Life(TechType)), Credit_EOR(t_emm) * POWER((1+EquityRate(t_sy,TechType)),t_sy.val-t_emm.val+1) )
            / sum(t_emm$(t_emm.val>=t_sy.val and t_emm.val<=t_sy.val+Life(TechType)), POWER((1+EquityRate(t_sy,TechType)),t_sy.val-t_emm.val+1) );
DAC_Saline_Credit(t_sy,TechType) = sum(t_emm$(t_emm.val>=t_sy.val and t_emm.val<=t_sy.val+Life(TechType)), Credit_Saline(t_emm) * POWER((1+EquityRate(t_sy,TechType)),t_sy.val-t_emm.val+1) )
            / sum(t_emm$(t_emm.val>=t_sy.val and t_emm.val<=t_sy.val+Life(TechType)), POWER((1+EquityRate(t_sy,TechType)),t_sy.val-t_emm.val+1) );
DAC_CDR_Credit(t_sy,TechType) = sum(t_emm$(t_emm.val>=t_sy.val and t_emm.val<=t_sy.val+Life(TechType)), Credit_CDR(t_emm) * POWER((1+EquityRate(t_sy,TechType)),t_sy.val-t_emm.val+1) )
            / sum(t_emm$(t_emm.val>=t_sy.val and t_emm.val<=t_sy.val+Life(TechType)), POWER((1+EquityRate(t_sy,TechType)),t_sy.val-t_emm.val+1) );

*************** Saline Cost Calculations ****************
parameters
         SinkCapCost(DAC_Saline,t_emm)     Fixed cost(millions of dollars) to build a SINK
         InjectCost(DAC_Saline,t_emm)      Variable cost (O&M) per tonne ($) for CO2 injection
         WellCapCost(DAC_Saline,t_emm)     Cost (millions of dollars) to build a well at each SINK
         WellMax(DAC_Saline)               Maximum (millions tonnes) injected annually at a well for each SINK
         InjectCap(DAC_Saline)             Total cumulative capacity in million tonnes at each SINK
         CarbonOffset(t)                   Variable offset per tonne (dollars)on CO2 credited when injected
         CarbonPriceTM(th)                 Carbon Price in $USD per tonne referenced by tm instead of t
         WellDepth(DAC_Saline)             Well Depth in Meters - Used to impose limit on annual meters of drilling allowed

         INJPipeCapCost(DAC_Saline)        Injection pipe capital cost
         NW_PreOp(DAC_Saline)              Non-well-dependent costs
         WDepCC(DAC_Saline)                Well-dependent costs ($ per well)
         OP3YRCC(DAC_Saline)               3-year repeating capital costs (Operations)
         OP5YRCC(DAC_Saline,t_emm)         5-year recurring costs
         OpExPerWell(DAC_Saline)           Operating expenses in $ per well
         OpExPerTon(DAC_Saline)            Operating expenses in $ per ton
         WellDepFinResp(DAC_Saline)        Well-dependent financial responsibility ($ per well)
         TonDepFinResp(DAC_Saline)         Ton-dependent financial responsibility ($ per ton)
;

***OPEX PER TONNE***
***site-level parameters for intermediate calculations***
parameters
         SIC(DAC_Saline)     site-independent costs
         CO2T(DAC_Saline)    CO2-dependent cost per ton
         CPRM(DAC_Saline)    Cost per reserve monitoring well
         CPWPA(DAC_Saline)   Cost per well plume area
         CPPA(DAC_Saline)    Cost per year plume area;


***OPEX PER WELL***
***site-level parameters for intermediate calculations***
parameters
         DCMW(DAC_Saline)                costs for dual-completion monitoring wells
         CMW(DAC_Saline)                 costs for monitoring wells
         CPIW(DAC_Saline)                costs per injection well per year
         DCPIJW(DAC_Saline)              direct costs per injection well
         DCPMJW(DAC_Saline)              additional direct cost for monitoring well
         DCPMJW_SUB1(DAC_Saline)         subcalc 1 for DCPMJW
         DCPMJW_SUB2(DAC_Saline)         subcalc 2 for DCPMJW

* Non-well-dependent site costs

parameters
         SISU(DAC_Saline)        Site-specific setup costs millions of 2011 $
         PreopPlume(DAC_Saline)
         PreopSeismic(DAC_Saline)
         FFPRE(t)                financial factor that accounts for impact of taxes associated w equity investment on the carrying cost
         FFPRE2
         FCRF_1530               fixed charge rate 15 year tax life 30 year project life
         np1
         np2
         np3
         CRF25
         CRF30
         CRF31
         CRF5;

*************************  Saline site operational period calcualtions ***************************************************************
parameters
         Financial_Factor_1(t_emm) financial factor for seismic costs assumed to be in five yr intervals
         Financial_Factor_2      financial factor for monitoring well cost expenditures assumed in 7 yr intervals
         FCRF_5_5                fixed charge rate five years tax rate five year recovery
         FCRF_5_7                fixed charge rate five years tax rate seven year recovery
         OP5YRCC_SUB1(DAC_Saline,t_emm)
         OP5YRCC_SUB2(DAC_Saline)
         Annual_Tonnes(DAC_Saline)
         RecurCap(DAC_Saline)
         FCRF_5_5_1               FCRF assuming 5 yr tax life 5 yr recovery
         MaxFormation(t_emm,DAC_Saline) Max injection rate per formation per year before new site is constructed
         MaxSinks(t_emm,DAC_Saline)     Max number of saline wells per site per year
         MaxWells(DAC_Saline)     Max number of saline wells per site per year
         MinWells(DAC_Saline)     Minimum number of saline wells per new injection site
         WellLimit(t_emm,DAC_Saline) Cap on number of saline wells per site per year
         InjLimit(t_emm,DAC_Saline)  Maximum Injection rate in million tonnes at each SINK
         SinkCapPerTon(DAC_Saline,t_emm)  Fixed cost(millions of dollars per ton) to build a SINK
         WellCapPerTon(DAC_Saline,t_emm)  Cost (millions of dollars per ton) to build a well at each SINK
         ;

alias(t1,t);

FCRF_1530 = 0.1118;
FCRF_5_5=0.2744;
FCRF_5_7=0.2005;
FCRF_5_5_1=0.2585;

*capital recovery factors used in this section
CRF5=1/sum(t_sy, CRF(t_sy,'Storage'));

***OPEX PER TON***
**Intermediate calcs **
*Site-Independent Costs
SIC(DAC_Saline) = Saline_Constants('SIC')/SinkProps2(DAC_Saline,'Tonnes');
*CO2 Dependent Costs (costs per tonne)
CO2T(DAC_Saline) = Saline_Constants('CO2T');
*Cost per reserve monitoring well
CPRM(DAC_Saline) = SinkProps2(DAC_Saline,'RESMWell_ETUC') * Saline_Coeffs('CPRMult') / (SinkProps2(DAC_Saline,'Tonnes') * 1e6);
*Cost per well plume area
CPWPA(DAC_Saline) = (SinkProps2(DAC_Saline,'wellPA_ETUC') * 6 / 30) / (SinkProps2(DAC_Saline,'Tonnes') * 1e6);
*Cost per year plume area
CPPA(DAC_Saline) = (SinkProps2(DAC_Saline,'W_PlumeR_ETUC') + SinkProps2(DAC_Saline,'PlumeR_ETUC')) / (SinkProps2(DAC_Saline,'Tonnes') * 1e6);

** Final Opex calc **
OpExPerTon(DAC_Saline) =     SIC(DAC_Saline) + CO2T(DAC_Saline) +
                         (CPRM(DAC_Saline) + CPWPA(DAC_Saline) + CPPA(DAC_Saline));


***OPEX PER WELL***
**Intermediate calcs**
*dual-completion monitoring well costs per injection well
DCMW(DAC_Saline) = SinkProps2(DAC_Saline,'DCMW_AC') / SinkProps2(DAC_Saline,'I_Wells');
* monitoring well costs per injection well: Avg monitoring wells * (avg mon. well cst + ann OM per foot * depth)
CMW(DAC_Saline) = SinkProps2(DAC_Saline,'M_Wells') / 2 * (Saline_Constants('AWC') + Saline_Coeffs('CPF1') * SinkProps2(DAC_Saline,'MW_Depth')) / SinkProps2(DAC_Saline,'I_Wells');
* injection well costs per well per year
CPIW(DAC_Saline) = Saline_Constants('CPIW');
* direct costs per injection well: injection well depth * ann. inj. well cost/ft + fixed inj. well cost + (last yr cost/ft*depth + last yr fixed)/(30 yrs)
DCPIJW(DAC_Saline) = (SinkProps2(DAC_Saline,'Inj_depth') * Saline_Coeffs('CPF2') + Saline_Coeffs('FCPW1'))
                 + (SinkProps2(DAC_Saline,'Inj_depth') * Saline_Coeffs('CPF3') + Saline_Coeffs('FCPW2')) / 30;
*additional direct costs per injection well:  (added monitoring well cst/ft*depth+monitoring well fixed)*(mon. wells) + (depth*5yr mon. well cst+5-yr fixed)*(mon. wells)
DCPMJW_SUB1(DAC_Saline) = (SinkProps2(DAC_Saline,'Inj_depth') * Saline_Coeffs('CPF4')+Saline_Coeffs('FCPMW1')) * (SinkProps2(DAC_Saline,'DCM_Wells')/2+1);
DCPMJW_SUB2(DAC_Saline) = (SinkProps2(DAC_Saline,'Inj_depth') * Saline_Coeffs('CPF5')+Saline_Coeffs('FCPMW2')) * (SinkProps2(DAC_Saline,'DCM_Wells')/2+1) * 30/6;

DCPMJW(DAC_Saline) = (DCPMJW_SUB1(DAC_Saline) + DCPMJW_SUB2(DAC_Saline) / 30) / SinkProps2(DAC_Saline,'I_Wells');
**Final Opex per well calc**

OpExPerWell(DAC_Saline) = DCMW(DAC_Saline) + CMW(DAC_Saline) + CPIW(DAC_Saline) + DCPIJW(DAC_Saline) + DCPMJW(DAC_Saline);
OpExPerWell(DAC_Saline) = OpExPerWell(DAC_Saline) / 1e6;

*************************  Begin new Saline site pre-operational period calcualtions ***************************************************************
PreopPlume(DAC_Saline) = SinkProps2(DAC_Saline,'PreopPA') * Saline_Coeffs('PAM');
*
PreopSeismic(DAC_Saline) = Saline_Coeffs('C3DS_N') * SinkProps2(DAC_Saline,'PA_B');

SISU(DAC_Saline) = SinkProps2(DAC_Saline,'PreopSite') + PreopPlume(DAC_Saline) + PreopSeismic(DAC_Saline);
SISU(DAC_Saline) = SISU(DAC_Saline) / (1e6);

FFPRE2 = FCRF_1530;

NW_PreOp(DAC_Saline) = (Saline_Constants('SISU') + SISU(DAC_Saline)) * FFPRE2;

*calculate WDepCC
WDepCC(DAC_Saline) = (SinkProps2(DAC_Saline,'StratT')+SinkProps2(DAC_Saline,'PreopWell'))/SinkProps2(DAC_Saline,'I_Wells')*FFPRE2;
WDepCC(DAC_Saline) = WDepCC(DAC_Saline)/1e6;

*************************  saline site operational period calcualtions ***************************************************************

Financial_Factor_1(t_sy) = (FCRF_5_5)/POWER(1+EquityRate(t_sy,'Storage'),5)+1/(POWER(1+EquityRate(t_sy,'Storage'),31));
Financial_Factor_2 = FCRF_5_7;


Annual_Tonnes(DAC_Saline) = SinkProps2(DAC_Saline,'Tonnes');

OP5YRCC_SUB1(DAC_Saline,t_sy) = Saline_Coeffs('C3DS_N') * SinkProps2(DAC_Saline,'PA_B') / Saline_Constants('ADJ1') * Financial_Factor_1(t_sy);

OP5YRCC_SUB2(DAC_Saline) = SinkProps2(DAC_Saline,'FiveETUC') * Financial_Factor_2;



OP5YRCC(DAC_Saline,t_sy) = ((OP5YRCC_SUB1(DAC_Saline,t_sy) +  OP5YRCC_SUB2(DAC_Saline)) / (Annual_Tonnes(DAC_Saline)*1e6));

RecurCap(DAC_Saline) = SinkProps2(DAC_Saline,'ThreeTRC')*FCRF_5_5_1/CRF5;

OP3YRCC(DAC_Saline) = RecurCap(DAC_Saline) / (Annual_Tonnes(DAC_Saline)*1e6);

WellDepFinResp(DAC_Saline) = (SinkProps2(DAC_Saline,'DiscPISC')/SinkProps2(DAC_Saline,'I_Wells'))/FVannuity ;
WellDepFinResp(DAC_Saline) =WellDepFinResp(DAC_Saline)/1e6;

INJPipeCapCost(DAC_Saline) = Saline_Constants('PipeVar')*SinkProps(DAC_Saline,'Plume_R')*0.333*(SinkProps(DAC_Saline,'SiteMax_MMT')/30) ;

Scalar   RND  nummber of decimals to round  /5/ ;

* Maximum (millions tonnes) injected annually at a well for saline formations
WellMax(DAC_Saline) = ROUND(SinkProps2(DAC_Saline,'Tonnes')/SinkProps2(DAC_Saline,'I_Wells'),RND);

* Well Depth for Saline Formations in meters
WellDepth(DAC_Saline) = ROUND(SinkProps(DAC_Saline,'Dtop')/3,RND)  ;

Parameter  TotalInj(DAC_Saline)  Total tons injected by other sectors over model horizon;

* Total cummmulative capacity in million tonnes at each saline formation
InjectCap(DAC_Saline) = SinkProps(DAC_Saline,'Capacity_MMT')*SinkProps(DAC_Saline,'MaxUse');

$if not exist ctusALL.gdx $goto SkipCTSall
$gdxin ctusALL.gdx
$load TotalInj
$gdxin

InjectCap(DAC_Saline) = max(0,SinkProps(DAC_Saline,'Capacity_MMT')*SinkProps(DAC_Saline,'MaxUse') - TotalInj(DAC_Saline));

$label SkipCTSall

* Add 1 to cover rounding error on EOR sites
*InjectCap(DAC_Sites)  = ROUND(InjectCap(DAC_Sites)+ 1 ,0);

* Constrain the annual injection into a saline saline formation per site
MaxFormation(t_sy,DAC_Saline)  = SinkProps(DAC_Saline,'SiteMax_MMT')/Life('Storage') ;

* Constrain the number of saline wells per year per site
MaxWells(DAC_Saline)  = ROUND(InjectCap(DAC_Saline)/Life('Storage')/WellMax(DAC_Saline),0) ;

* At least 4 wells must be drilled when activating a saline injection site
MinWells(DAC_Saline) = 4 ;

* Constrain the number of wells developed every year and then the injection rate per year
WellLimit(t_sy,DAC_Saline) = max(MinWells(DAC_Saline),min(999,MaxWells(DAC_Saline)) ) ;
InjLimit(t_sy,DAC_Saline) =  min(InjectCap(DAC_Saline)/Life('Storage'),WellLimit(t_sy,DAC_Saline)*WellMax(DAC_Saline));

* Constrain the number of sinks per year per formation
MaxSinks(t_sy,DAC_Saline)  = ROUND(InjLimit(t_sy,DAC_Saline)/MaxFormation(t_sy,DAC_Saline),0) ;

*Fixed New Injection Site Cost ($MM)
* Use PreOpCC in SinkCapCost (where 1 is now)    kmc
SinkCapCost(DAC_Saline,t_sy) = ( NW_PreOp(DAC_Saline))
                           * CAF(t_sy,'Storage') * ProgramGoal(t_sy,'1','FixedAdjS') ;

*Cost of a single well given the depth of this formation  ($MM)
WellCapCost(DAC_Saline,t_sy) = ( WDepCC(DAC_Saline) * ProgramGoal(t_sy,'1','FixedAdjS') +
                               OpExPerWell(DAC_Saline) * ProgramGoal(t_sy,'1','VarAdjS') +
                               WellDepFinResp(DAC_Saline) * ProgramGoal('2035','1','FixedAdjS'))
 ;

SinkCapPerTon(DAC_Saline,t_sy)$InjLimit(t_sy,DAC_Saline)
              = SinkCapCost(DAC_Saline,t_sy) / InjLimit(t_sy,DAC_Saline);

WellCapPerTon(DAC_Saline,t_sy)$InjLimit(t_sy,DAC_Saline)
              = WellCapCost(DAC_Saline,t_sy) * WellLimit(t_sy,DAC_Saline) / InjLimit(t_sy,DAC_Saline);

*Variable Injection Cost ($/tonne)
InjectCost(DAC_Saline,t_sy)    = ProgramGoal(t_sy,'1','VarAdjS') * (OP3YRCC(DAC_Saline) + OP5YRCC(DAC_Saline,t_sy) + OpExPerTon(DAC_Saline))
 ;


* Convert from 2011$ to start year $
SinkCapCost(DAC_Saline,t_sy) = SinkCapCost(DAC_Saline,t_sy) * (GDP(t_sy)/GDP('2011')) ;
WellCapCost(DAC_Saline,t_sy) = WellCapCost(DAC_Saline,t_sy) * (GDP(t_sy)/GDP('2011')) ;
SinkCapPerTon(DAC_Saline,t_sy) = SinkCapPerTon(DAC_Saline,t_sy) * (GDP(t_sy)/GDP('2011')) ;
WellCapPerTon(DAC_Saline,t_sy) = WellCapPerTon(DAC_Saline,t_sy) * (GDP(t_sy)/GDP('2011')) ;
InjectCost(DAC_Saline,t_sy)  = InjectCost(DAC_Saline,t_sy)  * (GDP(t_sy)/GDP('2011')) ;

parameter DAC_StorageCost(DAC_Sites,t_emm) Total Operating Cost of Storage at saline sinks
          TnS_Costs(FuelRegion)            Weighted-average total tranport and storage costs in 87$ per ton
          FR_OR_TranCost(FuelRegion,M8,t_emm)         Unit CO2 transport costs from each fuel region to each OGSM region in 2007$ per ton
          DAC_TnS_Costs(DAC_Sites,t_emm)  Transport & Storage cost at any DAC site
          DAC_TotalCost(DAC_Sites,t_emm)  Total Cost at DAC sites including 45Q credit for saline
          Q_DAC_Max(DAC_Sites,t_emm)      Capture Limit at any DAC site
          ;

$if not exist input\CTSSoln.gdx $goto SkipiCTS
$gdxin input\CTSSoln.gdx
$load TnS_Costs FR_OR_TranCost
$gdxin
$label SkipiCTS

$if not exist CTSSoln.gdx $goto SkipCTS
$gdxin CTSSoln.gdx
$load TnS_Costs FR_OR_TranCost
$gdxin
$label SkipCTS

***** Final DAC Cost calculations *****

DAC_StorageCost(DAC_Sites(DAC_Saline),t_sy) = WellCapPerTon(DAC_Saline,t_sy) +
                                      InjectCost(DAC_Saline,t_sy);
DAC_TnS_Costs(DAC_Sites(DAC_Saline),t_sy) = DAC_StorageCost(DAC_Sites,t_sy);
DAC_TnS_Costs(DAC_Sites(DAC_Pseudo),t_sy)
              = sum((FuelRegion,FuelReg)$(FuelRegion_2_FuelReg(FuelRegion,FuelReg)
                and DAC_FuelRegion(DAC_Sites,FuelReg)), TnS_Costs(FuelRegion)*GDP(t_sy));
DAC_TnS_Costs(DAC_Sites,t_sy)$(DAC_TnS_Costs(DAC_Sites,t_sy) eq 0) = 99*GDP(t_sy);
DAC_TnS_Costs(DAC_Sites(DAC_EOR),t_sy) = 0;

DAC_TotalCost(DAC_Sites,t_sy) = sum((TechType,ActiveEnergySource), DAC_Cost(t_sy,TechType,ActiveEnergySource,DAC_Sites))
                                + DAC_TnS_Costs(DAC_Sites,t_sy);

Q_DAC_Max(DAC_Sites(DAC_Saline),t_sy) = InjLimit(t_sy,DAC_Saline);
Q_DAC_Max(DAC_Sites(DAC_EOR),t_sy) =
                    sum((M8,M13,REGION_OGSM,MNUMYR)$(DAC_OGSM(DAC_Sites,REGION_OGSM)
                    and M8_to_REGION_OGSM(M8,REGION_OGSM) and MNUMYR_t_emm(MNUMYR,t_sy) and ord(M8)<8),
                         OGSMOUT_OGCO2PUR2(M8,M13,MNUMYR)/18000);
Q_DAC_Max(DAC_Sites(DAC_Pseudo),t_sy) = 1;
Q_DAC_Max(DAC_Sites(DAC_Saline),t_sy)$(SinkCapPerTon(DAC_Saline,t_sy)>100 or WellCapPerTon(DAC_Saline,t_sy)>100) = 0;

* Export Model data to gdx file
Execute_Unload 'DAC\DACPrep.gdx' ;
