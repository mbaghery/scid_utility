function d3index = d3index(params, l, m)
%D3INDEX Return the index of the third dimension.
%This function is only used internally.


  if (nargin < 2)
    l = params.lmax;
  end
    
  if (nargin < 3)
    m = min(l, params.mmax);
  end

  base = 0;
  for ll = 0:l-1
    base = base + min(ll, params.mmax) - max(-ll, params.mmin) + 1;
  end

  d3index = base + m - max(-l, params.mmin) + 1;
  
end