function trajectories_away(subjectNum)
% this function coded for eye movement trajectories task which
% designed for deviation away saccades.
%
% The review in this field: 
% Eye movement trajectories and what they tell us
% Van der Stigchel, Meeter and Theeuwes, 2006
% https://www.ncbi.nlm.nih.gov/pubmed/16497377
% DOI: 10.1016/j.neubiorev.2005.12.001
% figure 3a and section 4
%
% reference for this task:
% Curved saccade trajectories: Voluntary and reflexive saccades curve away from irrelevant distractors
% Doyle and Walker, 2001
% https://www.ncbi.nlm.nih.gov/pubmed/11545472
%
% By BYC, Jun 2019

eyelinkRecording = 1; % 0 for test mode, 1 for recording

global TRIALINFO
global SCREEN
global BOX

reflexive = 1; % 1 for reflexive task; 1 for voluntary task
voluntary = 1-reflexive;
% subjects' information 
if reflexive
    fileName = ['trajectories_reflexive_' num2str(subjectNum) '_' datestr(now,'yymmddHHMM')];
elseif voluntary
    fileName = ['trajectories_voluntary_' num2str(subjectNum) '_' datestr(now,'yymmddHHMM')];
end

savePath = fullfile(pwd,'data');
mkdir(savePath);
curdir = pwd;

%% parameter
calibrationInterval = 600; % unit s, re-calibration in every 10 min is recommended if the task takes more than 15 min.

%------------
SCREEN.distance = 58; % cm
% SCREEN.distance = 100; %

% SCREEN.width = 37.5; % cm
% SCREEN.height = 30; % cm

% SCREEN.width = 34.5; % laptop
% SCREEN.height = 19.5; % laptop

SCREEN.width = 121; % room 305 big screen
SCREEN.height = 68; % room 305 big screen
%-------------

targetDegree = 8; % degree
distractorDegree = 6; % degree£¬ azimuth  and  elevation  from  fixation
fixationSizeD = 1.4; % ^2,degree
targetSizeD = 0.6; % ^2, degree
boxSizeD = 1.6; % ^2, degree
distractorSizeD = 1.6; % ^2, degree

distractorType = 3; % 1(default): cross; 2: square; 3: both. Please see below for detail

eyeTrackerWin = 1.2; % degree of fixation window

fixationPeriod = 0.5; % unit s; Its the minimun duration for fixation period. The real duration would be random from this time to this time +1s
choicePeriod = 2; % s
trialInterval = 1; % s

repetition = 15;

colorDistractor = [255 0 0 255];
colorTarget = [0 255 0 255];
colorBox = [0 0 0 0];

lineWidth = 6;
boxWidth = 3;

% trial setting
TRIALINFO.distractionPosition = [0 1 2 3 4]; % 0 for absent, 1 for left-up, 2 for right-up, 3 for left-lower, 4 for right-lower
TRIALINFO.targetPosition = [-1 1]; % 1 for up, -1 for down, [1 -1] for half-half

timePredicted = (fixationPeriod+0.5 + choicePeriod + trialInterval) * repetition * length(TRIALINFO.targetPosition) * length(TRIALINFO.distractionPosition);
automaticCalibration = timePredicted > 15*60; % make automatic calibration (every 10 min in default) if the block takes more than 15 min.

% set keyboard
KbName('UnifyKeyNames'); 
skipKey = KbName('space'); % to skip this trial
escape = KbName('escape'); % to exit the program
leftArror = KbName('LeftArrow');
rightArror = KbName('RightArrow');
upArror = KbName('UpArrow');
cKey = KbName('c'); % to force calibrate

% parameter all set
% calculate for trials condition
conditions = calculateTrialCondition();

repeatIndex = repmat(conditions,repetition,1);
trialN = size(repeatIndex,1);
conditionIndex = randperm(trialN);

% the parameter need to recorded
trialStTime = zeros(trialN,1);
fixationFinTime = zeros(trialN,1);
choiceStTime = zeros(trialN,1);
trialEndTime = zeros(trialN,1);
fixDuration = zeros(trialN,1);
trialDir = zeros(trialN,2);

