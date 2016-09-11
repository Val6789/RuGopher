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
	def list_raw(path, query = "")
		socket = TCPSocket.open(@server, @port)
		if query.empty? then
			socket.print(path + "\n")
		else
			socket.print(path + "\t" + query + "\n")
		end
		response = socket.read
		
		return response
	end
	
	# Get the parsed file list
	def list(path, query = "")
		response = list_raw(path, query)
		
		lines = response.split "\n"
		
		# Handle the final dot if it is there
		if lines[-1].strip == "." then
			lines = lines[0..-2]
		end
		
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
	
	# Get a file
	def get(path)
		socket = TCPSocket.open(@server, @port)
		socket.print(path + "\n")
		response = socket.read
		
		return response
	end
	
	# Download to disk
	def download(path, destination)
		data = get(path)
		
		File.open(destination, "wb") { |file| file.write(data) }
	end
end
