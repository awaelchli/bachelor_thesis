function gui_display_layers( handles )

switch handles.data.axesLayersDisplayMode
    case handles.constants.displayMode.layers % display attenuation layers
        axes(handles.axesLayersPreview);
        imshow(squeeze(handles.data.attenuator.attenuationValues(handles.data.axesLayersPage, :, :, :)));
        axis equal image;
    case handles.constants.displayMode.backprojection % display back projection
        axes(handles.axesLayersPreview);
        imshow(squeeze(handles.data.backprojection(handles.data.axesLayersPage, :, :, :)));
        axis equal image;
end

end

