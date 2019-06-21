function trafectories_ana()
path = '';
close all
warning off

resultDir = fullfile(pwd,'data');

exeFilePath = '';
dataFilePath = path;
fileSaveName = 'result_';

errorSet = [7 8 9 10]; % set for micro-saccade detection
trialMax = 300; % maximum trial number, respectively
smooth_Hz = 60;

% set for convert process
edf2asc = 0; % 1:convert data from EDF files to asc files; 0: skip this process;
dataConvert = 0; % 1:convert data to mat files; 0: skip this process;


if edf2asc
    edf2ascConvert(dataFilePath,exeFilePath);
end

if dataConvert
    asc2matConvert(dataFilePath,errorSet);
end
    
edfFile = dir(fullfile(path,'*.edf'));

for i = 1:length(edfFile)
    
    configFile = strrep(edfFile(i).name,'.edf','.mat');
    dataFile = ['converted_' strrep(edfFile(i).name,'.edf','.mat')];
    
    % extract parameter
    CONFIG = load(fullfile(path,configFile));
    DATA = load(fullfile(path,dataFile));
    
    % set config for figures
    set(0,'defaultfigurecolor','w');
    set(figure(i),'pos',[20 20 1849 900],'Name',strrep(edfFile(i).name,'.edf',''));clf;
    subplot1{i} = tight_subplot(2,5,[0.1 0.035],[0.1 0.1]);
    
    axes(subplot1{i}(1));
    set(gca,'YDir','reverse');
    hold on
    axis equal
    plot([CONFIG.distractor{1}(1,1),CONFIG.distractor{1}(1,3)],[CONFIG.distractor{1}(1,2),CONFIG.distractor{1}(1,4)],'-k');
    plot([CONFIG.distractor{1}(2,1),CONFIG.distractor{1}(2,3)],[CONFIG.distractor{1}(2,2),CONFIG.distractor{1}(2,4)],'-k');
    title(subplot1{i}(1),'Up-Left(1)');
    
    axes(subplot1{i}(2));
    set(gca,'YDir','reverse');
    hold on
    axis equal
    plot([CONFIG.distractor{2}(1,1),CONFIG.distractor{2}(1,3)],[CONFIG.distractor{2}(1,2),CONFIG.distractor{2}(1,4)],'-k');
    plot([CONFIG.distractor{2}(2,1),CONFIG.distractor{2}(2,3)],[CONFIG.distractor{2}(2,2),CONFIG.distractor{2}(2,4)],'-k');
    title(subplot1{i}(2),'Up-Reft(2)');
    
    axes(subplot1{i}(3));
    set(gca,'YDir','reverse');
    hold on
    axis equal
    plot([CONFIG.distractor{3}(1,1),CONFIG.distractor{3}(1,3)],[CONFIG.distractor{3}(1,2),CONFIG.distractor{3}(1,4)],'-k');
    plot([CONFIG.distractor{3}(2,1),CONFIG.distractor{3}(2,3)],[CONFIG.distractor{3}(2,2),CONFIG.distractor{3}(2,4)],'-k');
    title(subplot1{i}(3),'Up-Left(3)');
    
    axes(subplot1{i}(4));
    set(gca,'YDir','reverse');
    hold on
    axis equal
    plot([CONFIG.distractor{4}(1,1),CONFIG.distractor{4}(1,3)],[CONFIG.distractor{4}(1,2),CONFIG.distractor{4}(1,4)],'-k');
    plot([CONFIG.distractor{4}(2,1),CONFIG.distractor{4}(2,3)],[CONFIG.distractor{4}(2,2),CONFIG.distractor{4}(2,4)],'-k');
    title(subplot1{i}(4),'Up-Right(4)');
    
    axes(subplot1{i}(5));
    set(gca,'YDir','reverse');
    hold on
    axis equal
    title(subplot1{i}(5),'Up-Control');
    
    axes(subplot1{i}(6));
    set(gca,'YDir','reverse');
    hold on
    axis equal
    plot([CONFIG.distractor{1}(1,1),CONFIG.distractor{1}(1,3)],[CONFIG.distractor{1}(1,2),CONFIG.distractor{1}(1,4)],'-k');
    plot([CONFIG.distractor{1}(2,1),CONFIG.distractor{1}(2,3)],[CONFIG.distractor{1}(2,2),CONFIG.distractor{1}(2,4)],'-k');
    title(subplot1{i}(6),'Lower-Left(1)');
    
    axes(subplot1{i}(7));
    set(gca,'YDir','reverse');
    hold on
    axis equal
    plot([CONFIG.distractor{2}(1,1),CONFIG.distractor{2}(1,3)],[CONFIG.distractor{2}(1,2),CONFIG.distractor{2}(1,4)],'-k');
    plot([CONFIG.distractor{2}(2,1),CONFIG.distractor{2}(2,3)],[CONFIG.distractor{2}(2,2),CONFIG.distractor{2}(2,4)],'-k');
    title(subplot1{i}(7),'Lower-Right(2)');
    
    axes(subplot1{i}(8));
    set(gca,'YDir','reverse');
    hold on
    axis equal
    plot([CONFIG.distractor{3}(1,1),CONFIG.distractor{3}(1,3)],[CONFIG.distractor{3}(1,2),CONFIG.distractor{3}(1,4)],'-k');
    plot([CONFIG.distractor{3}(2,1),CONFIG.distractor{3}(2,3)],[CONFIG.distractor{3}(2,2),CONFIG.distractor{3}(2,4)],'-k');
    title(subplot1{i}(8),'Lower-Left(3)');
    
    axes(subplot1{i}(9));
    set(gca,'YDir','reverse');
    hold on
    axis equal
    plot([CONFIG.distractor{4}(1,1),CONFIG.distractor{4}(1,3)],[CONFIG.distractor{4}(1,2),CONFIG.distractor{4}(1,4)],'-k');
    plot([CONFIG.distractor{4}(2,1),CONFIG.distractor{4}(2,3)],[CONFIG.distractor{4}(2,2),CONFIG.distractor{4}(2,4)],'-k');
    title(subplot1{i}(9),'Lower-Right(4)');
    
    axes(subplot1{i}(10));
    set(gca,'YDir','reverse');
    hold on
    axis equal
    title(subplot1{i}(10),'Lower-Control');
    
    upTrial = find(CONFIG.trialDir(:,1)==1);
    lowerTrial = find(CONFIG.trialDir(:,1)==-1);
    dis1 = find(CONFIG.trialDir(:,2) == 1);
    dis2 = find(CONFIG.trialDir(:,2) == 2);
    dis3 = find(CONFIG.trialDir(:,2) == 3);
    dis4 = find(CONFIG.trialDir(:,2) == 4);
    contrialTrial = find(CONFIG.trialDir(:,2) == 0);
    
    for j = 1:length(CONFIG.trialCondition)
        % get SCREEN parameter from the data file
        %%TODO
        
        if ismember(j,upTrial)
            if ismember(j,dis1)
                axes(subplot1{i}(1))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'b-');
            elseif ismember(j,dis2)
                axes(subplot1{i}(2))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'r-');
            elseif ismember(j,dis3)
                axes(subplot1{i}(3))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'b-');
            elseif ismember(j,dis4)
                axes(subplot1{i}(4))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'r-');
            elseif ismember(j,contrialTrial)
                axes(subplot1{i}(5))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'k-');
            end
        elseif ismember(j,lowerTrial)
            if ismember(j,dis1)
                axes(subplot1{i}(6))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'b-');
            elseif ismember(j,dis2)
                axes(subplot1{i}(7))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'r-');
            elseif ismember(j,dis3)
                axes(subplot1{i}(8))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'b-');
            elseif ismember(j,dis4)
                axes(subplot1{i}(9))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'r-');
            elseif ismember(j,contrialTrial)
                axes(subplot1{i}(10))
                plot(DATA.eyePath{j}(:,2),DATA.eyePath{j}(:,3),'k-');
            end
        end
    end
end

