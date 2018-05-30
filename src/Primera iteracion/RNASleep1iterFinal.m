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


db_name = 'C:\Users\Alejandro\Desktop\Entrega AA\sleep-EDF.mat';

patient_data = load_BD1iter(load(db_name));
input_data  = patient_data(1:4,:);
output_expected_data = patient_data(5,:);

hypno = output_expected_data;

figure(1);
subplot(6,1,1);
plot(hypno);
title('Hypno');

tempMedia = input_data(1,:);

subplot(6,1,2);
plot(tempMedia);
title('Temperatura Media');

tempStd = input_data(2,:);

subplot(6,1,3);
%plot(tempStd);
title('Temperatura Desviación Estándar');

EEGMedia = input_data(3,:);

subplot(6,1,4);
plot(EEGMedia);
title('EEG media');

EEGStd = input_data(4,:);

subplot(6,1,5);
plot(EEGStd);
title('EEG Desviación Estándar');



precision_array_training = zeros(10);
mean_precision_training = 1:10;
std_precision_training = 1:10;
conf = 1:10;
mejor_configuracion = 1;

for hidden_layers = 1:10;
    for j = 1:10,%Creamos e entrenamos a rede x veces
        rna = patternnet(hidden_layers);
        rng('shuffle');
        % partition = cvpartition(output_expected_data,'HoldOut',0.2);
    
        rna.trainParam.showWindow = false;
        [rna,tr] = train(rna, input_data, output_expected_data);
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
        
        % Confusión para cada conjunto
        conf_test = confusion(output_expected_data(:,tr.testInd),output_test);
        conf_train = confusion(output_expected_data(:,tr.trainInd),output_train);
        conf_val = confusion(output_expected_data(:,tr.valInd),output_val);
        conf(1,j) = conf_test;
        conf(2,j) = conf_train;
        conf(3,j) = conf_val;
        
        % Guardamos los datos de la mejor RNA
        if (conf_test < mejor_configuracion)
            mejor_rna = rna;
            mejor_test = output_expected_data(:,tr.testInd);
            mejor_output_test = output_test;
            mejor_configuracion = conf_test;
        end
         
        hypnoMax = size(hypno);       
        for k = 1:hypnoMax-1  
            if rna_outputs(k)>0.5 
                rna_outputs(k) = 1;
            else
                rna_outputs(k) = 0;
            end;
        end;
               
        %precision, no error 
        %funcion confusion
        % [c, cm, ind, per] = confusion(output_train,rna_outputs);
        %tempPrecision = 
        %VN = per(1,4);
        %VP = per(1,3);
        %FN = per(1,1);
        %FP = per(1,2);
        %precision_training = (VN+VP)/(VN+VP+FN+FP);
        %precision_array_training(j) = precision_training;
        %
        
    end;
    % Media de las confusiones
    meanc_test(hidden_layers) = mean(conf(1,:));
    meanc_train(hidden_layers) = mean(conf(2,:));
    meanc_val(hidden_layers) = mean(conf(3,:));
    desvc_test(hidden_layers) = std(conf(1,:));
    desvc_train(hidden_layers) = std(conf(2,:));
    desvc_val(hidden_layers) = std(conf(3,:));
    
    
end; 

plotconfusion(mejor_test,mejor_output_test);
