function f = compose(f, op, varargin)
%COMPOSE   Compose command for SPHEREFUN objects.
%   F = COMPOSE(F, OP)  returns the SPHEREFUN that approximates OP(F).
% 
%   F = COMPOSE(F, OP, G)  returns the SPHEREFUN that approximates OP(F).
%
%   F = COMPOSE(F, G) with a SPHEREFUN G with one column returns a SPHEREFUN
%   that approximates G(F).  If G has 3 columns, the result is a SPHEREFUNV.
%
%   This command is a wrapper for the SPHEREFUN constructor.

% Copyright 2016 by The University of Oxford and The Chebfun Developers.
% See http://www.chebfun.org/ for Chebfun information.


if ( isempty(op) )
    return
elseif ( isempty(f) )
    f = op;
    
elseif ( isa(op, 'chebfun') )
    % Composition OP(f) of SPHEREFUN object f and CHEBFUN OP
    
    if ( length(op.domain) > 2 )
        % If OP has several pices, OP(SPHEREFUN) might be inaccurate.
        warning('CHEBFUN:SPHEREFUN:compose:pieces', ...
            ['The composition of a CHEBFUN with several pieces and a SPHEREFUN\n', ...
            'might be inaccurate.']);
    end
    
    % Check that image(f) is contained in domain(OP).
    vals = minandmax2est(f);    % Estimate of image(f).
    if ( ~isSubset(vals, op.domain) )
        error('CHEBFUN:SPHEREFUN:COMPOSE:DomainMismatch', ...
            'OP(F) is not defined, since image(F) is not contained in domain(OP).')
    end
    
    nColumns = size(op, 2);
    if ( nColumns == 1 )
        % Call constructor:
        f = spherefun(@(x,y) op(feval(f, x, y)), f.domain);
        
    elseif ( nColumns == 3 )
        % Extract columns of the CHEBFUN OP:
        op1 = op(:,1);
        op2 = op(:,2);
        op3 = op(:,3);
        
        % Call constructor:
        f = spherefunv(@(x,y) op1(feval(f, x, y)), ...
            @(x,y) op2(feval(f, x, y)), @(x,y) op3(feval(f, x, y)));
        
    else
        % The CHEBFUN object OP has a wrong number of columns.
        error('CHEBFUN:SPHEREFUN:COMPOSE:Columns', ...
            'The CHEBFUN object must have 1 or 3 columns.')
        
    end
    
elseif ( nargin == 2 && nargin(op) == 1 )
    % OP has one input variable.
    
    % Call constructor: 
    f = spherefun(@(x,y) op( feval(f, x, y) ), f.domain);
    
elseif ( nargin == 3 && nargin(op) == 2 )
    % OP has two input variables. 
    
    g = varargin{1}; 
    if ( isa(g, 'double') )     % promote
        g = spherefun(@(x,y,z) g + 0*x, f.domain);
    end
    
    if ( isa(f, 'double') )     % promote
        f = spherefun(@(x,y,z) f + 0*x, g.domain); 
    end
    
    % Call constructor: 
    f = spherefun(@(x,y) op( feval(f, x, y), feval(g, x, y) ), f.domain);
    
else
    % Not sure what to do, error: 
    error('CHEBFUN:SPHEREFUN:COMPOSE:OP', 'NARGIN(OP) not correct.') 
end

end 