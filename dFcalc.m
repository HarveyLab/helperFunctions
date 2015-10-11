function dF = dFcalc(subTrace,rawTrace,mode)

if ~exist('mode','var') || isempty(mode)
    mode = 'exp_linear';
end

nSigs = size(subTrace,1);
dF = subTrace;
parfor nSig = 1:nSigs
    
    if all(isnan(subTrace(nSig,:))) || all(isnan(rawTrace(nSig,:)))
        dF(nSig,:) = nan;
        continue
    end
    disp(nSig)
    dF(nSig,:) = (subTrace(nSig,:) - getF_(subTrace(nSig,:), mode))...
        ./getF_(rawTrace(nSig,:), mode);
end