trialCondition = cell(trialN,1);
choiceFinTime = zeros(trialN,1);

%% Initialization
Screen('Preference', 'SkipSyncTests', 1);

% Setup unified keynames and normalized 0-1 color space:
PsychDefaultSetup(2);

% Setup Psychtoolbox for OpenGL 3D rendering support and initialize the
% mogl OpenGL wrapper:
InitializeMatlabOpenGL(1);

%% set screen
screenId = max(Screen('Screens')); % find the screen to use for display

% Define background color:
% backgroundColor = WhiteIndex(screenId);
backgroundColor = [0.30,0.60,0.70]; % sky blue

% Open a double-buffered full-screen window:
PsychImaging('PrepareConfiguration');
[win , winRect] = PsychImaging('OpenWindow', screenId, backgroundColor);

% extract current monitor refreshing rate
refreshRate = Screen('NominalFrameRate', screenId);

% extract screen parameter
SCREEN.widthPix = winRect(3);
SCREEN.heightPix = winRect(4);
SCREEN.center = [winRect(3) winRect(4)]/2;
SCREEN.aspectRatio = winRect(3)/winRect(4);

% calculate for target position and distractions' position
targetDisP = degree2pix(targetDegree,2); % distance from target to screen center
distractorX = degree2pix(distractorDegree,1); % distance from distractor to screen center on X axis
distractorY = degree2pix(distractorDegree,2); % distance from distractor to screen center on Y axis
fixationSizeP = degree2pix(fixationSizeD); % size of fixation point
targetSizeP = degree2pix(targetSizeD); % size of target point
boxSizeP = degree2pix(boxSizeD); % size of distractor point
distractorSizeP = degree2pix(distractorSizeD); % distractors' size
eyeTrackerWinP = degree2pix(eyeTrackerWin); % size of fixation window

% calculate for targets and distractions' location
%
%               upTarget
%   distractor1             distractor2
%               fixationPoint
%   distractor3             distractor4
%               lowerTarget
%
% for every distractors:[x1, y1, x2, y2; 
%                           x3, y3, x4, y4]
%
% mod 1: cross version (default):
%   x1,y1      x3,y3
%         \   /
%           x
%         /   \
%   x4,y4      x2,y2
%
% mod 2: square version (constant present): 
% x1,y1 -- x3,y3
%   |         |
% x4,y4 -- x2,y2
%
% mod 3: draw both

BOX.distractorBox{1} = [SCREEN.center(1)-distractorX-boxSizeP, SCREEN.center(2)-distractorY-boxSizeP, SCREEN.center(1)-distractorX+boxSizeP, SCREEN.center(2)-distractorY+boxSizeP;...
    SCREEN.center(1)-distractorX-boxSizeP, SCREEN.center(2)-distractorY+boxSizeP, SCREEN.center(1)-distractorX+boxSizeP, SCREEN.center(2)-distractorY-boxSizeP];
BOX.distractorBox{2} = [SCREEN.center(1)+distractorX-boxSizeP, SCREEN.center(2)-distractorY-boxSizeP, SCREEN.center(1)+distractorX+boxSizeP, SCREEN.center(2)-distractorY+boxSizeP;...
    SCREEN.center(1)+distractorX-boxSizeP, SCREEN.center(2)-distractorY+boxSizeP, SCREEN.center(1)+distractorX+boxSizeP, SCREEN.center(2)-distractorY-boxSizeP];
BOX.distractorBox{3} = [SCREEN.center(1)-distractorX-boxSizeP, SCREEN.center(2)+distractorY-boxSizeP, SCREEN.center(1)-distractorX+boxSizeP, SCREEN.center(2)+distractorY+boxSizeP;...
    SCREEN.center(1)-distractorX-boxSizeP, SCREEN.center(2)+distractorY+boxSizeP, SCREEN.center(1)-distractorX+boxSizeP, SCREEN.center(2)+distractorY-boxSizeP];
