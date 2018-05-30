

%Vai extremadamente lento
db_name = 'C:\Users\Alejandro\Desktop\Entrega AA\sleep-EDF.mat';

m = load(db_name);
%numero de veces a entrenar
n = 15;
%iterador global
a = 1;
precisionArray = zeros(n,1);
resultados = zeros(15,5);
%table
errorTest=zeros(n,1);
errorTraining=zeros(n,1);

p1 = m.sc4002e0;

hypnoMax = size(p1.Hypnogram);
hypno = p1.Hypnogram(1:hypnoMax-1); %Eliminamos el ultimo dato, que es invalido
hypno = transpose(hypno);

temp = p1.Temp_body;
tempAux = reshape(temp, 30, []);
tempMedia = mean(tempAux);
tempStd = std(tempAux);

EEG      = p1.EEG_Fpz_Cz;
EEGAux   = reshape(EEG, 3000, []);
EEGMedia = mean(EEGAux);
EEGStd   = std(EEGAux);

tempMax = size(p1.Temp_body);
% 
% figure(1);
% subplot(6,1,1);
% plot(hypno);
% title('Hypno');
% 
% subplot(6,1,2);
% plot(tempMedia);
% title('Temperatura Media');
% 
% subplot(6,1,3);
% plot(tempStd);
% title('Temperatura Desviacion Estandar');
% 
% subplot(6,1,4);
% plot(EEGMedia);
% title('EEG media');
% 
% subplot(6,1,5);
% plot(EEGStd);
% title('EEG Desviacion Estandar');
% hold on;
% %input
netInput = [tempMedia; tempStd; EEGMedia; EEGStd; hypno];

%remove invalid data
for i = 1:hypnoMax-1
    if netInput(5, i) == 9
        netInput(:,i) = [];
    end;
end;
%up down
for i = 1:hypnoMax-1          
    if netInput(5,i) > 0
        netInput(5,i) = 1;
    end;    
end;
kerlens ={'linear','rbf','polynomial'};
%for i = 1:3,
    for aux=4:1:6
        for j = 1:n,%Entenamos
            particion = cvpartition(transpose(netInput(5,:)) , 'HoldOut', aux/10);
            %if (i==3)
                model= fitcsvm(transpose(netInput(1:4,particion.training)), netInput(5,particion.training),'KernelFunction','polynomial','PolynomialOrder',2);
            %else
%                 if (i==2)
%                     model= fitcsvm(transpose(netInput(1:4,particion.training)), netInput(5,particion.training),'KernelFunction', 'rbf');
%                 else 
%                     model= fitcsvm(transpose(netInput(1:4,particion.training)), netInput(5,particion.training),'KernelFunction', 'linear');
%                 end;
%             end;
            % Probar los patrones
            clases = predict(model,transpose(netInput(1:4,particion.test)));
            %funcion confusion
            [c, cm, ind, per] = confusion(netInput(5,particion.test),transpose(clases));
            %
            errorTest(j) = mean(abs(netInput(5,particion.test)-clases'));
            %tempPrecision = 
                VN = per(1,4);
                VP = per(1,3);
                FN = per(1,1);
                FP = per(1,2);
                precision = (VN+VP)/(VN+VP+FN+FP);
                precisionArray(j) = precision;
                clases = predict(model,transpose(netInput(1:4,particion.training))); 
            errorTraining(j) = mean(abs(netInput(5,particion.training)-clases'));
                
        end;
    mediaPrecision= mean(nonzeros(precisionArray));
    desviacionPrecision= std(nonzeros(precisionArray));
    resultados(a,1)=aux/10;
    resultados(a,2)= mediaPrecision;
    resultados(a,3)= desviacionPrecision;
    resultados(a,4)=mean(errorTest);
    resultados(a,5)=mean(errorTraining);
    a=a+1;
    end;
%end;