function response=query(object,varargin)

response=communicate(object,varargin{:});
response=extractAfter(response,' ');

end