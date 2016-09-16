function [uSol, NuSol] = startMultistep(K, dt, L, Nc, Nv, pref, S, uInit, NuInit)
%STARTMULTISTEP  Get enough initial data when using a multistep scheme.
%    [USOL, NUSOL] = STARTMULTISTEP(K, dt, L, NC, NV, pref, S, uInit, NuInit)
%    uses a one-step algorithm with time-step DT, combined with a fixed point
%    algorithm, to get enough initial data to start the multistep SPINSCHEME K
%    using the linear part L, the nonlinear parts in coeff and value space NC
%    and NV, the SPINPREFERENCE object PREF, and the SPINOPERATOR S.

% Copyright 2016 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.

% Note for developers. The algorithm is in two parts:
% 1. Get an approximation of the data with ETDRK2.
% 2. Use a fixed point algorithm to refine this approximation.

%% Part 1: ETDRK2.

% Set-up:
M = pref.M;                 % points for the contour integral
q = K.steps;                % number of steps 
errTol = max(1e-10, dt^q);  % error tolerance 
nVars = S.numVars;          % number of unknown functions
N = size(L, 1)/nVars;       % grid points
dim = getDimension(S);      % spatial dimension (1, 2 or 3)

% Create a cell-array to store the coefficients at the Q steps:
uSol = cell(q, 1);
NuSol = cell(q, 1);

% Store the initial conidition in the last column:
uSol{q} = uInit{1};
NuSol{q} = NuInit{1};

% Set-up the scheme:
K = spinscheme('etdrk2');
schemeCoeffs = computeCoeffs(K, dt, L, M, S);

% Do (Q-1) steps:
uOld = uInit;
NuOld = NuInit;
for j = 1:(q-1)
    [uNew, NuNew] = oneStep(K, schemeCoeffs, Nc, Nv, nVars, uOld, NuOld);
    uSol{q-j} = uNew{1};
    NuSol{q-j} = NuNew{1};
    uOld = uNew;
    NuOld = NuNew;
end

%% Part 2: Fixed point algorithm.

% Create a contour around each eigenvalue of the linear part L:
LR = computeLR(S, dt, L, M);

% Get the gamma-functions:
g = cell(q-1);
g0 = cell(q-1, 1);
for j = 1:q-1
    g0{j} = spinscheme.gammaEval(0, j, LR, N, dim, nVars);
    for k = 1:q-1
        g{j, k} = spinscheme.gammaEval(j, k, LR, N, dim, nVars);
    end
end

% Take real part for diffusive problems (real eigenvalues):
if ( isreal(L) == 1 )
    g = cellfun(@(f) real(f), g, 'UniformOutput', 0);
    g0 = cellfun(@(f) real(f), g0, 'UniformOutput', 0);
end

% Fixed point iteration to achieve ERRTOL:
err = 1;
uOld = uSol;
NuOld = NuSol;
while ( err > errTol )
    err = 0;
    for j = 1:q-1
        uNew{q-j} = exp(j*dt*L).*uOld{q} + dt*g0{j}.*NuOld{q};
        for l = 1:q-1
            temp = 0;
            for i = 0:l
                temp = temp + (-1)^i*nchoosek(l, i).*NuOld{q-l+i};
            end
            uNew{q-j} = uNew{q-j} + dt*g{l,j}.*temp;
        end
        err = max(err, norm(uOld{q-j} - uNew{q-j}, inf));
        NuNew{q-j} = Nc.*fft(Nv(ifft(uNew{q-j})));
    end
    uNew{q} = uOld{q};
    NuNew{q} = NuOld{q};
    uOld = uNew;
    NuOld = NuNew;
end
uSol = uNew;
NuSol = NuNew;

end