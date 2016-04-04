function gui_display_image( axesHandle )

    handles = guidata(axesHandle);
    
%     center = ceil(handles.data.lightfield.angularResolution / 2);

    axes(axesHandle);
    imshow(squeeze(handles.data.lightfield.lightFieldData(1, 1, :, :, :)));
    axis equal image;
    
end

