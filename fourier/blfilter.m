function gout=blfilter(winname,fsupp,varargin)
%BLFILTER  Construct a band-limited filter
%   Usage:  g=blfilter(winname,fsupp,centre);
%           g=blfilter(winname,fsupp,centre,...);
%
%   Input parameters:
%      winname  : Name of prototype
%      fsupp    : Support length of the prototype
%
%   `blfilter(winname,fsupp)` constructs a band-limited filter. The parameter
%   *winname* specifies the shape of the frequency response. The name must be
%   one of the shapes accepted by |firwin|. The support of the frequency
%   response measured in normalized frequencies is specified by *fsupp*.
%
%   `blfilter(winname,fsupp,centre)` constructs a filter with a centre
%   frequency of *centre* measured in normalized frequencies.
%
%   If one of the inputs is a vector, the output will be a cell array
%   with one entry in the cell array for each element in the vector. If
%   more input are vectors, they must have the same size and shape and the
%   the filters will be generated by stepping through the vectors. This
%   is a quick way to create filters for |filterbank| and |ufilterbank|.
%
%   `blfilter` accepts the following optional parameters:
%
%     'fs',fs     If the sampling frequency *fs* is specified then the support
%                 *fsupp* and the centre frequency *centre* is specified in Hz.
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
%   Output format:
%   --------------
%
%   The output from `blfilter` is a structure. This type of structure can
%   be used to describe any bandlimited filter defined in terms of its
%   transfer function. The structure contains the following fields:
%
%     `H`
%        This is an anonymous function taking the transform length *L* as
%        input and producing the bandlimited transfer function in the form of a
%        vector.
%
%     `foff`
%        This is an anonymous function taking the transform length *L* as
%        input and procing the frequency offset of *H* as an integer. The
%        offset is the value of the lowest frequency of *H* measured in
%        frequency samples. *foff* is used to position the bandlimited
%        tranfer function stored in *H* correctly when multiplying in the
%        frequency domain.
%
%     `delay`
%        This is the desired delay of the filter measured in samples.
%
%     `realonly`
%        This is an integer with value *1* if the filter defined a
%        real-valued filter. In this case, the bandlimited transfer
%        function *H* will be mirrored from the positive frequencies to
%        the negative frequencies. If the filter is a natural lowpass
%        filter correctly centered around *0*, `realonly` does not need
%        to be *1*.
%
%     `fs`
%        The intended sampling frequency. This is an optional parameter
%        that is **only** used for plotting and visualization.
%
%   See also: blfilter, firwin, pfilt, filterbank

% Define initial value for flags and key/value pairs.
definput.import={'normalize'};
definput.importdefaults={'energy'};
definput.keyvals.delay=0;
definput.keyvals.centre=0;
definput.keyvals.fs=[];
definput.keyvals.scal=1;
definput.flags.real={'complex','real'};

[flags,kv]=ltfatarghelper({'centre'},definput,varargin);

[fsupp,kv.centre,kv.delay,kv.scal]=scalardistribute(fsupp,kv.centre,kv.delay,kv.scal);

if ~isempty(kv.fs)
    fsupp=fsupp/kv.fs*2;
    kv.centre=kv.centre/kv.fs*2;
end;

% Sanitize
kv.centre=modcent(kv.centre,2);

Nfilt=numel(fsupp);
gout=cell(1,Nfilt);

for ii=1:Nfilt
    g=struct();
    
    
    if flags.do_1 || flags.do_area 
        g.H=@(L)    fftshift(firwin(winname,round(L/2*fsupp(ii)), ...
                                    flags.norm))*kv.scal(ii)*L;        
    end;
    
    if  flags.do_2 || flags.do_energy
        g.H=@(L)    fftshift(firwin(winname,round(L/2*fsupp(ii)), ...
                                    flags.norm))*kv.scal(ii)*sqrt(L);                
    end;
        
    if flags.do_inf || flags.do_peak
        g.H=@(L)    fftshift(firwin(winname,round(L/2*fsupp(ii)), ...
                                    flags.norm))*kv.scal(ii);        
        
    end;
        
    g.foff=@(L) round(L/2*kv.centre(ii))-floor(round(L/2*fsupp(ii))/2);
    g.realonly=flags.do_real;
    g.delay=kv.delay(ii);
    g.fs=kv.fs;
    gout{ii}=g;
end;

if Nfilt==1
    gout=g;
end;
