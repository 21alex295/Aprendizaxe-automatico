%%%%%Funcion para cargar en matlab la BD y devuelve un paciente de la BD
%Recibe el nombre de la bd y el numero 
function [patient_data] = load_BD_3iter(db_name)
%paciente nº1
    %db_name = 'C:\Users\Alejandro\Documents\Clase\2017-2018\AA\sleep-EDF.mat';
    database = load(db_name);
    patient_data = struct2cell(database);
end
