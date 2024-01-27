$Title  Generate all reports for CTS model
$Ontext

* command line arguments for debugging
* r=CTStmp gdx=ctusAll.gdx --LPSolver=Cplex --dir=./ --ForceAllOn=-1

$Offtext

* Make sure these are not slightly nonnegative due to rounding error
CAPTURED.l(source,t)                = max(0,CAPTURED.l(source,t)) ;
PIPED.l(FromNode,ToNode,diameter,t) = max(0,PIPED.l(FromNode,ToNode,diameter,t)) ;
INJECTED.l(Inj,t)                   = max(0,INJECTED.l(Inj,t)) ;
INJECTED.l(Inj,t)$(INJECTED.l(Inj,t) le 1e-6)                   = 0 ;

* Check pipe size selections and check that the smallest pipe available was chosen for the necessary flow
parameter
          LinksOn(FromNode,ToNode)     active links
;

sets
  BestFit(FromNode,ToNode,diameter)    Best pipe choice based on flow
  ActualFit(FromNode,ToNode,diameter)    Actual pipe build choice
  PipeDone(FromNode,ToNode)
  PipeTooBig(FromNode,ToNode,diameter,diameter)
;

alias(diameter,diam);

LinksOn(FromTo(FromNode,ToNode)) = smax((diameter,t), PIPED.l(FromNode,ToNode,diameter,t));

PipeDone(FromNode,ToNode) = no ;
loop(link_input(FromNode,ToNode,diameter)$LinksOn(FromNode,ToNode),
  if ((LinksOn(FromNode,ToNode)< PipeMax(diameter)) and (not PipeDone(FromNode,ToNode)),
    BestFit(FromTo(FromNode,ToNode),diameter) = yes ;
    PipeDone(FromNode,ToNode) = yes ;
  );
);

ActualFit(FromTo(FromNode,ToNode),diameter) = sum(t, BLDPIPE.l(FromNode,ToNode,diameter,t)) ;

PipeTooBig(FromTo(FromNode,ToNode),diameter,diam)$(ActualFit(FromNode,ToNode,diameter) and
                                                   BestFit(FromNode,ToNode,diam) and
                                                  (not ActualFit(FromNode,ToNode,diam))) = yes ;

