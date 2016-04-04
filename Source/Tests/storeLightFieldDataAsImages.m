function storeLightFieldDataAsImages(lightFieldData, folder)

    filenumber = 1;
    for y = 1 : size(lightFieldData, 1)
        for x = 1 : size(lightFieldData, 2)
            imwrite(squeeze(lightFieldData(y, x, :, :, :)), [folder sprintf('%04d', filenumber) '.png']);
            filenumber = filenumber + 1;
        end
    end

end
