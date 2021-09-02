println(">> Para que el script funcione adecuadamente, deben estar instalados DataFrames, Plots, Plotly, CSV, y Dates.")
println(">> (1/8) Cargando paquetes...")
using Plots, DataFrames, CSV, Dates;plotly()
#
println(">> (2/8) Descargando y leyendo base de datos...")
Base_min=download("https://www.datos.gov.co/api/views/gt2j-8ykr/rows.csv?accessType=DOWNLOAD","Datos.csv")
BmS=CSV.read(Base_min,DataFrame)
#Fecha de reporte web: col 1
#Fecha de recuperado: col 20
#Fecha de diagnostico: col 19
#Fecha de muerte: col 18
#Ciudad de ubicación: col 7
#Código departamento: col 4 (Bog=11)
#
correct(x::String)=x[1:(findfirst(isequal(' '),x)-1)]
correct(x::Missing)=missing
#
#Colombia
println(">> (3/8) Calculando población suceptible, infectada, recuperada y fallecida para cada día...")
noti=Date.(correct.(BmS[:,3]),"d/m/y")
recuperacion=BmS[:,20]
muerte=BmS[:,18]
codi=BmS[:,4]
BmS=Nothing
recu=Date.(skipmissing(correct.(recuperacion)),"d/m/y")
muer=Date.(skipmissing(correct.(muerte)),"d/m/y")
Días=collect(Date("2020-03-02"):Day(1):today())
M=[0]::Vector{Int64}
for i=2:length(Días)
    push!(M,M[lastindex(M)]+sum(skipmissing(muer.==Días[i])))
end
R=[0]::Vector{Int64}
for i=2:length(Días)
    push!(R,R[lastindex(R)]+sum(skipmissing(recu.==Días[i])))
end
S=[49648699]::Vector{Int64}
for i=2:length(Días)
    push!(S,S[lastindex(S)]-sum(noti.==Días[i]))
end
I=49648700 .-S .-R .-M

#
println(">> (4/8) Creando el gráfico...")
p_col=plot(Días[15:end],[S[15:end] I[15:end] R[15:end] M[15:end]],col=["blue" "yellow" "green3" "red"],legend=false,labels=["Suceptibles" "Infectados" "Recuperados" "Muertos"],xlabel="Fecha",ylabel="Cantidad De Personas",title="Colombia",yscale=:log10)
#
#
#Bogotá
println(">> (5/8) Extrayendo casos de Bogotá...")
# BmS=filter!(row -> row."Código DIVIPOLA departamento"==11,BmS)
#
println(">> (6/8) Calculando población suceptible, infectada y removida para cada día en Bogotá...")
# noti=Date.(correct.(BmS[:,3]),"d/m/y")
noti=noti[codi .==11]
# recu=Date.(skipmissing(correct.(BmS[:,20])),"d/m/y")
recu=Date.(skipmissing(correct.(recuperacion[codi .==11])),"d/m/y")
muer=Date.(skipmissing(correct.(muerte[codi .==11])),"d/m/y")
# recu=recu[codi .==11]
# muer=Date.(skipmissing(correct.(BmS[:,18])),"d/m/y")
# muer=muer[codi .==11]
M=[0]::Vector{Int64}
for i=2:length(Días)
    push!(M,M[lastindex(M)]+sum(skipmissing(muer.==Días[i])))
end
R=[0]::Vector{Int64}
for i=2:length(Días)
    push!(R,R[lastindex(R)]+sum(skipmissing(recu.==Días[i])))
end
S=[7743955]::Vector{Int64}
for i=2:length(Días)
    push!(S,S[lastindex(S)]-sum(noti.==Días[i]))
end
I= 7743955 .-S .-R .-M

println(">> (7/8) Creando el gráfico de Bogotá...")
p_bog=plot(Días[24:end],[S[24:end] I[24:end] R[24:end] M[24:end]],col=["blue" "yellow" "green3" "red"],legend=:bottomright,labels=["Suceptibles" "Infectados" "Recuperados" "Muertos"],xlabel="Fecha",ylabel="Cantidad De Personas",title="Bogotá",yscale=:log10)
println(">> (8/8) Guardando gráficos...")
#
plot(p_col,p_bog,layout=(1,2),size=(1300,500))
savefig("/Archivos/A/Julia/Coronavirus/RepGen.html")
println("Proceso Finalizado Exitosamente")