* Implement the improved PipeTooBig options calculated above (updated to include all pipes)
$ontext
*loop((FromNode(OnePipeNodes),ToNode,diameter,diam)$PipeTooBig(FromNode,ToNode,diameter,diam),
loop((FromNode,ToNode,diameter,diam)$PipeTooBig(FromNode,ToNode,diameter,diam),
  PIPED.l(FromNode,ToNode,diam,t)       = PIPED.l(FromNode,ToNode,diameter,t) ;
  PIPED.l(FromNode,ToNode,diameter,t)   = 0 ;

  BLDPIPE.l(FromNode,ToNode,diam,t)     = BLDPIPE.l(FromNode,ToNode,diameter,t) ;
  BLDPIPE.l(FromNode,ToNode,diameter,t) = 0 ;

);
$offtext

* Calculate ton-miles metrics
Parameters
  TonMiles_Actual(t)       Ton-miles of CO2 transported in MM tons-miles per year
  TonMiles_Max(t)          Ton-miles of pipe built in MM tons-miles per year
;

TonMiles_Actual(t) = 0 ;
TonMiles_Max(t)    = 0 ;

TonMiles_Actual(t) = sum((FromNode,ToNode,diameter)$(PIPED.l(FromNode,ToNode,diameter,t)>0),
                       PIPED.l(FromNode,ToNode,diameter,t)*LinkDist(FromNode,ToNode) ) ;

TonMiles_Max(t)    = sum((FromNode,ToNode,diameter)$(PipeReady.l(FromNode,ToNode,diameter,t)>0),
                       PipeMax(diameter)*LinkDist(FromNode,ToNode) ) ;

*-----------------------------------------------------------------------------------------------------------------------------

Set         LinksUsed                active links
            PlantsUsed               plants with capture
            PlantsNotUsed            plants without capture
            InjUsed(INJ_TERMINALS,t)           injection sites used
            InjNotUsed(INJ_TERMINALS,t)        injection sites not used
;

Alias (transship,transshipFrom);
Alias (transship,transshipTo);
Alias (plant,plant2);

Parameter   PipeFlow      million tonnes of CO2 piped on a link;

PipeFlow(FromNode,ToNode,t)     = sum(diameter, PIPED.l(FromNode,ToNode,diameter,t));
LinksUsed(FromNode,ToNode,t)    = PipeFlow(FromNode,ToNode,t);
PlantsUsed(plant,t)             = sum((diameter,ToNode), PIPED.l(plant,ToNode,diameter,t));
PlantsNotUsed(plant,t)          = Not PlantsUsed(plant,t);
InjUsed(INJ_TERMINALS,t)        = sum((diameter,FromNode), PIPED.l(FromNode,INJ_TERMINALS,diameter,t));
InjNotUsed(INJ_TERMINALS,t)     = Not InjUsed(INJ_TERMINALS,t);

Variable           dummy
Positive Variable  PltFlow(plant,FromNode,ToNode,t)  flow from plant pipe-by-pipe to injection site;

Equations FlowBalance
          PlantBalance
          PlantOff
          InjectBalance
          TransBalance
          FlowOBJ ;

PlantBalance(plant,t)$PlantsUsed(plant,t)..
           sum(ToNode$LinksUsed(plant,ToNode,t), PltFlow(plant,plant,ToNode,t)) -
           sum((FromNode,INJ_TERMINALS)$LinksUsed(FromNode,INJ_TERMINALS,t), PltFlow(plant,FromNode,INJ_TERMINALS,t)) =E= 0 ;
FlowBalance(LinksUsed(FromNode,ToNode,t))..
            sum(plant$PlantsUsed(plant,t), PltFlow(plant,FromNode,ToNode,t)) =L= PipeFlow(FromNode,ToNode,t);
TransBalance(plant,ToNode,t)$(PlantsUsed(plant,t) and transship(ToNode))..
           sum(FromNode$LinksUsed(FromNode,ToNode,t), PltFlow(plant,FromNode,ToNode,t)) -
           sum((FromNode(ToNode),ToNode2)$LinksUsed(FromNode,ToNode2,t), PltFlow(plant,FromNode,ToNode2,t)) =E= 0 ;
InjectBalance(INJ_TERMINALS,t)..
           sum((plant,FromNode)$(LinksUsed(FromNode,INJ_TERMINALS,t) and PlantsUsed(plant,t)), PltFlow(plant,FromNode,INJ_TERMINALS,t))
           =E=
           ROUND(max(sum(Inj$INJ_TDIST(Inj,INJ_TERMINALS), INJECTED.l(Inj,t)),0),8) ;
*           ROUND(max(sum(Inj$INJ_TDIST(Inj,INJ_TERMINALS), INJECTED.l(Inj,t) - zInj.l(Inj,t)),0),8) ;

FlowOBJ..  dummy =E= 0;

PltFlow.fx(plant,LinksUsed(plant,ToNode,t)) = PipeFlow(plant,ToNode,t);

Model Flow  /FlowBalance, PlantBalance, TransBalance, InjectBalance, FlowOBJ/;

Flow.solprint=0; Flow.limcol=0; Flow.limrow=0;

option lp = %LPsolver% ;
*FLOW.Holdfixed=1;
option limrow = 0;
option limcol = 0;
Flow.solprint=0;

Solve Flow using lp minimizing dummy;

PltFlow.l(plant,FromNode,ToNode,t)$(PltFlow.l(plant,FromNode,ToNode,t) le 1e-6) = 0;
* Turn on for debugging
* Generate files for Matrix Analyzer
*$onecho > convert.op2
*ANALYZES
*$offecho

*-----------------------------------------------------------------------------------------------------------------------------

Variable           dummy2
Positive Variable  InjFlow flow from plant pipe-by-pipe to injection site;

Equations FlowBalance2
          PlantBalance2
          PlantOff2
          InjectBalance2
          TransBalance2
          FlowOBJ2 ;

InjectBalance2(INJ_TERMINALS,t)$InjUsed(INJ_TERMINALS,t)..
           sum(FromNode$LinksUsed(FromNode,INJ_TERMINALS,t), InjFlow(INJ_TERMINALS,FromNode,INJ_TERMINALS,t)) -
           sum((plant,ToNode)$LinksUsed(plant,ToNode,t), InjFlow(INJ_TERMINALS,plant,ToNode,t)) =E= 0 ;
FlowBalance2(LinksUsed(FromNode,ToNode,t))..
            sum(INJ_TERMINALS$InjUsed(INJ_TERMINALS,t), InjFlow(INJ_TERMINALS,FromNode,ToNode,t)) =L= PipeFlow(FromNode,ToNode,t);
TransBalance2(INJ_TERMINALS,ToNode,t)$(InjUsed(INJ_TERMINALS,t) and transship(ToNode)) ..
           sum(FromNode$LinksUsed(FromNode,ToNode,t), InjFlow(INJ_TERMINALS,FromNode,ToNode,t)) -
           sum((FromNode(ToNode),ToNode2)$LinksUsed(FromNode,ToNode2,t), InjFlow(INJ_TERMINALS,FromNode,ToNode2,t)) =E= 0 ;
PlantBalance2(plant,t)..
           sum((ToNode,INJ_TERMINALS)$(LinksUsed(plant,ToNode,t) and InjUsed(INJ_TERMINALS,t)), InjFlow(INJ_TERMINALS,plant,ToNode,t))
           =E=
           ROUND(max(sum(source$unitplt(source,plant),CAPTURED.l(source,t)+ zCap.l(source,t)),0),8) ;

FlowOBJ2..  dummy2 =E= 0;

InjFlow.fx(INJ_TERMINALS,LinksUsed(FromNode,INJ_TERMINALS,t)) = PipeFlow(FromNode,INJ_TERMINALS,t);

Model Flow2  /FlowBalance2, PlantBalance2, TransBalance2, InjectBalance2, FlowOBJ2/;

Flow2.solprint=0; Flow2.limcol=0; Flow2.limrow=0;
option lp = %LPsolver% ;
Solve Flow2 using lp minimizing dummy2;

InjFlow.l(INJ_TERMINALS,FromNode,ToNode,t)$(InjFlow.l(INJ_TERMINALS,FromNode,ToNode,t) le 1e-6) = 0;
$ontext
Set SrcSink       Source-Sink assignment
    SrcLink       Source-Link assignment;
Parameter
    SrcFlow ;

SrcFlow(source,LinksUsed(FromNode,ToNode,t))     = sum(plant$unitplt(source,plant),CAPTURED.l(source,t)$PltFlow.l(plant,FromNode,ToNode,t));
SrcSink(Source,Inj,t)                            = sum(FromNode, SrcFlow(source,FromNode,Inj,t));
SrcLink(Source,Link(FromNode,ToNode,diameter),t) = PIPED.l(link,t) * SrcFlow(source,FromNode,ToNode,t);
$offtext

* Implement the improved PipeTooBig options calculated above (updated to include all pipes)
loop((FromNode,ToNode,diameter,diam)$PipeTooBig(FromNode,ToNode,diameter,diam),
  PIPED.l(FromNode,ToNode,diam,t)       = PIPED.l(FromNode,ToNode,diameter,t) ;
  PIPED.l(FromNode,ToNode,diameter,t)   = 0 ;
  BLDPIPE.l(FromNode,ToNode,diam,t)     = BLDPIPE.l(FromNode,ToNode,diameter,t) ;
  BLDPIPE.l(FromNode,ToNode,diameter,t) = 0 ;
);
*-----------------------------------------------------------------------------------------------------------------------------

* Pull in some data from CTUSModin needed to generate the reportsx

Parameter   SourceProps           Source Properties (IGRP Summer Capacity (SCAP) etc.)

            WellBuild(Inj)        Fixed cost to build a well
            WellMonitor(Inj)      Fixed cost to monitor a well
            WellMonitorT(Inj)     Annual portion of fixed cost to monitor a well
;

Set
   th                   t master plus historical
   tm(th)               time master set
   tf(tm)               t financing - all cash flow years
   t_emm(tf)            t for emm output
   t(t_emm)             time horizon of the model
   CapPower(plant)      Existing power plants + new power plants (EPlant+NPlant)

   FuelRegion                                Max number of combined fuel regions census-gas-coal-carbon from NEMS
   M8                                        Generic set used for OGSM regions
   FuelReg                                   Set of EMM fuel regions for GAMS
   REGION_OGSM                               OGSM regions
   M8_to_REGION_OGSM(M8,REGION_OGSM)         Map NEMS OGSM index to CTUS OGSM index
   FuelRegion_2_FuelReg(FuelRegion,FuelReg)  Map NEMS fuel region indicies to GAMS fuel region indicies
   E_RG(source,FuelReg)                      Fuel regions - existing CTS source mapping
   E_OR(source,REGION_OGSM)                  OGSM regions - existing CTS source mapping
   TERM_OGSM(INJ_TERMINALS,REGION_OGSM)      Map terminal nodes to OGSM regions
   TERM_FuelRegion(INJ_TERMINALS,FuelReg)    Map terminal nodes to fuel regions
   MNUMYR
   MNUMYR_t_emm(MNUMYR,t_emm)                Map MNUMYR to t_emm
   CTUS
   plttype(plant,SourceType)                 Plant and Source Type mapping
   N_TYPE(source,SourceType)                 New CTS build source type
;




Parameter
  CarbonPriceTM                                Carbon prices for full horizon
  GDP(th)
  PipeCapCostInit(FuelReg,REGION_OGSM)         Fixed cost ($ per ton) to build a PIPE
  TransportCostInit(FuelReg,REGION_OGSM)       Variable Transportation Cost ($ per ton)
  PipeCapCostInitOR(REGION_OGSM,REGION_OGSM)         Fixed cost ($ per ton) to build a PIPE
  TransportCostInitOR(REGION_OGSM,REGION_OGSM)       Variable Transportation Cost ($ per ton)
  N_RG(source)                                 New CTS build fuel region
  N_OR(source)                                 New CTS build OGSM region
  PV(CTUS,t)                                   Present Value
  CRF(CTUS,t)                                  Capital Recovery Factor
  ANF(CTUS)                                    Annualization Factor
;

$gdxin %dir%CTUSModIN.gdx
$Load GDP, CRF, ANF, SourceProps, CarbonPriceTM
$Load FuelRegion, FuelReg, M8, REGION_OGSM, M8_to_REGION_OGSM, FuelRegion_2_FuelReg, E_RG, TERM_OGSM, N_RG
$Load PipeCapCostInit, TransportCostInit, MNUMYR, MNUMYR_t_emm, TERM_FuelRegion, plttype, N_TYPE, E_OR, N_OR
$load PipeCapCostInitOR, TransportCostInitOR
$gdxin

*Restore orginal data for reporting
$gdxin %dir%/input/CTSinput.gdx

Set         ProgramGoal_Att                    colset for ProgramGoal
            sink_att                           colset for SinkProps
            IGRP                               IGRPs for export
            Esource(source)                    Existing units IGRPs
;
Parameter   RetroBase                          from CTSinput to refresh SrcCapCost
            CapCostVar                         from CTSinput to refresh CaptureCost
            ProgramGoal(t_emm,PlantType,ProgramGoal_Att)    Program Goal Adjustments
            SinkProps(Inj,sink_att)            Sink properties
;

$Load RetroBase, CapCostVar, ProgramGoal_Att
$Load ProgramGoal, Esource
$gdxin
;

*-----------------------------------------------------------------------------------------------------------------------------

*** If ECP_Retrofits is on, then do not apply program goal adjustments for capture costs
If( RunDefn('ProgramGoals')= -1,
      ProgramGoal(t_emm,PlantType,ProgramGoal_Att) = 1 ;
);
If( RunDefn('ECP_Retrofits')= 1,
      ProgramGoal(t_emm,PlantType,'FixedAdjC') = 1 ;
      ProgramGoal(t_emm,PlantType,'VarAdjC') = 1  ;
);


*-----------------------------------------------------------------------------------------------------------------------------
* Now write the report
* II. create the CostWork components for capture, transportation, and injection

Parameter   CostWorkCap                         model costs for capture in $2102 per tonne
            CostWorkInj                         model costs for injection in $2012 per tonne
            CostWorkTran                        model costs for transportation in $2012 per tonne
            TransportPart                       Proportion of pipe flow assigned to a source

            InjAnn                               Injector Annuity Rewind
*** Add new calculations for subsidies based on IIJA ***
            TotPipeCapCost                      Total capital costs for transport by year before applying funds
            PipeFunds(t)                        Available funding each year for pipeline networks
                                                / 2025 600, 2026 600, 2027 300, 2028 300, 2029 300 /
            PipeFundUnused                      Cap the funding to the lesser of available funding and total capital cost (million $)
            PipeCCFund                          Apportion the maximum possible funding over all built pipes
            TotStorCapCost                      Total capital costs for storage by year before applying funds
            StorageFunds(t)                     Available funding each year for storage sites
                                                / 2025 500, 2026 500, 2027 500, 2028 500, 2029 500 /
            StorFundUnused                      Cap the funding to the lesser of available funding and total capital cost (million $)
            StorCCFund                          Apportion the maximum possible funding over all built storage sinks
            TotWellCapCost                      Total capital costs for wells by year before applying funds
            WellFunds(t)                        Available funding each year for well permits
                                                / 2025 11, 2026 11, 2027 11, 2028 11, 2029 11 /
            WellFundUnused                      Cap the funding to the lesser of available funding and total capital cost (million $)
            WellCCFund                          Apportion the maximum possible funding over all built wells
;
* PipeFunds(t) = 0;
TotPipeCapCost(t) = sum((FromNode,ToNode), sum(Diameter,BLDPIPE.l(FromNode,ToNode,Diameter,t)) * sum(Diameter,PipeCapCost(FromNode,ToNode,Diameter,t)));
PipeFundUnused = min(sum(t$(t.val ge 2025), TotPipeCapCost(t)), sum(t, PipeFunds(t) * GDP('2012') / GDP(t)));
PipeFundUnused = 0;
loop(t$(t.val ge 2025),
     PipeFundUnused = PipeFundUnused + PipeFunds(t) * GDP('2012') / GDP(t);
     PipeCCFund(FromNode,ToNode,t)$(sum(Diameter,BLDPIPE.l(FromNode,ToNode,Diameter,t))>0) =
            min(sum(Diameter,BLDPIPE.l(FromNode,ToNode,Diameter,t)) * sum(Diameter,PipeCapCost(FromNode,ToNode,Diameter,t)) / TotPipeCapCost(t) * PipeFundUnused,
                0.5 * sum(Diameter,BLDPIPE.l(FromNode,ToNode,Diameter,t)) * sum(Diameter,PipeCapCost(FromNode,ToNode,Diameter,t)));
     PipeFundUnused = max(0, PipeFundUnused - sum((FromNode,ToNode,Diameter), PipeCCFund(FromNode,ToNode,t)));
     );
PipeFundUnused = PipeFundUnused + max(0, sum(t$(t.val ge 2025), PipeFunds(t) * GDP('2012') / GDP(t) - TotPipeCapCost(t)));
* StorageFunds(t) = 0;
TotStorCapCost(t) = sum(InjSal, NEWSINK.l(InjSal,t) * SinkCapCost(InjSal,t));
StorFundUnused = min(sum(t$(t.val ge 2025), TotStorCapCost(t)), sum(t, StorageFunds(t) * GDP('2012') / GDP(t)));
StorFundUnused = 0;
loop(t$(t.val ge 2025),
     StorFundUnused = StorFundUnused + StorageFunds(t) * GDP('2012') / GDP(t);
     StorCCFund(InjSal,t)$NEWSINK.l(InjSal,t) = min(NEWSINK.l(InjSal,t) * SinkCapCost(InjSal,t) / TotStorCapCost(t) * StorFundUnused,
                0.5 * NEWSINK.l(InjSal,t) * SinkCapCost(InjSal,t));
     StorFundUnused = max(0, StorFundUnused - sum(InjSal, StorCCFund(InjSal,t)));
     );
StorFundUnused = StorFundUnused + max(0, sum(t$(t.val ge 2025), StorageFunds(t) * GDP('2012') / GDP(t) - TotStorCapCost(t)));
* WellFunds(t) = 0;
TotWellCapCost(t) = sum(InjSal, WELLNUM.l(InjSal,t) * WellCapCost(InjSal,t));
WellFundUnused = min(sum(t$(t.val ge 2025), TotWellCapCost(t)), sum(t, WellFunds(t) * GDP('2012') / GDP(t)));
WellFundUnused = 0;
loop(t$(t.val ge 2025),
     WellFundUnused = WellFundUnused + WellFunds(t) * GDP('2012') / GDP(t);
     WellCCFund(InjSal,t)$NEWSINK.l(InjSal,t) = min(WELLNUM.l(InjSal,t) * WellCapCost(InjSal,t) / TotWellCapCost(t) * WellFundUnused,
                0.5 * WELLNUM.l(InjSal,t) * WellCapCost(InjSal,t));
     WellFundUnused = max(0, WellFundUnused - sum(InjSal, WellCCFund(InjSal,t)));
     );
WellFundUnused = WellFundUnused + max(0, sum(t$(t.val ge 2025), WellFunds(t) * GDP('2012') / GDP(t) - TotWellCapCost(t)));

* Note, the injection and transport costs are being aggregated to Plant from source in the appropriate equations below.
* Calculates the annual payment to capital associated the capture site capital cost
* Note: ANF is an average discount rate over the horizon

* 1. capture costs
*     A. fixed costs
CostWorkCap(source,'Fixed')$(sum(t, CAPTURED.l(source,t)+zCap.l(source,t)) ne 0) =
  sum(t, NEWSOURCE.l(source,t) * SrcCapCost(source,t)) / sum(t, (CAPTURED.l(source,t)+zCap.l(source,t)) * PV("Capture",t));
*     B. variable costs
*        Assumes the CaptureCost has already been discounted to the begining of the planning horizon.  Thus these Capture-Var costs are the NPV of the variable costs
*        associated with a capture site over the period that it actually captured co2.
CostWorkCap(source,'Variable')$(sum(t, CAPTURED.l(source,t)+zCap.l(source,t)) ne 0) =
  sum(t, CaptureCost(source,t) * CAPTURED.l(source,t)+zCap.l(source,t)) /
    sum(t, (CAPTURED.l(source,t)+zCap.l(source,t)) * PV("Capture",t));

* 2. transportation costs
*     A. fixed costs (updated to include subsidies from IIJA)
CostWorkTran(FromNode,ToNode,'Fixed')$(sum((Diameter,t), PIPED.l(FromNode,ToNode,Diameter,t)) > 0) =
  sum(t, sum(Diameter,BLDPIPE.l(FromNode,ToNode,Diameter,t)) * sum(Diameter,PipeCapCost(FromNode,ToNode,Diameter,t)) - PipeCCFund(FromNode,ToNode,t)) /
    sum((Diameter,t), PIPED.l(FromNode,ToNode,Diameter,t) * PV("Transport",t));
*     B. variable costs
CostWorkTran(FromNode,ToNode,'Variable')$(sum((Diameter,t), PIPED.l(FromNode,ToNode,Diameter,t)) > 0) =
  sum((Diameter,t), TransportCost(FromNode,ToNode,Diameter,t) * PIPED.l(FromNode,ToNode,Diameter,t)) /
    sum((Diameter,t), PIPED.l(FromNode,ToNode,Diameter,t) * PV("Transport",t));

* 3. injection costs
*     A. fixed costs (updated to include subsidies from IIJA)
CostWorkInj(InjSal,'Fixed')$(sum(t, INJECTED.l(InjSal,t)) ne 0) =
  sum(t, (NEWSINK.l(InjSal,t)*SinkCapCost(InjSal,t) - StorCCFund(InjSal,t)) + WELLNUM.l(InjSal,t) * WellCapCost(InjSal,t) - WellCCFund(InjSal,t))
      / sum(t, INJECTED.l(InjSal,t) * PV("Storage",t));

InjAnn(InjSal)$(sum(t, INJECTED.l(InjSal,t)) ne 0) =
  sum(t, (NEWSINK.l(InjSal,t)*SinkCapCost(InjSal,t) - StorCCFund(InjSal,t) + WELLNUM.l(InjSal,t)*WellCapCost(InjSal,t) - WellCCFund(InjSal,t))
      /CRF("Storage",t)/PV("Storage",t));

*     B. variable costs
CostWorkInj(InjSal,'Variable')$(sum(t, INJECTED.l(InjSal,t)) ne 0) =
  sum(t, INJECTED.l(InjSal,t) * InjectCost(InjSal,t)) / sum(t, INJECTED.l(InjSal,t) * PV("Storage",t));
*     C. revenues
*        * saline storage revenue
CostWorkInj(InjSal,'RevenueStorage')$(sum(t, INJECTED.l(InjSal,t)) ne 0) =
  sum(t, INJECTED.l(InjSal,t) * CarbonPriceTM(t) * PV("Storage",t)) /
    sum(t, INJECTED.l(InjSal,t) * PV("Storage",t));

Set UnitCost_att   source attributes in unitcost
/SCAP
Total_Tonnes_Captured
NPV_Tonnes_Captured
Unit_Capture_Costs-Variable
Total_Capture_Costs-Fixed
Unit_Capture_Costs-Fixed
Unit_Transport_Costs-Variable
Total_Transport_Costs-Fixed
Unit_Transport_Costs-Fixed
Unit_Injection_Costs-Variable
Total_Injection_Costs-Fixed
Unit_Injection_Costs-Fixed
Total_Cost_Per_Tonne
Activation_Year
/;

Set CostOnly_att(UnitCost_att)  cost attributes in unitcost
/
Unit_Capture_Costs-Variable
Total_Capture_Costs-Fixed
Unit_Capture_Costs-Fixed
Unit_Transport_Costs-Variable
Total_Transport_Costs-Fixed
Unit_Transport_Costs-Fixed
Unit_Injection_Costs-Variable
Total_Injection_Costs-Fixed
Unit_Injection_Costs-Fixed
Total_Cost_Per_Tonne
/;


$ontext
Unit_Revenue-Storage
Unit_Revenue-Oil
Total_Revenue_Per_Tonne
Profit_Per_Tonne
$offtext

alias(source,source2);
alias(Inj,Inj2);
alias(Plant,Plant2);

Parameter UnitCostCap(source,UnitCost_att)       unit cost for all sources
          UnitCostInj(Inj,UnitCost_att)          unit cost for all injectors
          UnitCost(source,UnitCost_att)          unit cost for NEMS integrated
          UnitCostHkp(source,CostOnly_att)       unit hookup cost for all sources
;

* 1. Total Tonnes
UnitCostCap(source,'Total_Tonnes_Captured') = sum(t, CAPTURED.l(source,t)+zCap.l(source,t));
UnitCostInj(Inj,'Total_Tonnes_Captured') = sum(t, INJECTED.l(Inj,t));

* 2. NPV Tonnes

UnitCostCap(source,'NPV_Tonnes_Captured') = sum(t, (CAPTURED.l(source,t)+zCap.l(source,t)) * PV("Capture",t));
UnitCostInj(Inj(InjSal),'NPV_Tonnes_Captured') = sum(t, INJECTED.l(Inj,t) * PV("Storage",t));


* 3. SCAP
UnitCostCap(source,'SCAP')$(sum((t), CAPTURED.l(source,t)+zCap.l(source,t)) > 0) =
  sum(plant$unitplt(source,plant),SourceProps(source,plant,'SCAP'));


* 4. Capture Costs

*   A. Fixed Costs

UnitCostCap(source,'Unit_Capture_Costs-Fixed') = CostWorkCap(source,'Fixed');

UnitCostInj(Inj,'Unit_Capture_Costs-Fixed')$(sum((LinksUsed(Plant,ToNode,t)), InjFlow.l(Inj,Plant,ToNode,t)) > 0) =
  sum((plant,source,ToNode,INJ_TERMINALS,t)$(LinksUsed(plant,ToNode,t) and unitplt(source,plant) and InjFlow.l(INJ_TERMINALS,plant,ToNode,t) and INJ_TDIST(Inj,INJ_TERMINALS)),
    CostWorkCap(source,'Fixed') * InjFlow.l(INJ_TERMINALS,plant,ToNode,t) *
   ((CAPTURED.l(source,t)+zCap.l(source,t)) / sum(source2$unitplt(source2,plant),CAPTURED.l(source2,t)+zCap.l(source2,t))) *
    (INJECTED.l(Inj,t) / sum(Inj2$INJ_TDIST(Inj2,INJ_TERMINALS),INJECTED.l(Inj2,t))) * PV("Capture",t) ) /
     sum((t), INJECTED.l(Inj,t) * PV("Capture",t));

*   B. Variable Costs
*     * capture perspective carries directly from costwork

UnitCostCap(source,'Unit_Capture_Costs-Variable') = CostWorkCap(source,'Variable');

*     * allocate the flow weighted variable capture cost back to the injector
UnitCostInj(Inj,'Unit_Capture_Costs-Variable')$(sum((LinksUsed(Plant,ToNode,t)), InjFlow.l(Inj,Plant,ToNode,t)) > 0) =
  sum((plant,source,ToNode,INJ_TERMINALS,t)$(LinksUsed(plant,ToNode,t) and unitplt(source,plant) and InjFlow.l(INJ_TERMINALS,plant,ToNode,t) and INJ_TDIST(Inj,INJ_TERMINALS)),
   CostWorkCap(source,'Variable') * InjFlow.l(INJ_TERMINALS,plant,ToNode,t) *
   ((CAPTURED.l(source,t)+zCap.l(source,t)) / sum(source2$unitplt(source2,plant),CAPTURED.l(source2,t)+zCap.l(source2,t))) *
   (INJECTED.l(Inj,t) / sum(Inj2$INJ_TDIST(Inj2,INJ_TERMINALS),INJECTED.l(Inj2,t))) * PV("Capture",t) ) /
   sum((t), INJECTED.l(Inj,t) * PV("Capture",t));


* 5. Transport Costs
*   A. Fixed Costs

UnitCostCap(source,'Unit_Transport_Costs-Fixed')$(sum((t), CAPTURED.l(source,t)+zCap.l(source,t)) > 0) =
  sum((Plant,FromNode,ToNode,t)$(unitplt(source,plant) and PltFlow.l(Plant,FromNode,ToNode,t)),
  CostWorkTran(FromNode,ToNode,'Fixed') * PltFlow.l(Plant,FromNode,ToNode,t) *
  ((CAPTURED.l(source,t)+zCap.l(source,t)) / sum(source2$unitplt(source2,plant),CAPTURED.l(source2,t)+zCap.l(source2,t))) * PV("Transport",t)) /
   sum((t), (CAPTURED.l(source,t)+zCap.l(source,t)) * PV("Transport",t));

UnitCostInj(Inj,'Unit_Transport_Costs-Fixed')$(sum((LinksUsed(FromNode,ToNode,t)), InjFlow.l(Inj,FromNode,ToNode,t)) > 0) =
  sum((FromNode,ToNode,INJ_TERMINALS,t)$(INJ_TDIST(Inj,INJ_TERMINALS) and InjFlow.l(INJ_TERMINALS,FromNode,ToNode,t)),
  InjFlow.l(INJ_TERMINALS,FromNode,ToNode,t) * CostWorkTran(FromNode,ToNode,'Fixed') *
  (INJECTED.l(Inj,t) / sum(Inj2$INJ_TDIST(Inj2,INJ_TERMINALS),INJECTED.l(Inj2,t))) * PV("Transport",t) ) /
  sum((t), INJECTED.l(Inj,t) * PV("Transport",t));

*   B. Variable Costs

UnitCostCap(source,'Unit_Transport_Costs-Variable')$(sum(t, CAPTURED.l(source,t)+zCap.l(source,t)) > 0) =
  sum((Plant,FromNode,ToNode,t)$(unitplt(source,plant) and PltFlow.l(Plant,FromNode,ToNode,t)),
  CostWorkTran(FromNode,ToNode,'Variable') * PltFlow.l(Plant,FromNode,ToNode,t) *
  ((CAPTURED.l(source,t)+zCap.l(source,t)) / sum(source2$unitplt(source2,plant),CAPTURED.l(source2,t)+zCap.l(source2,t)) ) * PV("Transport",t) ) /
  sum((t), (CAPTURED.l(source,t)+zCap.l(source,t)) * PV("Transport",t));

UnitCostInj(Inj,'Unit_Transport_Costs-Variable')$(sum((LinksUsed(FromNode,ToNode,t)), InjFlow.l(Inj,FromNode,ToNode,t)) > 0) =
  sum((FromNode,ToNode,INJ_TERMINALS,t)$(INJ_TDIST(Inj,INJ_TERMINALS) and InjFlow.l(INJ_TERMINALS,FromNode,ToNode,t)),
  InjFlow.l(INJ_TERMINALS,FromNode,ToNode,t) * CostWorkTran(FromNode,ToNode,'Variable') *
  (INJECTED.l(Inj,t) / sum(Inj2$INJ_TDIST(Inj2,INJ_TERMINALS),INJECTED.l(Inj2,t))) * PV("Transport",t) ) /
  sum((t), INJECTED.l(Inj,t) * PV("Transport",t));

*      C. Transport Hookup Costs
UnitCostHkp(source,'Unit_Transport_Costs-Fixed')$(sum((t), CAPTURED.l(source,t)+zCap.l(source,t)) > 0) =
  sum((Plant,ToNode,t)$(unitplt(source,plant) and PltFlow.l(Plant,Plant,ToNode,t)),
  CostWorkTran(Plant,ToNode,'Fixed') * PltFlow.l(Plant,Plant,ToNode,t) *
  ((CAPTURED.l(source,t)+zCap.l(source,t)) / sum(source2$unitplt(source2,plant),CAPTURED.l(source2,t)+zCap.l(source2,t))) * PV("Transport",t)) /
   sum((t), (CAPTURED.l(source,t)+zCap.l(source,t)) * PV("Transport",t));
UnitCostHkp(source,'Unit_Transport_Costs-Variable')$(sum(t, CAPTURED.l(source,t)+zCap.l(source,t)) > 0) =
  sum((Plant,ToNode,t)$(unitplt(source,plant) and PltFlow.l(Plant,Plant,ToNode,t)),
  CostWorkTran(Plant,ToNode,'Variable') * PltFlow.l(Plant,Plant,ToNode,t) *
  ((CAPTURED.l(source,t)+zCap.l(source,t)) / sum(source2$unitplt(source2,plant),CAPTURED.l(source2,t)+zCap.l(source2,t)) ) * PV("Transport",t) ) /
  sum((t), (CAPTURED.l(source,t)+zCap.l(source,t)) * PV("Transport",t));
* 6. Injection Costs
*   A. Fixed Costs

UnitCostCap(source,'Unit_Injection_Costs-Fixed')$(sum(t, CAPTURED.l(source,t)) > 0 )
  = sum((Plant,FromNode,Inj,INJ_TERMINALS,t)$(unitplt(source,plant) and PltFlow.l(Plant,FromNode,INJ_TERMINALS,t) and INJ_TDIST(Inj,INJ_TERMINALS)),
  CostWorkInj(Inj,'Fixed') * PV("Capture",t) * PltFlow.l(Plant,FromNode,INJ_TERMINALS,t) *
  ((CAPTURED.l(source,t)+zCap.l(source,t)) / sum(source2$unitplt(source2,plant),CAPTURED.l(source2,t)+zCap.l(source2,t))) *
   (INJECTED.l(Inj,t) / sum(Inj2$INJ_TDIST(Inj2,INJ_TERMINALS),INJECTED.l(Inj2,t)))) /
  sum((t), (CAPTURED.l(source,t)+zCap.l(source,t)) * PV("Capture",t));

UnitCostInj(Inj,'Unit_Injection_Costs-Fixed')$(sum((t), INJECTED.l(Inj,t)) > 0 ) = CostWorkInj(Inj,'Fixed');

*   B. Variable Costs
*     * weighted injection variable cost based on flow values

UnitCostCap(source,'Unit_Injection_Costs-Variable')$(sum(t, CAPTURED.l(source,t)) > 0 )
  = sum((Plant,FromNode,Inj,INJ_TERMINALS,t)$(unitplt(source,plant) and PltFlow.l(Plant,FromNode,INJ_TERMINALS,t) and INJ_TDIST(Inj,INJ_TERMINALS)),
  CostWorkInj(Inj,'Variable') * PV("Capture",t) * PltFlow.l(Plant,FromNode,INJ_TERMINALS,t) *
  ((CAPTURED.l(source,t)+zCap.l(source,t)) / sum(source2$unitplt(source2,plant),CAPTURED.l(source2,t)+zCap.l(source2,t))) *
   (INJECTED.l(Inj,t) / sum(Inj2$INJ_TDIST(Inj2,INJ_TERMINALS),INJECTED.l(Inj2,t)))) /
  sum((t), (CAPTURED.l(source,t)+zCap.l(source,t)) * PV("Capture",t));

*      * injection unit cost passes right through from costwork

UnitCostInj(Inj,'Unit_Injection_Costs-Variable')$(sum((t), INJECTED.l(Inj,t)) > 0 ) = CostWorkInj(Inj,'Variable');

* 7. Total Costs Per Tonne

UnitCostCap(source,'Total_Cost_Per_Tonne') = UnitCostCap(source,'Unit_Capture_Costs-Fixed') + UnitCostCap(source,'Unit_Capture_Costs-Variable') +
                                         UnitCostCap(source,'Unit_Transport_Costs-Fixed') + UnitCostCap(source,'Unit_Transport_Costs-Variable') +
                                         UnitCostCap(source,'Unit_Injection_Costs-Fixed') + UnitCostCap(source,'Unit_Injection_Costs-Variable');

UnitCostInj(Inj,'Total_Cost_Per_Tonne') = UnitCostInj(Inj,'Unit_Capture_Costs-Fixed') + UnitCostInj(Inj,'Unit_Capture_Costs-Variable') +
                                          UnitCostInj(Inj,'Unit_Transport_Costs-Fixed') + UnitCostInj(Inj,'Unit_Transport_Costs-Variable') +
                                          UnitCostInj(Inj,'Unit_Injection_Costs-Fixed') + UnitCostInj(Inj,'Unit_Injection_Costs-Variable');

* 11. Activation Year
UnitCostCap(source,'Activation_Year') = sum(t, t.val * NEWSOURCE.l(source,t));
UnitCostInj(Inj(InjSal),'Activation_Year') = sum(t, t.val * NEWSINK.l(InjSal,t));
UnitCostInj(Inj(InjEOR),'Activation_Year') = sum(t, t.val * EOR_ON.l(InjEOR,t));

* 12. Non-unit costs in UnitCost
UnitCostCap(source,'Total_Capture_Costs-Fixed')$(sum((t), CAPTURED.l(source,t)+zCap.l(source,t)) > 0) = sum(t, NEWSOURCE.l(source,t) * SrcCapCost(source,t)/(PV("Capture",t)*CRF("Capture",t)));

alias (Plant,Plant2);
alias (t, t2);
Parameter PipeAnn(FromNode,ToNode) Pipe Annuity Payment per year;

* Updated to include subsidies from IIJA
PipeAnn(FromNode,ToNode) =  sum(t,(sum(Diameter,BLDPIPE.l(FromNode,ToNode,Diameter,t)) * sum(Diameter,PipeCapCost(FromNode,ToNode,Diameter,t))
                            - PipeCCFund(FromNode,ToNode,t))/CRF("Transport",t)/PV("Transport",t));

UnitCostCap(source,'Total_Transport_Costs-Fixed')$(sum(t, CAPTURED.l(source,t)+zCap.l(source,t)) > 0) =
  sum((Plant,FromNode,ToNode,t)$(unitplt(source,plant) and PltFlow.l(Plant,FromNode,ToNode,t)),
  PipeAnn(FromNode,ToNode) * PltFlow.l(Plant,FromNode,ToNode,t) *
  ((CAPTURED.l(source,t)+zCap.l(source,t)) / sum(source2$unitplt(source2,plant),CAPTURED.l(source2,t)+zCap.l(source2,t))) /
   (sum((Plant2,t2), PltFlow.l(Plant2,FromNode,ToNode,t2))));

UnitCostCap(source,'Total_Injection_Costs-Fixed')$(sum(t, CAPTURED.l(source,t)+zCap.l(source,t)) > 0) =
  sum((Plant,FromNode,Inj,INJ_TERMINALS,t)$(unitplt(source,plant) and PltFlow.l(Plant,FromNode,INJ_TERMINALS,t) and INJ_TDIST(Inj,INJ_TERMINALS) and (sum(t2, INJECTED.l(Inj,t2))>0) ),
    InjAnn(Inj) * PltFlow.l(Plant,FromNode,INJ_TERMINALS,t) *
    ((CAPTURED.l(source,t)+zCap.l(source,t)) / sum(source2$unitplt(source2,plant),CAPTURED.l(source2,t)+zCap.l(source2,t)) )*
    (INJECTED.l(Inj,t) / sum(Inj2$INJ_TDIST(Inj2,INJ_TERMINALS),INJECTED.l(Inj2,t)) ) /
      sum(t2, INJECTED.l(Inj,t2)) );

Parameter  TotalInj  Total tons injected over model horizon;

TotalInj(Inj) = sum(t,INJECTED.l(Inj,t));

* CO2 balance check
parameter CO2bal(t);

CO2bal(t) = sum(Inj, INJECTED.l(Inj,t)) - sum(source, CAPTURED.l(source,t)+zCap.l(source,t)) ;

* Fuel region to OGSM transport costs for EMM
Parameter
   FR_OR_TranCost(FuelRegion,M8,t_emm)         Unit CO2 transport costs from each fuel region to each OGSM region in 2007$ per ton
   FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm)         Unit CO2 transport costs by industry from each fuel region to each OGSM region in 2007$ per ton
   Prev_FR_OR_TranCost(FuelRegion,M8,t_emm)    Unit CO2 transport costs from each fuel region to each OGSM region in 2007$ per ton from previous cycle
   Prev_FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm)    Unit CO2 transport costs by industry from each fuel region to each OGSM region in 2007$ per ton from previous cycle
   OR_OR_TranCost(M8,M8,t_emm)                 Unit CO2 transport costs from each OGSM region to each OGSM region in 2007$ per ton
   OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm)                 Unit CO2 transport costs by industry from each OGSM region to each OGSM region in 2007$ per ton
   Prev_OR_OR_TranCost(M8,M8,t_emm)            Unit CO2 transport costs from each OGSM region to each OGSM region in 2007$ per ton from previous cycle
   Prev_OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm)            Unit CO2 transport costs by industry from each OGSM region to each OGSM region in 2007$ per ton from previous cycle
