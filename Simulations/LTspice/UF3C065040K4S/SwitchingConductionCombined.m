% This script is written for seperation of conduction and switching loss

%% LTSPice to Matlab
% Bipolar_UF3C065040K4S_Raw = LTspice2Matlab('Bipolar_UF3C065040K4S_DeadTime.raw');
% Unipolar_UF3C065040K4S_Raw = LTspice2Matlab('Unipolar_UF3C065040K4S_DeadTime.raw');
ModifiedUnipolar_UF3C065040K4S_Raw = LTspice2Matlab('ModifiedUnipolar_UF3C065040K4S_DeadTime.raw');
Vdc = 400;
Tsw = 1/50e3;
%% Bipolar Voltage-Current Array definitions 
t = Bipolar_UF3C065040K4S_Raw.time_vect;
Vsw_DS = Bipolar_UF3C065040K4S_Raw.variable_mat(10,:)-Bipolar_UF3C065040K4S_Raw.variable_mat(8,:);
Isw_S = Bipolar_UF3C065040K4S_Raw.variable_mat(45,:);
%% Unipolar Voltage-Current Array definitions 
t = Unipolar_UF3C065040K4S_Raw.time_vect;
Vsw_DS = Unipolar_UF3C065040K4S_Raw.variable_mat(10,:)-Unipolar_UF3C065040K4S_Raw.variable_mat(8,:);
Isw_S = Unipolar_UF3C065040K4S_Raw.variable_mat(45,:);
%% Modified Unipolar Voltage-Current Array definitions
% S1 High Freq
t = ModifiedUnipolar_UF3C065040K4S_Raw.time_vect;
Vsw_DS = ModifiedUnipolar_UF3C065040K4S_Raw.variable_mat(10,:)-...
    ModifiedUnipolar_UF3C065040K4S_Raw.variable_mat(8,:);
Isw_S = ModifiedUnipolar_UF3C065040K4S_Raw.variable_mat(47,:);
% S3 Low Freq
% t = ModifiedUnipolar_UF3C065040K4S_Raw.time_vect;
% Vsw_DS = ModifiedUnipolar_UF3C065040K4S_Raw.variable_mat(10,:)-...
%     ModifiedUnipolar_UF3C065040K4S_Raw.variable_mat(9,:);
% Isw_S = ModifiedUnipolar_UF3C065040K4S_Raw.variable_mat(55,:);

%% NaN Value Elimination with Average
for i = 1:numel(t)
    if (isnan(Vsw_DS(i)))
        a = 0;
        count = 0;
        for j = -3:3
            if (isnan(Vsw_DS(i+j)) == 0)
                a = a + Vsw_DS(i+j);
                count = count + 1;
            end
        end
        Vsw_DS(i) = a/count;
    end
    if (isnan(Isw_S(i)))
        a = 0;
        count = 0;
        for j = -3:3
            if (isnan(Isw_S(i+j)) == 0)
                a = a + Isw_S(i+j);
                count = count + 1;
            end
        end
        Isw_S(i) = a/count;
    end
end

%% Total Loss of Semiconductors
T = 0;
for i = 1:numel(t)-1
    %Esw(i) = Vsw_DS1(i)*Isw_1(i)*t(i);
    Esw(i) = (Vsw_DS(i+1)+Vsw_DS(i))*0.5*(Isw_S(i+1)+Isw_S(i))*0.5*(t(i+1)-t(i));
    if (isnan(Esw(i)) == 0)
        T = T + Esw(i);
    end
end
Psw = T*50;

%% General Loss Calculation for switching and conduction - Loss Calculations
[tTurnOnArray,tTransitionONtoOFFArray,tTurnOffArray,tTransitionOFFtoONArray]= ...
    FuncTurnOnOffArrays(t,Vsw_DS,Vdc,Tsw);
