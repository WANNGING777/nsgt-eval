function f = comp_iufwt(c,g,J,a)
%COMP_IUFWT Compute Inverse Undecimated DWT
%   Usage:  f = comp_iufwt(c,g,J,a);
%
%   Input parameters:
%         c     : L*M*W array of coefficients, M=J*(filtNo-1)+1.
%         g     : Synthesis wavelet filters-Cell-array of length *filtNo*.
%         J     : Number of filterbank iterations.
%         a     : Upsampling factors - array of length *filtNo*.
%
%   Output parameters:
%         f     : Reconstructed data - L*W array.
%
% 

% see comp_fwt for explanantion
assert(a(1)==a(2),'First two elements of a are not equal. Such wavelet filterbank is not suported.');

% For holding the impulse responses.
filtNo = length(g);
gOffset = cellfun(@(gEl) gEl.offset,g(:));
%Change format to a matrix
gMat = cell2mat(cellfun(@(gEl) gEl.h(:),g(:)','UniformOutput',0));
%Scale all filters
%gMat = bsxfun(@times,gMat,sqrt(1/(J+1)));
gMat = bsxfun(@times,gMat,sqrt(1./(a(:)')));

% Read top-level appr. coefficients.
ca = squeeze(c(:,1,:));
cRunPtr = 2;
for jj=1:J
   % Current iteration filter upsampling factor.
   filtUps = a(1)^(J-jj); 
   % Zero index position of the upsampled filetrs.
   offset = filtUps.*gOffset ;%+ filtUps; 
   % Run the filterbank
   ca=comp_iatrousfilterbank_td([reshape(ca,size(ca,1),1,size(ca,2)),...
                 c(:,cRunPtr:cRunPtr+filtNo-2,:)],gMat,filtUps,offset); 
   % Bookkeeping
   cRunPtr = cRunPtr + filtNo -1;
end
% Copy to the output.
f = ca;
    