BOX.distractorBox{4} = [SCREEN.center(1)+distractorX-boxSizeP, SCREEN.center(2)+distractorY-boxSizeP, SCREEN.center(1)+distractorX+boxSizeP, SCREEN.center(2)+distractorY+boxSizeP;...
    SCREEN.center(1)+distractorX-boxSizeP, SCREEN.center(2)+distractorY+boxSizeP, SCREEN.center(1)+distractorX+boxSizeP, SCREEN.center(2)+distractorY-boxSizeP];


distractor{1} = [SCREEN.center(1)-distractorX-distractorSizeP, SCREEN.center(2)-distractorY-distractorSizeP, SCREEN.center(1)-distractorX+distractorSizeP, SCREEN.center(2)-distractorY+distractorSizeP;...
    SCREEN.center(1)-distractorX-distractorSizeP, SCREEN.center(2)-distractorY+distractorSizeP, SCREEN.center(1)-distractorX+distractorSizeP, SCREEN.center(2)-distractorY-distractorSizeP];
distractor{2} = [SCREEN.center(1)+distractorX-distractorSizeP, SCREEN.center(2)-distractorY-distractorSizeP, SCREEN.center(1)+distractorX+distractorSizeP, SCREEN.center(2)-distractorY+distractorSizeP;...
    SCREEN.center(1)+distractorX-distractorSizeP, SCREEN.center(2)-distractorY+distractorSizeP, SCREEN.center(1)+distractorX+distractorSizeP, SCREEN.center(2)-distractorY-distractorSizeP];
distractor{3} = [SCREEN.center(1)-distractorX-distractorSizeP, SCREEN.center(2)+distractorY-distractorSizeP, SCREEN.center(1)-distractorX+distractorSizeP, SCREEN.center(2)+distractorY+distractorSizeP;...
    SCREEN.center(1)-distractorX-distractorSizeP, SCREEN.center(2)+distractorY+distractorSizeP, SCREEN.center(1)-distractorX+distractorSizeP, SCREEN.center(2)+distractorY-distractorSizeP];
distractor{4} = [SCREEN.center(1)+distractorX-distractorSizeP, SCREEN.center(2)+distractorY-distractorSizeP, SCREEN.center(1)+distractorX+distractorSizeP, SCREEN.center(2)+distractorY+distractorSizeP;...
    SCREEN.center(1)+distractorX-distractorSizeP, SCREEN.center(2)+distractorY+distractorSizeP, SCREEN.center(1)+distractorX+distractorSizeP, SCREEN.center(2)+distractorY-distractorSizeP];

distractorC{1} = [SCREEN.center(1)-distractorX,SCREEN.center(2)-distractorY];
distractorC{2} = [SCREEN.center(1)+distractorX,SCREEN.center(2)-distractorY];
distractorC{3} = [SCREEN.center(1)-distractorX,SCREEN.center(2)+distractorY];
distractorC{4} = [SCREEN.center(1)+distractorX,SCREEN.center(2)+distractorY];

BOX.upTarget = [SCREEN.center(1)-targetSizeP, SCREEN.center(2)-targetDisP-targetSizeP, SCREEN.center(1)+targetSizeP, SCREEN.center(2)-targetDisP+targetSizeP;...
                  SCREEN.center(1)+targetSizeP, SCREEN.center(2)-targetDisP-targetSizeP, SCREEN.center(1)-targetSizeP, SCREEN.center(2)-targetDisP+targetSizeP];
BOX.lowerTarget = [SCREEN.center(1)-targetSizeP, SCREEN.center(2)+targetDisP-targetSizeP, SCREEN.center(1)+targetSizeP, SCREEN.center(2)+targetDisP+targetSizeP;...
                     SCREEN.center(1)+targetSizeP, SCREEN.center(2)+targetDisP-targetSizeP, SCREEN.center(1)-targetSizeP, SCREEN.center(2)+targetDisP+targetSizeP];

