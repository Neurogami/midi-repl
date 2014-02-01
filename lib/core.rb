warn "Loading #{__FILE__}"

require 'yaml'
require 'pp'
Thread.abort_on_exception = true

# Ubuntu: May have to call
#     sudo modprobe snd-virmidi
#
# and then adjust Renoise or whatever is sending midi
#   http://jorgan.999862.n4.nabble.com/Virmidi-in-Ubuntu-td3439207.html
#

# http://tx81z.blogspot.com/2011/06/high-level-midi-io-with-ruby.html
require 'unimidi'
require 'midi-eye'
require 'midi-message'

include MIDIMessage

#require 'utils'
require "readline"

module Neurogami
  module MidiRepl

    class Core
#      include Utils

      DEFAULT_CONFIG = '.midi-config.yaml'

      def self.help
        puts "\tUsage:"
        puts "\tWhen run with no arguments the program expects to find the config file #{DEFAULT_CONFIG} in the current directory."
        puts "\tWhen run with an argument the program expects that you have given it the complete path to a config file."
        puts "\tThe config file must be a YAML file "
        puts "\t\t:device: <the MIDI device index>"
        puts "\t\t:initial_messages: Some preloaded messages"
        puts "\n\t Enjoy!"
      end

      def initialize config_file_path=nil,  initial_messages=nil

        config_file = config_file_path || Dir.pwd + '/' + DEFAULT_CONFIG 
        @config = load_config config_file 

        unless @config
          warn '*'*80
          warn "\tCannot get configuration data, so we're out of here.\n\tCheck your config file and try again."
          warn '*'*80
          exit
        end

        warn "@config  #{@config }"

        if @config[:initial_messages]
          warn "@config[:initial_messages] = #{@config[:initial_messages].inspect}"
          initial_messages ||= []
          initial_messages.concat @config[:initial_messages].map{|m| "#{m},"}
        end

        if initial_messages 
          @initial_messages = initial_messages.join ' '
        end

        warn "@initial_messages : #{@initial_messages.inspect }"

        select = @config[:device].to_i > 0 ? @config[:device].to_i:  nil 
        @input = UniMIDI::Input.use :first

        @output = if select
                    UniMIDI::Output.use select-1
                  else
                    UniMIDI::Output.gets
                  end
      end

      def quit? s
        s.strip =~ /^(q|quit)$/i
      end

      def run
        quit = nil 
        ARGV.clear
        initial_message = nil

        # We allow the user to provide a set of message to prepopulate the REPL history
        if @initial_messages  
          warn "Set up initial messages in history ..."
          @initial_messages.split(',').reverse.each do |m|
            m.strip!
            p m
            Readline::HISTORY.push m 
            initial_message = m
          end
          puts "*** Use the arrow keys to pull up your pre-loaded messages. ***\n"
        end

        while buf = Readline.readline( "> ", !quit)
          print "-] ", buf, "\n"
          puts buf  
          message = buf.to_s.strip
          if quit? message
            puts "Received the 'quit' command.  See you later!"
            @output.close
            exit
          else
            send message unless message.empty?
          end
        end
      end

      def string_to_message s
        msg_parts = s.split /\s/
        case msg_parts.size
        when 3  # note on
          if msg_parts[0] =~ /^\d/
            NoteOn.new msg_parts[0].to_i, msg_parts[1].to_i, msg_parts[2].to_i
          else
            NoteOn.new msg_parts[0], msg_parts[1].to_i, msg_parts[2].to_i
          end
        when 2  # note off
          NoteOn.new msg_parts[0].to_i, msg_parts[1].to_i
        else
          raise "Must have either 2 or 3 note-message values"
        end
      end


      def send s
        warn "*** send has #{s.inspect}"

        message = string_to_message s 

        t = Thread.new do
          begin
            @output.puts message 
          rescue 
            warn '!'*80
            warn "Error sending MIDI message: #{$!}"
            warn '!'*80
          end
        end

        t.join
        sleep 0.02
      end


      def load_config config_file
        warn "Look for '#{config_file}' in #{Dir.pwd}"
        unless File.exist? config_file
          warn "Cannot find config file '#{config_file}'"
          return nil
        end
        begin 
          YAML.load_file config_file
        rescue
          warn "There was an exception loading config file '#{config_file}': #{$!}"
          return nil
        end
      end
    end
  end
end
