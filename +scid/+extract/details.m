function [microtime, vp3d, dipole, acc, vel] = details(outputfile)
%DETAILS Extract the information in the details file
%and save it in a .mat file next to the original file.
%Furthermore, return the extracted information.
%
%   Input:
%     outputfile
%   Output:
%     [microtime, vector potential (x,y,z), dipole (x,y,z),
%      acceleration (x,y,z), velocity (x,y,z)]


  [path, name, ~] = fileparts(outputfile);
  matfile = fullfile(path, [name, '.mat']);

  if exist(matfile, 'file')
    load(matfile, 'microtime', 'vp3d', 'dipole', 'acc', 'vel');

    if exist('microtime', 'var')
      return;
    end
  end

  % load the parameters
  params = scid.extract.params(outputfile);


  f = fopen(fullfile(path, 'details.out'));

  line = upper(fgetl(f));
  while (line(1) == '#')
    line = upper(fgetl(f));
  end


  no_output_lines = round(params.simlength / params.dt);

  microtime = zeros(no_output_lines, 1);
  vp3d = zeros(no_output_lines, 3);
  dipole = complex(zeros(no_output_lines, 3));
  acc = complex(zeros(no_output_lines, 3));
  vel = complex(zeros(no_output_lines, 3));


  formatSpec = '%*f %f %f %f %f %*f %*f %*f %*f %*f %*f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f %f';

  for i = 1:no_output_lines

    a = sscanf(line, formatSpec);

    % time, vector potential, dipole, acceleration, velocity
    microtime(i) = a(1);
    vp3d(i,:) = [a(2)*sin(a(3))*cos(a(4)), a(2)*sin(a(3))*sin(a(4)), a(2)*cos(a(3))];
    dipole(i,:) = [a(5)+1i*a(6), a(7)+1i*a(8), a(9)+1i*a(10)];
    acc(i,:) = [a(11)+1i*a(12), a(13)+1i*a(14), a(15)+1i*a(16)];
    vel(i,:) = [a(17)+1i*a(18), a(19)+1i*a(20), a(21)+1i*a(22)];

    line = upper(fgetl(f));
  end


  if exist(matfile, 'file')
    save(matfile, 'microtime', 'vp3d', 'dipole', 'acc', 'vel', '-append');
  else
    save(matfile, 'microtime', 'vp3d', 'dipole', 'acc', 'vel');
  end


end
