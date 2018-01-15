function [px, py, pz] = momentum_kspace(wfk, params)
%MOMENTUM_KSPACE Calculate the momentum given the wave function in the momentum
%representation.
%
%   Input:
%      wfk: wave function in the momentum representation
%      params: the parameters from the output file


  pz = 0;
  pxy = 0;
  
  for l = 0:params.lmax
    
    d3indexbase = scid.util.d3index(params, l, 0);
    
    for m = max(-l, params.mmin):min(l, params.mmax)
      for lp = max(l-1, 0):min(l+1, params.lmax)

        index = d3indexbase + m;
        
        % when mp = m
        mp = m;
        
        if (mp >= max(-lp, params.mmin) && mp <= min(lp, params.mmax))
        
          int1 = lib.Prod3Ys([lp,l,1],[-mp,m,0]);

          p_index = scid.util.d3index(params, lp, mp);

          % expectation value of k
          expval_k   = sum(wfk(:,2,p_index) .* wfk(:,3,index) .* wfk(:,1,index));

          pz = pz + (-1)^mp * expval_k * int1;
          
        end


        % when mp = m+1
        mp = m+1;
        
        if (mp >= max(-lp, params.mmin) && mp <= min(lp, params.mmax))
          
          int3 = lib.Prod3Ys([lp,l,1],[-mp,m,1]);

          p_index = scid.util.d3index(params, lp, mp);

          % expectation value of k
          expval_k   = sum(wfk(:,2,p_index) .* wfk(:,3,index) .* wfk(:,1,index));

          pxy = pxy + (-1)^mp * expval_k * int3;
          
        end

      end
    end
    
  end

  pz = 2 * sqrt(pi/3) * pz;
  pxy = -2 * sqrt(2*pi/3) * pxy;
  px = real(pxy);
  py = imag(pxy);

end
