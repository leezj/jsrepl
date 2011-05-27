# TODO(max99x): Stop faking state and actually make it into a REPL.
# TODO(max99x): Implement standard library functions:
#   http://www.jgsee.kmutt.ac.th/exell/PracMath/IntrodQB.htm
#   http://www.qbasicstation.com/index.php?c=t_adv
#   http://www.uv.tietgen.dk/staff/mlha/pc/prog/bas/dos/qbasic/statement/index.htm

class JSREPL::Engines::QBasic
  constructor: (input_func, output_func, result_func, error_func, @sandbox, ready) ->
    # An interface to the QBasic VM.
    @virtual_machine = new @sandbox.QBasic.VirtualMachine {
      print: (str) =>
        if @output_history_index < @output_history.length
          console.assert @output_history[@output_history_index] == str
        else
          @output_history.push str
          output_func str
        @output_history_index++
      input: (callback) =>
        if @input_history_index < @input_history.length
          @input_history_index++
          callback @input_history[@input_history_index - 1]
        else
          @input_history_index++
          input_func (data) =>
            @input_history.push data
            callback data
    }
    @virtual_machine.INTERVAL_MS = 0
    @virtual_machine.instructionsPerInterval = 8192
    #@virtual_machine.debug = 1

    # Callbacks.
    @result_callback = result_func
    @error_callback = error_func

    # A history used to fake state.
    @command_history = []
    @input_history = []
    @input_history_index = 0
    @output_history = []
    @output_history_index = 0

    ready()

  Destroy: ->
    # Should be garbage collected?
    delete @virtual_machine

  Eval: (command) ->
    @input_history_index = @output_history_index = 0
    @command_history.push command
    try
      program = new @sandbox.QBasic.Program @command_history.join '\n'
      @virtual_machine.run program, false, => @result_callback ''
    catch e
      @command_history.pop()
      @error_callback e.message

  Highlight: (element) ->
    # TODO(max99x): Implement.
    console.log 'Highlighting of QBasic code not yet implemented.'