% initial Eyelink
if eyelinkRecording
    tempName = 'TEMP1'; % need temp name because Eyelink only know hows to save names with 8 chars or less. Will change name using matlab's moveFile later.
    dummymode=0;
    
    el=EyelinkInitDefaults(win);
    el.backgroundcolour = backgroundColor;
    el.foregroundcolour = BlackIndex(el.window);
    el.msgfontcolour    = BlackIndex(el.window);
    el.imgtitlecolour   = BlackIndex(el.window);
    
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        Eyelink('ShutDown');
        Screen('CloseAll');
        return
    end
    
    i = Eyelink('Openfile', tempName);
    if i~=0
        fprintf('Cannot create EDF file ''%s'' ', fileName);
        cleanup;
        Eyelink('ShutDown');
        Screen('CloseAll');
        return
    end
    
    %   SET UP TRACKER CONFIGURATION
    Eyelink('command', 'calibration_type = HV9');
    %	set parser (conservative saccade thresholds)
    Eyelink('command', 'saccade_velocity_threshold = 35');
    Eyelink('command', 'saccade_acceleration_threshold = 9500');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,AREA');
    Eyelink('command', 'online_dcorr_refposn = %1d, %1d', SCREEN.center(1), SCREEN.center(2));
    Eyelink('command', 'online_dcorr_maxangle = %1d', 30.0);
    % you must call this function to apply the changes from above
    EyelinkUpdateDefaults(el);
    
    % Calibrate the eye tracker
    EyelinkDoTrackerSetup(el);
    
    % do a final check of calibration using driftcorrection
    EyelinkDoDriftCorrection(el);
    
    Eyelink('StartRecording');
    
    Eyelink('message', 'SYNCTIME');	 	 % zero-plot time for EDFVIEW
    eye_used = Eyelink('EyeAvailable'); % get eye that's tracked
    if eye_used == el.BINOCULAR % if both eyes are tracked
        eye_used = el.LEFTEYE; % use left eye
    end
    errorCheck=Eyelink('checkrecording'); 		% Check recording status */
    if(errorCheck~=0)
        fprintf('Eyelink checked wrong status.\n');
        cleanup;  % cleanup function
        Eyelink('ShutDown');
        Screen('CloseAll');
    end
    
    calibrateCkeck = tic;
end

