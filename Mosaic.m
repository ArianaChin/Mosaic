clear all; close all; clc;
%% Load Screen

Screen('Preference', 'SkipSyncTests', 1);
%[window, rect] = Screen('OpenWindow', 0,[],[100 100 800 1000]); % opening the screen
[window, rect] = Screen('OpenWindow', 0);
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); % allowing transparency in the photos

HideCursor();
window_w = rect(3); % defining size of screen
window_h = rect(4);
cd('kinkade');

%% Creating Matrix of Mosaic Image Average Colors

pics = zeros(65,3);
for i = 1:65
    pic = imread(['k_' num2str(i) '.jpg']);
    pics(i,1) = sum(sum(pic(:,:,1))) / (size(pic,1)*size(pic,2));
    pics(i,2) = sum(sum(pic(:,:,2))) / (size(pic,1)*size(pic,2));
    pics(i,3) = sum(sum(pic(:,:,3))) / (size(pic,1)*size(pic,2));
    pics(i,4) = Screen('MakeTexture', window, pic);
    %pics_id(i) = {['k_' num2str(i) '.jpg']};
end

%% Reading Image to Recreate

cd ..;
block_size = 5;
img = imread('Cult.png');
img = imresize(img,[floor(size(img,1)/block_size)*block_size,floor(size(img,2)/block_size)*block_size]);
size_img = size(img);
if size_img(1) > window_h;
    
end;
matrix = zeros(floor(size_img(1)/block_size),floor(size_img(2)/block_size));
for i = 1:size(matrix, 1)
    for j = 1:size(matrix, 2)
        matrix(i,j,1) = sum(sum(img(block_size*(i-1)+1:block_size*i, block_size*(j-1)+1:block_size*j, 1))) / (block_size*block_size);
        matrix(i,j,2) = sum(sum(img(block_size*(i-1)+1:block_size*i, block_size*(j-1)+1:block_size*j, 2))) / (block_size*block_size);
        matrix(i,j,3) = sum(sum(img(block_size*(i-1)+1:block_size*i, block_size*(j-1)+1:block_size*j, 3))) / (block_size*block_size);
    end
end

%% Finding Images to Match Color

for i = 1:size(matrix,1)
    for j = 1:size(matrix,2)
        closest = 255*3;
        match = 0;
        for k = 1:65
            difference = abs(matrix(i,j,1)-pics(k,1)) + abs(matrix(i,j,2)-pics(k,2)) + abs(matrix(i,j,3)-pics(k,3));
            if difference < closest;
                closest = difference;
                match = k;
            end
        end
        matrix(i,j,4) = pics(match,4);
        %pics_montage{i,j} = pics_id(match);
    end
end
%image = montage(pics_montage, 'Size', [size(matrix,1), size(matrix,2)]);

%% Creating Grid
xStart = 0;
xEnd = floor(size_img(2)/block_size)*block_size-block_size;
yStart = 0;
yEnd = floor(size_img(1)/block_size)*block_size-block_size;
scale = 1;
if (size_img(2) - block_size) > window_w;
    xEnd = window_w;
    scale = window_w / (size_img(2)-block_size);
    yEnd = (size_img(1)-block_size)*scale;
end;
if (size_img(1) - block_size) > window_h && (size_img(1) - block_size)-window_h > (size_img(2) - block_size)-window_w;
    yEnd = window_h;
    scale = window_h / (size_img(1)-block_size);
    xEnd = (size_img(2)-block_size)*scale;
end;
nRows = size_img(1)/block_size;
nCols = size_img(2)/block_size;

x = linspace(xStart,xEnd,nCols);
y = linspace(yStart,yEnd,nRows);
[x,y] = meshgrid(x,y);

xy_rect = [x(:)'; y(:)'; x(:)'+(block_size*scale); y(:)'+(block_size*scale)];

%% Displaying Grid with Photos
grid_pictures = reshape(matrix(:,:,4),size(matrix,1)*size(matrix,2),1);

Screen('DrawTextures',window, grid_pictures, [], xy_rect);
Screen('Flip', window);
KbWait;
Screen('CloseAll');