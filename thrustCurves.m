function [curve1, curve2] = thrustCurves(file1, file2, t_offset)

    % Default offset to 0 if not provided
    if nargin < 3
        t_offset = 0;
    end

    data1 = readmatrix(file1, ...
        "FileType", "text", ...
        "NumHeaderLines", 2);

    data1 = data1(~any(isnan(data1),2), :);
    curve1 = [data1(:,1) data1(:,2)];

    % Prepend t=0 row with zero thrust
    if curve1(1,1) ~= 0
        curve1 = [[0, 0]; curve1];
    end


    data2 = readmatrix(file2, ...
        "FileType", "text", ...
        "NumHeaderLines", 2);

    data2 = data2(~any(isnan(data2),2), :);
    curve2 = [data2(:,1) data2(:,2)];

    % Shift sustainer timestamps by the offset
    curve2(:,1) = curve2(:,1) + t_offset;

    % Prepend a zero-thrust row just before ignition
    curve2 = [[t_offset, 0]; curve2];

end