for i = 1:(numel(tTurnOnArray)-1)
    TurnOffLoss = 0;
    j = 0;
    while j < tTurnOffArray(i)-tTransitionONtoOFFArray(i)
        TurnOffLoss = TurnOffLoss + [Vsw_DS(tTransitionONtoOFFArray(i)+j)+...
            Vsw_DS(tTransitionONtoOFFArray(i)+j+1)]*0.5*...
            [Isw_S(tTransitionONtoOFFArray(i)+j)+Isw_S(tTransitionONtoOFFArray(i)+j+1)]*...
            0.5*(t(tTransitionONtoOFFArray(i)+j+1)-t(tTransitionONtoOFFArray(i)+j));
        j = j+1;
    end
    TurnOnLossArray(i) = TurnOffLoss;

    TurnOnLoss = 0;
    j = 0;
    while j < tTurnOnArray(i+1)-tTransitionOFFtoONArray(i)
        TurnOnLoss = TurnOnLoss + [Vsw_DS(tTransitionOFFtoONArray(i)+j)+...
            Vsw_DS(tTransitionOFFtoONArray(i)+j+1)]*0.5*...
            [Isw_S(tTransitionOFFtoONArray(i)+j)+Isw_S(tTransitionOFFtoONArray(i)+j+1)]...
            *0.5*(t(tTransitionOFFtoONArray(i)+j+1)-t(tTransitionOFFtoONArray(i)+j));
        j = j+1;
    end
    TurnOffLossArray(i) = TurnOnLoss;

    ConductionLoss = 0;
    j = 0;
    while j < tTransitionONtoOFFArray(i)-tTurnOnArray(i)
        ConductionLoss = ConductionLoss + [Vsw_DS(tTurnOnArray(i)+j)+...
            Vsw_DS(tTurnOnArray(i)+j+1)]*0.5*...
            [Isw_S(tTurnOnArray(i)+j)+Isw_S(tTurnOnArray(i)+j+1)]*...
            0.5*(t(tTurnOnArray(i)+j+1)-t(tTurnOnArray(i)+j));
        j = j+1;
    end
    ConductionLossArray(i) = ConductionLoss;
end
PswTurnOn = sum(TurnOnLossArray)*50;
PswTurnOff = sum(TurnOffLossArray)*50;
Pconduction = sum(ConductionLossArray)*50;
PswLoss = PswTurnOn + PswTurnOff;
PtotalCalc = PswLoss + Pconduction;

%% Plot
% Some figure formatting
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');

figure(1);
subplot(2,1,1)
plot(t,Bipolar_UF3C065040K4S_Raw.variable_mat(41,:))
legend({'Load Current'},'FontSize',14)
title('$ILoad_{RMS}$')
xlabel('Time')
ylabel('Current (A)')
ylim([-40 40])
xlim([1e-3 21e-3])
set(findall(gcf,'Type','line'),'LineWidth',2)
set(findall(gcf,'-property','FontSize'),'FontSize',14);

xLoss = linspace(1,999,999);
subplot(2,1,2)
plot(xLoss,TurnOnLossArray.*50,xLoss,TurnOffLossArray.*50);
legend({'Turn On Loss','Turn Off Loss'},'FontSize',14)
title('Switching Loss in a Period')
xlabel('Switching Instants')
ylabel('Power (W)')
ylim([-5e-3 20e-3])
set(findall(gcf,'Type','line'),'LineWidth',2)
set(findall(gcf,'-property','FontSize'),'FontSize',14);




%% Function of Turn on region
function [tTurnOn,indextTurnOn] = FuncTurnOn(t,Vsw_DS,indexStart,Vdc,Tsw)
for i = indexStart:numel(t)
    StableIndicator = 0; % Indicator for ringing 
    if (abs(Vsw_DS(i))<= 0.02*Vdc)
        j = 0;
        t1 = t(i);
        StableIndicator = 1;
        while t(i+j) <= t1+0.01*Tsw % wait for %1 of Tsw for stabilization
            if (abs(Vsw_DS(i+j)) > 0.02*Vdc)
                StableIndicator = 0;
                break
            end
            j = j+1;
        end
    end
    if (StableIndicator == 1)
        indextTurnOn = i+j;
        tTurnOn = t(i+j);
        break;
    end
