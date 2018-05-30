clear all;
close all;

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

%array preallocation
precision_array_test = 1:50;
precision_array_training = 1:50;
precision_mean_test = 1:50;
precision_std_test = 1:50;
precision_mean_training = 1:50;
precision_std_training = 1:50;

%Entrenamiento de 1 a 50 vecinos
for neighbors = 1:50
    for i = 1:50
        partition = cvpartition(output_expected_data, 'HoldOut', 0.2);
        training_input   = input_data(partition.training);
        training_expected_output  = output_expected_data(partition.training);
        
        model  = fitcknn(training_input,training_expected_output,'NumNeighbors',neighbors);
        
        test_input  = input_data(partition.test);
        test_output = predict(model, test_input);
        training_output = predict(model, training_input);
        test_output = test_output';
        training_output = training_output';
        
        %calculo precision test
        test_output_expected        = output_expected_data(partition.test);
        binary_test_output_expected = [ ismember(test_output_expected, 6)
                                        ismember(test_output_expected, 5)
                                        ismember(test_output_expected, 3) 
                                        ismember(test_output_expected, 2) 
                                        ismember(test_output_expected,1) 
                                        ismember(test_output_expected,0)];
                                    
        binary_test_output          = [ ismember(test_output, 6)
                                        ismember(test_output, 5)
                                        ismember(test_output, 3)
                                        ismember(test_output, 2)
                                        ismember(test_output, 1)
                                        ismember(test_output, 0)];
                                    
        aux_precision_array_test = mean(binary_test_output_expected==binary_test_output);
        precision_array_test(i) = mean(aux_precision_array_test);
        
        %calculo precision training
        training_output_expected        = output_expected_data(partition.training);
        binary_training_output_expected = [ismember(training_output_expected,6)
                                        ismember(training_output_expected,5) 
                                        ismember(training_output_expected,3)
                                        ismember(training_output_expected,2)
                                        ismember(training_output_expected,1) 
                                        ismember(training_output_expected,0)];
        binary_training_output          = [ismember(training_output, 6)
                                        ismember(training_output, 5)
                                        ismember(training_output, 3)
                                        ismember(training_output, 2)
                                        ismember(training_output, 1)
                                        ismember(training_output, 0)];
                                    
        aux_precision_array_training = mean(binary_training_output_expected==binary_training_output);
        precision_array_training(i) = mean(aux_precision_array_training);
        
        
    
    end
    precision_mean_test(neighbors) = mean(precision_array_test);
    precision_std_test(neighbors) = std(precision_array_test);
    precision_mean_training(neighbors) = mean(precision_array_training);
    precision_std_training(neighbors) = std(precision_array_training);
end
figure(1);
subplot(4,1,1);
plot(precision_mean_test);
title('Precision del test por numero de vecinos');

subplot(4,1,2);
plot(precision_std_test);
title('Desviacion de la precision del test por numero de vecinos');

subplot(4,1,3);
plot(precision_mean_training);
title('Precision del entrenamiento por numero de vecinos');

subplot(4,1,4);
plot(precision_std_training);
title('Desviacion de la precision del entrenamiento por numero de vecinos');

