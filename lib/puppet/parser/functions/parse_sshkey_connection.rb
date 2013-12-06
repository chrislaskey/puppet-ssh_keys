module Puppet::Parser::Functions
  newfunction(:parse_sshkey_connection, :type => :rvalue) do |args|

	title = args[0]
	pieces = {}

	unless title.index(':') and title.index('@')
		return pieces
	end

	pieces["local_user"] = title[ 0 ... title.index(':') ]
	pieces["remote_user"] = title[ (title.index(':') + 1) ... title.index('@') ]
	pieces["remote_fqdn"] = title[ (title.index('@') + 1) .. -1 ]
	
	return pieces

  end
end
