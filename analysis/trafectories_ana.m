function trafectories_ana()
path = 'D:\ION\XinHua\EyeMovementTrajectories\data';
close all
warning off

resultDir = fullfile(pwd,'data');

exeFilePath = 'D:\ION\XinHua\EyeMovementTrajectories\analysis';
dataFilePath = path;
fileSaveName = 'result_';

errorSet = [7 8 9 10]; % set for micro-saccade detection
trialMax = 300; % maximum trial number, respectively
smooth_Hz = 60;

% set for convert process
edf2asc = 1; % 1:convert data from EDF files to asc files; 0: skip this process;
dataConvert = 1; % 1:convert data to mat files; 0: skip this process;


if edf2asc
    edf2ascConvert(dataFilePath,exeFilePath);
end

if dataConvert
    asc2matConvert(dataFilePath,errorSet);
end
    
edfFile = dir(fullfile(path,'*.edf'));

for i = 1:length(edfFile)
    
    % set config for figures
    %%TODO
    set(0,'defaultfigurecolor','w');
    set(figure(i),'pos',[20 20 1849 900],'Name','saccade path');clf;
    subplot1{i} = tight_subplot(2,3,[0.1 0.035],[0.1 0.1]);
    
    axes(subplot1{i}(1));
    hold on
    axis equal
    title(subplot1{i}(1),'Up-Left');
    
    axes(subplot1{i}(2));
    hold on
    axis equal
    title(subplot1{i}(2),'Up-Reft');
    
    axes(subplot1{i}(3));
    hold on
    axis equal
    title(subplot1{i}(3),'Up-Control');
    
    axes(subplot1{i}(4));
    hold on
    axis equal
    title(subplot1{i}(4),'Lower-Left');
    
    axes(subplot1{i}(5));
    hold on
    axis equal
    title(subplot1{i}(5),'Lower-Right');
    
    axes(subplot1{i}(6));
    hold on
    axis equal
    title(subplot1{i}(6),'Lower-Control');

    configFile = strrep(edfFile(i).name,'.edf','.mat');
    dataFile = ['converted_' strrep(edfFile(i).name,'.edf','.mat')];
    
    % extract parameter
    CONFIG = load(fullfile(path,configFile));
    DATA = load(fullfile(path,dataFile));
    
    upTrial = find(CONFIG.trialDir(:,1)==1);
    lowerTrial = find(CONFIG.trialDir(:,1)==-1);
    leftTrial = find(CONFIG.trialDir(:,2) == 1);
    rightTrial = find(CONFIG.trialDir(:,2) == 2);
    contrialTrial = find(CONFIG.trialDir(:,2) == 0);
    
    for j = 1:length(CONFIG.trialCondition)
        % get SCREEN parameter from the data file
        %%TODO
        if ismember(j,upTrial)
            if ismember(j,leftTrial)
                axes(subplot1{i}(1))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'b-');
            elseif ismember(j,rightTrial)
                axes(subplot1{i}(2))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'r-');
            elseif ismember(j,contrialTrial)
                axes(subplot1{i}(3))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'k-');
            end
        elseif ismember(j,lowerTrial)
            if ismember(j,leftTrial)
                axes(subplot1{i}(4))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'b-');
            elseif ismember(j,rightTrial)
                axes(subplot1{i}(5))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'r-');
            elseif ismember(j,contrialTrial)
                axes(subplot1{i}(6))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'k-');
            end
        end
    end
end

