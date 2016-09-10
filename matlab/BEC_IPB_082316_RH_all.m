%%attempt at IPB analysis from Rogers email on 8/23...including Null test
%H2 run on 8/4/16 (different core)..ipb1,COP=1.4 at 300c, directory=
%2016-06-25_half-h\ipb1_H2_seq_150c-400c-50w-_8-4-16_day-1.csv
%null core 8/20/16 (new core, never seen H2),
%isoperibolic1_data\2016-08-20-core_26b\-new-core_He_150c-400c_day-01 (and 2 and 3).csv
clear all;close all
addpath('C:\Users\jen_g\MATLAB scripts')
addpath('C:\Users\jen_g\MATLAB scripts\addaxis5')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%looking at BEC IPB
SYS = 'IPB:1 Core:26b'; %
Directory='C:\Users\jen_g\Data\IPB_copy\2016-08-20-CORE_26b'; %look for day-01 through 03, from email
AllFiles = getall(Directory);  %SORTED BY DATE....
%order of experiments
ExpOrd = {'Null(He)','H2_new','H2_cond1','H2_cond2','H2_cond3','H2D2_1','H2D2_2'};

stepsize = 0.2; %<15 min  %time to use for averaging at Q parameter step
whichwe = [1,2,6];
for we = whichwe
    
    switch (we)
        case 1  %Null
            ExpN = ExpOrd{we}
            Experiment = AllFiles(1:3)'
            Range = [182:11980]; %found after plotting...which is cheating...
            
            data = loadHHTr(Range,Directory,Experiment);
            
        case 2
            ExpN = ExpOrd{we}
            Experiment = AllFiles(4:6)'
            %loadHHT
            %plot(HeaterPower)
            Range = [712:12265]; %found after plotting...which is cheating...
            
            data = loadHHTr(Range,Directory,Experiment);
            
        case 3
            ExpN = ExpOrd{we}
            Experiment = AllFiles(7:8)'
            %Range = [1:11980]; %found after plotting...which is cheating...
            
            data = loadHHTr(Range,Directory,Experiment);
            
        case 4
            ExpN = ExpOrd{we}
            Experiment = AllFiles(9:10)'
            % Range = [182:11980]; %found after plotting...which is cheating...
            
            data = loadHHTr(Range,Directory,Experiment);
            
        case 5
            ExpN = ExpOrd{we}
            Experiment = AllFiles(11:12)'
            % Range = [182:11980]; %found after plotting...which is cheating...
            
            data = loadHHTr(Range,Directory,Experiment);
            
        case 6
            ExpN = ExpOrd{we}
            Experiment = AllFiles(13:15)'
            %loadHHT
            %plot(HeaterPower)
            Range = [200:11997]; %found after load with loadHHT, and plotting...which is cheating...
             data = loadHHTr(Range,Directory,Experiment);
            
        case 7
            ExpN = ExpOrd{we}
            Experiment = AllFiles(16)'
            %Range = [182:11980]; %found after plotting...which is cheating...
            
            data = loadHHTr(Range,Directory,Experiment);
            
            
        otherwise
            exit
    end;
    
    
    StepParam = data.QOccurred.*data.QPulseLengthns;
    AvgRange = getavgIPB(stepsize,StepParam);  %reduced to Range
    %AvgRange.start & AvgRange.end for starting and ending points used in averaging
    %this will include points when Q is off...for reference
    
    Results = struct(); % place to keep avg results...make this a function!
    for ii=1:length(AvgRange.start)
        pick = [AvgRange.start(ii):AvgRange.end(ii)];
        Results.mPL(ii) = mean(data.QPulseLengthns(pick)); %Q Pulse length
        Results.mCT(ii) = mean(data.CoreTemp(pick)); % Core Temp
        Results.mHP(ii) = mean(data.HeaterPower(pick)); % Heater Power
        Results.mQPow(ii) = mean(data.QPow(pick)); % Q Power (measured at pi filter)
        Results.mTTP(ii) = mean(data.TerminationHeatsinkPower(pick)); % Termination Thermal Power
        
        Results.mICP(ii) = mean(data.IsoperibolicCalorimetryPower(pick)); %
        Results.mQPCBP(ii) = mean(data.QPulsePCBHeatsinkPower(pick)); %Q PCB Heatsink Power
        Results.mCJP(ii) = mean(data.CalorimeterJacketPower(pick)); %Jacket Power
        Results.Qon(ii) = mean(data.QOccurred(pick)); %another way to weed out the ref with Q off.
    end
    
     if we == 1
        NResults = Results; %keep null results for later 
     end
    
    temps = unique(round(Results.mCT));
    pls = unique(Results.mPL);
    
    figure
    hold all
    plot(data.DateTime(AvgRange.start),Results.mHP,'*-')
    title([ExpOrd{1},': Heater Power'],'interpreter','none')
    grid
    ylabel('Heater Power')
    datetick('x','mm/dd HH:MM','keepticks')
    
    
    figure
    hold on
    for ii=1:length(temps)
        tempi = find(round(Results.mCT) == temps(ii) & Results.Qon > 0); %only plotting with Q on
        tempcal = find(round(Results.mCT) == temps(ii) & Results.Qon == 0); %use cal with Q off
        plot(Results.mPL(tempi),Results.mHP(tempcal(1))-Results.mHP(tempi),'o-') %relative to calibration with Q off before first step
        
    end
    title([ExpOrd{we},': Heater Power w/Q off - Heater w/Q on'],'interpreter','none')
    xlabel('pulse length (ns)')
    xlim([min(Results.mPL)-20 max(Results.mPL)+20 ])
    grid
    ylabel('Delta Q Heater Power')
    legend(num2str(temps'))
    
    figure
    hold on
    for ii=1:length(temps)
        tempi = find(round(Results.mCT) == temps(ii) & Results.Qon > 0); %only plotting with Q on
        tempcal = find(round(Results.mCT) == temps(ii) & Results.Qon == 0);%use cal with Q off
        plot(data.DateTime(AvgRange.start([tempi(1)-1,tempi])),Results.mHP(tempcal(1))-Results.mHP([tempcal(1),tempi]),'o-')
    end
    title([ExpOrd{we},': Heater Power Delta at each temp'],'interpreter','none')
    grid
    ylabel('Heater Power change with Q sequence at each temp')
    legend(num2str(temps'))
    datetick('x','mm/dd HH:MM','keepticks')
    ylim([0 5])
    
    figure(100)
    pickstr = {'.-','*-','s-','^-','d-','o-','+-','x-','.-','*-','s-','^-','d-','o-','+-','x-'};
    plotx = [1:6;8:13;15:20;22:27;29:34;36:41];
    hold on
    for ii=1:length(temps)
        tempi = find(round(Results.mCT) == temps(ii) & Results.Qon > 0); %only plotting with Q on
        tempcal = find(round(Results.mCT) == temps(ii) & Results.Qon == 0)%use cal with Q off
        p(we,ii) =  plot(plotx(ii,:),Results.mHP(tempcal(1))-Results.mHP([tempcal(1),tempi(1:5)]),pickstr{we}) %extra point...putting (1:5) was dirty way to ignore it
    end
    title(['Heater Power Delta at each temp'],'interpreter','none')
    grid on
    ylabel('Heater Power change with Q sequence at each temp')
    if we == whichwe(end)
        legend([p(whichwe,1)],ExpOrd{whichwe})
    else
    end
    ax = gca;
    ax.XTick = [4:7:42];
    ax.XTickLabel = num2str(temps');
    xlabel('Core Temperature (deg C)')
    ylim([0 5])
    hold off
        
    figure(101)
    pickstr = {'.-','*-','s-','^-','d-','o-','+-','x-','.-','*-','s-','^-','d-','o-','+-','x-'};
    plotx = [1:6;8:13;15:20;22:27;29:34;36:41];
    hold on
    XHP = Results.mHP; %done to shorten
    NHP = NResults.mHP;
    for ii=1:length(temps)
        tempi = find(round(Results.mCT) == temps(ii) & Results.Qon > 0); %only plotting with Q on
        tempcal = find(round(Results.mCT) == temps(ii) & Results.Qon == 0)%use cal with Q off
        XHP = Results.mHP(tempcal(1))-Results.mHP([tempcal(1),tempi(1:5)]); %done to shorten plot line...
        NHP = NResults.mHP(tempcal(1))-NResults.mHP([tempcal(1),tempi(1:5)]); %only works with experiments in same order
        p(we,ii) =  plot(plotx(ii,:),XHP-NHP,pickstr{we}) %extra point...putting (1:5) was dirty way to ignore it
    end
    title([SYS,', Heater Power Delta, referenced to Null (He) test'],'interpreter','none')
    grid on
    ylabel('Heater Power change, normalized to Null(He) test')
    if we == whichwe(end)
        legend([p(whichwe,1)],ExpOrd{whichwe})
    else
    end
    ax = gca;
    ax.XTick = [4:7:42];
    ax.XTickLabel = num2str(temps');
    xlabel('Core Temperature (deg C)')
 
    hold off
    
        figure(200)
        pickstr = {'.-','*-','s-','^-','d-','o-','+-','x-','.-','*-','s-','^-','d-','o-','+-','x-'};
        plotx = [1:6;8:13;15:20;22:27;29:34;36:41];
        hold on
        for ii=1:length(temps)
            tempi = find(round(Results.mCT) == temps(ii) & Results.Qon > 0); %only plotting with Q on
            tempcal = find(round(Results.mCT) == temps(ii) & Results.Qon == 0)%use cal with Q off
            q(we,ii) =  plot(plotx(ii,:),Results.mHP([tempcal(1),tempi(1:5)]),pickstr{we}) %extra point...putting (1:5) was dirty way to ignore it
        end
        title(['Heater Power (W) at each temp'],'interpreter','none')
        grid on
        ylabel('Heater Power with Q sequence at each temp')
          if we == whichwe(end)
        legend([q(whichwe,1)],ExpOrd{whichwe})
        else
        end
        ax = gca;
        ax.XTick = [4:7:42];
        ax.XTickLabel = num2str(temps');
        xlabel('Core Temperature (deg C)')
        hold off
        
          figure(201)
        pickstr = {'.-','*-','s-','^-','d-','o-','+-','x-','.-','*-','s-','^-','d-','o-','+-','x-'};
        plotx = [1:6;8:13;15:20;22:27;29:34;36:41];
        hold on
        Qr = (Results.mICP + Results.mQPCBP + Results.mTTP) - (Results.mHP + Results.mQPow);
        for ii=1:length(temps)
            tempi = find(round(Results.mCT) == temps(ii) & Results.Qon > 0); %only plotting with Q on
            tempcal = find(round(Results.mCT) == temps(ii) & Results.Qon == 0)%use cal with Q off
            qq(we,ii) =  plot(plotx(ii,:),Qr([tempcal(1),tempi(1:5)]),pickstr{we}) %extra point...putting (1:5) was dirty way to ignore it
        end
        title([SYS,', Q_reaction (W) at each temp'])
        grid on
        ylabel('Reaction? Power with Q sequence at each temp')
          if we == whichwe(end)
        legend([qq(whichwe,1)],ExpOrd{whichwe})
        else
        end
        ax = gca;
        ax.XTick = [4:7:42];
        ax.XTickLabel = num2str(temps');
        xlabel('Core Temperature (deg C)')
        hold off
        
          figure(202)
        pickstr = {'.-','*-','s-','^-','d-','o-','+-','x-','.-','*-','s-','^-','d-','o-','+-','x-'};
        plotx = [1:6;8:13;15:20;22:27;29:34;36:41];
        hold on
        Qr = (Results.mICP + Results.mQPCBP + Results.mTTP) - (Results.mHP + Results.mQPow);
        Qrnull = (NResults.mICP + NResults.mQPCBP + NResults.mTTP) - (NResults.mHP + NResults.mQPow);
        for ii=1:length(temps)
            tempi = find(round(Results.mCT) == temps(ii) & Results.Qon > 0); %only plotting with Q on
            tempcal = find(round(Results.mCT) == temps(ii) & Results.Qon == 0)%use cal with Q off
            %the following only works because things were run in the same
            %order...this needs to be generalized
            qq(we,ii) =  plot(plotx(ii,:),Qr([tempcal(1),tempi(1:5)])-Qrnull([tempcal(1),tempi(1:5)]),pickstr{we}) %extra point...putting (1:5) was dirty way to ignore it
        end
        title([SYS,', Q_reaction - NULL(W) at each temp'])
        grid on
        ylabel('Reaction? Power - null with Q sequence at each temp')
          if we == whichwe(end)
        legend([qq(whichwe,1)],ExpOrd{whichwe})
        else
        end
        ax = gca;
        ax.XTick = [4:7:42];
        ax.XTickLabel = num2str(temps');
        xlabel('Core Temperature (deg C)')
        hold off
        
        figure
        hold on
        aa_splot(data.DateTime,data.CoreTemp,'linewidth',2)
        addaxis(data.DateTime,data.QKHz)
        addaxis(data.DateTime,data.IsoperibolicCalorimetryPower,'linewidth',2)
        addaxis(data.DateTime,data.HeaterPower,'linewidth',2)
        addaxis(data.DateTime,data.QPulseLengthns,'linewidth',1)
        addaxis(data.DateTime,data.QPow,'linewidth',1)
        legend('Core Temp','Q Frequency',' IPB Cal Power','Heater Power','Q Pulse Length','Q Power')
        grid on
        grid minor
        datetick('x','mm/dd, HH:MM','keeplimits')
        title([SYS,' <',ExpOrd{we},'> ',datestr(data.DateTime(1),'mmm dd @ HH:MM'),' through ',datestr(data.DateTime(end),'mmm dd @ HH:MM')],'interpreter','none','fontsize',14)
        addaxislabel(1,'Core Temp (degC)');
        addaxislabel(2,'Q Frequency (kHz)');
        addaxislabel(3,' IPB Cal Power (W)');
        addaxislabel(4,'Heater Power (W)');
        addaxislabel(5,'Q Pulse Length (ns)');
        addaxislabel(6,'Q Power (W)');
        
        figure(300)
        RT = 24*(data.DateTime-data.DateTime(1));
        hold on
        h1(we) = plot(RT,data.QPow)
        h2(we) = plot(RT,data.HeaterPower,'linewidth',2)
        grid on
        grid minor
    xlabel('Time Elapsed (hours)')
        title([SYS,', Q Power and Heater Power'],'interpreter','none','fontsize',14)
       if we == whichwe(end)
         legend([h2(whichwe)],ExpOrd{whichwe})
        else
       end
        
         figure(301)
        RT = 24*(data.DateTime-data.DateTime(1));
        hold on
        h1(we) = plot(RT,data.QSupplyVolt,'linewidth',2)
        h2(we) = plot(RT,data.QPulseVolt,'linewidth',2)
        grid on
        grid minor
    xlabel('Time Elapsed (hours)')
        title([SYS,', Q Pulse Volt'],'interpreter','none','fontsize',14)
       if we == whichwe(end)
         legend([h2(whichwe)],ExpOrd{whichwe})
        else
        end
        
end

%%
%
%     Null26b.Results = Results;
%     Null26b.AvgRange = AvgRange;
%     Null26b.data = data;
%     Null26b.Files = Experiment;
%
%     cd('C:\Users\jen_g\Data\IPB_copy')
%save Null26b Null26b
%% H2_new
%Experiment = H2_new;
Experiment = eval(ExpOrd{2});

data = loadHHTr(Range,Directory,Experiment);
Range = [575:length(data.QPow)];
stepsize = 0.2; %<15 min
StepParam = data.QOccurred.*data.QPulseLengthns;
AvgRange = getavgIPB(stepsize,StepParam);  %reduced to Range
Results = struct(); % place to keep avg results...make this a function!
for ii=1:length(AvgRange.start)
    pick = [AvgRange.start(ii):AvgRange.end(ii)];
    Results.mPL(ii) = mean(data.QPulseLengthns(pick)); %Q Pulse length
    Results.mCT(ii) = mean(data.CoreTemp(pick)); % Core Temp
    Results.mHP(ii) = mean(data.HeaterPower(pick)); % Heater Power
    Results.mQPow(ii) = mean(data.QPow(pick)); % Q Power (measured at pi filter)
    Results.mTTP(ii) = mean(data.TerminationHeatsinkPower(pick)); % Termination Thermal Power
    
    Results.mICP(ii) = mean(data.IsoperibolicCalorimetryPower(pick)); %
    Results.mQPCBP(ii) = mean(data.QPulsePCBHeatsinkPower(pick)); %Q PCB Heatsink Power
    Results.mCJP(ii) = mean(data.CalorimeterJacketPower(pick)); %Jacket Power
    Results.Qon(ii) = mean(data.QOccurred(pick)); %another way to weed out the ref with Q off.
end

temps = unique(round(Results.mCT))
pls = unique(Results.mPL)

figure
hold on
plot(data.DateTime(AvgRange.start),Results.mHP,'*-')
title([ExpOrd{2},': Heater Power'])
grid
ylabel('Heater Power')
datetick('x','mm/dd HH:MM','keepticks')


figure
hold on
for ii=1:length(temps)
    tempi = find(round(Results.mCT) == temps(ii) & Results.Qon > 0); %only plotting with Q on
    tempcal = find(round(Results.mCT) == temps(ii) & Results.Qon == 0); %use cal with Q off
    plot(Results.mPL(tempi),Results.mHP(tempcal(1))-Results.mHP(tempi),'o-') %relative to calibration with Q off before first step
    
end
title([ExpOrd{2},': Heater Power w/Q off - Heater w/Q on'])

xlabel('pulse length (ns)')
xlim([min(Results.mPL)-20 max(Results.mPL)+20 ])
grid
ylabel('Delta Q Heater Power')
legend(num2str(temps'))



figure
hold on
for pp=1:length(pls)
    plsi = find(round(Results.mPL) == pls(pp) & Results.Qon > 0);
    
    plot(Results.mCT(plsi),Results.mHP(plsi),'o-')
    
end
title('Heater Power')
datetick('x','mm/dd ','keepticks')
legend(num2str(pls'))

H2new_26b.Results = Results;
H2new_26b.AvgRange = AvgRange;
H2new_26b.data = data;
H2new_26b.Files = Experiment;

cd('C:\Users\jen_g\Data\IPB_copy')
save H2new_26b H2new_26b

%% H2D2_1
Experiment = H2D2_1;
data = loadHHTr(Range,Directory,Experiment);
Range = [1:length(data.QPow)];
stepsize = 0.2; %<15 min
StepParam = data.QOccurred.*data.QPulseLengthns;
AvgRange = getavgIPB(stepsize,StepParam);  %reduced to Range
Results = struct(); % place to keep avg results...make this a function!
for ii=1:length(AvgRange.start)
    pick = [AvgRange.start(ii):AvgRange.end(ii)];
    Results.mPL(ii) = mean(data.QPulseLengthns(pick)); %Q Pulse length
    Results.mCT(ii) = mean(data.CoreTemp(pick)); % Core Temp
    Results.mHP(ii) = mean(data.HeaterPower(pick)); % Heater Power
    Results.mQPow(ii) = mean(data.QPow(pick)); % Q Power (measured at pi filter)
    Results.mTTP(ii) = mean(data.TerminationHeatsinkPower(pick)); % Termination Thermal Power
    
    Results.mICP(ii) = mean(data.IsoperibolicCalorimetryPower(pick)); %
    Results.mQPCBP(ii) = mean(data.QPulsePCBHeatsinkPower(pick)); %Q PCB Heatsink Power
    Results.mCJP(ii) = mean(data.CalorimeterJacketPower(pick)); %Jacket Power
    Results.Qon(ii) = mean(data.QOccurred(pick));
    %another way to weed out the ref with Q off.
end


temps = unique(round(Results.mCT))
pls = unique(Results.mPL)

figure
hold on
starti = find(Results.Qon > 0); %again, getting rid fo the few points with no Q
plot(data.DateTime(AvgRange.start(starti)),Results.mHP(starti)-Results.mHP(starti(1)),'*-')
title(['Heater Power for H2D2 Exp'])
xlabel('pulse length (ns)')
grid
ylabel('Heater Power change from beginning of Q sequence')
datetick('x','mm/dd HH:MM','keepticks')


figure
hold on
for ii=1:length(temps)
    tempi = find(round(Results.mCT) == temps(ii) & Results.Qon > 0); %only plotting with Q on
    
    plot(Results.mPL(tempi),Results.mHP(tempi)-Results.mHP(tempi(1)),'o-')
    
end
title('Heater Power')
xlabel('pulse length (ns)')
xlim([min(Results.mPL)-20 max(Results.mPL)+20 ])
grid
ylabel('Heater Power change from beginning of Q sequence')
legend(num2str(temps'))

figure
hold on
for pp=1:length(pls)
    plsi = find(round(Results.mPL) == pls(pp) & Results.Qon > 0);
    plot(Results.mCT(plsi),Results.mHP(plsi),'o-')
end
title('Heater Power')
datetick('x','mm/dd ','keepticks')
legend(num2str(pls'))

H2D2_1_26b.Results = Results;
H2D2_1_26b.AvgRange = AvgRange;
H2D2_1_26b.data = data;
H2D2_1_26b.Files = Experiment;

cd('C:\Users\jen_g\Data\IPB_copy')
save H2D2_1_26b H2D2_1_26b