clear all;close all

addpath('C:\jinwork\BE\matlab')
addpath('C:\jinwork\BE\matlab\addaxis5')

%looking at Berkeley HHT
SYS = 'BEC Core B37';
whichEx = 1;
Directory='C:\jinwork\BEC\Data\isoperibolic_data\2016-08-20-CORE_26b';
AllFiles = getall(Directory);  %SORTED BY DATE....

%1 21 (8/10/2016 6:00 - 8/11/2016 5:59)
%2 22 (8/11/2016 6:00 - 8/12/2016 5:59)
%3 23 (8/12/2016 6:00 - 8/13/2016 5:59)
%4 24 (8/13/2016 6:00 - 8/14/2016 5:59)
%5 25 (8/14/2016 6:00 - 8/15/2016 5:59)
%6 26 (8/15/2016 6:00 - 8/16/2016 5:59)
%7 27 (8/16/2016 6:00 - 8/17/2016 5:59)
%8 28 (8/17/2016 6:00 - 8/18/2016 5:59)
%9 29 (8/18/2016 6:00 - 8/19/2016 5:59)
%10 30 (8/19/2016 6:00 - 8/20/2016 5:59)
%11 31 (8/20/2016 6:00 - 8/21/2016 5:59)
%12 32 (8/21/2016 6:00 - 8/22/2016 5:59)
%10 30 (8/18/2016 23:00 - 8/19/2016 13:00)
%e1 8/10/2016 16:35(10 hours) - 8/12/2016 9:35 (20 hours) he no Q
%e2 8/12/2016 17:00(11 hours) - 8/15/2016 17:45 (11 hours) he w Q
%e3 8/15/2016 22:00(16 hours) - 8/18/2016 20:00 (10 hours) h w Q
%e4 8/18/2016 23:00(17 hours) - 8/19/2016 13:00 (17 hours) h no Q
%e5 8/19/2016 16:30(10 hours) -                            h w Q
qpulse = 1;
switch (whichEx)
    case 1 
        startTime = 0; %11 hours after 6:00
        endTime = 0;   %20 hours before next day 6:00am
        Experiment = AllFiles(1:3);
        rowPerFigure = 1;
        columnPerFigure = 1;
        qpulse = 0;
    case 2
        startTime = 10; %
        endTime = 11.5;
        Experiment = AllFiles(3:6);
        rowPerFigure = 1;
        columnPerFigure = 1;
    case 3
        startTime = 13; %
        endTime = 5;
        Experiment = AllFiles(6:9);
        rowPerFigure = 5;
        columnPerFigure = 3;
   case 4
        startTime = 10; %
        endTime = 0;
        Experiment = AllFiles(9:10);
        rowPerFigure = 1;
        columnPerFigure = 1;
        qpulse = 0
   case 5
        startTime = 9; %
        endTime = 0;
        Experiment = AllFiles(10:14);
        rowPerFigure = 1;
        columnPerFigure = 1;
    otherwise
        exit
end;
Experiment'

loadIPB 
%change a few messy variable names
QOccurred = QOccurred0x3F; clear QPulseOccurred0x3F
QPulseLengthns = QPulseLength0x28ns0x29; clear QPulseLength0x28ns0x29
QPulseDelays = QPulseDelay0x28s0x29; clear QPulseDelay0x28s0x29
QkHz = QKHz; clear QKHz;
dateN=datenum(DateTime,'mm/dd/yyyy HH:MM:SS');
DateTime(1+startTime*360)
DateTime(end - endTime*360)
reltime=24*(dateN-dateN(1)); %in days*24 = hours
%titletxt=strcat('BEC HHT test from ',DateTime(startTime*360),' through ',DateTime(end - endTime*360)); %how to keep trailing spaces?
j1 = horzcat(dateN,CoreTemp,QkHz,QPulseVolt,isoperibolicCalorimetryPower);
%start only when runs started
j1=j1(startTime*360:end-endTime*360,:);

dt = datetime(j2(:,1), 'ConvertFrom', 'datenum') ;   
figure(1) 

%# Some initial computations:
axesPosition = [110 40 200 200];  %# Axes position, in pixels
yWidth = 30;                      %# y axes spacing, in pixels
xLimit = [min(x) max(x)];         %# Range of x values
xOffset = -yWidth*diff(xLimit)/axesPosition(3);

%# Create the figure and axes:
figure('Units','pixels','Position',[200 200 330 260]);
h1 = axes('Units','pixels','Position',axesPosition,...
          'Color','w','XColor','k','YColor','r',...
          'XLim',xLimit,'YLim',[0 1],'NextPlot','add');
h2 = axes('Units','pixels','Position',axesPosition+yWidth.*[-1 0 1 0],...
          'Color','none','XColor','k','YColor','m',...
          'XLim',xLimit+[xOffset 0],'YLim',[0 10],...
          'XTick',[],'XTickLabel',[],'NextPlot','add');
h3 = axes('Units','pixels','Position',axesPosition+yWidth.*[-2 0 2 0],...
          'Color','none','XColor','k','YColor','b',...
          'XLim',xLimit+[2*xOffset 0],'YLim',[-50 50],...
          'XTick',[],'XTickLabel',[],'NextPlot','add');
xlabel(h1,'date');
ylabel(h3,'temp');

%# Plot the data:
plot(h1,dt,j1(:,2),'r');
plot(h2,dt,j1(:,3),'m');
plot(h3,dt,j1(:,5),'b');
