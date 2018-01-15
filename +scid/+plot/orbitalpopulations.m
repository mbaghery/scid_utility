function orbitalpopulations(spectrum, params)
%ORBITALPOPULATION Plot the population of each orbital
%   spectrum is the output of extractSpec
%   spectrum is a 3D matrix, whose 3rd dimension is determined by lmax.
%   The size of the first dimension is determined by nradial.
%   The second dimension consists of:
%       E (Re,Im), Wgt (Re,Im), <I|W> (Re,Im), <W|I> (Re,Im)

xs = 0:params.lmax;
ys = zeros(size(xs));

  for l = 0:params.lmax
    indices = scid.util.d3index(params, l, max(-l, params.mmin)):scid.util.d3index(params, l, min(l, params.mmax));
    ys(l+1) = sum(sum(real(spectrum(:,2,indices)),3),1);
  end

  semilogy(xs, ys, '-', 'LineWidth', 1.5);
  
  grid on;

  title(scid.util.createtitle(params));
  xlabel('orbital angular momentum');
    
end
