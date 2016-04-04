function gui_update_layerNumbers_for_print( handles )

n = handles.data.attenuator.numberOfLayers;
set(handles.editPrintFrom, 'String', 1);
set(handles.editPrintTo, 'String', n);
set(handles.editMatrixSizeY, 'String', n); 
set(handles.editMatrixSizeX, 'String', 1);

end

