function gui_enable_reconstruction_preview( handles, onOff )

set(handles.btnShowReconstruction, 'Enable', onOff);

if ~strcmp('', get(handles.editRecIndexY, 'String')) || ~strcmp('', get(handles.editRecIndexX, 'String'))
    % Keep the numbers the user entered
    return;
end

set(handles.editRecIndexY, 'String', ceil(handles.data.evaluation.lightField.angularResolution(1) / 2));
set(handles.editRecIndexX, 'String', ceil(handles.data.evaluation.lightField.angularResolution(2) / 2));

end

