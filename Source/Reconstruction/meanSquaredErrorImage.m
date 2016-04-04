function [ errorImage, rmse, psnr ] = meanSquaredErrorImage( image1, image2 )

channels = size(image1, 3);

errorImage = (255 * (image1 - image2)) .^ 2;
errorImage = sum(errorImage, 3);

mse = mean(errorImage(:)) / channels;
rmse = sqrt(mse);
psnr = 10 * log10((255^2) / mse);

errorImage = errorImage / (255^2);

end