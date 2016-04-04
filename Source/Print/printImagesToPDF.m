function printImagesToPDF( outputFolder, filename, images, printSize, arrangementMatrix )
% Prints all images from the input on one A4 paper and stores the result in a PDF file.
    
    gridSizeY = size(arrangementMatrix, 1);
    gridSizeX = size(arrangementMatrix, 2);
    relSizeY = 1 / gridSizeY;
    relSizeX = 1 / gridSizeX;
    
    fig = figure('Menubar', 'none', 'Visible', 'on');
    
    for iy = 1 : gridSizeY
        for ix = 1 : gridSizeX
            
            imageNumber = arrangementMatrix(iy, ix);
            if (imageNumber == 0)
                continue;
            end
            
            img = squeeze(images(imageNumber, :, :, :));
            relPosY = 1 - iy * relSizeY;
            relPosX = (ix - 1) * relSizeX;
            
            subplot('Position', [relPosX, relPosY, relSizeX, relSizeY]), image(im2uint8(img));
            set(gca, 'XTickLabel', [], 'YTickLabel', []);
            set(gca, 'XTick', [], 'YTick', []);
            
        end
    end

    set(fig, 'PaperPositionMode', 'manual')
    set(fig, 'PaperUnits', 'centimeters')
    set(fig, 'PaperPosition', [0.2, 0.2, printSize(2) * gridSizeX / 10, printSize(1) * gridSizeY / 10])
    set(fig, 'PaperType', 'A4')
    set(fig, 'PaperOrientation', 'portrait')
    
    print(fig, '-dpdf', '-r0', [outputFolder, filename, '.pdf']);
    
    close(fig);
    
end

