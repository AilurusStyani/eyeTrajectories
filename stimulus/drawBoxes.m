function drawBoxes(win,color,lineWidth)
global BOX
mod = 2;
drawDistractor(win,BOX.distractorBox{1},color,lineWidth,mod);
drawDistractor(win,BOX.distractorBox{2},color,lineWidth,mod);
drawDistractor(win,BOX.distractorBox{3},color,lineWidth,mod);
drawDistractor(win,BOX.distractorBox{4},color,lineWidth,mod);

drawDistractor(win,BOX.upTarget,color,lineWidth,mod);
drawDistractor(win,BOX.lowerTarget,color,lineWidth,mod);

