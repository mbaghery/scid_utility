function pes(spectrum, params)
%PES Plot the photo-electros spectrum.
%
%   Input: 
%     spectrum: the output of extract.pes
%       It is a 3D matrix, whose 3rd dimension is determined by lmax.
%       The size of the first dimension is determined by nradial.
%       The second dimension consists of:
%         E (Re,Im), Wgt (Re,Im), <I|W> (Re,Im), <W|I> (Re,Im)
%     params: parameters from the output file


  hold on;
  
  for l = 0:params.lmax
    indices = scid.util.d3index(params, l, ...
      max(-l, params.mmin)):scid.util.d3index(params, l, min(l, params.mmax));
    
    p1 = plot(real(spectrum(:,1,indices(1))), sum(real(spectrum(:,2,indices)),3));
    p1.LineStyle = '-';
    p1.LineWidth = 1.5;
  end

  hold off
  

  xlabel('Energy [a.u.]');
  
  grid on;
  xlim([0,2]);
  
  legend(num2cell(num2str((0:params.lmax)'),2), 'location', 'eastoutside');
  
end
