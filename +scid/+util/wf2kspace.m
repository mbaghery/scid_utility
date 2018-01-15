function wavefunction_kspace = wf2kspace(wavefunction, params)
%WF2KSPACE Convert the wave function from the position representation to the
%momentum representation.
%   The momentum representation is calculated by projecting the wave function
%   onto spherical Bessel functions.

  
  r = wavefunction(:,1,1);
  dr = params.dr;
  dk = 2*pi / r(end);
  M = length(r);
  k = dk * (1:M/2-1);
  
  s = size(wavefunction);
  s(1) = s(1)/2 - 1; % '-1' is because spherical bessel j diverges for k=0, therefore, we won't include it  
  wavefunction_kspace = complex(zeros(s));
  
  for l = 0:params.lmax
    sphbessj = lib.sphbesselj(l, r .* k);
    
    for m = max(-l, params.mmin):min(l, params.mmax)
      index3d = scid.util.d3index(params, l, m);
      
      F = sum(sphbessj .* r .* wavefunction(:,2,index3d) * sqrt(dr), 1);
      wavefunction_kspace(:,1,index3d) = k;
      wavefunction_kspace(:,2,index3d) = sqrt(2/pi) * (1i)^l * sqrt(dk) * k .* F;
      
      F = sum(sphbessj .* r .* wavefunction(:,3,index3d) * sqrt(dr), 1);
      wavefunction_kspace(:,3,index3d) = sqrt(2/pi) * (-1i)^l * sqrt(dk) * k .* F;
      
    end
    
  end
  
end
