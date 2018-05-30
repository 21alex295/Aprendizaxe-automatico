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



precision_array = 1:50;
precision_mean = 1:50;
precision_std = 1:50;
for i = 1:length(output_expected_data -1);
    %soño lixeiro
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
    %soño profundo
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

    %for i = 1:3
        partition = cvpartition(output_expected_data, 'HoldOut', 0.2);
        input_training   = input_data(partition.training);
        input_test = input_data(partition.test);
        %output_training  = output_expected_data(partition.training);
        
        model_lightsleep = fitcsvm(input_training, output_expected_array(1,partition.training),'KernelFunction', 'rbf');
        model_sleep = fitcsvm(input_training, output_expected_array(2,partition.training),'KernelFunction', 'rbf');
        model_deepsleep = fitcsvm(input_training, output_expected_array(3,partition.training),'KernelFunction', 'rbf');
        model_rem = fitcsvm(input_training, output_expected_array(3,partition.training),'KernelFunction', 'rbf');

%         if (i==3)
%              model_awaken  = fitcsvm(input_training, output_expected_array(1,partition.training),'KernelFunction','polynomial','PolynomialOrder',2);
%              model_lightsleep = fitcsvm(input_training, output_expected_array(2,partition.training),'KernelFunction','polynomial','PolynomialOrder',2);
%              model_sleep = fitcsvm(input_training, output_expected_array(3,partition.training),'KernelFunction','polynomial','PolynomialOrder',2);
%         else
%             if (i==2)
%                model_awaken  = fitcsvm(input_training, output_expected_array(1,partition.training),'KernelFunction', 'rbf');
%                model_lightsleep = fitcsvm(input_training, output_expected_array(2,partition.training),'KernelFunction', 'rbf');
%                model_sleep = fitcsvm(input_training, output_expected_array(3,partition.training),'KernelFunction', 'rbf');
%             else 
%                 model_awaken  = fitcsvm(input_training, output_expected_array(1,partition.training),'KernelFunction', 'linear');
%                 model_lightsleep = fitcsvm(input_training, output_expected_array(2,partition.training),'KernelFunction', 'linear');
%                 model_sleep = fitcsvm(input_training, output_expected_array(3,partition.training),'KernelFunction', 'linear');
%             end;
%          end;
        
        
        % Transformate the model in order to get probabilities instead of scores.
        model_lightsleep = fitSVMPosterior(model_lightsleep);
        model_sleep = fitSVMPosterior(model_sleep);
        model_deepsleep = fitSVMPosterior(model_deepsleep);
        model_rem = fitSVMPosterior(model_rem);
        
        [outputs_lightsleep_test, scores_lightsleep] = predict(model_lightsleep, input_test);
        [outputs_sleep_test, scores_sleep] = predict(model_sleep, input_test);
        [outputs_deepsleep_test, scores_deepsleep] = predict(model_deepsleep, input_test);
        [outputs_rem_test, scores_rem] = predict(model_rem, input_test);

        
        outputs_lightsleep_test=outputs_lightsleep_test';
        outputs_sleep_test=outputs_sleep_test';       
        outputs_deepsleep_test=outputs_deepsleep_test';
        outputs_rem_test=outputs_rem_test';
        
        
        %precisiones test
        test_output_expected_lightsleep= output_expected_array(1,partition.test);
        test_output_expected_sleep= output_expected_array(2,partition.test);
        test_output_expected_deepsleep= output_expected_array(3,partition.test);
        test_output_expected_rem= output_expected_array(4,partition.test);


        binary_test_output_expected_lightsleep = [ismember(test_output_expected_lightsleep,1) 
                                        ismember(test_output_expected_lightsleep,0)];
        binary_test_output_expected_sleep = [ismember(test_output_expected_sleep,1) 
                                        ismember(test_output_expected_sleep,0)];
        binary_test_output_expected_deepsleep = [ismember(test_output_expected_deepsleep,1) 
                                        ismember(test_output_expected_deepsleep,0)];
        binary_test_output_expected_rem = [ismember(test_output_expected_rem,1) 
                                        ismember(test_output_expected_rem,0)];                                                       
                                    

        binary_test_output_lightsleep= [ismember(outputs_lightsleep_test, 1)
                                        ismember(outputs_lightsleep_test, 0)];
        binary_test_output_sleep= [ismember(outputs_sleep_test, 1)
                                        ismember(outputs_sleep_test, 0)];
        binary_test_output_deepsleep= [ismember(outputs_deepsleep_test, 1)
                                        ismember(outputs_deepsleep_test, 0)];
        binary_test_output_rem= [ismember(outputs_rem_test, 1)
                                        ismember(outputs_rem_test, 0)];

        %calculo precision test
        aux_precision_array_lightsleep_test = mean(binary_test_output_expected_lightsleep==binary_test_output_lightsleep);
        aux_precision_array_sleep_test = mean(binary_test_output_expected_sleep==binary_test_output_sleep);
        aux_precision_array_deepsleep_test = mean(binary_test_output_expected_deepsleep==binary_test_output_deepsleep);
        aux_precision_array_rem_test = mean(binary_test_output_expected_rem==binary_test_output_rem);

      
        
        precision_array_lightsleep(i) = mean(aux_precision_array_lightsleep_test);
        precision_array_sleep(i) = mean(aux_precision_array_sleep_test);
        precision_array_deepsleep(i) = mean(aux_precision_array_deepsleep_test);
        precision_array_rem(i) = mean(aux_precision_array_rem_test);

        precision_mean_ligthsleep = mean(aux_precision_array_lightsleep_test)
        precision_mean_sleep = mean(aux_precision_array_sleep_test)
        precision_mean_deepsleep = mean(aux_precision_array_deepsleep_test)
        precision_mean_rem = mean(aux_precision_array_rem_test)

        precision_std_lightsleep = std(aux_precision_array_lightsleep_test)
        precision_std_sleep = std(aux_precision_array_sleep_test)
        precision_std_deepsleep = std(aux_precision_array_deepsleep_test)
        precision_std_rem = std(aux_precision_array_rem_test)
        
        %precisiones training
        
        [outputs_ligthsleep_training, scores_lightsleep] = predict(model_lightsleep, input_training);
        [outputs_sleep_training, scores_sleep] = predict(model_sleep, input_training);
        [outputs_deepsleep_training, scores_deepsleep] = predict(model_deepsleep, input_training);
        [outputs_rem_training, scores_rem] = predict(model_rem, input_training);
        
        
        outputs_ligthsleep_training=outputs_ligthsleep_training';
        outputs_sleep_training=outputs_sleep_training';
        outputs_deepsleep_training=outputs_deepsleep_training';
        outputs_rem_training=outputs_rem_training';
        
        training_output_expected_lightsleep= output_expected_array(1,partition.training);
        training_output_expected_sleep= output_expected_array(2,partition.training);
        training_output_expected_deepsleep= output_expected_array(3,partition.training);
        training_output_expected_rem= output_expected_array(4,partition.training);

        binary_training_output_expected_lightsleep = [ismember(training_output_expected_lightsleep,1) 
                                        ismember(training_output_expected_lightsleep,0)];
        binary_training_output_expected_sleep = [ismember(training_output_expected_sleep,1) 
                                        ismember(training_output_expected_sleep,0)];
        binary_training_output_expected_deepsleep = [ismember(training_output_expected_deepsleep,1) 
                                        ismember(training_output_expected_deepsleep,0)];
        binary_training_output_expected_rem = [ismember(training_output_expected_rem,1) 
                                        ismember(training_output_expected_rem,0)];

                                                                                                            

        binary_training_output_ligthsleep= [ismember(outputs_ligthsleep_training, 1)
                                        ismember(outputs_ligthsleep_training, 0)];
        binary_training_output_sleep= [ismember(outputs_sleep_training, 1)
                                        ismember(outputs_sleep_training, 0)];
        binary_training_output_deepsleep= [ismember(outputs_deepsleep_training, 1)
                                        ismember(outputs_deepsleep_training, 0)];
        binary_training_output_rem= [ismember(outputs_rem_training, 1)
                                        ismember(outputs_rem_training, 0)];


                
                
                
                                    
        %calculo precision trainnig
        
        aux_precision_array_lightsleep_training = mean(binary_training_output_expected_lightsleep==binary_training_output_ligthsleep);
        aux_precision_array_sleep_training = mean(binary_training_output_expected_sleep==binary_training_output_sleep);
        aux_precision_array_deepsleep_training = mean(binary_training_output_expected_deepsleep==binary_training_output_deepsleep);
        aux_precision_array_rem_training = mean(binary_training_output_expected_rem==binary_training_output_rem);
        
        precision_array_lightsleep_training(i) = mean(aux_precision_array_lightsleep_training);
        precision_array_sleep_training(i) = mean(aux_precision_array_sleep_training);
        precision_array_deepsleep_training(i) = mean(aux_precision_array_deepsleep_training);
        precision_array_rem_training(i) = mean(aux_precision_array_rem_training);
        
        precision_mean_lightsleep_training = mean(aux_precision_array_lightsleep_training)
        precision_mean_sleep_training = mean(aux_precision_array_sleep_training)
        precision_mean_deepsleep_training = mean(aux_precision_array_deepsleep_training)
        precision_mean_rem_training = mean(aux_precision_array_rem_training)

        precision_std_lightsleep_training = std(aux_precision_array_lightsleep_training)
        precision_std_sleep_training = std(aux_precision_array_sleep_training)
        precision_std_deepsleep_training = std(aux_precision_array_deepsleep_training)
        precision_std_rem_training = std(aux_precision_array_rem_training)
        
    %end


