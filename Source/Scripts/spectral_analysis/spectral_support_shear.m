close all;
clc;

%% 1D Fourier transform for each 1D layer

folder = 'journal/results/tiles_legotruck_6x6x480x640_480x640x5_tiling_4x6x200x200_overlap_0.5/';
names = {'1.png', '2.png', '3.png', '4.png', '5.png'};

N = 2;
row = 240;
width = 639;

p = 9 / 480;
f0 = 1 / (2 * p);

layers = zeros(N, width);

for i = 1 : N
    im = rgb2gray(imread([folder names{i}]));
    im1D = im(row, 1 : width);
    im1D = (im1D - min(im1D)) / (max(im1D) - min(im1D));
   	layers(i, :) = im1D;
end

%layers = rand(N, width);

figure; imshow(layers);

fs1D = cell(1, N);
for i = 1 : N
    fs1D{i} = fftshift(fft(layers(i, :)));
    figure; plot(log(1 + abs(fs1D{i})));
end

%% Shear the 1D Fourier image to create slanted line in 2D spectrum

sz = 3001;
slopes = [-0.5, 0.5, 0 0.25, -0.25];
domain = -(width - 1) / 2 : (width - 1) / 2;

fs2D = cell(1, N);

for i = 1 : N
    
    y = round(slopes(i) * domain);  
  
    x = domain + (width - 1) / 2 + 1;
    y = y + (width - 1) / 2 + 1;
    y = y(end : -1 : 1);
  
    x = x + (sz - width) / 2;
    y = y + (sz - width) / 2;
   
    inds = sub2ind([sz, sz], y(:), x(:));
  
    f = zeros(sz);
    f(inds) = fs1D{i};
  
    figure; imagesc(log(1 + abs(f))); colormap jet;
  
    fs2D{i} = f;
  
end

%% Repeated convolution

c = fs2D{1};

for i = 2 : N
    
    fprintf('Convolution %i ... ', i - 1);
    
    c = conv2(c, fs2D{i}, 'same');
    
    fprintf('Done\n');
end

step = 2 * f0 / width;
labelsX = -step * (sz - 1) / 2 : step : step * (sz - 1) / 2;
labelsY = labelsX;

figure; imagesc(labelsX, labelsY, log(1 + abs(c))); axis equal image; colormap jet;
set(gca, 'Ydir', 'normal');

%% Save convolution

im = log(1 + abs(c));
im = (im - min(im(:))) / (max(im(:)) - min(im(:)));

rgb = ind2rgb(gray2ind(im, 255), jet(255));
filename = ['../../bachelor_thesis/Document/Figures/spectral_support/' 'convolution_' num2str(N) '_layers.png'];
imwrite(rgb, filename);

