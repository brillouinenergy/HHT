clear all;close all

addpath('C:\jinwork\BE\matlab')
addpath('C:\jinwork\BE\matlab\addaxis5')

%looking at Berkeley HHT
SYS = 'BEC Core B37';
whichEx = 2;
Directory='C:\jinwork\BEC\data\ConF00_copy\2016-07-21';
AllFiles = getall(Directory);  %SORTED BY DATE....

%1 21 (8/10/2016 6:00 - 8/11/2016 5:59)
%2 22 (8/11/2016 6:00 - 8/12/2016 5:59)
%3 23 (8/12/2016 6:00 - 8/13/2016 5:59)
%4 24 (8/13/2016 6:00 - 8/14/2016 5:59)
%5 25 (8/14/2016 6:00 - 8/15/2016 5:59)
%6 26 (8/15/2016 6:00 - 8/16/2016 5:59)
%7 27 (8/16/2016 6:00 - 8/17/2016 5:59)
%e1 8/10/2016 16:35(10 hours) - 8/12/2016 9:35 (20 hours) 
%e2 8/12/2016 17:00(11 hours) - 8/15/2016 17:45 (11 hours)
%e3 8/15/2016 22:00(16 hours)
switch (whichEx)
    case 1 
        startTime = 10; %11 hours after 6:00
        endTime = 20;   %20 hours before next day 6:00am
        Experiment = AllFiles(1:3);
        rowPerFigure = 1;
        columnPerFigure = 1;
    case 2
        startTime = 10; %
        endTime = 11.5;
        Experiment = AllFiles(3:6);
        rowPerFigure = 5;
        columnPerFigure = 3;

    case 3
        startTime = 16; %
        endTime = 0;
        Experiment = AllFiles(6:7);
        rowPerFigure = 5;
        columnPerFigure = 3;


    otherwise
        exit
end;

%Experiment = AllFiles(4:7);
Experiment'

loadHHT 
%change a few messy variable names
QOccurred = QOccurred0x3F; clear QPulseOccurred0x3F
QPulseLengthns = QPulseLength0x28ns0x29; clear QPulseLength0x28ns0x29
QPulseDelays = QPulseDelay0x28s0x29; clear QPulseDelay0x28s0x29
QkHz = QKHz; clear QKHz;
dateN=datenum(DateTime,'mm/dd/yyyy HH:MM:SS');


DateTime(startTime*360)
DateTime(end - endTime*360)
mldatetime = date;
reltime=24*(dateN-dateN(1)); %in days*24 = hours
%titletxt=strcat('BEC HHT test from ',DateTime(startTime*360),' through ',DateTime(end - endTime*360)); %how to keep trailing spaces?
qi=find(QOccurred == 1);
size(DateTime);
j1 = horzcat(dateN,InnerCoreTemp,CoreHtrPow,QkHz,QPulseVolt);

size(j1);
%start only when runs started
j1=j1(startTime*360:end-endTime*360,:);
%take out temperature noise
%IC1 = j1(:,2) < 90 ;
%tabulate(IC1)
%j1(IC1,:)=[];

%IC2 = j1(:,2) > 610;
%tabulate(IC2)
%j1(IC2,:)=[];
%size(j1)
t1 = [100 200 300 400 500 600];
tp = [];
vi = 0;
for qV = 50:50:250
    vi = vi + 1;
    ki = 0;
    for qkHz = 50:25:100
        ki = ki + 1;
        clear j2
        clear j3
        clear j4
        qVC = qV*sqrt(2);
        j2 = j1((abs(j1(:,4)-qkHz) < 1 & abs(j1(:,5)-qVC) < 19) ,:);
        
        if size(j2(:,1)) > 0
            fn = ['C:\jinwork\BEC\data\q' num2str(whichEx) num2str(qV) num2str(qkHz) '.csv'];
            
            dt = datetime(j2(:,1), 'ConvertFrom', 'datenum') ;
            
            %dt.Format = 'mm/dd/yyyy HH:MM:SS';
            
            T = table(dt,j2(:,2),j2(:,3),j2(:,4),j2(:,5),'VariableName',{'DateTime','InnerCoreTemp','Power','QkHz','Qvolts'});
            writetable(T,fn);
            %fileID = fopen(fn,'w');
            %fprintf(fileID,
            %fprintf(fileID,'%datetime %6.2f %6.2f %6.2f %6.2f %6.2f',dt,j2(:,2),j2(:,3),j2(:,4),j2(:,5));
            %fclose(fileID);
            %dlmwrite(fn1, j2,',');
            %dlmwrite(fn1, dt);
            figure(1)
            grid
            subplot(rowPerFigure,columnPerFigure,ki + (vi-1)*3)
            %title(['QkHz=' num2str(qkHz) ' QVolts=' num2str(qV)])
            title([num2str(qV) num2str(qkHz)],'fontsize', 8)
            %xlabel('Date')
            yyaxis left
            ylim([0 700])
            %ylabel('Inner Core Temp')
            hold on
            grid
            %plot(dt,j2(:,2),'linewidth',2)
            plot(dt,j2(:,2))
            yyaxis right
            %ylabel('Heat Power')
            ylim([0 150])
            grid
            %plot(dt,j2(:,3),'linewidth',2)
            plot(dt,j2(:,3))
            hold off
            j4 = [];
            for temp = [100 200 300 400 500 600]
                %pick up data with the particular tempareture
                j3 = j2((abs(j2(:,2)-temp) < 15) ,:);
                dt3 = datetime(j3(:,1), 'ConvertFrom', 'datenum') ;
                
                if size(j3(:,1)) > 0   
                   if dt3 
                    j4(temp/100) = mean(j3(end-15:end-5,3));
                end
            end
            nt = size(j4,2);
            if nt > 0 
                t2 = t1; %(1:nt);
                p=polyfit(t2, j4, 2);
                polyfit_str = ['fitting:' num2str(p(1)) '*x^2+(' num2str(p(2)) '*x)+(' num2str(p(3)) ')'];
               
                y1 = polyval(p,t2);
                figure(2)
                xlim([100 600])
                subplot(rowPerFigure,columnPerFigure,ki + (vi-1)*3)
                plot(t2,j4,'r')
                ylim([0 150])
                title([num2str(qV) num2str(qkHz)],'fontsize', 8)
                %title(['QkHz=' num2str(qkHz) ' QVolts=' num2str(qV)])
                hold on
                plot(t2,y1,'b')
                %legend('Heat Power',polyfit_str) 
                %ylabel('Heat Power')
                %xlabel('Inner Core Temp')
                grid
                xlim([100 600])
                hold off
               
                tpi = [qV qkHz p(1) p(2) p(3) j4];
                tp = vertcat(tp,tpi);
            end
        end
    end
end 

%figure
%surf(tp(:,1:3));

fn = ['C:\jinwork\BEC\data\tp' num2str(whichEx) '.csv']
dlmwrite(fn,tp,',');