;

  alias (REGION_OGSM,REGION_OGSM2);
  alias (M8,M8_2);
* Initial cost matrix based on direct pipes only
FR_OR_TranCost(FuelRegion,M8,t_emm) =
  sum((FuelReg,REGION_OGSM)$(M8_to_REGION_OGSM(M8,REGION_OGSM) and FuelRegion_2_FuelReg(FuelRegion,FuelReg)),
    PipeCapCostInit(FuelReg,REGION_OGSM) +
    TransportCostInit(FuelReg,REGION_OGSM) ) * GDP('2007') / GDP('2012') ;
OR_OR_TranCost(M8,M8_2,t_emm) =
  sum((REGION_OGSM,REGION_OGSM2)$(M8_to_REGION_OGSM(M8,REGION_OGSM) and M8_to_REGION_OGSM(M8_2,REGION_OGSM2)),
    PipeCapCostInitOR(REGION_OGSM,REGION_OGSM2) +
    TransportCostInitOR(REGION_OGSM,REGION_OGSM2) ) * GDP('2007') / GDP('2012') ;
loop(SourceType,
    FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm) = FR_OR_TranCost(FuelRegion,M8,t_emm);
    OR_OR_SrcTrnCost(SourceType,M8,M8_2,t_emm) = OR_OR_TranCost(M8,M8_2,t_emm);
    );

