function [ M ] = createLineMask( imsize, slope, resolution)
%CREATELINEMASK Create a binary mask for a line through the center of the image.
%   
%   Input:          imsize          Scalar, size of mask
%                   slope           Scalar, slope of the line
%                   resolution      Number of samples to use for the line in horizontal direction
%   
%   Output:         M               Binary mask of size imsize x imsize              

height = imsize;
width = imsize;
sz = [height, width];

M = zeros(sz);

x = linspace(-0.5, 0.5, resolution);
y = -slope * x;

% Shift to matrix indices
x = x + 0.5;
x = x * (width - 1) + 1;
y = y + 0.5;
y = y * (height - 1) + 1;

i1 = y < 1;
i2 = y > height;

y(i1 | i2) = [];
x(i1 | i2) = [];

ind = sub2ind(sz, round(y), round(x));
M(ind) = 1;

end

