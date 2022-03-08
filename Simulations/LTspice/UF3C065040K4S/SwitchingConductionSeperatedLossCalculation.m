% Moving average of Vsw_DS

MovAvg = movmean(Vsw_DS1,101);
plot(t,MovAvg,t,Vsw_DS1);
legend('MovingAvg','Vsw_DS1');

%% Find turn on region of switch (Vds = 0)
Vdc = 400;
Tsw = 1/50e3;
for i = 1:numel(t)
    if (abs(Vsw_DS1(i))<= 0.02*Vdc)
        j = 0;
        t1 = t(i);
        StableIndicator = 1;
        %TurnOnStable_Current = 0;
        while t(i+j) <= t1+0.01*Tsw
            if (abs(Vsw_DS1(i+j)) > 0.02*Vdc)
                StableIndicator = 0;
                break;
                % TurnOnStable_Current(j+1) = Vsw_DS1(i+j);
            end
            j = j+1;
        end
    end
    if (StableIndicator == 1)
        tTurnOn = t(i);
        break;
    end
    i = i+j;
end
%% Try of functions
[tTurnOn,indextTurnOn] = FuncTurnOn(t,Vsw_DS1,1,400,(1/50e3));
[tTransitionONtoOFF,indextTransitionONtoOFF] = FuncTransitionONtoOFF(t,Vsw_DS1,indextTurnOn,400,(1/50e3));
[tTurnOff,indextTurnOff] = FuncTurnOff(t,Vsw_DS1,indextTransitionONtoOFF,400,(1/50e3));
[tTransitionOFFtoON,indextTransitionOFFtoON] = FuncTransitionOFFtoON(t,Vsw_DS1,...
    indextTurnOff,400,(1/50e3));
%% General Loss Calculation for switching and conduction - Construction of Arrays

init = 1;
tTurnOn = 0;
i = 1;
while tTurnOn <= (t(numel(t))-2*(1/50e3))
    if init == 1
        [tTurnOn,indextTurnOn] = FuncTurnOn(t,Vsw_DS1,1,400,(1/50e3));
        [tTransitionONtoOFF,indextTransitionONtoOFF] = FuncTransitionONtoOFF(t,Vsw_DS1,indextTurnOn,400,(1/50e3));
        [tTurnOff,indextTurnOff] = FuncTurnOff(t,Vsw_DS1,indextTransitionONtoOFF,400,(1/50e3));
        [tTransitionOFFtoON,indextTransitionOFFtoON] = FuncTransitionOFFtoON(t,Vsw_DS1,...
            indextTurnOff,400,(1/50e3));
        tTurnOnArray(1) = indextTurnOn;
        tTransitionONtoOFFArray(1) = indextTransitionONtoOFF;
        tTurnOffArray(1) = indextTurnOff;
        tTransitionOFFtoONArray(1) = indextTransitionOFFtoON;
        i = i+1;
        init = 0;
    end
    [tTurnOn,indextTurnOn] = FuncTurnOn(t,Vsw_DS1,indextTransitionOFFtoON,400,(1/50e3));
    [tTransitionONtoOFF,indextTransitionONtoOFF] = FuncTransitionONtoOFF(t,Vsw_DS1,indextTurnOn,400,(1/50e3));
    [tTurnOff,indextTurnOff] = FuncTurnOff(t,Vsw_DS1,indextTransitionONtoOFF,400,(1/50e3));
    [tTransitionOFFtoON,indextTransitionOFFtoON] = FuncTransitionOFFtoON(t,Vsw_DS1,...
        indextTurnOff,400,(1/50e3));
    tTurnOnArray(i) = indextTurnOn;
    tTransitionONtoOFFArray(i) = indextTransitionONtoOFF;
    tTurnOffArray(i) = indextTurnOff;
    tTransitionOFFtoONArray(i) = indextTransitionOFFtoON;
    i = i+1;
end

%% General Loss Calculation for switching and conduction - Loss Calculations

for i = 1:(numel(tTurnOnArray)-1)
    TurnOnLoss = 0;
    j = 0;
    while j < tTurnOffArray(i)-tTransitionONtoOFFArray(i)
        TurnOnLoss = TurnOnLoss + [Vsw_DS1(tTransitionONtoOFFArray(i)+j)+...
            Vsw_DS1(tTransitionONtoOFFArray(i)+j+1)]*0.5*...
            [Isw_1(tTransitionONtoOFFArray(i)+j)+Isw_1(tTransitionONtoOFFArray(i)+j+1)]*...
            0.5*(t(tTransitionONtoOFFArray(i)+j+1)-t(tTransitionONtoOFFArray(i)+j));
        j = j+1;
    end
    TurnOnLossArray(i) = TurnOnLoss;

    TurnOffLoss = 0;
    j = 0;
    while j < tTurnOnArray(i+1)-tTransitionOFFtoONArray(i)
        TurnOffLoss = TurnOffLoss + [Vsw_DS1(tTransitionOFFtoONArray(i)+j)+...
            Vsw_DS1(tTransitionOFFtoONArray(i)+j+1)]*0.5*...
            [Isw_1(tTransitionOFFtoONArray(i)+j)+Isw_1(tTransitionOFFtoONArray(i)+j+1)]...
            *0.5*(t(tTransitionOFFtoONArray(i)+j+1)-t(tTransitionOFFtoONArray(i)+j));
        j = j+1;
    end
    TurnOffLossArray(i) = TurnOffLoss;
