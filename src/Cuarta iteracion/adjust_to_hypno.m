%funcion para ajustar los datos al hipnograma y devolver la media y
%desviacion tipica del dato.
%entradas: -señal/datos a procesar
%          -numero de muestras por cada dato en el hipnograma
%salidas:  -media
%          -desviacion
function [data_mean, data_std] = adjust_to_hypno(data, n_samples_per_hypno)
    tempAux = reshape(data, n_samples_per_hypno, []);
    data_mean = mean(tempAux);
    data_std = std(tempAux);
end