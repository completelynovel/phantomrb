class PhantomRb
  PHANTOM_MARKER_START = '### PHANTOMRB_JSON_MARKER::START ###'
  PHANTOM_MARKER_END   = '### PHANTOMRB_JSON_MARKER::END ###'

  # The agrument passed by the ruby
  ARGS = {}
  try
    ARGS = JSON.parse(phantom.args)
  catch error
    ARGS = {}

  # Retrieve a argument
  @arg = (key) ->
    ARGS[key]

  # Either
  #   <<exit_status>>, <<return_json>>
  # Or not specifying an exit status will exit with status 0 (success)
  #  <<return_json>>
  @exit = (args...) ->
    ret_json = {}
    if args.length < 2
      status  = 0
      ret_obj = args[0]
    else
      status  = args[0]
      ret_obj = args[1]

    # Stringify it for transport over stdout
    ret_str = JSON.stringify(ret_obj)

    console.log """
    #{PHANTOM_MARKER_START}
    #{ret_str}
    #{PHANTOM_MARKER_END}
    """
    phantom.exit(status)

  # Helper function
  @functionArgs = (args, f) ->
    # Awkward bit
    args = JSON.stringify(args)
    fStr = """
      function(args) {
        return #{f.toString()}(#{args});
      }
    """

window.PhantomRb = PhantomRb
