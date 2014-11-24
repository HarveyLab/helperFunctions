function f = deBleach(f, mode)
% f = deBleach(f, mode) removes bleaching 

switch mode
    case 'exponential'
        % Robustly fit a straight line to log(fluorescence) and then
        % subtract exp(straightLine).
        f(f<0.1) = 0.1; % So that log() works without imaginary issues.
        fl = log(f);
        x = 1:numel(f);
        b = robustfit(x, fl);
        f_ = exp(b(1)+b(2)*x);
        f = f-f_+mean(f_);
        
    case 'linear'
%         f = detrend(f);
        % Detrend is not robust to outliers, so we use robustfit instead:
        x = 1:numel(f);
        b = robustfit(x, f);
        f_ = b(1)+b(2)*x;
        f = f-f_+mean(f_);

end