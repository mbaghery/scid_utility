function [dx, dy, dz] = dipole(wf, params)
%DIPOLE Calculate the expectation value of the dipole operator.
%
%   Input:
%     wf: the wave function
%     params: the parameters from the output file
%   Output:
%     [dx, dy, dz]: the dipole moment along the three cartesian axes


  electron_charge = -1;
  
  dz = 0;
  dxy = 0;

  for l = 0:params.lmax
    d3indexbase = scid.util.d3index(params, l, 0);
    
    for m = max(-l, params.mmin):min(l, params.mmax)
      
      index = d3indexbase + m;
      
      for lp = max(l-1, 0):min(l+1, params.lmax)
        % when mp = m
        mp = m;
        
        if (mp >= max(-lp, params.mmin) && mp <= min(lp, params.mmax))
          int1 = lib.Prod3Ys([l,lp,1],[-m,mp,0]);
          p_index = scid.util.d3index(params, lp, mp);

          % expectation value of r
          expval_r = sum(wf(:,2,index) .* wf(:,3,p_index) .* wf(:,1,index));

          dz = dz + (-1)^m * expval_r * int1;
        end
        
        
        % when mp = m-1
        mp = m-1;
        
        if (mp >= max(-lp, params.mmin) && mp <= min(lp, params.mmax))
          int2 = lib.Prod3Ys([l,lp,1],[-m,mp,1]);
          p_index = scid.util.d3index(params, lp, mp);

          % expectation value of r
          expval_r = sum(wf(:,2,index) .* wf(:,3,p_index) .* wf(:,1,index));

          dxy = dxy + (-1)^m * expval_r * int2;
        end
        
      end
      
    end
  end
        
  dz = electron_charge * 2 * sqrt(pi/3) * dz;
  dxy = -2 * sqrt(2*pi/3) * dxy;
  dx = electron_charge * real(dxy);
  dy = electron_charge * imag(dxy);
    
end