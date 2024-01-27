* DAC Input GDX creator

* Allows a set to be empty
$onempty
* Allows a set to get filled with multiple statements, e.g starts out empty and gets fileld in later
$onmulti

Set     th                   t master plus historical /1981*2100/
        EnergySource         potential energy sources / 1 'NG+Grid', 2 'NG+Cogen' /
        ActiveEnergySource(EnergySource)   potential energy sources
        TechType             Types of DAC Technologies / 1 'Liquid Solvent', 2 'Solid Adsorbent' /
        DAC                  Set for financial calculations / set.TechType, Storage 'Storage Site' /
        DAC_Saline           DAC at Saline Injection sites
        DAC_EOR              DAC at EOR Injection sites
        DAC_Pseudo           DAC at Pseudo sites in EMM Fuel regions /DAC_Fuel_1*DAC_Fuel_23/
        REGION_EMM           EMM regions
        REGION_OGSM          OGSM regions
        FuelReg              Set of EMM fuel regions for GAMS
        DAC_Props_att        Headers for DAC constants
        / ProfiletoUse,
        EquityFraction,
        DebtFraction,
        DebtLife,
        TaxLife,
        EquipLife,
        Life,
        Beta,
        CapFactor,
        CaptureRate /
        ;

$gdxin input\CTSinput.gdx
$loadm DAC_EOR=InjPseudo, DAC_Saline=InjSal
$load  REGION_EMM, REGION_OGSM, FuelReg

Sets    DAC_Sites            All DAC Facilities / set.DAC_Saline, set.DAC_EOR, set.DAC_Pseudo /
        DAC_OGSM(DAC_Sites,REGION_OGSM)    Map DAC sites to OGSM regions
        DAC_FuelRegion(DAC_Sites,FuelReg)  Map DAC sites to fuel regions
        DAC_EMM(DAC_Sites,REGION_EMM)      Map DAC sites to EMM regions
        ;

$loadm DAC_EMM=INJ_EMM DAC_OGSM=INJ_OGSM
$gdxin

$call csv2gdx "input\DAC\DAC_EMM.csv" output=input\DAC\DAC_EMM.gdx id=DAC_EMM Index=(1,2) Value=3 UseHeader=Y
$call csv2gdx "input\DAC\DAC_FuelRegion.csv" output=input\DAC\DAC_FuelRegion.gdx id=DAC_FuelRegion Index=(1,2) Value=3 UseHeader=Y
$call csv2gdx "input\DAC\DAC_OGSM.csv" output=input\DAC\DAC_OGSM.gdx id=DAC_OGSM Index=(1,2) Value=3 UseHeader=Y
$call csv2gdx "input\DAC\ActiveEnergySource.csv" output=input\DAC\ActiveEnergySource.gdx id=ActiveEnergySource Index=1 Value=2 UseHeader=Y

$gdxin input\DAC\DAC_EMM.gdx
$loadm DAC_EMM
$gdxin
$gdxin input\DAC\DAC_FuelRegion.gdx
$loadm DAC_FuelRegion
$gdxin
$gdxin input\DAC\DAC_OGSM.gdx
$loadm DAC_OGSM
$gdxin
$gdxin input\DAC\ActiveEnergySource.gdx
$loadm ActiveEnergySource
$gdxin

Parameter  DAC_BaseCap(th,TechType,EnergySource) DAC capital costs per tonne
           Q_el(th,TechType,EnergySource)        Electricity Consumption
           Q_ng(th,TechType,EnergySource)        NG Consumption
           DAC_NGCCSf(th,TechType,EnergySource)  Maximum fraction of NG CO2 emissions captured relative to DAC by technology and year
           DAC_Props(DAC,DAC_Props_att)  DAC constants
           ;

$set QEL_File input\DAC\Q_EL_Adv.csv
$set QNG_File input\DAC\Q_NG_Adv.csv
$set BaseCap_File input\DAC\DAC_BaseCap_Adv.csv
$set NGCCSf_File input\DAC\DAC_NGCCSf_Adv.csv
$set Output_File DAC\DAC_Inputs_Adv.gdx

$call csv2gdx %QEL_File% output=input\DAC\Q_EL.gdx id=Q_EL Index=(1,2,3) Value=4 UseHeader=Y
$call csv2gdx %QNG_File% output=input\DAC\Q_NG.gdx id=Q_NG Index=(1,2,3) Value=4 UseHeader=Y
$call csv2gdx %BaseCap_File% output=input\DAC\DAC_BaseCap.gdx id=DAC_BaseCap Index=(1,2,3) Value=4 UseHeader=Y
$call csv2gdx %NGCCSf_File% output=input\DAC\DAC_NGCCSf.gdx id=DAC_NGCCSf Index=(1,2,3) Value=4 UseHeader=Y
$call csv2gdx "input\DAC\DAC_Props.csv" output=input\DAC\DAC_Props.gdx id=DAC_Props Index=(1,2) Value=3 UseHeader=Y

$gdxin input\DAC\Q_EL.gdx
$loadm Q_EL
$gdxin
$gdxin input\DAC\Q_NG.gdx
$loadm Q_NG
$gdxin
$gdxin input\DAC\DAC_BaseCap.gdx
$loadm DAC_BaseCap
$gdxin
$gdxin input\DAC\DAC_NGCCSf.gdx
$loadm DAC_NGCCSf
$gdxin
$gdxin input\DAC\DAC_Props.gdx
$loadm DAC_Props
$gdxin

$gdxout %Output_File%
$unload DAC_EMM DAC_FuelRegion DAC_OGSM Q_EL Q_NG DAC_BaseCap DAC_NGCCSf DAC_Props
$unload TechType EnergySource ActiveEnergySource DAC_Props_att
$gdxout
