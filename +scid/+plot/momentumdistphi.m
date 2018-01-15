function momentumdistphi(wf_k_truncated, params)
%MOMENTUMDISTPHI Plot the momentum distribution as a function of phi
%
%   Input:
%     wf_k_truncated: the continuum part of the wave function
%     params: the parameters extracted from the output file.


  k = wf_k_truncated(:,1,1);
  
  % to increase perfomance, I am filtering out 9 out of every 10 radial points.
  % Therefore, I'll have to multiply the final result by 10 to compensate for
  % the filtering. Furthermore, energies beyond k=2 are rejected.
  filter = false(size(k));
  filter(1:10:end) = true;
  filter(k>2) = false;
  
  theta = linspace(0, pi, 50);
  phi = linspace(0, 2*pi, 100);
  
  dtheta = theta(2) - theta(1);
  
  [Phi, Theta] = meshgrid(phi, theta);
  
  psi_r = zeros(length(theta), length(phi), sum(filter));
  psi_l = psi_r;
  

  for l = 0:params.lmax
    
    index3dbase = scid.util.d3index(params, l, 0);
    
    for m = max(-l, params.mmin):min(l, params.mmax)
      index3d = index3dbase + m;
      
      y_lm = lib.sphericalY(l, m, Theta, Phi);

      psi_r = psi_r + y_lm ...
        .* reshape(wf_k_truncated(filter,3,index3d), 1, 1, sum(filter));
      psi_l = psi_l + conj(y_lm) ...
        .* reshape(wf_k_truncated(filter,2,index3d), 1, 1, sum(filter));
      
    end
    
    disp(num2str(l));
    
  end
  
  psi_sqrd = abs(psi_l .* psi_r);
  
  
  % to see why there's a 10 below, read the comment above.
  spectrum = sum(sum(psi_sqrd .* sin(Theta), 1), 3) * dtheta * 10;
  
  
  
  p1 = plot(phi, spectrum./max(spectrum));
  p1.LineWidth = 2;
  
  ax = gca;
  ax.XGrid = 'on';
  ax.YGrid = 'on';
  ax.XTick = [0, pi/2, pi, 3*pi/2, 2*pi];
  ax.XTickLabel = {'0', '\pi/2', '\pi', '3\pi/2', '2\pi'};
  ax.LineWidth = 2;
  ax.Color = [1, 1, 1] * 0.9;
  ax.FontSize = 12;
  
  xlim([0, 2] * pi);
  
end