$Ifi %ForceAllOn% == 1 $goto next8
$Ifi %ForceAllOn% == 2 $goto next8

  Parameter
     TranCostFlow(plant,INJ_TERMINALS,t)    Yearly flow between each origin-destination pair in MMT
     TranCostFixed(plant,INJ_TERMINALS)     Discounted unit fixed cost between each origin-destination pair in 2012$ per ton
     TranCostVar(plant,INJ_TERMINALS)       Discounted unit fixed cost between each origin-destination pair in 2012$ per ton
  ;

  TranCostFlow(plant,INJ_TERMINALS,t)$(sum((FromNode,ToNode)$(PltFlow.l(Plant,FromNode,ToNode,t) eq InjFlow.l(INJ_TERMINALS,FromNode,ToNode,t)
                                       and PltFlow.l(Plant,FromNode,ToNode,t)),1)>0) =
    sum((FromNode,ToNode)$(PltFlow.l(Plant,FromNode,ToNode,t) eq InjFlow.l(INJ_TERMINALS,FromNode,ToNode,t)
                                       and PltFlow.l(Plant,FromNode,ToNode,t)),
      PltFlow.l(Plant,FromNode,ToNode,t) ) /
    sum((FromNode,ToNode)$(PltFlow.l(Plant,FromNode,ToNode,t) eq InjFlow.l(INJ_TERMINALS,FromNode,ToNode,t)
                                       and PltFlow.l(Plant,FromNode,ToNode,t)),
      1 );

  TranCostFixed(plant,INJ_TERMINALS)$(sum(t, TranCostFlow(plant,INJ_TERMINALS,t) * PV("Transport",t) )>0) =
    sum((FromNode,ToNode,t),
      CostWorkTran(FromNode,ToNode,'Fixed') * PltFlow.l(Plant,FromNode,ToNode,t) * PV("Transport",t) ) /
    sum(t, TranCostFlow(plant,INJ_TERMINALS,t) * PV("Transport",t) );

  TranCostVar(plant,INJ_TERMINALS)$(sum(t, TranCostFlow(plant,INJ_TERMINALS,t) * PV("Transport",t) )>0) =
    sum((FromNode,ToNode,t),
      CostWorkTran(FromNode,ToNode,'Variable') * PltFlow.l(Plant,FromNode,ToNode,t) * PV("Transport",t) ) /
    sum(t, TranCostFlow(plant,INJ_TERMINALS,t) * PV("Transport",t) );

  Parameter
    TotalFlow
    TotalPltFlow(SourceType)  Total flow by industry type
    AvgTranCost(FuelReg,REGION_OGSM)
    PltTranCost(FuelReg,REGION_OGSM,SourceType) Average cost by industry type
    OGSMTranCost(REGION_OGSM,REGION_OGSM)
    SrcTranCost(REGION_OGSM,REGION_OGSM,SourceType) Average cost by industry type
  ;

  set PlantFuelReg(plant,FuelReg)   Plant to Fuel Region mapping
      PlantOGSMReg(plant,REGION_OGSM)   Plant to Fuel Region mapping
  ;
  PlantFuelReg(plant,FuelReg)$(sum(source$(E_RG(source,FuelReg) and unitplt(source,plant)), 1)>0) = yes ;
  PlantFuelReg(plant,FuelReg)$(sum(source$(N_RG(source)=FuelReg.val and unitplt(source,plant)), 1)>0) = yes ;
  PlantOGSMReg(plant,REGION_OGSM)$(sum(source$(E_OR(source,REGION_OGSM) and unitplt(source,plant)), 1)>0) = yes ;
  PlantOGSMReg(plant,REGION_OGSM)$(sum(source$(N_OR(source)=REGION_OGSM.val and unitplt(source,plant)), 1)>0) = yes ;

  AvgTranCost(FuelReg,REGION_OGSM) = 0 ;
  loop((FuelReg,REGION_OGSM),

    TotalFlow = sum((plant,INJ_TERMINALS,t)$(PlantFuelReg(plant,FuelReg) and TERM_OGSM(INJ_TERMINALS,REGION_OGSM)),
                 TranCostFlow(plant,INJ_TERMINALS,t) * PV("Transport",t)) ;

    If (TotalFlow > 0,
      loop((plant,INJ_TERMINALS)$(PlantFuelReg(plant,FuelReg) and TERM_OGSM(INJ_TERMINALS,REGION_OGSM) and (sum(t,TranCostFlow(plant,INJ_TERMINALS,t))>0) and TotalFlow>0),

        AvgTranCost(FuelReg,REGION_OGSM) = AvgTranCost(FuelReg,REGION_OGSM) +
          (TranCostFixed(plant,INJ_TERMINALS)+TranCostVar(plant,INJ_TERMINALS)) * sum(t,TranCostFlow(plant,INJ_TERMINALS,t)*PV("Transport",t)) / TotalFlow ;

      );
    else
      AvgTranCost(FuelReg,REGION_OGSM) = 99 * (GDP('2012') / GDP('2007')) ;
    );
  );

  PltTranCost(FuelReg,REGION_OGSM,SourceType) = 0;
  loop((FuelReg,REGION_OGSM,SourceType),
    TotalPltFlow(SourceType) = sum((plant,INJ_TERMINALS,t)$(PlantFuelReg(plant,FuelReg) and TERM_OGSM(INJ_TERMINALS,REGION_OGSM) and plttype(plant,SourceType)),
                 TranCostFlow(plant,INJ_TERMINALS,t) * PV("Transport",t)) ;
    If (TotalPltFlow(SourceType) > 0,
      loop((plant,INJ_TERMINALS)$(PlantFuelReg(plant,FuelReg) and TERM_OGSM(INJ_TERMINALS,REGION_OGSM) and (sum(t,TranCostFlow(plant,INJ_TERMINALS,t))>0)
      and TotalPltFlow(SourceType)>0 and plttype(plant,SourceType)),
        PltTranCost(FuelReg,REGION_OGSM,SourceType) = PltTranCost(FuelReg,REGION_OGSM,SourceType) +
          (TranCostFixed(plant,INJ_TERMINALS)+TranCostVar(plant,INJ_TERMINALS)) * sum(t,TranCostFlow(plant,INJ_TERMINALS,t)*PV("Transport",t)) / TotalPltFlow(SourceType) ;
      );
    else
      PltTranCost(FuelReg,REGION_OGSM,SourceType) = 0 * (GDP('2012') / GDP('2007')) ;
    );
  );
  OGSMTranCost(REGION_OGSM,REGION_OGSM) = 0 ;
  loop((REGION_OGSM,REGION_OGSM2),
    TotalFlow = sum((plant,INJ_TERMINALS,t)$(PlantOGSMReg(plant,REGION_OGSM) and TERM_OGSM(INJ_TERMINALS,REGION_OGSM2)),
                 TranCostFlow(plant,INJ_TERMINALS,t) * PV("Transport",t)) ;
    If (TotalFlow > 0,
      loop((plant,INJ_TERMINALS)$(PlantOGSMReg(plant,REGION_OGSM) and TERM_OGSM(INJ_TERMINALS,REGION_OGSM2) and (sum(t,TranCostFlow(plant,INJ_TERMINALS,t))>0) and TotalFlow>0),
        OGSMTranCost(REGION_OGSM,REGION_OGSM2) = OGSMTranCost(REGION_OGSM,REGION_OGSM2) +
          (TranCostFixed(plant,INJ_TERMINALS)+TranCostVar(plant,INJ_TERMINALS)) * sum(t,TranCostFlow(plant,INJ_TERMINALS,t)*PV("Transport",t)) / TotalFlow ;
      );
    else
      OGSMTranCost(REGION_OGSM,REGION_OGSM2) = 999 * (GDP('2012') / GDP('2007')) ;
    );
  );
  SrcTranCost(REGION_OGSM,REGION_OGSM,SourceType) = 0 ;
  loop((REGION_OGSM,REGION_OGSM2,SourceType),
    TotalPltFlow(SourceType) = sum((plant,INJ_TERMINALS,t)$(PlantOGSMReg(plant,REGION_OGSM) and TERM_OGSM(INJ_TERMINALS,REGION_OGSM2) and plttype(plant,SourceType)),
                 TranCostFlow(plant,INJ_TERMINALS,t) * PV("Transport",t)) ;
    If (TotalPltFlow(SourceType) > 0,
      loop((plant,INJ_TERMINALS)$(PlantOGSMReg(plant,REGION_OGSM) and TERM_OGSM(INJ_TERMINALS,REGION_OGSM2) and (sum(t,TranCostFlow(plant,INJ_TERMINALS,t))>0)),
        SrcTranCost(REGION_OGSM,REGION_OGSM2,SourceType) = SrcTranCost(REGION_OGSM,REGION_OGSM2,SourceType) +
          (TranCostFixed(plant,INJ_TERMINALS)+TranCostVar(plant,INJ_TERMINALS)) * sum(t,TranCostFlow(plant,INJ_TERMINALS,t)*PV("Transport",t)) / TotalPltFlow(SourceType) ;
      );
    else
      SrcTranCost(REGION_OGSM,REGION_OGSM2,SourceType) = 0 * (GDP('2012') / GDP('2007')) ;
    );
  );
  FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm) =
    sum((FuelReg,REGION_OGSM)$(M8_to_REGION_OGSM(M8,REGION_OGSM) and FuelRegion_2_FuelReg(FuelRegion,FuelReg)),
      PltTranCost(FuelReg,REGION_OGSM,SourceType) * GDP('2007') / GDP('2012') );