end
end
%% Function of transition from turn on to turn off
function [tTransitionONtoOFF,indextTransitionONtoOFF] = FuncTransitionONtoOFF(t,Vsw_DS,...
    indexStart,Vdc,Tsw)

for i = indexStart:numel(t)
    if (abs(Vsw_DS(i)) > 0.05*Vdc)
        tTransitionONtoOFF = t(i);
        indextTransitionONtoOFF = i;
        break;
    end
end
end
%% Function of Turn off region
function [tTurnOff,indextTurnOff] = FuncTurnOff(t,Vsw_DS,indexStart,Vdc,Tsw)

for i = indexStart:numel(t)
    StableIndicator = 0;
    if (0.98*Vdc <= Vsw_DS(i) <= 1.02*Vdc)
        j = 0;
        t1 = t(i);
        StableIndicator = 1;
        while t(i+j) <= t1+0.01*Tsw
            if ((Vsw_DS(i+j) < 0.98*Vdc) & (Vsw_DS(i+j) > 1.02*Vdc))
                StableIndicator = 0;
                break
            end
            j = j+1;
        end
    end
    if (StableIndicator == 1)
        indextTurnOff = i+j;
        tTurnOff = t(i+j);
        break;
    end
end
end
%% Function of transition from turn off to turn on
function [tTransitionOFFtoON,indextTransitionOFFtoON] = FuncTransitionOFFtoON(t,Vsw_DS,...
    indexStart,Vdc,Tsw)

for i = indexStart:numel(t)
    if (abs(Vsw_DS(i)) < 0.95*Vdc)
        tTransitionOFFtoON = t(i);
        indextTransitionOFFtoON = i;
        break;
    end
end
end
%% Function of turn on off arrays (On, off & transition)
function [tTurnOnArray,tTransitionONtoOFFArray,tTurnOffArray,tTransitionOFFtoONArray]= ...
    FuncTurnOnOffArrays(t,Vsw_DS,Vdc,Tsw)

init = 1;
tTurnOn = 0;
i = 1;
while tTurnOn <= (t(numel(t))-2*(1/50e3))
    if init == 1
        [tTurnOn,indextTurnOn] = FuncTurnOn(t,Vsw_DS,1,Vdc,Tsw);
        [tTransitionONtoOFF,indextTransitionONtoOFF] = FuncTransitionONtoOFF(t,Vsw_DS,indextTurnOn,Vdc,Tsw);
        [tTurnOff,indextTurnOff] = FuncTurnOff(t,Vsw_DS,indextTransitionONtoOFF,Vdc,Tsw);
        [tTransitionOFFtoON,indextTransitionOFFtoON] = FuncTransitionOFFtoON(t,Vsw_DS,...
            indextTurnOff,Vdc,Tsw);
        tTurnOnArray(1) = indextTurnOn;
        tTransitionONtoOFFArray(1) = indextTransitionONtoOFF;
        tTurnOffArray(1) = indextTurnOff;
        tTransitionOFFtoONArray(1) = indextTransitionOFFtoON;
        i = i+1;
        init = 0;
    end
    [tTurnOn,indextTurnOn] = FuncTurnOn(t,Vsw_DS,indextTransitionOFFtoON,Vdc,Tsw);
    [tTransitionONtoOFF,indextTransitionONtoOFF] = FuncTransitionONtoOFF(t,Vsw_DS,indextTurnOn,Vdc,Tsw);
    [tTurnOff,indextTurnOff] = FuncTurnOff(t,Vsw_DS,indextTransitionONtoOFF,Vdc,Tsw);
    [tTransitionOFFtoON,indextTransitionOFFtoON] = FuncTransitionOFFtoON(t,Vsw_DS,...
        indextTurnOff,Vdc,Tsw);
    tTurnOnArray(i) = indextTurnOn;
    tTransitionONtoOFFArray(i) = indextTransitionONtoOFF;
    tTurnOffArray(i) = indextTurnOff;
    tTransitionOFFtoONArray(i) = indextTransitionOFFtoON;
    i = i+1;
end
end