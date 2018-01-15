function pad(wf, params)
%PAD Plot the photoelectron angular distribution
%
%   Input:
%     wf is the wave function (the output of extract.wf)
%       1st dimension: r
%       2nd dimension: R, left wfn (Re, Im), right wfn (Re, Im)
%       3rd dimension: l
%     params: parameters from the output file.



  lmax = params.lmax;
  
  dtheta = 0.01;
  theta = (0:dtheta:pi)';
  
  
  PAD = zeros(size(theta));
  for l1 = 0:lmax
    for l2 = 0:lmax
      PAD = PAD + 2 * pi * dtheta * ...
        lib.sphericalY(l1,0,theta,0) .* lib.sphericalY(l2,0,theta,0) * ...
        sum(wf(:,2,l1+1) .* wf(:,3,l2+1));
    end
  end
  
  
  
  plot(theta, real(PAD));
  
  xlabel('\theta');
  
  ax = gca;
  ax.XGrid = 'on';
  ax.YGrid = 'on';
  ax.XTick = [0 pi/4 pi/2 3*pi/4 pi];
  ax.XTickLabel = {'0','\pi/4','\pi/2','3\pi/4','\pi'};
  
  xlim([0, pi]);
  
end

