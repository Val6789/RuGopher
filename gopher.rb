require 'socket'

# Example usage
# z = Gopher.new("gopher.quux.org")
# puts z.list "/"

class Gopher
	def initialize(server, port = 70)
		@server = server
		@port = port
	end
	
	# Returns the raw output from a Gopher request
	def list_raw(path)
		socket = TCPSocket.open(@server, @port)
		socket.print(path + "\n")
		response = socket.read
		
		return response
	end
	
	def list(path)
		response = list_raw(path)
		
		lines = response.split "\n"
		# TODO handle final dot
		
		result = Array.new lines.size
		lines.each.with_index do |line, i|
			type = line[0]
			splitted = line.split "\t"
			splitted[0] = splitted[0][1..-1] # Remove the item type character
			
			result[i] = {
				:type => type,
				:description => splitted[0],
				:path => splitted[1],
				:host => splitted[2],
				:port => splitted[3].to_i
			}
		end
		
		return result
	end
	
	def get(path)
		socket = TCPSocket.open(@server, @port)
		socket.print(path + "\n")
		response = socket.read
		
		return response
	end
	
	# Download to disk
	def download(path, destination)
		data = get(path)
		
		# TODO
	end
end
