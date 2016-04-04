close all;
clc;

input1 = 'output/fft_layer_1.mat';
input2 = 'output/fft_layer_2.mat';
input3 = 'output/fft_layer_3.mat';

inputs = {input1, input2, input3};

%% Read input

n = numel(inputs);
ffts = cell(1, numel(n));

m = ceil(sqrt(n));

figure;

for i = 1 : n
    
    load(inputs{i}, 'f');
    ffts{i} = f;
  
    subplot(m, m, i); 
    imagesc(log(1 + abs(ffts{i})));
    colormap jet;
    axis equal image;
end

%% Repeated convolution

c = ffts{1};
for i = 2 : n
    
    c = conv2(c, ffts{i}, 'same');
    
    fprintf('Done with convolution %i \n', i);
    
end

%% Display

% Normalize
response = abs(c);
response = log(1 + response);
response = (response - min(response(:))) / (max(response(:)) - min(response(:)));

figure;
imagesc(log(1 + response));
colormap jet;
colorbar;
axis equal image;
title('Convolution of Fourier images');

fprintf('Minimum of response: %i \n', min(abs(c(:))));
fprintf('Maximum of response: %i \n', max(abs(c(:))));
