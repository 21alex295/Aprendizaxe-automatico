
%%%%%%%Procesamiento de los datos de entrada%%%%%%%%%%7
%Entradas -> base de datos de matlab
%salidas  -> 1.-Datos de entrada al sistema de aprendizaje
%            2.-Datos de salida esperados


function [data_input, data_output] = load_BD(database)
%paciente nº1
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

    tempMax = size(p1.Temp_body);
    netInput = [tempMedia; tempStd; EEGMedia; EEGStd; hypno];

    expected_result = netInput(5,:);

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
    data_input = netInput;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