** End new calculations by industry type **
  FR_OR_TranCost(FuelRegion,M8,t_emm) =
    sum((FuelReg,REGION_OGSM)$(M8_to_REGION_OGSM(M8,REGION_OGSM) and FuelRegion_2_FuelReg(FuelRegion,FuelReg)),
      AvgTranCost(FuelReg,REGION_OGSM) * GDP('2007') / GDP('2012') );

  OR_OR_TranCost(M8,M8_2,t_emm) =
    sum((REGION_OGSM,REGION_OGSM2)$(M8_to_REGION_OGSM(M8,REGION_OGSM) and M8_to_REGION_OGSM(M8_2,REGION_OGSM2)),
      OGSMTranCost(REGION_OGSM,REGION_OGSM2) * GDP('2007') / GDP('2012') );
  OR_OR_SrcTrnCost(SourceType,M8,M8_2,t_emm) =
    sum((REGION_OGSM,REGION_OGSM2)$(M8_to_REGION_OGSM(M8,REGION_OGSM) and M8_to_REGION_OGSM(M8_2,REGION_OGSM2)),
      SrcTranCost(REGION_OGSM,REGION_OGSM2,SourceType) * GDP('2007') / GDP('2012') );
$label next8


* Set UnitCost equal to UnitCostCap for only power sources
UnitCost(Esource,UnitCost_att) = UnitCostCap(Esource,UnitCost_att) ;
UnitCost(N_IGRP,UnitCost_att) = UnitCostCap(N_IGRP,UnitCost_att) ;
UnitCost(HMM_Source,UnitCost_att) = UnitCostCap(HMM_Source,UnitCost_att) ;
UnitCost(Cem_Source_exs,UnitCost_att) = UnitCostCap(Cem_Source_exs,UnitCost_att) ;
UnitCost(Cem_Source_new,UnitCost_att) = UnitCostCap(Cem_Source_new,UnitCost_att) ;

