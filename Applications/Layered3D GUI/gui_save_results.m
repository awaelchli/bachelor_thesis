function gui_save_results( handles )

gui_evaluate_all_views(handles);

outputFolder = get(handles.editOutputFolder, 'String');
saveCount = 0;

set(handles.textSaveInfo, 'String', 'Saving data ...');
drawnow;

if get(handles.checkboxSaveLayers, 'Value') && ~isempty(handles.data.evaluation)
    handles.data.evaluation.outputFolder = outputFolder;
    handles.data.evaluation.storeLayers(1 : handles.data.attenuator.numberOfLayers);
    saveCount = saveCount + 1;
end
if get(handles.checkboxReconstructedViews, 'Value') && ~isempty(handles.data.evaluation)
    handles.data.evaluation.outputFolder = outputFolder;
    handles.data.evaluation.storeReconstructedViews();
    saveCount = saveCount + 1;
end
if get(handles.checkboxErrorImages, 'Value') && ~isempty(handles.data.evaluation)
    handles.data.evaluation.outputFolder = outputFolder;
    handles.data.evaluation.storeErrorImages();
    saveCount = saveCount + 1;
end
if get(handles.checkboxBackProjection, 'Value') && ~isempty(handles.data.backprojection)
    for i = 1 : handles.data.attenuator.numberOfLayers
        imwrite(squeeze(handles.data.backprojection(i, :, :, :)), sprintf('%sBack_Projection_Layer_%i.png', outputFolder, i));
    end
    saveCount = saveCount + 1;
end
if get(handles.checkboxSaveMATFiles, 'Value') && ~isempty(handles.data.evaluation)
    % Save relevant data to MATLAB files
    handles.data.evaluation.outputFolder = outputFolder;
    attenuator = handles.data.attenuator;
    evaluation = handles.data.evaluation;
    save(fullfile(outputFolder, 'attenuator.mat'), 'attenuator', '-v7.3');
    save(fullfile(outputFolder, 'evaluation.mat'), 'evaluation', '-v7.3');
    saveCount = saveCount + 1;
end

set(handles.textSaveInfo, 'String', 'Saving data ... Done.');
drawnow;

if saveCount == 0
    set(handles.textSaveInfo, 'String', 'Nothing to save');
end

end