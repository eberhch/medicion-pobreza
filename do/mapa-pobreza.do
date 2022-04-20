
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

 use "$datatemporal\pobreza-2020", clear
  
  **********************************************************************
 
 
 
* collapse


    collapse (mean) gast_per gastper_men pobre pobre_nbi pobreza_integrada linea [aw=factor08], ///
                  by(dpto)
    generate dpt = _n
	rename dpt id
	order id dpto
	save "$datatemporal\mapa-pobreza-2020", replace
************************************************************************			
	
	ssc install geo2xy, replace     
    ssc install palettes, replace        
    ssc install colrspace, replace
	ssc install schemepack, replace  // optional
    
	set scheme white_tableau

    graph set window fontface "Arial Narrow"
    help spmap

******************************************************************

   use "$mapas\dbperu", clear
   merge 1:1 id using "$datatemporal\mapa-pobreza-2020"
   
   replace pobre = pobre*100
   format pobre %9.1f
   
   replace pobre_nbi = pobre_nbi*100
   format pobre_nbi %9.1f
   
   replace pobreza_integrada = pobreza_integrada*100
   format pobreza_integrada %9.1f
   
  
 
 ****************************************************************************************
 
 * customizing colors	
   help colorpalette
	
   colorpalette viridis, n(10)	
    return list

   colorpalette viridis, n(10)	nograph
    local colors `r(p)'
	 
* POBREZA POR NECESIDADES BASICAS INSATISFECHAS:
	
  colorpalette viridis, n(12) nograph reverse
   local colors `r(p)'
	
  spmap pobre_nbi using "$mapas\cordenadas", id(id) ///
	                clnum(10) ///
	                fcolor("`colors'") 	///
	                label( x(x_centro) y(y_centro) label(pobre_nbi)  gap(100) size(*0.8 ..) position(0 6) length(25)) ///
	                legstyle(2) legend(pos(7) size(2.8) region(fcolor(gs15))) ///
                    ocolor(white ..) osize(0.05 ..) ///
	                title("Pobreza de Necesidades Basicas Insatisfechas", size(4)) ///
	                subtitle("peru 2020", size()) ///
				    legtitle("Tasa de pobreza (%)") ///
	                note("Fuente:INEI,elaboracion propia", size(2.5))
  
  gr_edit .legend.plotregion1.label[1].DragBy 1.104507079200059 -7.068845306880384
  gr_edit .plotregion1.plot12.style.editstyle label(textstyle(size(2.5))) editcopy
  gr_edit .plotregion1.plot12.style.editstyle label(textgap(180-pt)) editcopy
  
  graph export "$grahp\mapa_nbi.eps", as(eps) fontfacesymbol(stSymbol) replace	

 
* POBREZA MONETARIA:

   colorpalette viridis, n(12) nograph reverse
   local colors `r(p)'

  spmap pobre using "$mapas\cordenadas", id(id) ///
	               clnum(10) ///
	               fcolor("`colors'") 	///
	               label( x(x_centro) y(y_centro) label(pobre)  gap(100) size(*0.8 ..) position(0 6) length(25)) ///
	               legstyle(2) legend(pos(7) size(2.8) region(fcolor(gs15))) ///
                   ocolor(white ..) osize(0.05 ..) ///
	               title("Pobreza Monetaria", size(4)) ///
	               subtitle("peru 2020", size()) ///
				   legtitle("Tasa de pobreza (%)") ///
	               note("Fuente:INEI,elaboracion propia", size(2.5))
  
  gr_edit .legend.plotregion1.label[1].DragBy 1.104507079200059 -7.068845306880384
  gr_edit .plotregion1.plot12.style.editstyle label(textstyle(size(2.5))) editcopy
  gr_edit .plotregion1.plot12.style.editstyle label(textgap(180-pt)) editcopy

  graph export "$grahp\mapa-pobre-mon.eps", as(eps) fontfacesymbol(stSymbol) replace	

 
 
 * POBREZA INTEGRADA :
 
  colorpalette viridis, n(12) nograph reverse
    local colors `r(p)'

  spmap pobreza_integrada using "$mapas\cordenadas", id(id) ///
	              clnum(10) ///
	              fcolor("`colors'") 	///
	              label( x(x_centro) y(y_centro) label(pobreza_integrada)  gap(100) size(*0.8 ..) position(0 6) length(25)) ///
	              legstyle(2)	legend(pos(7) size(2.8) region(fcolor(gs15))) ///
                  ocolor(gs10 gs9 gs8 gs7) ///
	              title("Pobreza Integrada", size(4)) ///
	              subtitle("peru 2020", size()) ///
	              legtitle("Tasa de pobreza (%)") ///
	              note("Fuente:INEI,elaboracion propia", size(2.5))
	
  gr_edit .legend.plotregion1.label[1].DragBy 1.104507079200059 -7.068845306880384
  gr_edit .plotregion1.plot12.style.editstyle label(textstyle(size(2.5))) editcopy
  gr_edit .plotregion1.plot12.style.editstyle label(textgap(180-pt)) editcopy

  graph export "$grahp\mapa-pobre-intgr.eps", as(eps) fontfacesymbol(stSymbol) replace	

		
****************************************************************************************************
 
 


 
 
 
 
 
 
