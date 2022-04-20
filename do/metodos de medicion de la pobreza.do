

* data         : ENAHO modulo 100 y sumaria 2012-2020
* version stata: 17


*  METODOS DE MEDCION DE LA POBREZA EL PERU
*
*      1.- el metodo de linea de pobreza
*	   2.- el metodo de la necesidades basicas basicas insatisfechas
*      3.- el metodo de medicion  integrado

 *====================================================================
  clear all
  set more off
  
  global ruta         "V:\STATA\ENAHO"
  global data         "$ruta\data"
  global datatemporal "$ruta\datatemporal"
  global grahp        "$ruta\grahp"
  global mapas        "$ruta\mapas"
  
  
 *================================================= ==================

 
 
*******************************************************************
* preparamos los bases de trabajo

* modulo 100

 use "$data\modulo100-2020", clear
 
 describe, short
 fre result
 keep if (result == 1 | result == 2)
 gsort conglome vivienda hogar 
 
 save "$datatemporal\mod100-2020", replace
 
 * sumaria-2020
 
 use "$data\sumaria-2020", clear
 describe, short
 gsort conglome vivienda hogar
 
 save "$datatemporal\sumari-2020",replace
 
 
 * merge
 
 use "$datatemporal\mod100-2020", clear
 
 merge 1:1 conglome vivienda hogar using "$datatemporal\sumari-2020"
 drop _merge
 
 save "$datatemporal\pobreza-2020", replace

**********************************************************************
 
 *   GENERACION DE VARIABLES
 
 
 * generamos varaible area
 
 fre estrato
 recode estrato(1/5 = 0 "urbana") (6/8 =1 "rural"), gen (area)
 
 * generamos varibale dominio geografico por area y region natural
 
 fre dominio
 recode dominio( 1/3 8 =1 "costa") (4/6 = 2 "sierra")(7 = 3 "selva"), ///
        generate (region_nat)
 label var region_nat "regional natural"
 
 * generamos varaibles por area y region natural
 
 generate Dominio = 1 if (area == 1 & region_nat == 1)
 replace  Dominio = 2 if (area == 2 & region_nat == 1)
 replace  Dominio = 3 if (area == 1 & region_nat == 2)
 replace  Dominio = 4 if (area == 2 & region_nat == 2)
 replace  Dominio = 5 if (area == 1 & region_nat == 3)
 replace  Dominio = 6 if (area == 2 & region_nat == 3)
 replace  Dominio = 7 if (dominio == 8)
 label de Dominio ///
  1 "costa urbana" ///
  2 "costa rural" ///
  3 "sierra urbana" ///
  4 "sierra rural" ///
  5 "selva urbana" ///
  6 "selava rural" ///
  7 "lima metropolitana"
 label values Dominio Dominio
 label var Dominio "dominio geografico"
 
 * generamos varaible deparatmentos
 
 generate departamento = real(substr(ubigeo,1,2))
 recode departamento ///
		(1 = 1 "Amazonas") ///
		(2 = 2 "Ancash") /// 
		(3 = 3 "Apurímac") /// 
		(4 = 4 "Arequipa") /// 
		(5 = 5 "Ayacucho") ///
		(6 = 6 "Cajamarca") ///
		(7 = 7 "Callao") ///
		(8 = 8 "Cusco") ///
		(9 = 9 "Huancavelica") ///
		(10 = 10 "Huánuco") ///
		(11 = 11 "Ica") ///
		(12 = 12 "Junín") ///
		(13 = 13 "La Libertad") ///
		(14 = 14 "Lambayeque") ///
		(15 = 15 "Lima") ///
		(16 = 16 "Loreto") ///
		(17 = 17 "Madre de Dios") ///
		(18 = 18 "Moquegua") ///
		(19 = 19 "Pasco") ///
		(20 = 20 "Piura") ///
		(21 = 21 "Puno") ///
		(22 = 22 "San Martín") ///
		(23 = 23 "Tacna") ///
		(24 = 24 "Tumbes") ///
		(25 = 25 "Ucayali"), gen(dpto)
 label var dpto "departamentos"
 drop departamento
*===============================================================
* POBREZA POR LA LINEA DE POBREZA
*===============================================================
 
 describe gashog2d  ld mieperho 
 generate gast_per =gashog2d/(ld*mieperho*12)
 
 * factor de expansion poblacional
 generate factor08 =factor07*mieperho
 
 ci means gast_per
 ci means gast_per [aw=factor08]
 ci means gast_per [w=factor08]
 
 svyset [pw = factor08], psu(conglome) strata(estrato) //diseño muestral
 svy:mean gast_per
 svy: mean gast_per, cformat(%9.1fc)
 
 svy: mean gast_per, over(area) cformat(%9.1fc)
 svy: mean gast_per, over(region_nat) cformat(%9.1fc)
 svy: mean gast_per, over(Dominio) cformat(%9.1fc)
 svy: mean gast_per, over(dpto) cformat(%9.1fc)

 * incidencia brecha y severidad
 
 svy: mean linea linpe, cformat(%9.1fc)
 
 * agrupamos la pobreza
 
 fre pobreza
 recode pobreza(3 = 0 "no pobre") (1 2 = 1 " pobre"), gen (pobre)
 label var pobre "pobreza monetaria"
 
 svy: proportion pobre
 svy: tabulate pobre area, col format(%9.1f) percent 
 
 * indicador FGT
 
 generate gastper_men = gashog2d/(mieperho*12)
 label var gastper_men "gastopercapita corriente mensual"
 
 povdeco gastper_men [w = factor08], varpl(linea)
 povdeco gastper_men [w = factor08], varpl(linea) by(area)
 
