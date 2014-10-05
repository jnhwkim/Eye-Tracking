function [datum] = pb_read_Datum(buffer, buffer_start, buffer_end)
%pb_read_Datum Reads the protobuf message Datum.
%   function [datum] = pb_read_Datum(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     channels       : optional int32, defaults to int32(0).
%     height         : optional int32, defaults to int32(0).
%     width          : optional int32, defaults to int32(0).
%     data           : optional uint8 vector, defaults to uint8('').
%     label          : optional int32, defaults to int32(0).
%     float_data     : repeated single, defaults to single([]).
  
  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end
  
  descriptor = pb_descriptor_Datum();
  datum = pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  datum.descriptor_function = @pb_descriptor_Datum;