* Convert cost entries to 2007$
UnitCost(Esource,CostOnly_att) = UnitCost(Esource,CostOnly_att) * GDP('2007') / GDP('2012') ;
UnitCost(N_IGRP,CostOnly_att)  = UnitCost(N_IGRP,CostOnly_att) * GDP('2007') / GDP('2012') ;
UnitCost(HMM_Source,CostOnly_att)  = UnitCost(HMM_Source,CostOnly_att) * GDP('2007') / GDP('2012') ;
UnitCost(Cem_Source_exs,CostOnly_att)  = UnitCost(Cem_Source_exs,CostOnly_att) * GDP('2007') / GDP('2012') ;
UnitCost(Cem_Source_new,CostOnly_att)  = UnitCost(Cem_Source_new,CostOnly_att) * GDP('2007') / GDP('2012') ;

* Convert hookup costs to 2007$
UnitCostHkp(Esource,CostOnly_att) = UnitCostHkp(Esource,CostOnly_att) * GDP('2007') / GDP('2012') ;
UnitCostHkp(N_IGRP,CostOnly_att)  = UnitCostHkp(N_IGRP,CostOnly_att) * GDP('2007') / GDP('2012') ;
UnitCostHkp(HMM_Source,CostOnly_att)  = UnitCostHkp(HMM_Source,CostOnly_att) * GDP('2007') / GDP('2012') ;
UnitCostHkp(Cem_Source_exs,CostOnly_att)  = UnitCostHkp(Cem_Source_exs,CostOnly_att) * GDP('2007') / GDP('2012') ;
UnitCostHkp(Cem_Source_new,CostOnly_att)  = UnitCostHkp(Cem_Source_new,CostOnly_att) * GDP('2007') / GDP('2012') ;
* Calculate weighted-average TnS costs in 87$ by fuel region
parameter
  tempTons(FuelRegion)
  tempCost(FuelRegion)
  tempTonsSrc(FuelRegion,SourceType)
  tempCostSrc(FuelRegion,SourceType)
  TnS_Costs(FuelRegion)         Weighted-average total transport and storage costs in 87$ per ton
  Src_TnS_Costs(FuelRegion,SourceType)     Weighted-average total transport and storage costs by industry in 87$ per ton
  THCCS(FuelRegion)             Weighted-average transport hookup costs in 87$ per ton
  TFCCS(FuelRegion)             Weighted-average transport fixed costs in 87$ per ton
  TVCCS(FuelRegion)             Weighted-average transport variable costs in 87$ per ton
  IFCCS(FuelRegion)             Weighted-average injection fixed costs in 87$ per ton
  IVCCS(FuelRegion)             Weighted-average injection variable costs in 87$ per ton
  Inject_EOR(M8,MNUMYR)         CO2 injected into EOR by OGSM region and year in MMT CO2
  Inject_SAL(FuelRegion,MNUMYR) CO2 injected into saline by OGSM region and year in MMT CO2
  Prev_TnS_Costs(FuelRegion)         Weighted-average total transport and storage costs in 87$ per ton
  Prev_Src_TnS_Costs(FuelRegion,SourceType)     Weighted-average total transport and storage costs by industry in 87$ per ton
  Wt                            /1.0/
;

