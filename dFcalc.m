function dF = dFcalc(subTrace,rawTrace,mode)

if ~exist('mode','var') || isempty(mode)
    mode = 'linear';
end

nSigs = size(subTrace,1);
dF = subTrace;
parfor nSig = 1:nSigs
    dF(nSig,:) = subTrace(nSig,:)./getF_(rawTrace(nSig,:),mode);
    dF(nSig,:) = dF(nSig,:) - getF_(dF(nSig,:),mode);
end