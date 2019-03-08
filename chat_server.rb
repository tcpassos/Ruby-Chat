require "socket"

class String
    def black;          "\e[30m#{self}\e[0m" end
    def red;            "\e[31m#{self}\e[0m" end
    def green;          "\e[32m#{self}\e[0m" end
    def brown;          "\e[33m#{self}\e[0m" end
    def blue;           "\e[34m#{self}\e[0m" end
    def magenta;        "\e[35m#{self}\e[0m" end
    def cyan;           "\e[36m#{self}\e[0m" end
    def gray;           "\e[37m#{self}\e[0m" end
end

class Server
    def initialize( port, ip )
        @server = TCPServer.open( port, ip )
        @connections = Hash.new
        @rooms = Hash.new
        @clients = Hash.new
        @connections[:server] = @server
        @connections[:rooms] = @rooms
        @connections[:clients] = @clients

        puts "SERVIDOR: Ativo em #{ip}:#{port}"
        run
    end
    
    def run
        loop {
            # Clients thread
            Thread.start(@server.accept) do |client|
                username = client.gets.chomp.to_sym
                # Iterates in connections array and checks if the username already exists
                @connections[:clients].each do |other_username, other_client|
                    if username == other_username || client == other_client
                        client.puts "O usuario ja existe".red
                        Thread.kill self
                    end
                end
                
                puts "#{username} #{client}".red
                @connections[:clients][username] = client
                client.puts "SERVIDOR: Conectado como #{username}.\n".red

                listen_messages(username, client)
            end
        }.join
    end
    
    def listen_messages(username, client)
        loop {
            msg = client.gets.chomp
            @connections[:clients].each do |other_username, other_client|
                # Sends the message to the other client
                unless other_username == username
                    other_client.puts "#{username.to_s}: #{msg}".blue
                end
            end
        }
    end
end

# Server setup
server = Server.new("localhost", 6660)
