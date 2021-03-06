function [h,g,a] = wfilt_dtree(N)
%WFILT_DTREE  Dual-TREE complex wavelet transform filters
%   Usage: [h,g,a] = wfilt_dtree(N);
%
%   `[h,g,a]=wfilt_dtree(N)` computes filters used in the dual-tree complex wavelet transform. 
%
%   References: selesnick2005dtree
%


switch(N)
case 1
harr = [
                  0                  0
  -0.08838834764832  -0.01122679215254
   0.08838834764832   0.01122679215254
   0.69587998903400   0.08838834764832
   0.69587998903400   0.08838834764832
   0.08838834764832  -0.69587998903400
  -0.08838834764832   0.69587998903400
   0.01122679215254  -0.08838834764832
   0.01122679215254  -0.08838834764832
                  0                  0
];
case 2
harr = [
  0.01122679215254                   0
   0.01122679215254                  0
  -0.08838834764832  -0.08838834764832
   0.08838834764832  -0.08838834764832
   0.69587998903400   0.69587998903400
   0.69587998903400  -0.69587998903400
   0.08838834764832   0.08838834764832
  -0.08838834764832   0.08838834764832
                  0   0.01122679215254
                  0  -0.01122679215254
];

case 3
harr = [
   0.03516384000000                  0
                  0                  0
  -0.08832942000000  -0.11430184000000
   0.23389032000000                  0
   0.76027237000000   0.58751830000000
   0.58751830000000  -0.76027237000000
                  0   0.23389032000000
  -0.11430184000000   0.08832942000000
                  0                  0
                  0  -0.03516384000000
];

case 4
harr = [
                  0  -0.03516384000000
                  0                  0
  -0.11430184000000   0.08832942000000
                  0   0.23389032000000
   0.58751830000000  -0.76027237000000
   0.76027237000000   0.58751830000000
   0.23389032000000                  0
  -0.08832942000000  -0.11430184000000
                  0                  0
   0.03516384000000                  0
];

 otherwise
        error('%s: No such Dual-Tree Complex Wavelet Transform Filters..',upper(mfilename));
end
a= [2;2];

h=mat2cell(harr.',[1,1],length(harr));

if(nargout>1)
    garr = harr(end:-1:1, :);
    g=mat2cell(garr.',[1,1],length(garr));
end