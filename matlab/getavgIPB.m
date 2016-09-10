%AvgRange = getavg(stepsize, StepParam);
% range = point in larger data set to use
% step size (in hours)
% Step Param (like Q PulseLengthns) to use in finding steps
% modified on 8/24/16 to use IPB parametersm, and only spit out the ranges
% needed for averaging.

% mData.SP = StepParam(Range); %step parameter
% mData.R = Range;

function [AvgRange] = getavg(stepsize, StepParam);


dQSP = abs(diff(StepParam));
% [peakLoc] = peakfinder(x0,sel,thresh) returns the indicies of local
%         maxima that are at least sel above surrounding data and larger
%         (smaller) than thresh if you are finding maxima (minima).
clear peaki legstr Expstart Expend
[peaki] = peakfinder(dQSP,2,2);
peaki = [peaki;length(StepParam)-5];

figure
subplot(2,1,1)
plot([1:length(StepParam)],StepParam)
grid
hold on
plot(peaki,StepParam(peaki),'m*')
title('StepParam - starting points') %...used to find data ranges
subplot(2,1,2)
plot(dQSP)
hold on
plot(peaki,dQSP(peaki),'ro')
grid on

Expend = peaki-10; %end just before the next voltage step
explength = stepsize; %take ? hours of data.
Expstart = [Expend-(explength*60*60/10)]; %"explength" each region
neg = find(Expstart < 1);
Expstart(neg) = 1;

figure
plot([1:length(StepParam)],StepParam)
grid
hold on
plot(peaki,StepParam(peaki),'m*')
title('StepParam - starting points') %...used to find data ranges
plot(Expstart,StepParam(Expstart),'go')
plot(Expend,StepParam(Expend),'ro')


AvgRange.start = Expstart;
AvgRange.end = Expend;


end