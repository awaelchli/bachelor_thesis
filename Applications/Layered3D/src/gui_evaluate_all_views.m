function gui_evaluate_all_views( handles )

    indY = 1 : handles.data.evaluation.lightField.angularResolution(1);
    indX = 1 : handles.data.evaluation.lightField.angularResolution(2);
    indY = repmat(indY, numel(indX), 1);
    indX = repmat(indX, 1, size(indY, 2));
    indices = [indY(:), indX(:)];

    handles.data.evaluation.evaluateViews(indices);

end