tempCost(FuelRegion) = 0 ;
tempTons(FuelRegion) = 0 ;
loop(FuelRegion_2_FuelReg(FuelRegion,FuelReg),

  tempTons(FuelRegion) =
    sum(N_IGRP$(FuelReg.val = N_RG(N_IGRP)), UnitCost(N_IGRP,'NPV_Tonnes_Captured') ) +
    sum(HMM_Source$(FuelReg.val = N_RG(HMM_Source)), UnitCost(HMM_Source,'NPV_Tonnes_Captured') ) +
    sum(Cem_Source_exs$(FuelReg.val = N_RG(Cem_Source_exs)), UnitCost(Cem_Source_exs,'NPV_Tonnes_Captured') ) +
    sum(Cem_Source_new$(FuelReg.val = N_RG(Cem_Source_new)), UnitCost(Cem_Source_new,'NPV_Tonnes_Captured') ) +
    sum(Esource$E_RG(Esource,FuelReg), UnitCost(Esource,'NPV_Tonnes_Captured') )
     ;

* Transport hookup costs
  tempCost(FuelRegion) =
    sum(N_IGRP$(FuelReg.val = N_RG(N_IGRP)), UnitCost(N_IGRP,'NPV_Tonnes_Captured') *
      (UnitCostHkp(N_IGRP,'Unit_Transport_Costs-Variable') + UnitCostHkp(N_IGRP,'Unit_Transport_Costs-Fixed') ) ) +
    sum(HMM_Source$(FuelReg.val = N_RG(HMM_Source)), UnitCost(HMM_Source,'NPV_Tonnes_Captured') *
      (UnitCostHkp(HMM_Source,'Unit_Transport_Costs-Variable') + UnitCostHkp(HMM_Source,'Unit_Transport_Costs-Fixed') ) ) +
    sum(Cem_Source_exs$(FuelReg.val = N_RG(Cem_Source_exs)), UnitCost(Cem_Source_exs,'NPV_Tonnes_Captured') *
      (UnitCostHkp(Cem_Source_exs,'Unit_Transport_Costs-Variable') + UnitCostHkp(Cem_Source_exs,'Unit_Transport_Costs-Fixed') ) ) +
    sum(Cem_Source_new$(FuelReg.val = N_RG(Cem_Source_new)), UnitCost(Cem_Source_new,'NPV_Tonnes_Captured') *
      (UnitCostHkp(Cem_Source_new,'Unit_Transport_Costs-Variable') + UnitCostHkp(Cem_Source_new,'Unit_Transport_Costs-Fixed') ) ) +
    sum(Esource$E_RG(Esource,FuelReg), UnitCost(Esource,'NPV_Tonnes_Captured') *
      (UnitCostHkp(Esource,'Unit_Transport_Costs-Variable') + UnitCostHkp(Esource,'Unit_Transport_Costs-Fixed') ) ) ;

  THCCS(FuelRegion)                          = 0 ;
  THCCS(FuelRegion)$(tempTons(FuelRegion)>0) = tempCost(FuelRegion) / tempTons(FuelRegion) ;

* Transport fixed costs
  tempCost(FuelRegion) =
    sum(N_IGRP$(FuelReg.val = N_RG(N_IGRP)),
      UnitCost(N_IGRP,'NPV_Tonnes_Captured') * UnitCost(N_IGRP,'Unit_Transport_Costs-Fixed') ) +
    sum(HMM_Source$(FuelReg.val = N_RG(HMM_Source)),
      UnitCost(HMM_Source,'NPV_Tonnes_Captured') * UnitCost(HMM_Source,'Unit_Transport_Costs-Fixed') ) +
    sum(Cem_Source_exs$(FuelReg.val = N_RG(Cem_Source_exs)),
      UnitCost(Cem_Source_exs,'NPV_Tonnes_Captured') * UnitCost(Cem_Source_exs,'Unit_Transport_Costs-Fixed') ) +
    sum(Cem_Source_new$(FuelReg.val = N_RG(Cem_Source_new)),
      UnitCost(Cem_Source_new,'NPV_Tonnes_Captured') * UnitCost(Cem_Source_new,'Unit_Transport_Costs-Fixed') ) +
    sum(Esource$E_RG(Esource,FuelReg),
      UnitCost(Esource,'NPV_Tonnes_Captured') * UnitCost(Esource,'Unit_Transport_Costs-Fixed') ) ;

  TFCCS(FuelRegion)                          = 0 ;
  TFCCS(FuelRegion)$(tempTons(FuelRegion)>0) = tempCost(FuelRegion) / tempTons(FuelRegion) ;

* Transport variable costs
  tempCost(FuelRegion) =
    sum(N_IGRP$(FuelReg.val = N_RG(N_IGRP)),
      UnitCost(N_IGRP,'NPV_Tonnes_Captured') * UnitCost(N_IGRP,'Unit_Transport_Costs-Variable') ) +
    sum(HMM_Source$(FuelReg.val = N_RG(HMM_Source)),
      UnitCost(HMM_Source,'NPV_Tonnes_Captured') * UnitCost(HMM_Source,'Unit_Transport_Costs-Variable') ) +
    sum(Cem_Source_exs$(FuelReg.val = N_RG(Cem_Source_exs)),
      UnitCost(Cem_Source_exs,'NPV_Tonnes_Captured') * UnitCost(Cem_Source_exs,'Unit_Transport_Costs-Variable') ) +
    sum(Cem_Source_new$(FuelReg.val = N_RG(Cem_Source_new)),
      UnitCost(Cem_Source_new,'NPV_Tonnes_Captured') * UnitCost(Cem_Source_new,'Unit_Transport_Costs-Variable') ) +
    sum(Esource$E_RG(Esource,FuelReg),
      UnitCost(Esource,'NPV_Tonnes_Captured') * UnitCost(Esource,'Unit_Transport_Costs-Variable') ) ;

  TVCCS(FuelRegion)                          = 0 ;
  TVCCS(FuelRegion)$(tempTons(FuelRegion)>0) = tempCost(FuelRegion) / tempTons(FuelRegion) ;

* Injection fixed costs
  tempCost(FuelRegion) =
    sum(N_IGRP$(FuelReg.val = N_RG(N_IGRP)),
      UnitCost(N_IGRP,'NPV_Tonnes_Captured') * UnitCost(N_IGRP,'Unit_Injection_Costs-Fixed') ) +
    sum(HMM_Source$(FuelReg.val = N_RG(HMM_Source)),
      UnitCost(HMM_Source,'NPV_Tonnes_Captured') * UnitCost(HMM_Source,'Unit_Injection_Costs-Fixed') ) +
    sum(Cem_Source_exs$(FuelReg.val = N_RG(Cem_Source_exs)),
      UnitCost(Cem_Source_exs,'NPV_Tonnes_Captured') * UnitCost(Cem_Source_exs,'Unit_Injection_Costs-Fixed') ) +
    sum(Cem_Source_new$(FuelReg.val = N_RG(Cem_Source_new)),
      UnitCost(Cem_Source_new,'NPV_Tonnes_Captured') * UnitCost(Cem_Source_new,'Unit_Injection_Costs-Fixed') ) +
    sum(Esource$E_RG(Esource,FuelReg),
      UnitCost(Esource,'NPV_Tonnes_Captured') * UnitCost(Esource,'Unit_Injection_Costs-Fixed') ) ;

  IFCCS(FuelRegion)                          = 0 ;
  IFCCS(FuelRegion)$(tempTons(FuelRegion)>0) = tempCost(FuelRegion) / tempTons(FuelRegion) ;

*       Injection costs $/ton IVCCS(fuel region, year)
  tempCost(FuelRegion) =
    sum(N_IGRP$(FuelReg.val = N_RG(N_IGRP)),
      UnitCost(N_IGRP,'NPV_Tonnes_Captured') * UnitCost(N_IGRP,'Unit_Injection_Costs-Variable') ) +
    sum(HMM_Source$(FuelReg.val = N_RG(HMM_Source)),
      UnitCost(HMM_Source,'NPV_Tonnes_Captured') * UnitCost(HMM_Source,'Unit_Injection_Costs-Variable') ) +
    sum(Cem_Source_exs$(FuelReg.val = N_RG(Cem_Source_exs)),
      UnitCost(Cem_Source_exs,'NPV_Tonnes_Captured') * UnitCost(Cem_Source_exs,'Unit_Injection_Costs-Variable') ) +
    sum(Cem_Source_new$(FuelReg.val = N_RG(Cem_Source_new)),
      UnitCost(Cem_Source_new,'NPV_Tonnes_Captured') * UnitCost(Cem_Source_new,'Unit_Injection_Costs-Variable') ) +
    sum(Esource$E_RG(Esource,FuelReg),
      UnitCost(Esource,'NPV_Tonnes_Captured') * UnitCost(Esource,'Unit_Injection_Costs-Variable') ) ;

  IVCCS(FuelRegion)                          = 0 ;
  IVCCS(FuelRegion)$(tempTons(FuelRegion)>0) = tempCost(FuelRegion) / tempTons(FuelRegion) ;

* TnS_Costs
  tempCost(FuelRegion) =
    sum(N_IGRP$(FuelReg.val = N_RG(N_IGRP)), UnitCost(N_IGRP,'NPV_Tonnes_Captured') *
      (UnitCost(N_IGRP,'Unit_Transport_Costs-Variable') + UnitCost(N_IGRP,'Unit_Injection_Costs-Variable') +
       UnitCost(N_IGRP,'Unit_Transport_Costs-Fixed') + UnitCost(N_IGRP,'Unit_Injection_Costs-Fixed') ) ) +
    sum(HMM_Source$(FuelReg.val = N_RG(HMM_Source)), UnitCost(HMM_Source,'NPV_Tonnes_Captured') *
      (UnitCost(HMM_Source,'Unit_Transport_Costs-Variable') + UnitCost(HMM_Source,'Unit_Injection_Costs-Variable') +
       UnitCost(HMM_Source,'Unit_Transport_Costs-Fixed') + UnitCost(HMM_Source,'Unit_Injection_Costs-Fixed') ) ) +
    sum(Cem_Source_exs$(FuelReg.val = N_RG(Cem_Source_exs)), UnitCost(Cem_Source_exs,'NPV_Tonnes_Captured') *
      (UnitCost(Cem_Source_exs,'Unit_Transport_Costs-Variable') + UnitCost(Cem_Source_exs,'Unit_Injection_Costs-Variable') +
       UnitCost(Cem_Source_exs,'Unit_Transport_Costs-Fixed') + UnitCost(Cem_Source_exs,'Unit_Injection_Costs-Fixed') ) ) +
    sum(Cem_Source_new$(FuelReg.val = N_RG(Cem_Source_new)), UnitCost(Cem_Source_new,'NPV_Tonnes_Captured') *
      (UnitCost(Cem_Source_new,'Unit_Transport_Costs-Variable') + UnitCost(Cem_Source_new,'Unit_Injection_Costs-Variable') +
       UnitCost(Cem_Source_new,'Unit_Transport_Costs-Fixed') + UnitCost(Cem_Source_new,'Unit_Injection_Costs-Fixed') ) ) +
    sum(Esource$E_RG(Esource,FuelReg), UnitCost(Esource,'NPV_Tonnes_Captured') *
      (UnitCost(Esource,'Unit_Transport_Costs-Variable') + UnitCost(Esource,'Unit_Injection_Costs-Variable') +
       UnitCost(Esource,'Unit_Transport_Costs-Fixed') + UnitCost(Esource,'Unit_Injection_Costs-Fixed') ) ) ;
  TnS_Costs(FuelRegion)                          = 0 ;
  TnS_Costs(FuelRegion)$(tempTons(FuelRegion)>0) = tempCost(FuelRegion) / tempTons(FuelRegion) ;
);
***** New TnS Costs by Industry Source *****
tempCostSrc(FuelRegion,SourceType) = 0 ;
tempTonsSrc(FuelRegion,SourceType) = 0 ;
loop((FuelRegion_2_FuelReg(FuelRegion,FuelReg),SourceType),
  tempTonsSrc(FuelRegion,SourceType) =
    sum(N_IGRP$(FuelReg.val = N_RG(N_IGRP) and N_TYPE(N_IGRP,SourceType)), UnitCost(N_IGRP,'NPV_Tonnes_Captured') ) +
    sum(HMM_Source$(FuelReg.val = N_RG(HMM_Source) and N_TYPE(HMM_Source,SourceType)), UnitCost(HMM_Source,'NPV_Tonnes_Captured') ) +
    sum(Cem_Source_exs$(FuelReg.val = N_RG(Cem_Source_exs) and N_TYPE(Cem_Source_exs,SourceType)), UnitCost(Cem_Source_exs,'NPV_Tonnes_Captured') ) +
    sum(Cem_Source_new$(FuelReg.val = N_RG(Cem_Source_new) and N_TYPE(Cem_Source_new,SourceType)), UnitCost(Cem_Source_new,'NPV_Tonnes_Captured') ) +
    sum(Esource$(E_RG(Esource,FuelReg) and UnitType(Esource,SourceType)), UnitCost(Esource,'NPV_Tonnes_Captured') ) ;
* TnS_Costs by Source
  tempCostSrc(FuelRegion,SourceType) =
    sum(N_IGRP$(FuelReg.val = N_RG(N_IGRP) and N_TYPE(N_IGRP,SourceType)), UnitCost(N_IGRP,'NPV_Tonnes_Captured') *
      (UnitCost(N_IGRP,'Unit_Transport_Costs-Variable') + UnitCost(N_IGRP,'Unit_Injection_Costs-Variable') +
       UnitCost(N_IGRP,'Unit_Transport_Costs-Fixed') + UnitCost(N_IGRP,'Unit_Injection_Costs-Fixed') ) ) +
    sum(HMM_Source$(FuelReg.val = N_RG(HMM_Source) and N_TYPE(HMM_Source,SourceType)), UnitCost(HMM_Source,'NPV_Tonnes_Captured') *
      (UnitCost(HMM_Source,'Unit_Transport_Costs-Variable') + UnitCost(HMM_Source,'Unit_Injection_Costs-Variable') +
       UnitCost(HMM_Source,'Unit_Transport_Costs-Fixed') + UnitCost(HMM_Source,'Unit_Injection_Costs-Fixed') ) ) +
    sum(Cem_Source_exs$(FuelReg.val = N_RG(Cem_Source_exs) and N_TYPE(Cem_Source_exs,SourceType)), UnitCost(Cem_Source_exs,'NPV_Tonnes_Captured') *
      (UnitCost(Cem_Source_exs,'Unit_Transport_Costs-Variable') + UnitCost(Cem_Source_exs,'Unit_Injection_Costs-Variable') +
       UnitCost(Cem_Source_exs,'Unit_Transport_Costs-Fixed') + UnitCost(Cem_Source_exs,'Unit_Injection_Costs-Fixed') ) ) +
    sum(Cem_Source_new$(FuelReg.val = N_RG(Cem_Source_new) and N_TYPE(Cem_Source_new,SourceType)), UnitCost(Cem_Source_new,'NPV_Tonnes_Captured') *
      (UnitCost(Cem_Source_new,'Unit_Transport_Costs-Variable') + UnitCost(Cem_Source_new,'Unit_Injection_Costs-Variable') +
       UnitCost(Cem_Source_new,'Unit_Transport_Costs-Fixed') + UnitCost(Cem_Source_new,'Unit_Injection_Costs-Fixed') ) ) +
    sum(Esource$(E_RG(Esource,FuelReg) and UnitType(Esource,SourceType)), UnitCost(Esource,'NPV_Tonnes_Captured') *
      (UnitCost(Esource,'Unit_Transport_Costs-Variable') + UnitCost(Esource,'Unit_Injection_Costs-Variable') +
       UnitCost(Esource,'Unit_Transport_Costs-Fixed') + UnitCost(Esource,'Unit_Injection_Costs-Fixed') ) ) ;
  Src_TnS_Costs(FuelRegion,SourceType)                          = 0 * GDP('2007') ;
  Src_TnS_Costs(FuelRegion,SourceType)$(tempTonsSrc(FuelRegion,SourceType)>0)
            = tempCostSrc(FuelRegion,SourceType) / tempTonsSrc(FuelRegion,SourceType) ;
);
* Convert to 87$
TnS_Costs(FuelRegion) = TnS_Costs(FuelRegion) / GDP('2007') ;
THCCS(FuelRegion)     = THCCS(FuelRegion) / GDP('2007') ;
TFCCS(FuelRegion)     = TFCCS(FuelRegion) / GDP('2007') ;
TVCCS(FuelRegion)     = TVCCS(FuelRegion) / GDP('2007') ;
IFCCS(FuelRegion)     = IFCCS(FuelRegion) / GDP('2007') ;
IVCCS(FuelRegion)     = IVCCS(FuelRegion) / GDP('2007') ;
Src_TnS_Costs(FuelRegion,SourceType) = Src_TnS_Costs(FuelRegion,SourceType) / GDP('2007') ;
$if not exist CTSSoln.gdx $goto SkipCTS
$gdxin CTSSoln.gdx
$load Prev_TnS_Costs=TnS_Costs Prev_Src_TnS_Costs=Src_TnS_Costs
$load Prev_FR_OR_TranCost=FR_OR_TranCost Prev_FR_OR_SrcTrnCost=FR_OR_SrcTrnCost
$load Prev_OR_OR_TranCost=OR_OR_TranCost Prev_OR_OR_SrcTrnCost=OR_OR_SrcTrnCost
$gdxin
*TnS_Costs(FuelRegion)$(not TnS_Costs(FuelRegion)) = Prev_TnS_Costs(FuelRegion);
*TnS_Costs(FuelRegion)$TnS_Costs(FuelRegion) = Wt * min(300,TnS_Costs(FuelRegion)) + (1-Wt) * Prev_TnS_Costs(FuelRegion);
Src_TnS_Costs(FuelRegion,SourceType)$(not Src_TnS_Costs(FuelRegion,SourceType)) = Prev_Src_TnS_Costs(FuelRegion,SourceType);
Src_TnS_Costs(FuelRegion,SourceType)$Src_TnS_Costs(FuelRegion,SourceType) = Wt * min(300,Src_TnS_Costs(FuelRegion,SourceType)) + (1-Wt) * Prev_Src_TnS_Costs(FuelRegion,SourceType);
*FR_OR_TranCost(FuelRegion,M8,t_emm)$(FR_OR_TranCost(FuelRegion,M8,t_emm) ne 99) = Wt * min(150,FR_OR_TranCost(FuelRegion,M8,t_emm)) + (1-Wt) * Prev_FR_OR_TranCost(FuelRegion,M8,t_emm);
*FR_OR_TranCost(FuelRegion,M8,t_emm)$(FR_OR_TranCost(FuelRegion,M8,t_emm) eq 99) = Prev_FR_OR_TranCost(FuelRegion,M8,t_emm);
FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm)$(not FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm)) = Prev_FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm);
FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm)$FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm) = Wt * min(150,FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm)) + (1-Wt) * Prev_FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm);
*OR_OR_TranCost(M8,M8,t_emm)$(OR_OR_TranCost(M8,M8,t_emm) ne 999) = Wt * min(150,OR_OR_TranCost(M8,M8,t_emm)) + (1-Wt) * Prev_OR_OR_TranCost(M8,M8,t_emm);
*OR_OR_TranCost(M8,M8,t_emm)$(OR_OR_TranCost(M8,M8,t_emm) eq 999) = Prev_OR_OR_TranCost(M8,M8,t_emm);
OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm)$(not OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm)) = Prev_OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm);
OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm)$OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm) = Wt * min(1500,OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm)) + (1-Wt) * Prev_OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm);
$goto UpCst
$label SkipCTS
$if not exist input\CTSSoln.gdx $goto SkipiCTS
$gdxin input\CTSSoln.gdx
$load Prev_TnS_Costs=TnS_Costs Prev_FR_OR_TranCost=FR_OR_TranCost Prev_OR_OR_TranCost=OR_OR_TranCost
$gdxin
Prev_Src_TnS_Costs(FuelRegion,SourceType)=Prev_TnS_Costs(FuelRegion);
Prev_FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm)=Prev_FR_OR_TranCost(FuelRegion,M8,t_emm);
Prev_OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm)=Prev_OR_OR_TranCost(M8,M8,t_emm);
*TnS_Costs(FuelRegion)$(not TnS_Costs(FuelRegion)) = Prev_TnS_Costs(FuelRegion);
*TnS_Costs(FuelRegion)$TnS_Costs(FuelRegion) = Wt * min(300,TnS_Costs(FuelRegion)) + (1-Wt) * Prev_TnS_Costs(FuelRegion);
Src_TnS_Costs(FuelRegion,SourceType)$(not Src_TnS_Costs(FuelRegion,SourceType)) = Prev_Src_TnS_Costs(FuelRegion,SourceType);
Src_TnS_Costs(FuelRegion,SourceType)$Src_TnS_Costs(FuelRegion,SourceType) = Wt * min(300,Src_TnS_Costs(FuelRegion,SourceType)) + (1-Wt) * Prev_Src_TnS_Costs(FuelRegion,SourceType);
FR_OR_TranCost(FuelRegion,M8,t_emm)$(FR_OR_TranCost(FuelRegion,M8,t_emm) ne 99) = Wt * min(150,FR_OR_TranCost(FuelRegion,M8,t_emm)) + (1-Wt) * Prev_FR_OR_TranCost(FuelRegion,M8,t_emm);
FR_OR_TranCost(FuelRegion,M8,t_emm)$(FR_OR_TranCost(FuelRegion,M8,t_emm) eq 99) = Prev_FR_OR_TranCost(FuelRegion,M8,t_emm);
FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm)$(not FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm)) = Prev_FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm);
FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm)$FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm) = Wt * min(150,FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm)) + (1-Wt) * Prev_FR_OR_SrcTrnCost(SourceType,FuelRegion,M8,t_emm);
OR_OR_TranCost(M8,M8,t_emm)$(OR_OR_TranCost(M8,M8,t_emm) ne 999) = Wt * min(1500,OR_OR_TranCost(M8,M8,t_emm)) + (1-Wt) * Prev_OR_OR_TranCost(M8,M8,t_emm);
OR_OR_TranCost(M8,M8,t_emm)$(OR_OR_TranCost(M8,M8,t_emm) eq 999) = Prev_OR_OR_TranCost(M8,M8,t_emm);
OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm)$(not OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm)) = Prev_OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm);
OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm)$OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm) = Wt * min(1500,OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm)) + (1-Wt) * Prev_OR_OR_SrcTrnCost(SourceType,M8,M8,t_emm);
$label SkipiCTS
$label UpCst

