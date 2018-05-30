
% Funcion para aplicar un filtro de frecuencia a una transformada de fourier
% Entradas: -La transformada que se quiere tratar
%           -Frecuencia mas pequeña del intervalo que se desea
%           -Frecuencia mas grande del intervalo que se desea
% 
% Salida:   -La transformada filtrada en el intervalo deseado

function [transform_filtered] = get_band(transform, band_low, band_high)
   
    freq_sampling = 100;
    freq  = freq_sampling/2;
    n_samples = length(transform)/2;

    n_band_low = (band_low/freq)* n_samples + 1;
    n_band_high = (band_high/freq)* n_samples ;
    
    transform_filtered = transform(n_band_low: n_band_high);
end