*================================================================
* POBREZA POR NECESIDADES BASICAS INSATISFECHAS
*================================================================

 generate suma_nbi = nbi1+ nbi2 + nbi3 + nbi4 + nbi5
 fre suma_nbi
 recode suma_nbi  (0=0 "no pobre") (1/5 = 1 "pobre"), gen (pobre_nbi) 
 label var pobre_nbi "pobreza: necesidades basicas insatisfechas"
 
 tab pobre_nbi
 tab pobre_nbi [iw=factor08]
 
 svyset conglome [pw = factor08], strata(estrato)
 svy: tabulate pobre_nbi area, col format(%9.1f) percent
 
 
*================================================================
* POBREZA INTEGRADA
*=================================================================

 generate pob_integrada = 4 if (pobre == 1 & pobre_nbi == 1) 
 replace  pob_integrada = 3 if (pobre == 1 & pobre_nbi == 0) 
 replace  pob_integrada = 2 if (pobre == 0 & pobre_nbi == 1) 
 replace  pob_integrada = 1 if (pobre == 0 & pobre_nbi == 0) 
 label de pob_integrada ///
  1 "pobre integrado socialmente" ///
  2 "pobreza inercial" ///
  3 "pobre reciente" ///
  4 "pobre cronico"
 label values pob_integrada pob_integrada
 label var pob_integrada "pobreza por el metodo integrado"

 * clasificacion: no pobre, pobre 

 recode pob_integrada (1 = 0 "no pobre") (2/4 = 1 "pobre"), gen (pobreza_integrada)
 label var pobreza_integrada "pobreza integrada"
 
 svyset conglome [pw = factor08], strata(estrato)
 svy: tabulate pob_integrada area, col format(%9.1f) percent
 svy: tabulate pobreza_integrada area, col format(%9.1f) percent

*====================================================================
* 
*                           2010 -2020
*
*=====================================================================
 
* PROGRAM

 program variables
 
 * generamos varaible area
 
 fre estrato
 recode estrato(1/5 = 0 "urbana") (6/8 =1 "rural"), gen (area)
 
 * generamos varibale dominio geografico por area y region natural
 
 fre dominio
 recode dominio( 1/3 8 =1 "costa") (4/6 = 2 "sierra")(7 = 3 "selva"), ///
        generate (region_nat)
 label var region_nat "regional natural"
 
 * generamos varaibles por area y region natural
 
 generate Dominio = 1 if (area == 1 & region_nat == 1)
 replace  Dominio = 2 if (area == 2 & region_nat == 1)
 replace  Dominio = 3 if (area == 1 & region_nat == 2)
 replace  Dominio = 4 if (area == 2 & region_nat == 2)
 replace  Dominio = 5 if (area == 1 & region_nat == 3)
 replace  Dominio = 6 if (area == 2 & region_nat == 3)
 replace  Dominio = 7 if (dominio == 8)
 label de Dominio ///
  1 "costa urbana" ///
  2 "costa rural" ///
  3 "sierra urbana" ///
  4 "sierra rural" ///
  5 "selva urbana" ///
  6 "selava rural" ///
  7 "lima metropolitana"
 label values Dominio Dominio
 label var Dominio "dominio geografico"
 
 * generamos varaible deparatmentos
 
 generate departamento = real(substr(ubigeo,1,2))
 recode departamento ///
		(1 = 1 "Amazonas") ///
		(2 = 2 "Ancash") /// 
		(3 = 3 "Apurímac") /// 
		(4 = 4 "Arequipa") /// 
		(5 = 5 "Ayacucho") ///
		(6 = 6 "Cajamarca") ///
		(7 = 7 "Callao") ///
		(8 = 8 "Cusco") ///
		(9 = 9 "Huancavelica") ///
		(10 = 10 "Huánuco") ///
		(11 = 11 "Ica") ///
		(12 = 12 "Junín") ///
		(13 = 13 "La Libertad") ///
		(14 = 14 "Lambayeque") ///
		(15 = 15 "Lima") ///
		(16 = 16 "Loreto") ///
		(17 = 17 "Madre de Dios") ///
		(18 = 18 "Moquegua") ///
		(19 = 19 "Pasco") ///
		(20 = 20 "Piura") ///
		(21 = 21 "Puno") ///
		(22 = 22 "San Martín") ///
		(23 = 23 "Tacna") ///
		(24 = 24 "Tumbes") ///
		(25 = 25 "Ucayali"), gen(dpto)
 label var dpto "departamentos"
 drop departamento