* CO2 injected to EOR by OGSM region
Inject_EOR(M8,MNUMYR) =
  sum((t,REGION_OGSM,InjEOR,INJ_TERMINALS)$(M8_to_REGION_OGSM(M8,REGION_OGSM) and
                                            MNUMYR_t_emm(MNUMYR,t) and
                                            INJ_TDIST(InjEOR,INJ_TERMINALS) and
                                            TERM_OGSM(INJ_TERMINALS,REGION_OGSM)),
   INJECTED.l(InjEOR,t) ) ;

* CO2 injected to saline by fuel region
Inject_SAL(FuelRegion,MNUMYR) =
  sum((t,FuelReg,InjSAL,INJ_TERMINALS)$(FuelRegion_2_FuelReg(FuelRegion,FuelReg) and
                                        MNUMYR_t_emm(MNUMYR,t) and
                                        INJ_TDIST(InjSAL,INJ_TERMINALS) and
                                        TERM_FuelRegion(INJ_TERMINALS,FuelReg)),
   INJECTED.l(InjSAL,t) ) ;


IGRP(source)  = no ;
IGRP(Esource) = yes ;
IGRP(N_IGRP)$N_RY(N_IGRP) = yes ;

$Ifi %ForceAllOn% == -1 $goto next10
  IGRP(N_IGRP)$N_RY(N_IGRP)     = no ;
  UnitCost(N_IGRP,UnitCost_att) = 0 ;

* Make sure costs are not too high in "Force-all" case
  TnS_Costs(FuelRegion) = min(99/GDP('2007'),TnS_Costs(FuelRegion)) ;
$label next10


$IF NOT SET Trunks $Set OutDir .\

*Restore orginal program goals for ECP
Execute_load "%dir%/input/CTSinput.gdx" , ProgramGoal ;

Execute_Unload "%Outdir%ctusALL.gdx";

Execute_Unload "%Outdir%CTSSoln.gdx",
   CAPTURED,EOR_ON, SrcCapCost, RetroBase, PIPED,
   WELLNUM, UnitCost, UnitCostCap, UnitCostInj, UnitCost_att, TotalCost, OR_OR_SrcTrnCost,
   IGRP, PipeTooBig, RunDefn, CostWorkCap, CostWorkInj, TotalInj, SourceType, OR_OR_TranCost,
   t_emm, ProgramGoal, PlantType, ProgramGoal_att, FR_OR_TranCost, FR_OR_SrcTrnCost, FuelRegion, M8,
   TFCCS, TVCCS, IFCCS, IVCCS, TnS_Costs, Src_TnS_Costs, Inject_EOR, Inject_SAL, MNUMYR;

