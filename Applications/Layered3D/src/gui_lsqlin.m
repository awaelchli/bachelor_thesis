function [x, resnorm] = gui_lsqlin( P, l, x0, lb, ub, iterations )
	
    x = x0;

    for c = 1 : size(l, 2)
        
        Jinfo = speye(size(P));
        jmfun = @(Jinfo, Y, flag) projection(P, Y, flag);
        options = optimset('Display', 'off', 'MaxIter', iterations, 'JacobMult', jmfun);
        [x(:, c), resnorm, ~, ~, ~, ~] = lsqlin(Jinfo, l(:, c), [], [], [], [], lb(:, c), ub(:, c), x0(:, c), options);

%         fprintf('Residual Norm: %i\n', resnorm);
    end

end

function W = projection(P, Y, flag ) 

    % Forward projection
    if flag > 0
        W = P * Y;                                       
    % Back-projection
    elseif flag < 0 
        W = P' * Y;                                                                                                         
    % Forward and then back-projection
    else
        W = P' * (P * Y);        
    end    
end

