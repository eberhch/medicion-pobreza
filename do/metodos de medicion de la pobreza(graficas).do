
*  data         : ENAHO modulo 100 y sumaria 2012-2020
*  version stata: 17

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

 use "$datatemporal\pobreza-2010-2020", clear
  
  list pobre
  destring año , replace
   
 replace pobre = pobre *100
 replace pobre_nbi = pobre_nbi *100
 replace pobreza_integrada= pobreza_integrada *100
 
 
***************************************************************
*  incidencia de la pobreza monetria
**************************************************************

  global graph_opts1 ///
           bgcolor(white) ///
           graphregion(color(white)) ///
           legend(region(lc(none) fc(none))) ///
           ylab(,angle(0) nogrid) ///
           title("Evolucion de la Incidencia de la Pobreza Monetaria ", justification(left) color(black) span pos(12)) ///
           subtitle(" Peru 2012-2020", justification(left) color(black))

 
  graph  bar  pobre, over(año) ///
         	  scheme(_grstyle_) ///
              blabel(bar, format(%9.1f)) ///
		      ylabel(0(5)35) ///
			  ytitle(%) ///
			  ${graph_opts1} ///
			  intensity(90) ///
			  note("Fuente: INEI, elaboracion propia", justification(left) color(black) span position(7))

			  
  graph export "$grahp\grafica1.eps", as(eps) logo(on) fontfaceserif("Times New Roman") replace	
  graph export "$grahp\grafica2.eps", as(eps) logo(off) fontfacesymbol(stSymbol) replace	

*************************************************************************************************
*   incidencia de la pobreza-2010-2020 
***************************************************************************************
  graph twoway line (pobre año), ///
                    scheme(s2color) ///
					bgcolor(white) ///
					graphregion(color(white)) ///
					legend(region(lc(none) fc(none))) ///
					ylab(,angle(0) nogrid) ///
					lcolor(orange) ///
					ylabel(20(2)32) ///
					xlabel(2012(1)2020, labsize()) ///
					ytitle(%) ///
					xtitle("") ///
					title("{stSerif:Evolucion de la Incidencia de la Pobreza Monetaria} ", justification(left)  color(black) span pos(12)) ///
                    subtitle(" Peru 2012-2020", justification(left) color(black)) ///
					note("Fuente: INEI, elaboracion propia", justification(left) color(black) span position(7))

  graph export "$grahp\grafica3.eps", as(eps) logo(off) fontfacesymbol(stSymbol) replace	

 
**************************************************************************************************
* evolucion de gasto percapita
**************************************************************************************************

  
  graph  bar  gast_per, over(año) ///
              scheme(_grstyle_) ///
			  bgcolor(white) ///
              graphregion(color(white)) ///
              legend(region(lc(none) fc(none))) ///
              ylab(,angle(0) nogrid) ///	
              blabel(bar, format(%9.0f)) ///
		      ylabel(100(100)900) ///
			  bar(1, color(green*.8)) ///
			  intensity(80) ///
			  ytitle("gasto percapita  mensual", justification(left) color(black)) ///
			  title("Evolucion de Gasto Percapita Mensual ", justification(left)  color(black) span pos(12)) ///
              subtitle(" Peru 2012-2020", justification(left) color(black)) ///
			  note("Fuente: INEI, elaboracion propia", justification(left) color(black) span position(7))
		  
  graph export "$grahp\gasto_percapita.eps", as(eps) logo(on) fontfaceserif(stSerif) replace
 
***************************************************************************************************
* metodos de medicion de pobreza
**************************************************************************************************
 
  graph twoway line (pobre pobre_nbi pobreza_integrada  año), ///
                    scheme(yale) ///
					bgcolor(white) ///
					graphregion(color(white)) ///
					legend(col(1) label(1 "pobreza monetaria")label(2 "pobreza por necesidades basicas insatisfechas")label(3 "pobreza integrada")) ///
					ylab(,angle(0) nogrid) ///
					lcolor(1 red) ///
					ylabel(15(3)40) ///
					xlabel(2012(1)2020, labsize()) ///
					ytitle("tasa de pobreza %") ///
					xtitle("") ///
					title("{stSerif:Evolucion de la Pobreza Peruana 2012-2020} ", justification(left)  color(black) span pos(13)) ///
                    subtitle("", justification(left) color(black)) ///
					note("Fuente: INEI, elaboracion propia", justification(left) color(black) span position(7))
  
  graph export "$grahp\pobreza-peruana.eps", as(eps) logo(on) fontfacesymbol(Symbol) replace

				
			
				
				
				
				
				
				
				
				
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
   
       
   
 
 
 
 
 
 
  