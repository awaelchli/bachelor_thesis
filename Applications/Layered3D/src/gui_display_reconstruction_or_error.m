function gui_display_reconstruction_or_error( handles )
%GUI_DISPLAY_RECONSTRUCTION Summary of this function goes here
%   Detailed explanation goes here

angularRes = handles.data.evaluation.lightField.angularResolution;

indexY = str2double(get(handles.editRecIndexY, 'String'));
indexX = str2double(get(handles.editRecIndexX, 'String'));
indices = [indexY, indexX];

if isnan(indexY) || indexY > angularRes(1) || indexY < 1 || rem(indexY, 1) ~= 0
    set(handles.editRecIndexY, 'ForegroundColor', 'Red');
    drawnow;
    return;
end
if isnan(indexX) || indexX > angularRes(2) || indexX < 1 || rem(indexX, 1) ~= 0
    set(handles.editRecIndexX, 'ForegroundColor', 'Red');
    drawnow;
    return;
end

handles.data.evaluation.evaluateViews(indices);

switch get(handles.popupReconstructionPreview, 'Value')
    case 1 % Display reconstructed view
        handles.data.evaluation.displaySingleReconstructedView(indices, handles.axesReconstruction);
        colorbar('off');
        axis equal image;
        if handles.data.attenuator.channels == 1
            colormap(handles.axesReconstruction, gray);
        end
    case 2 % Display error view
        handles.data.evaluation.displaySingleErrorImage(indices, handles.axesReconstruction);
        axes(handles.axesReconstruction);
        colormap(handles.axesReconstruction, 'jet');
        colorbar('eastoutside');
        axis equal image;
end



