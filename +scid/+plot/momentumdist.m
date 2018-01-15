function momentumdist(wf_k_truncated, params)
%MOMENTUMDIST Plot the momentum distribution from three different angles.
%
%   Input:
%     wf_k_truncated: the continuum part of the wave function in the
%     momentum representation
%     params: the parameters extracted from the output file.


  kx = linspace(-2,2,100);
  dk = kx(2) - kx(1);
  
  [KX, KY, KZ] = meshgrid(kx, kx, kx);
  
  K = sqrt(KX.^2 + KY.^2 + KZ.^2);
  THETA = acos(KZ ./ K);
  PHI = atan2(KY, KX);
  
  
  psi_r = zeros(size(K));
  psi_l = psi_r;

  for l = 0:params.lmax
    
    index3dbase = scid.util.d3index(params, l, 0);
    
    for m = max(-l, params.mmin):min(l, params.mmax)
      index3d = index3dbase + m;
      
      y_lm = lib.sphericalY(l, m, THETA, PHI);
      
      psi_r = psi_r + y_lm ...
        .* interp1(real(wf_k_truncated(:,1,index3d)), wf_k_truncated(:,3,index3d), K, 'spline');
      psi_l = psi_l + conj(y_lm) ...
        .* interp1(real(wf_k_truncated(:,1,index3d)), wf_k_truncated(:,2,index3d), K, 'spline');
      
    end
    
    disp(num2str(l));
    
  end
  
  psi_r = psi_r ./ K / sqrt(wf_k_truncated(2,1,1)-wf_k_truncated(1,1,1));
  psi_l = psi_l ./ K / sqrt(wf_k_truncated(2,1,1)-wf_k_truncated(1,1,1));
  
  psi_sqrd = real(psi_l .* psi_r);
  


  n = 30; % number of steps for the contour plot
    
    
  subplot(2,2,1);
  [~,p1] = contourf(squeeze(KX(1,:,:)), squeeze(KZ(1,:,:)), ...
    squeeze(sum(psi_sqrd,1)) * dk, n);
  p1.EdgeColor = 'none';
  colorbar;

  axis square
  xlabel('x');
  ylabel('z');


  subplot(2,2,2);
  [~,p2] = contourf(squeeze(KY(:,1,:)), squeeze(KZ(:,1,:)), ...
    squeeze(sum(psi_sqrd,2)) * dk, n);
  p2.EdgeColor = 'none';
  colorbar;

  axis square
  xlabel('y');
  ylabel('z');


  subplot(2,2,3);
  [~,p3] = contourf(squeeze(KX(:,:,1)), squeeze(KY(:,:,1)), ...
    squeeze(sum(psi_sqrd,3)) * dk, n);
  p3.EdgeColor = 'none';
  colorbar;

  axis square
  xlabel('x');
  ylabel('y');


  colormap(flipud(gray));
  
end
