#!/bin/bash

#calcolo di wind speed e direction utilizzando la stessa funzione uv2ds del pacchetto R rWind

#    direction <- atan2(u, v)
#    direction <- rad2deg(direction)
#    direction[direction < 0] <- 360 + direction[direction < 0]
#    speed <- sqrt((u * u) + (v * v))
#    res <- cbind(dir = direction, speed = speed)
#    return(res)

# ${1}: componente u <--
# ${2}: componente v <--

cdo atan2 ${1} ${2} atan2.nc
#atan2.nc eredita come field name u10, che trasformo in gradi da radianti
cdo expr,'var1=deg(u10);' atan2.nc direction.nc

#crea maschera per la direzione: assegno 1 a tutte le direzioni minori di zero (tra 0 e -180), altrimenti assegno 0
cdo ltc,0 direction.nc direction_mask.nc

#credo un file con i valori di direzione sommati a 360
cdo addc,360 direction.nc direction_360.nc

#usando la maschera, prendo i valori sommati a 360 per i valori di direzione negativi (valori 1 nella maschera) altrimenti prendo i valori di direzione
cdo ifthenelse direction_mask.nc direction_360.nc direction.nc wdir_daily.nc


#wind speed
cdo -b 64 sqr ${1} ${1%.nc}_sqr.nc
cdo -b 64 sqr ${2} ${2%.nc}_sqr.nc
cdo -b 64 add ${1%.nc}_sqr.nc ${2%.nc}_sqr.nc somma_sqr.nc
cdo -b 64 sqrt somma_sqr.nc wspeed_daily.nc

rm -rf ${1%.nc}_sqr.nc ${2%.nc}_sqr.nc somma_sqr.nc direction.nc direction_mask.nc direction_360.nc atan2.nc
