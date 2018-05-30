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

db_name = 'C:\Users\Alejandro\Desktop\Entrega AA\sleep-EDF.mat';
[input_data, output_expected_data] = load_BD_3iter(db_name);

precision_array = 1:50;
precision_mean = 1:50;
precision_std = 1:50;

for i = 1:2830;
    if (output_expected_data(i) == 0)
        output_expected_array(1,i) = 1;
        output_expected_array(2,i) = 0;
        output_expected_array(3,i) = 0;
    end
    
    if (output_expected_data(i) == 1)
        output_expected_array(1,i) = 0;
        output_expected_array(2,i) = 1;
        output_expected_array(3,i) = 0;
    end
    
    if (output_expected_data(i) == 2)
        output_expected_array(1,i) = 0;
        output_expected_array(2,i) = 0;
        output_expected_array(3,i) = 1;
    end
end

    %for i = 1:3
        partition = cvpartition(output_expected_data, 'HoldOut', 0.2);
        input_training   = input_data(partition.training);
        input_test = input_data(partition.test);
        %output_training  = output_expected_data(partition.training);
        
        modelawaken  = fitcsvm(input_training, output_expected_array(1,partition.training),'KernelFunction', 'rbf');
        modelrem = fitcsvm(input_training, output_expected_array(2,partition.training),'KernelFunction', 'rbf');
        modelrest = fitcsvm(input_training, output_expected_array(3,partition.training),'KernelFunction', 'rbf');
        
                    if (i==3)
                         modelawaken  = fitcsvm(input_training, output_expected_array(1,partition.training),'KernelFunction','polynomial','PolynomialOrder',2);
                         modelrem = fitcsvm(input_training, output_expected_array(2,partition.training),'KernelFunction','polynomial','PolynomialOrder',2);
                         modelrest = fitcsvm(input_training, output_expected_array(3,partition.training),'KernelFunction','polynomial','PolynomialOrder',2);
                    else
                 if (i==2)
                       modelawaken  = fitcsvm(input_training, output_expected_array(1,partition.training),'KernelFunction', 'rbf');
                       modelrem = fitcsvm(input_training, output_expected_array(2,partition.training),'KernelFunction', 'rbf');
                       modelrest = fitcsvm(input_training, output_expected_array(3,partition.training),'KernelFunction', 'rbf');
                 else 
                     modelawaken  = fitcsvm(input_training, output_expected_array(1,partition.training),'KernelFunction', 'linear');
                     modelrem = fitcsvm(input_training, output_expected_array(2,partition.training),'KernelFunction', 'linear');
                     modelrest = fitcsvm(input_training, output_expected_array(3,partition.training),'KernelFunction', 'linear');
                 end;
             end;
        
        
        % Transformate the model in order to get probabilities instead of scores.
        modelwaken = fitSVMPosterior(modelrem);
        modelrem = fitSVMPosterior(modelrem);
        modelrest = fitSVMPosterior(modelrest);
        
        [outputswaken_test, scoreswaken] = predict(modelwaken, input_test);
        [outputsrem_test, scoresrem] = predict(modelrem, input_test);
        [outputsrest_test, scoresrest] = predict(modelrest, input_test);
        
        
        outputswaken_test=outputswaken_test';
        outputsrem_test=outputsrem_test';
        outputsrest_test=outputsrest_test';
       
        %precisiones test
        test_output_expected_awaken= output_expected_array(1,partition.test);
        test_output_expected_rem= output_expected_array(2,partition.test);
        test_output_expected_rest= output_expected_array(3,partition.test);

        binary_test_output_expected_awake = [ismember(test_output_expected_awaken,1) 
                                        ismember(test_output_expected_awaken,0)];
        binary_test_output_expected_rem = [ismember(test_output_expected_rem,1) 
                                        ismember(test_output_expected_rem,0)];
        binary_test_output_expected_rest = [ismember(test_output_expected_rest,1) 
                                        ismember(test_output_expected_rest,0)];
                                    
        binary_test_outputwaken= [ismember(outputswaken_test, 1)
                                        ismember(outputswaken_test, 0)]; 
        binary_test_outputrem= [ismember(outputsrem_test, 1)
                                        ismember(outputsrem_test, 0)];
        binary_test_outputrest= [ismember(outputsrest_test, 1)
                                        ismember(outputsrest_test, 0)];
        %calculo precision test
        aux_precision_array_awaken_test = mean(binary_test_output_expected_awake==binary_test_outputwaken);
        aux_precision_array_rem_test = mean(binary_test_output_expected_rem==binary_test_outputrem);
        aux_precision_array_rest_test = mean(binary_test_output_expected_rest==binary_test_outputrest);
        precision_array_awake(i) = mean(aux_precision_array_awaken_test);
        precision_array_rem(i) = mean(aux_precision_array_rem_test);
        precision_array_rest(i) = mean(aux_precision_array_rest_test);
        precision_mean_awake = mean(aux_precision_array_awaken_test)
        precision_mean_rem = mean(aux_precision_array_rem_test)
        precision_mean_rest = mean(aux_precision_array_rest_test)

        precision_std_awake = std(aux_precision_array_awaken_test)
        precision_std_rem = std(aux_precision_array_rem_test)
        precision_std_rest = std(aux_precision_array_rest_test)
        
        %precisiones training
        
        [outputswaken_training, scoreswaken] = predict(modelwaken, input_training);
        [outputsrem_training, scoresrem] = predict(modelrem, input_training);
        [outputsrest_training, scoresrest] = predict(modelrest, input_training);
        
        
        outputswaken_training=outputswaken_training';
        outputsrem_training=outputsrem_training';
        outputsrest_training=outputsrest_training';
        
        training_output_expected_awaken= output_expected_array(1,partition.training);
        training_output_expected_rem= output_expected_array(2,partition.training);
        training_output_expected_rest= output_expected_array(3,partition.training);

        binary_training_output_expected_awake = [ismember(training_output_expected_awaken,1) 
                                        ismember(training_output_expected_awaken,0)];
        binary_training_output_expected_rem = [ismember(training_output_expected_rem,1) 
                                        ismember(training_output_expected_rem,0)];
        binary_training_output_expected_rest = [ismember(training_output_expected_rest,1) 
                                        ismember(training_output_expected_rest,0)];
                                    
        binary_training_outputwaken= [ismember(outputswaken_training, 1)
                                        ismember(outputswaken_training, 0)];
        binary_training_outputrem= [ismember(outputsrem_training, 1)
                                        ismember(outputsrem_training, 0)];
        binary_training_outputrest= [ismember(outputsrest_training, 1)
                                        ismember(outputsrest_training, 0)];
        %calculo precision trainnig
        
        aux_precision_array_awaken_training = mean(binary_training_output_expected_awake==binary_training_outputwaken);
        aux_precision_array_rem_training = mean(binary_training_output_expected_rem==binary_training_outputrem);
        aux_precision_array_rest_training = mean(binary_training_output_expected_rest==binary_training_outputrest);
        
        precision_array_awake_training(i) = mean(aux_precision_array_awaken_training);
        precision_array_rem_training(i) = mean(aux_precision_array_rem_training);
        precision_array_rest_training(i) = mean(aux_precision_array_rest_training);
        
        precision_mean_awake_training = mean(aux_precision_array_awaken_training)
        precision_mean_rem_training = mean(aux_precision_array_rem_training)
        precision_mean_rest_training = mean(aux_precision_array_rest_training)

        precision_std_awake_training = std(aux_precision_array_awake_training)
        precision_std_rem_training = std(aux_precision_array_rem_training)
        precision_std_rest_training = std(aux_precision_array_rest_training)
        
    %end


