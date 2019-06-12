function asc2matConvert(dataPath,errorSet)

currentPath = pwd;
cd(dataPath)
fileName = dir('*.asc');
if isempty(fileName)
    error('There is no .asc file in this path.')
end

for i = 1:length(fileName)
    fileNameI = fileName(i).name;
    saveName = ['converted_' strrep(fileNameI,'.asc','.mat')];
    
    % extract the time on file names as the error marker
    num = regexp(fileNameI,'(\d+)','tokens');
    subjectNum = str2double(num{1});
    
    % extract data
    fid = fopen(fileNameI);
    fseek(fid,0,'eof');
    numLine = ftell(fid);
    fclose(fid);
    rawData = importdata(fileNameI,' ',numLine);
    
    % trial start time recorded by Eyelink
    ts = regexp(rawData(contains(rawData,'Trial start','IgnoreCase',true)),'(\d+)','tokens');
    trialStart = nan(length(ts),2);
    for j=1:length(ts)
        if ~isempty(ts{j})
            trialStart(j,:) = [str2double(ts{j}{1}) str2double(ts{j}{2})];
            if j>1
                if trialStart(j,2) == trialStart(j-1,2)
                    trialStart(j-1,:) = NaN; % mark the broken trials as NaN
                end
            end
        end
    end
    trialStart(isnan(trialStart(:,1)),:) = []; % delet broken trials
    
    % Completing fixation time recorded by Eyelink
    fc = regexp(rawData(contains(rawData,'Fixation completed','IgnoreCase',true)),'(\d+)','tokens');
    fixationComplete = nan(length(fc),2);
    for j=1:length(fc)
        if ~isempty(fc{j})
            fixationComplete(j,:) = [str2double(fc{j}{1}) str2double(fc{j}{2})];
            if j>1
                if fixationComplete(j,2) == fixationComplete(j-1,2)
                    fixationComplete(j-1,:) = NaN; % mark the broken trials as NaN
                end
            end
        end
    end
    fixationComplete(isnan(fixationComplete(:,1)),:) = []; % delet broken trials
    
    % Choice starting time recorded by Eyelink
    st = regexp(rawData(contains(rawData,'Start choice','IgnoreCase',true)),'(\d+)','tokens');
    startChoice = nan(length(st),2);
    for j=1:length(st)
        if ~isempty(st{j})
            startChoice(j,:) = [str2double(st{j}{1}) str2double(st{j}{2})];
            if j>1
                if startChoice(j,2) == startChoice(j-1,2)
                    startChoice(j-1,:) = NaN; % mark the broken trials as NaN
                end
            end
        end
    end
    startChoice(isnan(startChoice(:,1)),:) = []; % delet broken trials
    
    % completeing chosen time recorded by Eyelink
    tc = regexp(rawData(contains(rawData,'Target Chosen','IgnoreCase',true)),'(\d+)','tokens');
    targetChosen = nan(length(tc),2);
    for j=1:length(tc)
        if ~isempty(tc{j})
            targetChosen(j,:) = [str2double(tc{j}{1}) str2double(tc{j}{2})];
            if j>1
                if targetChosen(j,2) == targetChosen(j-1,2)
                    targetChosen(j-1,:) = NaN; % mark the broken trials as NaN
                end
            end
        end
    end
    targetChosen(isnan(targetChosen(:,1)),:) = []; % delet broken trials
    
    % time of trial end recorded by Eyelink
    te = regexp(rawData(contains(rawData,'Target Chosen','IgnoreCase',true)),'(\d+)','tokens');
    trialFinish = nan(length(te),2);
    for j=1:length(te)
        if ~isempty(te{j})
            trialFinish(j,:) = [str2double(te{j}{1}) str2double(te{j}{2})];
            if j>1
                if trialFinish(j,2) == trialFinish(j-1,2)
                    trialFinish(j-1,:) = NaN; % mark the broken trials as NaN
                end
            end
        end
    end
    trialFinish(isnan(trialFinish(:,1)),:) = []; % delet broken trials
    
   
    ind = strfind(rawData,'...');
    ind = ~cellfun(@isempty,ind);
    data = rawData(ind);
    
    rawData = []; % instead of clear function in parfor
    
    data = strrep(data,'...','');
    data = cellfun(@str2num,data,'UniformOutput',false);
    positionData = cell2mat(data);
    
    eyeData = positionData(:,1:4);
    
    % clear
    data = [];
    positionData = [];
    ind = [];
    
    % check if 2000Hz, convert to 1000Hz
    time = eyeData(:,1);
    if ~isempty(find(unique(diff(time))==0,1))
        for k = 1:2
            if time(k)==time(k+1)
                tempData = eyeData(k:2:end,:);
            end
        end
        eyeData = tempData;
        time = eyeData(:,1);
    end
    
    % replace all the missing data as 0
    dt = mode(diff(time));
    ind = (time-time(1))/dt+1;
    tempData = zeros(ind(end),size(eyeData,2));
    tempData(:,1) = time(1):dt:time(end);
    tempData(ind,2:end) = eyeData(:,2:end);
    
    eyeData = [];
    
    eyePath = cell(length(trialStart),1);
    trialEyeData = cell(length(trialStart),1);
    
    trialI = targetChosen(:,2)';
    
    for j = trialI(~isnan(trialI))
        eyeMoveSt = find(tempData(:,1) >= fixationComplete(fixationComplete(:,2) == j,1),1);
        eyeMoveEnd = find(tempData(:,1) <= targetChosen(targetChosen(:,2) == j,1),1,'last');
        eyePath{j} = tempData(eyeMoveSt:eyeMoveEnd,:);
        
        trialSt = find(tempData(:,1) >= trialStart(trialStart(:,2) == j,1),1);
        trialEnd = find(tempData(:,1) <= trialFinish(trialFinish(:,2) == j,1),1,'last');
        trialEyeData{j} = tempData(trialSt:trialEnd,:);
    end
    %% todo try cell
    save(saveName,'trialEyeData','eyePath','trialStart');
%     saveMat(saveName,trialEyeData,eyePath,trialStart);
end

cd(currentPath);
end