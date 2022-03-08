% Plot
% Comparison of Bipolar, Unipolar and Modified Unipolar

%% Create loss arrays
for i = 1:4
    text="Bipolar_UF3C065040K4S_"+(20+i*20)+"Load.mat";
    load(text);
    BipolarTurnOn(i) = PswTurnOn;
    BipolarTurnOff(i) = PswTurnOff;
    BipolarConductionLoss(i) = Pconduction;
    BipolarTotalLoss(i) = Psw;
    BipolarEff(i) = 100*(1-(Psw*4)/(1000+i*1000));
end

for i = 1:4
    text="Unipolar_UF3C065040K4S_"+(20+i*20)+"Load.mat";
    load(text);
    UnipolarTurnOn(i) = PswTurnOn;
    UnipolarTurnOff(i) = PswTurnOff;
    UnipolarConductionLoss(i) = Pconduction;
    UnipolarTotalLoss(i) = Psw;
    UnipolarEff(i) = 100*(1-(Psw*4)/(1000+i*1000));
end

for i = 1:4
    text="ModifiedUnipolar_UF3C065040K4S_HFSwitch_"+(20+i*20)+"Load.mat";
    load(text);
    ModifiedUnipolarTurnOn(i) = PswTurnOn;
    ModifiedUnipolarTurnOff(i) = PswTurnOff;
    ModifiedUnipolarConductionLoss(i) = Pconduction;
    ModifiedUnipolarTotalLoss(i) = Psw;
end

for i = 1:4
    text="ModifiedUnipolar_UF3C065040K4S_LFSwitch_"+(20+i*20)+"Load.mat";
    load(text);
    ModifiedUnipolarTotalLoss_LF(i) = Psw;
end

ModifiedUnipolarEff = 100*(1-(2*ModifiedUnipolarTotalLoss+2*ModifiedUnipolarTotalLoss_LF)...
    ./([2000 3000 4000 5000]));
%% Plot latex settings
% Some figure formatting
set(groot,'defaulttextinterpreter','latex');  
set(groot, 'defaultAxesTickLabelInterpreter','latex');  
set(groot, 'defaultLegendInterpreter','latex');
%% Plot Bipolar
loadpercent= [40 60 80 100];
figure(1)
plot(loadpercent,BipolarConductionLoss,loadpercent,BipolarTurnOn,...
    loadpercent,BipolarTurnOff,loadpercent,BipolarTotalLoss);
legend({'Conduction','Turn on','Turn off','Total'},'FontSize',14)
title('Bipolar Modulation Losses')
xlabel('Load Percentage')
ylabel('Loss $W$')
set(findall(gcf,'Type','line'),'LineWidth',2)
set(findall(gcf,'-property','FontSize'),'FontSize',14);

% Plot Unipolar
loadpercent= [40 60 80 100];
figure(2)
plot(loadpercent,UnipolarConductionLoss,loadpercent,UnipolarTurnOn,...
    loadpercent,UnipolarTurnOff,loadpercent,UnipolarTotalLoss);
legend({'Conduction','Turn on','Turn off','Total'},'FontSize',14)
title('Unipolar Modulation Losses')
xlabel('Load Percentage')
ylabel('Loss $W$')
set(findall(gcf,'Type','line'),'LineWidth',2)
set(findall(gcf,'-property','FontSize'),'FontSize',14);

% Plot Modified Unipolar HF
loadpercent= [40 60 80 100];
figure(3)
plot(loadpercent,ModifiedUnipolarConductionLoss,loadpercent,ModifiedUnipolarTurnOn,...
    loadpercent,ModifiedUnipolarTurnOff,loadpercent,ModifiedUnipolarTotalLoss);
legend({'Conduction','Turn on','Turn off','Total'},'FontSize',14)
title('Modified Unipolar Modulation Losses HF')
xlabel('Load Percentage')
ylabel('Loss $W$')
set(findall(gcf,'Type','line'),'LineWidth',2)
set(findall(gcf,'-property','FontSize'),'FontSize',14);

% Plot Modified Unipolar LF
loadpercent= [40 60 80 100];
figure(4)
plot(loadpercent,ModifiedUnipolarTotalLoss_LF)
legend({'Total'},'FontSize',14)
title('Modified Unipolar Modulation Losses LF')
xlabel('Load Percentage')
ylabel('Loss $W$')
set(findall(gcf,'Type','line'),'LineWidth',2)
set(findall(gcf,'-property','FontSize'),'FontSize',14);

% Plot efficiency
loadpercent= [40 60 80 100];
figure(5)
plot(loadpercent,BipolarEff,loadpercent,UnipolarEff,loadpercent,ModifiedUnipolarEff)
legend({'Bipolar','Unipolar','Modified Unipolar'},'FontSize',14)
title('Comparison of Modulation Techniques')
xlabel('Load Percentage')
ylabel('Efficiency')
set(findall(gcf,'Type','line'),'LineWidth',2)
set(findall(gcf,'-property','FontSize'),'FontSize',14);