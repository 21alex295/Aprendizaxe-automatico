% Funcion para procesar los datos de un paciente
% 
% -Entrada: -Datos de un paciente
% -Salida:  -Datos de entrada para los algoritmos
%           -Datos de salida esperados para los algoritmos

function [data_input, data_output] = process_data(patient_data)
    
    hypnoMax = size(patient_data.Hypnogram);
    hypno = patient_data.Hypnogram(1:hypnoMax-1); %Eliminamos el ultimo dato, que es invalido
    hypno = transpose(hypno);

    %Ajustamos la temperatura y el EEG para que los intervalos coincidan con
    %los del hipnograma
    
    
    temp = patient_data.Temp_body;
    [tempMedia tempStd] = adjust_to_hypno(temp, 30);

    EEG      = patient_data.EEG_Fpz_Cz;
    [EEGMedia EEGStd] = adjust_to_hypno(EEG, 3000); 
    
    EEG_fourier = (abs(fft(patient_data.EEG_Fpz_Cz)));
    EEG_fourier = EEG_fourier(1:(length(EEG_fourier)/2));
    [EEG_fourier_mean, EEG_fourier_std] = adjust_to_hypno(EEG_fourier, 1500);
    
    
     EEG_fourier_0_5= get_band(EEG_fourier,0, 5);
     EEG_fourier_5_10  = get_band(EEG_fourier,5, 10);

    [EEG_fourier_mean_0_5,  EEG_fourier_std_0_5]  = adjust_to_hypno(EEG_fourier_0_5,75);
    [EEG_fourier_mean_5_10, EEG_fourier_std_5_10] = adjust_to_hypno(EEG_fourier_5_10,75);
        
    
    EEG_wavelet = (cwt(EEGMedia,1, 'sym2' ));
    
    %Paso banda transformada fourier entre f1 e f2%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     for i = 1:hypnoMax-1
%         if hypno(i) ~= 0
%             EEG0(i) = 0;
%         end
%     end
%     for i = 1:hypnoMax-1
%         if hypno(i) ~= 1
%             EEG1(i) = 0;
%         end
%     end
%     for i = 1:hypnoMax-1
%         if hypno(i) ~= 4
%             EEG4(i) = 0;
%         end
%     end
%     for i = 1:hypnoMax-1
%         if hypno(i) ~= 5
%             EEG5(i) = 0;
%         end
%     end
% 
%     figure(1);
%     subplot(5,1,1);
%     plot(abs(fft(EEG0)));
% 
%     subplot(5,1,2);
%     plot(abs(fft(EEG1)));
%     subplot(5,1,3);
%     plot(abs(fft(EEG4)));
% 
%     subplot(5,1,4);
%     plot(abs(fft(EEG5)));
%     subplot(5,1,5);
%     plot(EEG_fourier_mean)
%     title('Transformada media');
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
    netInput = [EEGMedia; EEGStd;EEG_fourier_mean; 
        EEG_fourier_std;EEG_fourier_mean_0_5;EEG_fourier_std_0_5;
        EEG_fourier_mean_5_10 ; hypno];
  %   netInput = [tempMedia; tempStd; EEGMedia; EEGStd;EEG_wavelet ; hypno];


    %Eliminamos valores incorrectos
    netInput = netInput(:,(netInput(end,:)~=0));
    netInput = netInput(:,(netInput(end,:)~=6));
    netInput = netInput(:,(netInput(end,:)~=9));
    %We simplify the hypnogram data so:
    % 0 -> awake
    % 1 -> light sleep or rem
    % 2 -> the rest of the phases
    
    %for the last iteration, we take the hypnogram with all the data
    %but in latest studies, phases 3 and 4 are the same (before deep sleep 
    %and deep sleep) so those two are combined in one

    for i = 1:length(netInput(8,:))         
        if (netInput(8,i) == 4)
                 netInput(8,i) = 3;
        end;    
    end;
    data_input  = netInput(1:7,:);
    data_output = netInput(8,:);
end


