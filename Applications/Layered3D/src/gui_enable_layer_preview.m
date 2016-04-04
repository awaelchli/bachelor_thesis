function gui_enable_layer_preview( handles, onOff )

set(handles.btnNextLayer, 'Enable', onOff);
set(handles.btnPrevLayer, 'Enable', onOff);
set(handles.textLayerPageNumber, 'Enable', onOff, 'String', '1');
drawnow;

end