% trial start
indexI = 1;
escFlag = 0;
blockTime = tic;
SetMouse(0,0);
while indexI < length(conditionIndex)+1
    while indexI < length(conditionIndex)+1
        % draw the fixation point whith point out the target position
        drawBoxes(win,colorBox,boxWidth);
        Screen('DrawLine', win, [255 255 255],SCREEN.center(1),SCREEN.center(2),SCREEN.center(1)-fixationSizeP,SCREEN.center(2),lineWidth);
        Screen('DrawLine', win, [255 255 255],SCREEN.center(1),SCREEN.center(2),SCREEN.center(1)+fixationSizeP,SCREEN.center(2),lineWidth);
        if reflexive
            Screen('DrawLine', win, [255 255 255],SCREEN.center(1),SCREEN.center(2),SCREEN.center(1),SCREEN.center(2)-fixationSizeP,lineWidth);
            Screen('DrawLine', win, [255 255 255],SCREEN.center(1),SCREEN.center(2),SCREEN.center(1),SCREEN.center(2)+fixationSizeP,lineWidth);
        elseif voluntary
            if repeatIndex(conditionIndex(indexI),2) == 1 % up
                Screen('DrawLine', win, [255 255 255],SCREEN.center(1),SCREEN.center(2),SCREEN.center(1),SCREEN.center(2)-fixationSizeP,lineWidth);
            elseif repeatIndex(conditionIndex(indexI),2) == -1 % lower
                Screen('DrawLine', win, [255 255 255],SCREEN.center(1),SCREEN.center(2),SCREEN.center(1),SCREEN.center(2)+fixationSizeP,lineWidth);
            end
        end
        Screen('DrawingFinished',win);
        Screen('Flip',win,0,0);
        
        [~,~,keyCode] = KbCheck;
        if keyCode(escape)
            escFlag = 1;
            break;
        end
        
        if eyelinkRecording
            if automaticCalibration
                if toc(calibrateCkeck) >= calibrationInterval
                    EyelinkDoTrackerSetup(el);
                    Eyelink('StartRecording');
                    Eyelink('message', 'Calibrate Finished');	 	 % zero-plot time for EDFVIEW
                    errorCheck=Eyelink('checkrecording'); 		% Check recording status */
                    if(errorCheck~=0)
                        fprintf('Eyelink checked wrong status.\n');
                        cleanup;  % cleanup function
                        Eyelink('ShutDown');
                        Screen('CloseAll');
                    end
                    calibrateCkeck = tic;
                end
            end
            
            if keyCode(cKey) % press c to calibrate
                EyelinkDoTrackerSetup(el);
                Eyelink('StartRecording');
                Eyelink('message', 'Force Calibrate Finished');	 	 % zero-plot time for EDFVIEW
                errorCheck=Eyelink('checkrecording'); 		% Check recording status */
                if(errorCheck~=0)
                    fprintf('Eyelink checked wrong status.\n');
                    cleanup;  % cleanup function
                    Eyelink('ShutDown');
                    Screen('CloseAll');
                end
                calibrateCkeck = tic;
                WaitSecs(0.5); % wait a little bit, in case the key press during calibration influence the following keyboard check
            end
            
            
            trialStTime(indexI) = toc(blockTime);
            
            Eyelink('message', ['Trial start ' num2str(indexI)]);
            
            fixationTime = fixationPeriod+rand();
            fixationPoint = SCREEN.center;
            [escFlag,retryFlag] = fixationCheck(fixationPoint,eyeTrackerWinP,fixationTime,eye_used,escape,skipKey,cKey,el);
            
            if escFlag
                break;
            elseif retryFlag
                conditionIndex = [conditionIndex conditionIndex(indexI)];
                conditionIndex(indexI) = [];
                break;
            end
            fixDuration(indexI) = fixationTime;
            Eyelink('message', ['Fixation completed ' num2str(indexI)]);
            fixationFinTime(indexI) = toc(blockTime);
        else
            trialStTime(indexI) = toc(blockTime);
            WaitSecs(fixationPeriod);
            fixationFinTime(indexI) = toc(blockTime);
        end
        
        % fixation completed. Display the target and distractor
        drawBoxes(win,colorBox,boxWidth);
        Screen('DrawLine', win, [255 255 255],SCREEN.center(1),SCREEN.center(2),SCREEN.center(1)-fixationSizeP,SCREEN.center(2),lineWidth);
        Screen('DrawLine', win, [255 255 255],SCREEN.center(1),SCREEN.center(2),SCREEN.center(1)+fixationSizeP,SCREEN.center(2),lineWidth);
        
        if reflexive
            Screen('DrawLine', win, [255 255 255],SCREEN.center(1),SCREEN.center(2),SCREEN.center(1),SCREEN.center(2)-fixationSizeP,lineWidth);
            Screen('DrawLine', win, [255 255 255],SCREEN.center(1),SCREEN.center(2),SCREEN.center(1),SCREEN.center(2)+fixationSizeP,lineWidth);
            if repeatIndex(conditionIndex(indexI),2) == 1 % up
                drawDistractor(win,BOX.upTarget,colorTarget,lineWidth);
            elseif repeatIndex(conditionIndex(indexI),2) == -1 % lower
                drawDistractor(win,BOX.lowerTarget,colorTarget,lineWidth);
            end
        elseif voluntary
            if repeatIndex(conditionIndex(indexI),2) == 1 % up
                Screen('DrawLine', win, [255 255 255],SCREEN.center(1),SCREEN.center(2),SCREEN.center(1),SCREEN.center(2)-fixationSizeP,lineWidth);
            elseif repeatIndex(conditionIndex(indexI),2) == -1 % lower
                Screen('DrawLine', win, [255 255 255],SCREEN.center(1),SCREEN.center(2),SCREEN.center(1),SCREEN.center(2)+fixationSizeP,lineWidth);
            end
        end
        
        distractorNum = repeatIndex(conditionIndex(indexI),1); % - repeatIndex(conditionIndex(indexI),2) + 1;
        if repeatIndex(conditionIndex(indexI),1)~=0
            drawDistractor(win,distractor{distractorNum},colorDistractor,lineWidth,distractorType);
        end
        
        Screen('DrawingFinished',win);
        Screen('Flip',win,0,0);
        
        sound(sin(2*pi*25*(1:4000)/300)); % give a go signal by sound
        
        choiceSt = tic;
        
        % start choice
        choiceStTime(indexI) = toc(blockTime);
        choiceFlag = 0;
        if eyelinkRecording
            Eyelink('message', ['Start choice ' num2str(indexI)]);
            while toc(choiceSt) < choicePeriod
                if Eyelink( 'NewFloatSampleAvailable')>0
                    % get the sample in the form of an event structure
                    evt = Eyelink( 'NewestFloatSample');
                    if eye_used ~= -1 % do we know which eye to use yet?
                        px =evt.gx(eye_used+1); % +1 as we're accessing MATLAB array
                        py = evt.gy(eye_used+1);
                    end
                end
                if repeatIndex(conditionIndex(indexI),1)~=0
                    if abs((distractorC{distractorNum}(1)-px)+(distractorC{distractorNum}(2)-py)*1i) < eyeTrackerWinP
                        choiceFlag = 0;
                        Eyelink('message', ['Trial Break ' num2str(indexI)]);
                        break
                    end
                end
                if repeatIndex(conditionIndex(indexI),2) == 1 % if choice up target when up target shown
                    if abs((SCREEN.center(1)-px)+(SCREEN.center(2)-targetDisP-py)*1i) < eyeTrackerWinP
                        choiceFlag = 1;
                        Eyelink('message', ['Up Target Chosen ' num2str(indexI)]);
                        choiceFinTime(indexI) = toc(choiceSt);
                        sound(sin(2*pi*25*(1:4000)/200));
                        break
                    end
                elseif repeatIndex(conditionIndex(indexI),2) == -1 % if choice lower target when lower target shown
                    if abs((SCREEN.center(1)-px)+(SCREEN.center(2)+targetDisP-py)*1i) < eyeTrackerWinP
                        choiceFlag = 1;
                        Eyelink('message', ['Lower Target Chosen ' num2str(indexI)]);
                        choiceFinTime(indexI) = toc(choiceSt);
                        sound(sin(2*pi*25*(1:4000)/200));
                        break
                    end
                end
            end
        end
        
        WaitSecs(0.5);
        
        trialCondition{indexI} = repeatIndex(conditionIndex,:);
        trialDir(indexI,:) = [repeatIndex(conditionIndex(indexI),2), repeatIndex(conditionIndex(indexI),1)]; % two column: [up/down, left/right]
        trialEndTime(indexI) = toc(blockTime);
        
        if eyelinkRecording
            Eyelink('message',['Trial End ' num2str(indexI)]);
        end
        
        
        if choiceFlag
            indexI = indexI+1;
        else
            sound(sin(2*pi*25*(1:4000)/600));
            conditionIndex = [conditionIndex conditionIndex(indexI)];
            conditionIndex(indexI) = [];
        end
        
        WaitSecs(trialInterval);
    end
    if escFlag
        break;
    end
