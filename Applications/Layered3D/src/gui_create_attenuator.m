function [ attenuator ] = gui_create_attenuator( handles )

attenuator = [];

numberOfLayers = get(handles.sliderLayers, 'Value');
thickness = str2double(get(handles.editThickness, 'String'));
layerSize = [str2double(get(handles.editLayerSizeY, 'String')), str2double(get(handles.editLayerSizeX, 'String'))];
layerResolution = [str2double(get(handles.editLayerResY, 'String')), str2double(get(handles.editLayerResX, 'String'))];
channels = 3;

if get(handles.checkboxGrayscale, 'Value')
    channels = 1;
end

if isnan(thickness) || thickness <= 0
    gui_warning(handles.textOptimizationInfo, 'Attenuator thickness must be a positive number');
    return;
end

if any(isnan(layerSize)) || any(layerSize <= 0)
    gui_warning(handles.textOptimizationInfo, 'Layer size must be a positive number');
    return;
end

if any(isnan(layerResolution)) || any(layerResolution <= 0) || any(rem(layerResolution, 1) ~= 0)
    gui_warning(handles.textOptimizationInfo, 'Layer resolution must be a positive integer');
    return;
end

attenuator = Attenuator(numberOfLayers, layerResolution, layerSize, thickness, channels);

end

