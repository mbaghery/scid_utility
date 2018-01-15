function [px, py, pz] = momentum(wf, params)
%MOMENTUM Calculate the current momentum.
%
%   Input:
%     wf, params
%   Output:
%     [px, py, pz]


  d3size = scid.util.d3index(params);

  Dr = lib.sptoeplitz([0;-1/2;zeros(params.nradial-2,1)], ...
                      [0,1/2 ,zeros(1,params.nradial-2)]) / params.dr;

  dwf = zeros(params.nradial,d3size);
  for i=1:d3size
    dwf(:,i) = Dr * wf(:,3,i);
  end


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
        
          int1 = lib.Prod3Ys([l,lp,1],[-m,mp,0]);
          int2 = lib.Prod3Ys([l,lp,1],[-m,mp+1,-1]);

          p_index = scid.util.d3index(params, lp, mp);

          % expectation value of pd_r
          expval_dr   = sum(wf(:,2,index) .* dwf(:,p_index));

          % expectation value of 1/r
          expval_rinv = sum(wf(:,2,index) .* wf(:,3,p_index) ./ wf(:,1,index));

          pz = pz + (-1)^m * ((expval_dr - (mp+1) * expval_rinv) * int1 ...
             - sqrt(2*(lp-mp)*(lp+mp+1)) * expval_rinv * int2);
        
        end


        % when mp = m-1
        mp = m-1;
        
        if (mp >= max(-lp, params.mmin) && mp <= min(lp, params.mmax))
          
          int3 = lib.Prod3Ys([l,lp,1],[-m,mp,1]);
          int4 = lib.Prod3Ys([l,lp,1],[-m,mp+1,0]);

          p_index = scid.util.d3index(params, lp, mp);

          % expectation value of pd_r
          expval_dr   = sum(wf(:,2,index) .* dwf(:,p_index));

          % expectation value of 1/r
          expval_rinv = sum(wf(:,2,index) .* wf(:,3,p_index) ./ wf(:,1,index));


          pxy = pxy + (-1)^m * ((-expval_dr + (mp+1) * expval_rinv) * int3 ...
              + sqrt((lp-mp)*(lp+mp+1)/2) * expval_rinv * int4);
        end

      end
    end
    
  end

  pz = -1i * 2 * sqrt(pi/3) * pz;
  pxy = -1i * 2 * sqrt(2*pi/3) * pxy;
  px = real(pxy);
  py = imag(pxy);

end
