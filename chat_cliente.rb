require "socket"

class Client
    def initialize(server)
        @server   = server
        @request  = nil
        @response = nil
        send
        listen
        @request.join
        @response.join
    end
end

def send
    print "Usuario: "
    @request = Thread.new do
        loop {
            msg = $stdin.gets.chomp
            @server.puts(msg)
        }
    end
end

def listen
    @response = Thread.new do
        loop {
            msg = @server.gets.chomp
            puts "#{msg}"
        }
    end
end

server = TCPSocket.open("localhost", 6660)
client = Client.new(server)

