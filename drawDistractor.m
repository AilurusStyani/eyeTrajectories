function drawDistractor(win,distractor,colorDistractor,lineWidth,mod)
% this function draw distractor for trajectories
%
% for every distractors:[x1, y1, x2, y2; x3, y3, x4, y4]
% When mod == 1: cross version:
%   x1,y1      x3,y3
%         \   /
%           x
%         /   \
%   x4,y4      x2,y2
%
% When mod == 2: square version:
% x1,y1 -- x3,y3
%   |        |
% x4,y4 -- x2,y2
if nargin == 5
    if mod == 1
        Screen('DrawLine',win,colorDistractor,distractor(1,1),distractor(1,2),distractor(1,3),distractor(1,4),lineWidth);
        Screen('DrawLine',win,colorDistractor,distractor(2,1),distractor(2,2),distractor(2,3),distractor(2,4),lineWidth);
    elseif mod == 2
        Screen('DrawLine',win,colorDistractor,distractor(1,1),distractor(1,2),distractor(2,1),distractor(2,2),lineWidth);
        Screen('DrawLine',win,colorDistractor,distractor(1,1),distractor(1,2),distractor(2,3),distractor(2,4),lineWidth);
        Screen('DrawLine',win,colorDistractor,distractor(1,3),distractor(1,4),distractor(2,1),distractor(2,2),lineWidth);
        Screen('DrawLine',win,colorDistractor,distractor(1,3),distractor(1,4),distractor(2,3),distractor(2,4),lineWidth);
    end
else
    Screen('DrawLine',win,colorDistractor,distractor(1,1),distractor(1,2),distractor(1,3),distractor(1,4),lineWidth);
    Screen('DrawLine',win,colorDistractor,distractor(2,1),distractor(2,2),distractor(2,3),distractor(2,4),lineWidth);
end
