function g = besselk(nu, f, scale, pref)
%BESSELK   Modified Bessel function of second kind of a CHEBFUN.
%   K = BESSELK(NU, F) computes the modified Bessel function of second kind
%   K_NU(F) of the nonzero CHEBFUN F. If F passes through the origin in its
%   domain, then an error is returned. The order NU need not be an integer but
%   must be real. The argument F can be complex.
%
%   K = BESSELK(NU, F, SCALE) returns a scaled K_NU(F) specified by SCALE:
%         0 - (default) is the same as BESSELK(NU, F),
%         1 - scales K_NU(F) by exp(F)).
%
%   K = BESSELK(NU, F, SCALE, PREF) uses the preference structure PREF when
%   building the CHEBFUN K.
%
% See also AIRY, BESSELH, BESSELI, BESSELJ, BESSELY.
%
% Copyright 2013 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org for Chebfun information.

if ( nargin < 4 )
    pref = chebfun.pref();
end

% Check for roots:
r = roots(f, 'nojump', 'nozerofun');
if ( numel(r) > 0 )
    error('CHEBFUN:besselk:zero', 'F has roots in its domain.');
end

% Compose:
g = compose(f, @(x) besselk(nu, x), pref);

% Scale (as described in help documentation):
if ( (nargin >= 3) && (scale == 1) )
    scl = exp(f);
    g = scl.*g;
end

end