*===============================================================
* POBREZA POR LA LINEA DE POBREZA
*===============================================================
 
 describe gashog2d  ld mieperho 
 generate gast_per =gashog2d/(ld*mieperho*12)
 
 * factor de expansion poblacional
 generate factor08 =factor07*mieperho
 
 ci means gast_per
 ci means gast_per [aw=factor08]
 ci means gast_per [w=factor08]
 
 svyset [pw = factor08], psu(conglome) strata(estrato) //diseño muestral
 svy:mean gast_per
 svy: mean gast_per, cformat(%9.1fc)
 
 svy: mean gast_per, over(area) cformat(%9.1fc)
 svy: mean gast_per, over(region_nat) cformat(%9.1fc)
 svy: mean gast_per, over(Dominio) cformat(%9.1fc)
 svy: mean gast_per, over(dpto) cformat(%9.1fc)

 * incidencia brecha y severidad
 
 svy: mean linea linpe, cformat(%9.1fc)
 
 * agrupamos la pobreza
 
 fre pobreza
 recode pobreza(3 = 0 "no pobre") (1 2 = 1 " pobre"), gen (pobre)
 label var pobre "pobreza monetaria"
 
 svy: proportion pobre
 svy: tabulate pobre area, col format(%9.1f) percent 
 
 * indicador FGT
 
 generate gastper_men = gashog2d/(mieperho*12)
 label var gastper_men "gastopercapita corriente mensual"
 
 povdeco gastper_men [w = factor08], varpl(linea)
 povdeco gastper_men [w = factor08], varpl(linea) by(area)
 
*================================================================
* POBREZA POR NECESIDADES BASICAS INSATISFECHAS
*================================================================

 generate suma_nbi = nbi1+ nbi2 + nbi3 + nbi4 + nbi5
 fre suma_nbi
 recode suma_nbi  (0=0 "no pobre") (1/5 = 1 "pobre"), gen (pobre_nbi) 
 label var pobre_nbi "pobreza: necesidades basicas insatisfechas"
 
 tab pobre_nbi
 tab pobre_nbi [iw=factor08]
 
 svyset conglome [pw = factor08], strata(estrato)
 svy: tabulate pobre_nbi area, col format(%9.1f) percent
 
 
*================================================================
* POBREZA INTEGRADA
*=================================================================

 generate pob_integrada = 4 if (pobre == 1 & pobre_nbi == 1) 
 replace  pob_integrada = 3 if (pobre == 1 & pobre_nbi == 0) 
 replace  pob_integrada = 2 if (pobre == 0 & pobre_nbi == 1) 
 replace  pob_integrada = 1 if (pobre == 0 & pobre_nbi == 0) 
 label de pob_integrada ///
  1 "pobre integrado socialmente" ///
  2 "pobreza inercial" ///
  3 "pobre reciente" ///
  4 "pobre cronico"
 label values pob_integrada pob_integrada
 label var pob_integrada "pobreza por el metodo integrado"

 * clasificacion: no pobre, pobre 

 recode pob_integrada (1 = 0 "no pobre") (2/4 = 1 "pobre"), gen (pobreza_integrada)
 label var pobreza_integrada "pobreza integrada"
 
 svyset conglome [pw = factor08], strata(estrato)
 svy: tabulate pob_integrada area, col format(%9.1f) percent
 svy: tabulate pobreza_integrada area, col format(%9.1f) percent
 
 
 end
 
 
 * loops 
 
 
 forvalues i = 2012/2020 {
   use "$data\modulo100-`i'", clear
   keep if (result == 1 | result == 2)
   gsort conglome vivienda hogar 
   save "$datatemporal\mod100-`i'", replace
 
 
 * merge
 
 
   use "$datatemporal\mod100-`i'", clear
   merge 1:1 conglome vivienda hogar using "$data\sumaria-`i'.dta" 
   
   save "$datatemporal\pobreza-merge-`i'", replace

 variables
 
  rename aÑo año
  order año, first
  keep  año conglome vivienda hoga region_nat dpto Dominio gast_per ld mieperho ///
       gastper_men factor08 factor07 linea linpe pobre pobreza suma_nbi pobre_nbi ///
	   pob_integrada pobreza_integrada
	      
  save "$datatemporal\pobreza-`i'", replace 
 
 }	 
 
 


 * append
 
  forvalues i = 2012/2020{
      gsort año
	  append using "$datatemporal\pobreza-`i'"
  }
  save "$data\metodos de pobreza-2010-2020", replace

*==========================================================================
  preserve
    collapse (mean) gast_per gastper_men pobre pobre_nbi pobreza_integrada linea [aw=factor08], ///
                  by(año)
	save "$datatemporal\pobreza-2010-2020", replace
				  
  restore
*============================================================================== 
 
 

 
 
 
 
 