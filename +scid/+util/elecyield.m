function ionisation = elecyield(spectrum, params)
%ELECYIELD Calculate the amount of ionized electron
%
%   Input:
%     spectrum: the output of extract.pes
%     params: the parameters from the output file
%   Output:
%     ionisation: the level of ionisation
%     The output should be a real number, but because of the left-right wave
%     functions in SCID there is always an imaginary part which should be small.
%     If the imaginary part is not small then the simulation should be re-run
%     with a bigger box, or smaller dr.
  
  
  bound_population = 0;
  
  for i = 1:scid.util.d3index(params)
    bound_population = bound_population + ...
      sum(spectrum(real(spectrum(:,1,i)) < 0,2,i), 1);
  end
  
  ionisation = 1 - bound_population;

end

