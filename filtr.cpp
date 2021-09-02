// Librerias
#include <iostream>
#include <iomanip>
#include <Rcpp.h>
// #include <fstream>
// #include <math.h>
#include <time.h>
using namespace Rcpp;

// Colores
#define RESET   "\033[0m"
#define BLACK   "\033[30m"      // Black 
#define RED     "\033[31m"      // Red 
#define GREEN   "\033[32m"      // Green 
#define YELLOW  "\033[33m"      // Yellow 
#define BLUE    "\033[34m"      // Blue 
#define MAGENTA "\033[35m"      // Magenta 
#define CYAN    "\033[36m"      // Cyan 
#define WHITE   "\033[37m"      // White 
#define BOLDBLACK   "\033[1m\033[30m"      // Bold Black 
#define BOLDRED     "\033[1m\033[31m"      // Bold Red 
#define BOLDGREEN   "\033[1m\033[32m"      // Bold Green 
#define BOLDYELLOW  "\033[1m\033[33m"      // Bold Yellow 
#define BOLDBLUE    "\033[1m\033[34m"      // Bold Blue 
#define BOLDMAGENTA "\033[1m\033[35m"      // Bold Magenta 
#define BOLDCYAN    "\033[1m\033[36m"      // Bold Cyan 
#define BOLDWHITE   "\033[1m\033[37m"      // Bold White 


// [[Rcpp::export]]
DataFrame filtrado(NumericVector Infe,NumericVector Rec, NumericVector Mue){
	
		// Reportar inicio de ejecución.
		std::cout << BLUE << "Ejecutando C++" << RESET << std::endl;

		// Primer día de la pandemia y día actual.
		long long priD = min(Infe),  ultD = max(Infe);
		
		// Cantidad de días de pandemia.
		long long  n = (ultD - priD + 1);

		// Cantidad de casos.
		long long Ninf = Infe.size();

		// Cantidad de muertes.
		long long Nmue = Mue.size();

		// Cantidad de recuperados.
		long long Nrec = Rec.size();
		
		// Vectores de resultados.
		NumericVector InfD(n);
		NumericVector RecD(n);
		NumericVector MueD(n);
		NumericVector D(n);

		// Llenar el vector de fechas.
		for (long long i=0;i<n;i++)
				D(i) = priD + i;

		clock_t t = clock();
		// Llenar los vectores de resultados.
		for (long long i=0;i<n;i++){

				// Reportar avance
				if ( clock()-t > 5*CLOCKS_PER_SEC ){
						t = clock();
						std::cout << YELLOW << std::setprecision(3) << (float)i/n*100 << "% completado." << RESET << std::endl;
				};


				// Contadores diarios.
				int infHoy = 0;
				int recHoy = 0;
				int mueHoy = 0;
				
				// Contar infectados.
				for (long long j=0;j<Ninf;j++)
						if (Infe(j)==D(i))
								infHoy++;

				// Contar recuperados.
				for (long long j=0;j<Nrec;j++)
						if (Rec(j)==D(i))
								recHoy++;

				// Contar muertes.
				for (long long j=0;j<Nmue;j++)
						if (Mue(j)==D(i))
								mueHoy++;

				// Guardar conteos.
				InfD(i) = infHoy;
				RecD(i) = recHoy;
				MueD(i) = mueHoy;

		};

		// Crear dataframe de resultados.
		DataFrame results = DataFrame::create( Named("NumDía") = D, Named("Infec") = InfD, Named("Recup") = RecD, Named("Muert") = MueD);

		// Reportar cierre de función
		std::cout << BOLDGREEN << "Proceso completado satisfactoriamente." << RESET << std::endl;

		return results;

}