end
PswTurnOn = sum(TurnOnLossArray)*50;
PswTurnOff = sum(TurnOffLossArray)*50;
PswLoss = PswTurnOn + PswTurnOff;
%% Function of Turn on region
function [tTurnOn,indextTurnOn] = FuncTurnOn(t,Vsw_DS,indexStart,Vdc,Tsw)
Vsw_DS1 = Vsw_DS;
for i = indexStart:numel(t)
    StableIndicator = 0;
    if (abs(Vsw_DS1(i))<= 0.02*Vdc)
        j = 0;
        t1 = t(i);
        StableIndicator = 1;
        while t(i+j) <= t1+0.01*Tsw
            if (abs(Vsw_DS1(i+j)) > 0.02*Vdc)
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
Vsw_DS1 = Vsw_DS;
for i = indexStart:numel(t)
    if (abs(Vsw_DS1(i)) > 0.05*Vdc)
        tTransitionONtoOFF = t(i);
        indextTransitionONtoOFF = i;
        break;
    end
end
end
%% Function of Turn off region
function [tTurnOff,indextTurnOff] = FuncTurnOff(t,Vsw_DS,indexStart,Vdc,Tsw)
Vsw_DS1 = Vsw_DS;
for i = indexStart:numel(t)
    StableIndicator = 0;
    if (0.98*Vdc <= Vsw_DS1(i) <= 1.02*Vdc)
        j = 0;
        t1 = t(i);
        StableIndicator = 1;
        while t(i+j) <= t1+0.01*Tsw
            if ((Vsw_DS1(i+j) < 0.98*Vdc) & (Vsw_DS1(i+j) > 1.02*Vdc))
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
Vsw_DS1 = Vsw_DS;
for i = indexStart:numel(t)
    if (abs(Vsw_DS1(i)) < 0.95*Vdc)
        tTransitionOFFtoON = t(i);
        indextTransitionOFFtoON = i;
        break;
    end
end
end
%% Function of turn on off array (On, off & transition)
function [tTurnOnArray,tTransitionONtoOFFArray,tTurnOffArray,tTransitionOFFtoONArray]= ...
    FuncTurnOnOffArrays(t,Vsw_DS,Vdc,Tsw)
init = 1;
tTurnOn = 0;
i = 1;
while tTurnOn <= (t(numel(t))-2*(1/50e3))
    if init == 1
        [tTurnOn,indextTurnOn] = FuncTurnOn(t,Vsw_DS1,1,400,(1/50e3));
        [tTransitionONtoOFF,indextTransitionONtoOFF] = FuncTransitionONtoOFF(t,Vsw_DS1,indextTurnOn,400,(1/50e3));
        [tTurnOff,indextTurnOff] = FuncTurnOff(t,Vsw_DS1,indextTransitionONtoOFF,400,(1/50e3));
        [tTransitionOFFtoON,indextTransitionOFFtoON] = FuncTransitionOFFtoON(t,Vsw_DS1,...
            indextTurnOff,400,(1/50e3));
        tTurnOnArray(1) = indextTurnOn;
        tTransitionONtoOFFArray(1) = indextTransitionONtoOFF;
        tTurnOffArray(1) = indextTurnOff;
        tTransitionOFFtoONArray(1) = indextTransitionOFFtoON;
        i = i+1;
        init = 0;
    end
    [tTurnOn,indextTurnOn] = FuncTurnOn(t,Vsw_DS1,indextTransitionOFFtoON,400,(1/50e3));
    [tTransitionONtoOFF,indextTransitionONtoOFF] = FuncTransitionONtoOFF(t,Vsw_DS1,indextTurnOn,400,(1/50e3));
    [tTurnOff,indextTurnOff] = FuncTurnOff(t,Vsw_DS1,indextTransitionONtoOFF,400,(1/50e3));
    [tTransitionOFFtoON,indextTransitionOFFtoON] = FuncTransitionOFFtoON(t,Vsw_DS1,...
        indextTurnOff,400,(1/50e3));
    tTurnOnArray(i) = indextTurnOn;
    tTransitionONtoOFFArray(i) = indextTransitionONtoOFF;
    tTurnOffArray(i) = indextTurnOff;
    tTransitionOFFtoONArray(i) = indextTransitionOFFtoON;
    i = i+1;
end
end
