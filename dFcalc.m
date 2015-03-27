function dF = dFcalc(subTrace,rawTrace,mode)

if ~exist('mode','var') || isempty(mode)
    mode = 'exp_linear';
end

nSigs = size(subTrace,1);
dF = subTrace;
parfor nSig = 1:nSigs
    dF(nSig,:) = (subTrace(nSig,:) - getF_(subTrace(nSig,:)))...
        ./getF_(rawTrace(nSig,:),mode);
end