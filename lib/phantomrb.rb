require 'escape'
require 'open4'
require 'tempfile'
require 'json'

class PhantomRb

  # The return object wrapper
  class ReturnObj
    # The unix exit status of the phantom script
    attr_reader :exit_status

    def initialize(exit_status, json)
      @exit_status = exit_status
      @json        = json || {}
    end

    def method_missing(m, *args, &block)
      @json[m.to_s]
    end
  end

  PHANTOM_MARKER_START = '### PHANTOMRB_JSON_MARKER::START ###'
  PHANTOM_MARKER_END   = '### PHANTOMRB_JSON_MARKER::END ###'

  # Scripts included by default
  JS_MASTER_INCLUDES = ['js/phantomrb.coffee']

  # Initialize a script
  #  * filepath  - path to the script to run
  #  * x_display - display to run on (useful for virtual x servers)
  def initialize(filepath, x_display=nil)
    if !File.file?(filepath)
      throw "Script '#{filepath}' not found"
    end

    log "script: #{filepath}"
    @script_path = filepath
    @x_display   = x_display
  end


  # Simple logging method, either export `LIB_VERBOSE` in your environment or
  # run you script with `ruby -v` to enable logging
  def log(str)
    if $VERBOSE || ENV['LIB_VERBOSE']
      puts str
    end
  end


  # Run!
  def run(opts)
    log "running script: #{@script_path}"

    ret = nil
    build_script(@script_path) do |script_path|
      opts = opts.to_json

      # Escape the command
      cmd_opts = ["phantomjs", script_path]
      cmd_opts = cmd_opts << opts
      cmd      = Escape.shell_command(cmd_opts)

      # Set the virtual x-server if one is defined
      if @x_display
        cmd = "DISPLAY=':#{@x_display}' #{cmd}"
      end

      ret_obj = nil
      log "Running command:\n\t#{cmd}"
      status = Open4.popen4(cmd) do |pid, stdin, stdout, stderr|
        out = stdout.read
        err = stderr.read
        log "stderr: #{err}"
        log "stdout: #{out}"

        ret_str = get_range(out, PHANTOM_MARKER_START, PHANTOM_MARKER_END)

        if ret_str
          ret_obj = JSON.parse(ret_str)
        end
      end

      ret = ReturnObj.new(status.exitstatus, ret_obj)
    end
    ret
  end

  private
    # Returns text between 2 special markers (re_start/re_end) building a
    # multiline RegExp
    def get_range(text, regex_start, regex_end)
      re = /(#{regex_start})(.*?)(#{regex_end})/m
      match = text.match(re)
      if match
        return match[2].strip
      end
    end

    def js_master_includes
      includes = []
      JS_MASTER_INCLUDES.each do |js|
        base = File.dirname(__FILE__)
        path = File.join(base, js)
        abs_path = File.expand_path(path)
        includes << "phantom.injectJs('#{abs_path}')"
      end

      # Join by new lines
      includes.join("\n")
    end

    def build_script(script)
      log "building script #{script}"

      temp = Tempfile.new(['running_phantom_script', '.coffee'])

      # Add the base includes
      temp.puts js_master_includes

        # Add the script to be run
      temp.puts File.read(script)

      temp.rewind
      yield(temp.path)
      
      # Close
      temp.close
    end
end
