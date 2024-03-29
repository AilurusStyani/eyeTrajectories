function [degree_data,acceleration,dt]=pixel2degreev(eyedata,SCREEN,col_t,col_x,col_y)
% this function can convert pixel data of x/y to saccade degree in every ms
% eyedata shoule be in at least three column, first for time marker, second for x-axis position in pixel, third for y-axis
% position in pixel. col_t, col_x and col_y present which column is for time, x-axis and y-axis.
%
% BYC Sep 2018

% checking for screen parameter, 1280*1024 pixel and 37.5 * 30 cm as default. 
% The unit for height and width could differ from cm, but should be the same to eye-screen distance.
% global SCREEN

if ~exist('SCREEN.height','var')
    screenH = 30; % cm
else
    screenH = SCREEN.height;
end

if ~exist('SCREEN.width','var')
    screenW = 37.5; % cm
else
    screenW = SCREEN.width;
end

if ~exist('SCREEN.heightPix','var')
    screenHP = 1024; % pixel
else
    screenHP = SCREEN.heightPix;
end

if ~exist('SCREEN.widthPix','var')
    screenWP = 1280; % pixel
else
    screenWP = SCREEN.widthPix;
end

% set the distance from eye to screen, 60 cm as default
if ~exist('SCREEN.viewdistance','var') && ~exist('SCREEN.distance','var')
    viewDis = 60; % cm
elseif exist('SCREEN.viewdistance','var')
    viewDis = SCREEN.viewdistance;
else
    viewDis = SCREEN.distance;
end

if ~exist('clo_t','var') || isempty(col_t); col_t = 1; end
if ~exist('clo_x','var') || isempty(clo_x); col_x = 2; end
if ~exist('clo_y','var') || isempty(clo_y); col_y = 3; end

dt = ( mode(eyedata(2:end,col_t) - eyedata(1:end-1,col_t)) ); % ms
index_length = length(eyedata(:,1));

if index_length <= 6
    error('Input data are too short or you may need to transpose the matrix.')
end

index_p = zeros(size(eyedata,1),2);

for i = 1 : size(eyedata,1)
    if i == 1 || i == size(eyedata,1)
        index_p(i,:) = 0;
    elseif i == 2 || i == size(eyedata,1) - 1
        index_p(i,:) = (eyedata(i+1,2:3) - eyedata(i-1,2:3)) / 2;
    elseif i == 3 || i == size(eyedata,1) - 2
        index_p(i,:) = (eyedata(i+2,2:3) + eyedata(i+1,2:3) - eyedata(i-1,2:3) - eyedata(i-2,2:3)) / 6;
    elseif i == 4 || i == size(eyedata,1) - 3
        index_p(i,:) = (eyedata(i+3,2:3) + eyedata(i+2,2:3) + eyedata(i+1,2:3) - eyedata(i-1,2:3) - eyedata(i-2,2:3) - eyedata(i-3,2:3)) / 12;
    else
        index_p(i,:) = (eyedata(i+4,2:3) + eyedata(i+3,2:3) + eyedata(i+2,2:3) + eyedata(i+1,2:3) - eyedata(i-1,2:3) - eyedata(i-2,2:3) - eyedata(i-3,2:3) - eyedata(i-4,2:3)) / 20;
    end
end

% convert velocity unit in x-y pixel to x-y in real distance 
index_cm = [index_p(:,1) ./ screenWP .* screenW , index_p(:,2) ./ screenHP .* screenH];

% convert x-y distance to vector distance
index_v = sqrt(power(index_cm(:,1),2) + power(index_cm(:,2),2)) ./ viewDis;

% convert to velocity in degree
index_vd = atand(index_v) /dt*1000; % degree/s

% calculate for  acceleration
acceleration = [0;(index_vd(2:end) - index_vd(1:end-1))/dt*1000]; % degree/s^2

[~,col_num] = size(eyedata);
unchanged_col = 1:col_num;
unchanged_col([col_t col_x col_y]) = [];

degree_data = [eyedata(:,1) , index_vd, eyedata(:,[col_x,col_y,unchanged_col])];
end
    