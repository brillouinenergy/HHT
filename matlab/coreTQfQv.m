clear all;close all

addpath('C:\jinwork\BE\matlab')
addpath('C:\jinwork\BE\matlab\addaxis5')

%looking at Berkeley HHT
SYS = 'BEC Core B37';
Directory='C:\jinwork\BEC\data\ConF00_copy\2016-07-21';
AllFiles = getall(Directory);  %SORTED BY DATE....
Experiment = AllFiles(4:7);
Experiment'

loadHHT 
%change a few messy variable names
QOccurred = QOccurred0x3F; clear QPulseOccurred0x3F
QPulseLengthns = QPulseLength0x28ns0x29; clear QPulseLength0x28ns0x29
QPulseDelays = QPulseDelay0x28s0x29; clear QPulseDelay0x28s0x29
QkHz = QKHz; clear QKHz;
dateN=datenum(DateTime,'mm/dd/yyyy HH:MM:SS');
dateN(1)
%convert DateTime to datetime type in 
%startTime 8/12/2016 17:30 assume 11.5*360
%endTime 8/15/2016 17 assume (8/12-8/15) 24*4 - 16
%datetime_dt = datetime(DateTime);
%dateHour_dt(1)
startTime = 11*360
endTime = 12.5*360
DateTime(12.5*360)
DateTime(end - endTime)
mldatetime = date
reltime=24*(dateN-dateN(1)); %in days*24 = hours
titletxt=strcat('BEC HHT test from ',DateTime(startTime),' through ',DateTime(end - endTime)); %how to keep trailing spaces?
qi=find(QOccurred == 1);
size(DateTime)

size(CoreReactorTemp)
%dlmwrite('dt.txt',DateTime,'');
j1 = horzcat(dateN,CoreReactorTemp,CoreHtrPow,QkHz,QPulseVolt);
%dlmwrite('j1.txt',j1,',');

size(j1)
%start only when runs started
j1=j1(11*360:end-endTime,:);
%take out temperature noise
%IC1 = j1(:,2) < 90 ;
%tabulate(IC1)
%j1(IC1,:)=[];

%IC2 = j1(:,2) > 610;
%tabulate(IC2)
%j1(IC2,:)=[];
%size(j1)
t1 = [100 200 300 400 500 600]
for qkHz = 50:25:100
    for qV = 50:50:250
        clear j2
        clear j3
        clear j4
        qVC = qV*sqrt(2)
        j2 = j1((j1(:,4)==qkHz & abs(j1(:,5)-qVC) < 20) ,:);
        dt = datetime(j2(:,1), 'ConvertFrom', 'datenum') ;
        figure
        grid
        
        title(['QkHz=' num2str(qkHz) ' QVolts=' num2str(qV)])
        xlabel('Date')
        yyaxis left
        ylabel('Inner Core Temp')
        hold on
        grid
        plot(dt,j2(:,2),'linewidth',2)
        yyaxis right
        ylabel('Heat Power')
        ylim([0 150])
        grid
        plot(dt,j2(:,3),'linewidth',2)
        hold off
        
        for temp = [ 100 200 300 400 500 600]
            %pick up the tempareture
            j3 = j2((abs(j2(:,2)-temp) < 1) ,:);
       
            j4(temp/100) = mean(j3(:,3));
           
        end
        
        p=polyfit(t1, j4, 2);
        polyfit_str = ['fitting:' num2str(p(1)) '*x^2+' num2str(p(2)) '*x+' num2str(p(3))]

        y1 = polyval(p,t1);
        figure
        plot(t1,j4,'linewidth',2)
        title(['QkHz=' num2str(qkHz) ' QVolts=' num2str(qV)])
        hold on
        plot(t1,y1,'linewidth',2)
        legend('Heat Power',polyfit_str) 
        ylabel('Heat Power')
        xlabel('Inner Core Temp')
        grid
        hold off


    end
end    

