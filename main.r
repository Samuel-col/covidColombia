
cat("Cargando paquetes.\n")
library('Rcpp')
library('fs')
library('stringr')


# Última vez que se descargó la base.
fs::file_info("baseCorona.csv")$modification_time -> ulMod

cat("Actualizando datos de ser necesario.\n")
# Descargar la base de ser necesario.
if ( difftime(Sys.time(),ulMod,units="days") > 1 ){
		download.file("https://www.datos.gov.co/api/views/gt2j-8ykr/rows.csv?accessType=DOWNLOAD","baseCorona.csv",method="wget",quiet=F)

		cat("Compilando función de C++ para filtrar datos por día.\n")
		# Cargar filtro de C++
		sourceCpp("filtr.cpp")
		
		
		# Función que corrige las fechas.
		arrFe <- function(str){
		  str %>% str_split(" ") %>%
		    lapply(function(arr) {return( arr[1] )}) %>%
		    unlist %>%
		    as.Date("%d/%m/%Y") -> r
		  
		  return(r)
		}
		

		cat("Cargando la base a R.\n")
		# Cargar la base.
		read.csv("baseCorona.csv") -> Base
		
		
		cat("Extrayendo información de interés.\n")
		# Extraer información de interés.
		Base <- with(Base,data.frame(ID.de.caso,feInf=arrFe(fecha.reporte.web),
												feMue=arrFe(Fecha.de.muerte),feRec=arrFe(Fecha.de.recuperación),
												edad=Edad,sexo=Sexo,codDepto=Código.DIVIPOLA.departamento))
		
		# Borrar base completa para ahorrar memoria ram.
		# rm(BaseCompleta)
		
		
		
		# Obtener estadísticas diarias.
		diario = with(Base,filtrado(as.numeric(feInf),as.numeric(feRec),as.numeric(feMue)))
		# rm(data)
		
		cat("Guardando resultados diarios obtenidos.\n")
		# Guardar resultados.
		write.table(diario,"diario.csv")

}else{

		read.table("diario.csv") -> diario
}



