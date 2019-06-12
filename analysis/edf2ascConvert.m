function edf2ascConvert(dataPath,exeFilePath)
% This script can convert EYELINK DATA FILE(.EDF) to ASCII(.asc) files.
% The processing might need a period of time. If you have a significant
% number of files need to processing, please well arrange your time 
% before running this script.
%
% By BYC June,2019

if ~exist('dataPath','var')
    error('There is no file in this path or there is a wrong path.');
end

if ~exist('exeFilePath','var')
    error('There is no file in this path or there is a wrong path.');
elseif contains(exeFilePath,'edf2asc.exe')
    exeFileName = [exeFilePath ' -ntime_check'];
else
    exeFileName = [fullfile(exeFilePath,'edf2asc.exe') ' -ntime_check'];
end
curPath = pwd;
cd (dataPath);
dataFile= dir(fullfile(dataPath, '*.EDF'));
ascCheck = 1; % how to deal the existed asc files? 1. overwrite; 0. skip. You could set 0 after the second process.

if ascCheck
    delete *.asc
end

for i = 1:length(dataFile)
    originFile = fullfile(dataPath,dataFile(i).name);
    
    if contains(originFile,'.EDF')
        ascName = strrep(dataFile(i).name,'.EDF','.asc');
    elseif contains(originFile,'.edf')
        ascName = strrep(dataFile(i).name,'.edf','.asc');
    else
        error([dataFile(i).name ' is not a EDF file']);
    end
    
    if ~ascCheck
        checkResult = fopen(ascName);
        if checkResult > 0
            continue
        end
    end
    
    cmd = [exeFileName 32 originFile];
    [~,log] = system(cmd);
    logName = ['log_' strrep(dataFile(i).name,'.edf','')];
    saveMat(logName,log);
    
    % %% reverse for the error report
% error_report = status(status(:,1)~=1,:);
% if ~isempty(error_report)
%     report_savename = [datestr(now,'yymmddHHMM') '_edf2asc.mat'];
%     save(report_savename,'status','error_report');
% end
end

cd(curPath);
end