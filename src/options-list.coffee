
class OptionsList extends QingModule

  @opts:
    wrapper: null
    locales: null
    options: null
    optionRenderer: null
    totalOptionSize: null
    maxListSize: 0

  _setOptions: (opts) ->
    super
    $.extend @opts, OptionsList.opts, opts

  _init: ->
    @wrapper = $ @opts.wrapper
    return unless @wrapper.length > 0

    @highlighted = false
    @_render()
    @_bind()

  _render: ->
    @el = $ '<div class="options-list"></div>'
      .appendTo @wrapper

    if @opts.options
      @renderOptions @opts.options, @opts.totalOptionSize

  _bind: ->
    @el.on 'click', '.option', (e) =>
      $option = $ e.currentTarget
      @setHighlighted $option
      @trigger 'optionClick', [$option]
      null

  renderOptions: (options = [], totalOptionSize) ->
    options = options.slice 0, @opts.maxListSize
    @el.empty().css('min-height', 0)
    @highlighted = false

    if options.length > 0
      @_append(@_optionEl(option)) for option in options
      if totalOptionSize > options.length
        @_renderHiddenSize(totalOptionSize - options.length)
      @_lastRenderGroup = null
    else
      @_renderEmpty()

  _groupEl: (groupName) ->
    $("""
      <div class="optgroup">#{groupName}</div>
    """)

  _optionEl: (option) ->
    $optionEl = $("""
      <div class="option">
        <div class="left">
          <span class="name"></span>
        </div>
        <div class="right">
          <span class="hint"></span>
        </div>
      </div>
    """).data('option', option)
    $optionEl.find('.name').text(option.data.label || option.name)
    $optionEl.find('.hint').text(option.data.hint) if option.data.hint
    $optionEl.attr 'data-value', option.value
    $optionEl.data 'option', option

    @setHighlighted($optionEl) if option.selected

    if $.isFunction @opts.optionRenderer
      @opts.optionRenderer.call(@, $optionEl, option)

    $optionEl

  _append: (optionEl) ->
    $groupEl = null
    group = optionEl.data('option').data?.group
    return @el.append(optionEl) unless group

    if @_lastRenderGroup != group
      @_lastRenderGroup = group
      @el.append(@_groupEl(group))
    @el.append(optionEl)

  _renderEmpty: ->
    @el.append """
      <div class="no-options">#{@opts.locales.noOptions}</div>
    """

  _renderHiddenSize: (size) ->
    text = @opts.locales.hiddenSize.replace(/__size__/g, size)
    @el.append """
      <div class="hidden-size">#{text}</div>
    """

  setLoading: (loading) ->
    return if loading == @loading
    if loading
      setTimeout =>
        return unless @loading
        @el.addClass 'loading'
        @el.append """
          <div class="loading-message">#{@opts.locales.loading}</div>
        """
      , 500
    else
      @el.removeClass 'loading'
      @el.find('.loading').remove()

    @loading = loading
    @

  setHighlighted: (highlighted) ->
    unless typeof highlighted == 'object'
      highlighted = @el.find(".option[data-value='#{highlighted}']")

    return unless highlighted.length > 0

    @highlighted.removeClass('highlighted') if @highlighted
    @highlighted = highlighted.addClass('highlighted')
    @

  highlightNextOption: ->
    if @highlighted
      $nextOption = @highlighted.nextAll('.option:first')
    else
      $nextOption = @el.find('.option:first')

    @setHighlighted($nextOption) if $nextOption.length > 0

  highlightPrevOption: ->
    if @highlighted
      $prevOption = @highlighted.prevAll('.option:first')
    else
      $prevOption = @el.find('.option:first')

    @setHighlighted($prevOption) if $prevOption.length > 0

module.exports = OptionsList
