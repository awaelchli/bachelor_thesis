function gui_enable_all_import_controls( handles )

controls = [handles.editAngularIndToX, handles.editAngularIndStepX, handles.editAngularIndFromX, handles.editAngularIndToY, handles.editAngularIndStepY, ...
            handles.editAngularIndFromY, handles.textImportInfo, handles.editSpatialScale, handles.popupFileType, handles.editFOVX, handles.editFOVY, handles.popupDataType, ...
            handles.sliderSpatialScale, handles.btnLoad, handles.checkboxInvX, handles.checkboxInvY, handles.editAngularResX, handles.editAngularResY, handles.btnBrowse, ...
            handles.editPath, handles.popupProjectionType];
        
set(controls, 'Enable', 'on');

end

