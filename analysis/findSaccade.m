function [saccadePair,saccadeMeanV,meanAmplitude] = findSaccade(eyedata,saccadeVThres,saccadeAThres,SCREEN)

% convert pixel position to velocity and acceleration
[degreeData,acceleration,dt]=pixel2degreev(eyedata,1,2,3,SCREEN);

% find saccade based on velocity
sacVBin = degreeData(:,2) >= saccadeVThres;

if sum(sacVBin)
    sacVI = find(diff(sacVBin) == 1); % saccade initial index
    sacVT = find(diff(sacVBin) == -1);% saccade terminate index
    if length(sacVI) == length(sacVT)
        sacPair = [sacVI',sacVT'];
    elseif length(sacVI) == length(sacVT)+1
        sacPair = [sacVI',[sacVT';length(sacVBin)]];
    elseif length(sacVI)+1 == length(sacVT)
        sacPair = [[1;sacVI'],sacVT'];
    else
        error('Some problem caused in saccade detection.')
    end
else
    saccadePair = [];
    saccadeMeanV = [];
    meanAmplitude = [];
    return
end

% find saccade based on acceleration
sacABin = acceleration >= saccadeAThres;
if sum(sacABin)
    sacA = find(diff(sacABin) == 1);
else
    saccadePair = [];
    saccadeMeanV = [];
    meanAmplitude = [];
    return
end

saccadePair = [];
meanIndex = [];
amplitude = [];

for i = 1:size(sacPair,1)
    if sum(ismember(sacA,sacPair(i,1):sacPair(i,2))) && (sacPair(i,2)-sacPair(i,1))*dt >= 4 % saccade maintained for at least 4ms
        saccadePair = cat(1,saccadePair,sacPair(i,:));
        amplitude = cat(1,amplitude,sum( degreeData(sacPair(i,1):sacPair(i,2),2) ));
        meanIndex = cat(2,meanIndex,sacPair(i,1):sacPair(i,2));
    end
end

saccadeMeanV = nanmean(degreeData(meanIndex,2));
meanAmplitude = nanmean(amplitude); % this output still problematic
end