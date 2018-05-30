
%%%%%%%Procesamiento de los datos de entrada%%%%%%%%%%7
%Entradas -> base de datos de matlab
%salidas  -> 1.-Datos de entrada al sistema de aprendizaje
%            2.-Datos de salida esperados


function [data_input, data_output] = load_BD_3iter(database)
%paciente nº1
db_name = 'C:\Users\Alejandro\Documents\Clase\2017-2018\AA\sleep-EDF.mat';

    database = load(db_name)
    p1 = database.sc4002e0;
    
    hypnoMax = size(p1.Hypnogram);
    hypno = p1.Hypnogram(1:hypnoMax-1); %Eliminamos el ultimo dato, que es invalido
    hypno = transpose(hypno);

    %Ajustamos la temperatura y el EEG para que los intervalos coincidan con
    %los del hipnograma
    temp = p1.Temp_body;
    tempAux = reshape(temp, 30, []);
    tempMedia = mean(tempAux);
    tempStd = std(tempAux);

    EEG      = p1.EEG_Fpz_Cz;
    EEGAux   = reshape(EEG, 3000, []);
    EEGMedia = mean(EEGAux);
    EEGStd   = std(EEGAux);    
    
   
    EEG_fourier = (abs(fft(p1.EEG_Fpz_Cz)));
    EEG_fourier_aux = reshape(EEG_fourier, 3000, []);
    EEG_fourier_mean = mean(EEG_fourier_aux);
    EEG_fourier_std  = std(EEG_fourier_aux);
    
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:hypnoMax-1
        if hypno(i) ~= 0
            EEG0(i) = 0;
        else
            EEG0(i) = 1;
        end
    end
    for i = 1:hypnoMax-1
        if hypno(i) ~= 1
            EEG1(i) = 0;
        else
            EEG1(i) = 1;
        end
    end
    for i = 1:hypnoMax-1
        if hypno(i) ~= 4
            EEG4(i) = 0;
        else
            EEG4(i) = 1;
        end
    end
    for i = 1:hypnoMax-1
        if hypno(i) ~= 5
            EEG5(i) = 0;
        else
            EEG5(i) = 1;
        end
    end
    figure(1);
    subplot(4,1,1);
    plot(EEG0);

    subplot(4,1,2);
    plot(EEG1);
    subplot(4,1,3);
    plot(EEG4);

    subplot(4,1,4);
    plot(EEG5);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %trans(i,:) = transformada;
    
    %band_0_5  = (get_band(EEG_fourier,0,5));
    %band_5_10 = (get_band(EEG_fourier,5,10));

    %plot(band_0_5)
   
    %figure(2)
    %plot(EEG_fourier)
    %{ 
    qmf = MakeONFilter('Haar',3)
    
    EEG_wavelet      = FWT_PO(p1.EEG_Fpz_Cz,3,qmf);
    EEG_wavelet_aux  = reshape(EEG_wavelet, 3000, []);
    EEG_wavelet_mean = mean(EEG_wavelet_aux);
    EEG_wavelet_std  = std(EEG_wavelet_aux); 
    %}
    tempMax = size(p1.Temp_body);
    netInput = [tempMedia; tempStd; EEGMedia; EEGStd;EEG_fourier_mean; EEG_fourier_std; hypno];

    expected_result = netInput(7,:);

    %Eliminamos valores incorrectos
    for i = 1:hypnoMax-1
        if netInput(5, i) == 9
            netInput(:,i) = [];
        end;
    end;

    %We simplify the hypnogram data so:
    % 0 -> awake
    % 1 -> light sleep or rem
    % 2 -> the rest of the phases
    for i = 1:hypnoMax-1          
        if netInput(5,i) == 0;
           netInput(5,i) = 0;
        else if (netInput(5,i) == 1 || netInput(5,i) == 5)
                 netInput(5,i) = 1;
            else
                netInput(5,i) = 2;
            end
        end;    
    end;
    data_input  = netInput(1:6,:);
    data_output = netInput(7,:);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%load_BD_3iter('C:\Users\Alejandro\Documents\Clase\2017-2018\AA\sleep-EDF.mat');