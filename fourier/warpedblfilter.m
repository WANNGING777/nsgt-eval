function gout=warpedblfilter(winname,fsupp,fc,fs,freqtoscale,varargin)
%WARPEDBLFILTER  Construct a warped band-limited filter
%   Usage:  g=warpedblfilter(winname,fsupp,fc,fs,freqtoscale);
%           g=warpedblfilter(winname,fsupp,fc,...);
%
%   Input parameters:
%      winname     : Name of prototype.
%      fsupp       : Support length of the prototype (in scale units).
%      fc          : Centre frequency (in Hz).
%      fs          : Sampling rate
%      freqtoscale : Function handle to convert Hz to scale units
%
%   Output parameters:
%      g           : Filter definition, see |blfilter|.
%
%   `warpedblfilter(winname,fsupp)` constructs a band-limited filter that is
%   warped on a given frequency scale. The parameter *winname* specifies the basic
%   shape of the frequency response. The name must be one of the shapes
%   accepted by |firwin|. The support of the frequency response measured on
%   the selected frequency scale is specified by *fsupp*, the centre
%   frequency by *fc* and the scale by the function handle *freqtoscale*
%   of a function that converts Hz into the choosen scale.
%
%   If one of the inputs is a vector, the output will be a cell array
%   with one entry in the cell array for each element in the vector. If
%   more input are vectors, they must have the same size and shape and the
%   the filters will be generated by stepping through the vectors. This
%   is a quick way to create filters for |filterbank| and |ufilterbank|.
%
%   `warpedblfilter` accepts the following optional parameters:
%
%     'complex'   Make the filter complex valued if the centre frequency
%                 is non-zero.necessary. This is the default.
%
%     'real'      Make the filter real-valued if the centre frequency
%                 is non-zero.
%
%     'delay',d   Set the delay of the filter. Default value is zero.
%
%     'scal',s    Scale the filter by the constant *s*. This can be
%                 useful to equalize channels in a filterbank.
%
%   It is possible to normalize the transfer function of the filter by
%   passing any of the flags from the |normalize| function. The default
%   normalization is `'energy'`.
%
%   The filter can be used in the |pfilt| routine to filter a signal, or
%   in can be placed in a cell-array for use with |filterbank| or
%   |ufilterbank|.
%
%   The output format is the same as that of |blfilter|. 
%
%   See also: blfilter, firwin, pfilt, filterbank

% Define initial value for flags and key/value pairs.
definput.import={'normalize'};
definput.importdefaults={'energy'};
definput.keyvals.delay=0;
definput.keyvals.scal=1;
definput.flags.real={'complex','real'};

[flags,kv]=ltfatarghelper({},definput,varargin);

[fsupp,fc,kv.delay,kv.scal]=scalardistribute(fsupp,fc,kv.delay,kv.scal);

Nfilt=numel(fsupp);
gout=cell(1,Nfilt);

for ii=1:Nfilt
    g=struct();
    
    
    if flags.do_1 || flags.do_area 
        g.H=@(L)    comp_warpedfreqresponse(winname,freqtoscale(fc(ii)), ...
                                            fsupp(ii),fs,L,freqtoscale, ...
                                            flags.norm)*kv.scal(ii)*L;
    end;
    
    if  flags.do_2 || flags.do_energy
        g.H=@(L)    comp_warpedfreqresponse(winname,freqtoscale(fc(ii)), ...
                                            fsupp(ii),fs,L,freqtoscale, ...
                                            flags.norm)*kv.scal(ii)*sqrt(L);
    end;
        
    if flags.do_inf || flags.do_peak
        g.H=@(L)    comp_warpedfreqresponse(winname,freqtoscale(fc(ii)), ...
                                            fsupp(ii),fs,L,freqtoscale, ...
                                            flags.norm)*kv.scal(ii);
    end;
        
    g.foff=@(L) 0;
    g.realonly=flags.do_real;
    g.delay=kv.delay(ii);
    g.fs=fs;
    gout{ii}=g;
end;

if Nfilt==1
    gout=g;
end;
