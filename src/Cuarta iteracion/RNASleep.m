close all;
clear all;

%EEG and EOG  100hz
%EMG 1hz
%Oro-nasal, event marker, rectal temp 1Hz


% Hypnogram leyenda
% 0 - awake
% 1 - light sleep
% 2 - sleep -> temp empieza a bajar
% 3 - sleep -> antes de deep sleep, 
% 4 - deep sleep
% 5 - REM
% 6 - Movement time
% 9 - dato invalido

%db_name = '\\udc.pri\alumnos\alumnos4\al_informatica\62534\noPerfil\Mis documentos\AA\sleep-EDF.mat';
db_name = 'C:\Users\Alejandro\Documents\Clase\2017-2018\AA\sleep-EDF.mat';
 

[patient_data] = load_BD(db_name);
output_expected_data = []
input_data = []
for i = 1:4
    patient = get_patient(patient_data, i);
    [input_data_aux, output_data_aux] = process_data(patient);
    input_data = [input_data , input_data_aux];
    output_expected_data = [output_expected_data, output_data_aux];
end





hypno = output_expected_data;

%plot_input_data(input_data, output_data)

precision_array_training = zeros(10);
mean_precision_training = 1:10;
std_precision_training = 1:10;
conf = 1:10;
mejor_configuracion = 1;

output_expected_data = hypno;
for i = 1:length(output_expected_data -1);
    %so�o lixeiro
    if (output_expected_data(i) == 1)
        output_expected_array(1,i) = 1;
        output_expected_array(2,i) = 0;
        output_expected_array(3,i) = 0;
        output_expected_array(4,i) = 0;
    end
    %durmido, baixa temp
    if (output_expected_data(i) == 2)
        output_expected_array(1,i) = 0;
        output_expected_array(2,i) = 1;       
        output_expected_array(3,i) = 0;
        output_expected_array(4,i) = 0;
    end
    %so�o profundo
     if (output_expected_data(i) == 3)
        output_expected_array(1,i) = 0;
        output_expected_array(2,i) = 0;       
        output_expected_array(3,i) = 1;
        output_expected_array(4,i) = 0;
     end   
    %REM
     if (output_expected_data(i) == 5)
        output_expected_array(1,i) = 0;
        output_expected_array(2,i) = 0;       
        output_expected_array(3,i) = 0;
        output_expected_array(4,i) = 1;
     end
     %fase de movemento
  
end



%para 8 neuronas en capa oculta, medias:[0.0693 0.0657 0.1003], haberia que mirar
%mais
%for hidden_layers = 1:10;
    for j = 1:30 %Creamos e entrenamos a rede x veces
        rna = patternnet([10]);
        rng('shuffle');
        % partition = cvpartition(output_expected_data,'HoldOut',0.2);
    
        rna.trainParam.showWindow = false;
        [rna,tr] = train(rna, input_data, output_expected_array);
        validation_ratio = rna.divideParam.valRatio;
        test_ratio = rna.divideParam.testRatio;
        rna_outputs = sim(rna,input_data);
        
        % Validation
        targets_test = input_data(:, tr.testInd);
        targets_train = input_data(:, tr.trainInd);
        targets_val = input_data(:, tr.testInd);
        
        % RNA outputs
        output_test = rna(targets_test);
        output_train = rna(targets_train);
        output_val = rna(targets_val);
        
        % Confusi�n para cada conjunto
        conf_test = confusion(output_expected_array(:,tr.testInd),output_test);
        conf_train = confusion(output_expected_array(:,tr.trainInd),output_train);
        conf_val = confusion(output_expected_array(:,tr.valInd),output_val);
        conf(1,j) = conf_test; 
        conf(2,j) = conf_train; 
        conf(3,j) = conf_val; 
        
        % Guardamos los datos de la mejor RNA
        if (conf_test < mejor_configuracion)
            mejor_rna = rna;
            mejor_test = output_expected_array(:,tr.testInd);
            mejor_output_test = output_test;
            mejor_configuracion = conf_test;
           % mejor_arquitectura = hidden_layers;
        end
         
        
    end;
    % Media de las confusiones cambiar 1 por hidden_layers
    meanc_test  = mean(conf(1,:))
    meanc_train = mean(conf(2,:))
    meanc_val   = mean(conf(3,:))
    desvc_test  = std(conf(1,:))
    desvc_train = std(conf(2,:))
    desvc_val   = std(conf(3,:))
    
    
%end; 

plotconfusion(mejor_test,mejor_output_test);
view(rna);