end
Screen('Flip', win);

if eyelinkRecording
    Eyelink('StopRecording');
    Eyelink('CloseFile');
    try
        fprintf('Receiving data file ''%s''\n',fileName);
        status=Eyelink('ReceiveFile',tempName ,savePath,1);
        if status > 0
            fprintf('ReceiveFile status %d\n ', status);
        end
        if exist(fileName, 'file')==2
            fprintf('Data file ''%s'' can be found in '' %s\n',fileName, pwd);
        end
    catch
        fprintf('Problem receiving data file ''%s''\n',fileName);
    end
    
    cd (savePath);
    save(fullfile(savePath,fileName));
    movefile([savePath,'\',tempName,'.edf'],[savePath,'\',fileName,'.edf']);
end
upTarget = BOX.upTarget;
lowerTarget = BOX.lowerTarget;
fixationPoint = SCREEN.center;
%% save the real and the choiced heading
save(fullfile(savePath,fileName),'upTarget','lowerTarget','fixationPoint','trialStTime','fixationFinTime','choiceStTime','trialEndTime','trialCondition','choiceFinTime','fixDuration','SCREEN','trialDir','distractor');

%close the eye tracker.
if eyelinkRecording
    Eyelink('ShutDown');
end

Screen('CloseAll');
cd(curdir);