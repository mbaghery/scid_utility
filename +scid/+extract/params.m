function parameters = params(outputfile)
%PARAMS Extract the parameter values from the output file
%and save them in a .mat file next to the output file.
%Furthermore, return the values.
%
%   Input:
%     outputfile
%   Output:
%     A struct with the following fields:
%       nradial, dr, lmax, pulseshape, A0, omega, phase, fwhm, midlaser, ...
%       A0_x, omega_x, phase_x, fwhm_x, midlaser_x, no of timesteps, simlength



  [path,name,~] = fileparts(outputfile);
  matfile = fullfile(path, [name, '.mat']);
  
  if exist(matfile, 'file')
    load(matfile, 'parameters');
    
    if exist('parameters', 'var')
      return;
    end
  end


  
  f = fopen(outputfile);
  
  while ~feof(f)
    line = fgetl(f);
    lineUpper = upper(line);
    
    if contains(lineUpper, ' SD_NRADIAL ')
      parameters.nradial = sscanf(lineUpper, '%*s = %f');
    elseif contains(lineUpper, ' SD_RGRID_DR ')
      parameters.dr = sscanf(lineUpper, '%*s = %f');
    elseif contains(lineUpper, ' SD_LMAX ')
      parameters.lmax = sscanf(lineUpper, '%*s = %d');
    elseif contains(lineUpper, ' SD_MMAX ')
      parameters.mmax = sscanf(lineUpper, '%*s = %d');
    elseif contains(lineUpper, ' SD_MMIN ')
      parameters.mmin = sscanf(lineUpper, '%*s = %d');
    elseif contains(lineUpper, ' VP_SHAPE ')
      lineUpper = strrep(lineUpper, '=', ' ');
      lineUpper = strrep(lineUpper, ' VP_SHAPE', ' ');
      parameters.pulseshape = strtrim(lineUpper);
    elseif contains(lineUpper, ' VP_SCALE ')
      parameters.A0 = sscanf(lineUpper, '%*s = %f');
    elseif contains(lineUpper, ' VP_PARAM ')
      lineUpper = strrep(lineUpper, ',', ' ');
      lineUpper = correctFortran(lineUpper);
      
      a = sscanf(lineUpper, '%*s = %f %f %f %f');
      
      parameters.omega = a(1);
      parameters.phase = a(2);
      parameters.midlaser = a(3);
      parameters.fwhm = a(4);
    elseif contains(lineUpper, ' VP_SCALE_X ')
      parameters.A0_x = sscanf(lineUpper, '%*s = %f');
    elseif contains(lineUpper, ' VP_PARAM_X ')
      lineUpper = strrep(lineUpper, ',', ' ');
      lineUpper = correctFortran(lineUpper);
      
      a = sscanf(lineUpper, '%*s = %f %f %f %f');
      
      parameters.omega_x = a(1);
      parameters.phase_x = a(2);
      parameters.midlaser_x = a(3);
      parameters.fwhm_x = a(4);
    elseif contains(lineUpper, ' DT ')
      parameters.dt = sscanf(lineUpper, '%*s = %f');
    elseif contains(lineUpper, ' OUTPUT_EACH ')
      parameters.output_each = sscanf(lineUpper, '%*s = %f');
    elseif contains(lineUpper, ' TIMESTEPS ')
      parameters.simlength = sscanf(lineUpper, '%*s = %f') * parameters.dt;
    elseif contains(lineUpper, ' FINAL_WF_DUMP_PREFIX ')
      parameters.final_wf_prefix = sscanf(line, '%*s = %s');
    elseif contains(lineUpper, 'END SIMULATION PARAMETERS')
      break;
    end
  end
  
  fclose(f);

  
  if exist(matfile, 'file')
    save(matfile, 'parameters', '-append');
  else
    save(matfile, 'parameters');
  end


  
  function text = correctFortran(text)
    
    text = [text, '  '];

    k = strfind(text, '*');

    while ~isempty(k)
      j = k(1);
      text(j) = ' ';

      c_index = j + find(text(j+1:end) == ' ', 1, 'first');
      b_index = find(text(1:j-1) == ' ', 1, 'last');

      c = str2double(text(j+1:c_index));
      b = str2double(text(b_index:j-1));

      b_matrix = c * ones(1, b-1);

      text = [text(1:b_index), num2str(b_matrix), text(j:end)];

      k = strfind(text, '*');
    end

  end

  
end

