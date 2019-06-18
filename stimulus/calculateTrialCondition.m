function trialCondition = calculateTrialCondition()
global TRIALINFO
if isempty(find(TRIALINFO.distractionPosition==0, 1))
disTar = [sort(repmat(TRIALINFO.distractionPosition',length(TRIALINFO.targetPosition),1)),...
        repmat(TRIALINFO.targetPosition',length(TRIALINFO.distractionPosition),1)];
else
    disPIndex = TRIALINFO.distractionPosition~=0;
    disTarLR = [sort(repmat(TRIALINFO.distractionPosition(disPIndex)',length(TRIALINFO.targetPosition),1)),...
        repmat(TRIALINFO.targetPosition',length(TRIALINFO.distractionPosition(disPIndex)),1)];
    disTar = [disTarLR;zeros(length(TRIALINFO.targetPosition),1),TRIALINFO.targetPosition'];
end
    
% dispositionDisTar = [sort(repmat(TRIALINFO.distractionPosition',length(TRIALINFO.targetPosition)*...
%         length(TRIALINFO.distraction),1),1), repmat(disTar,length(TRIALINFO.distractionPosition),1)];
    
trialCondition = disTar;