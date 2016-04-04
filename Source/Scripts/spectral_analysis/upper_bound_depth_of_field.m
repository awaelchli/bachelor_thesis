%% Approximate upper bound on depth of field for multi-layer 3D displays

h = 1;
N = [2, 3, 4, 5, 6];
f_0 = 34;
z = linspace(-12, 12, 500);

data = cell(2, numel(N));
legend_txt = cell(1, numel(N));

for i = 1 : numel(N)
    
    n = N(i);
    
    bound = n * f_0 * sqrt( (n + 1) .* h^2 ./ ( (n + 1) .* h^2 + 12 .* (n - 1) .* (z .^2) ) );
    data{1, n} = z;
    data{2, n} = bound;
    
    legend_txt{i} = [num2str(n) ' layers'];
end


figure; plot(data{:});
xlim([-4, 12]);
ylim([0, 40]);
legend(legend_txt{:});
title('Upper Bound on Depth of Field for Multi-layer Displays');
xlabel('distance of virtual plane from center');
ylabel('spatial cut-off frequency');