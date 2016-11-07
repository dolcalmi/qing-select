
class HtmlSelect extends QingModule

  @opts:
    el: null

  _setOptions: (opts) ->
    super
    $.extend @opts, HtmlSelect.opts, opts

  _init: ->
    @el = $ @opts.el

  getOptions: ->
    options = []
    @el.find('option').each (i, optionEl) =>
      $option = $ optionEl
      return unless (value = $option.val()) && !$option.is(':disabled')
      data = $option.data()
      data.selected = true if $option.is(':selected')
      data.group = $option.parent('optgroup').prop('label') if $option.parent('optgroup').length
      options.push [$option.text(), value, data]
    options

  selectOption: (option) ->
    $option = @el.find("option[value='#{option.value}']")
    unless $option.length > 0
      $option = @_renderOption(option).appendTo @el
    $option.prop 'selected', true
    @

  unselectOption: (option) ->
    $option = @el.find("option[value='#{option.value}']")
    $option.prop 'selected', false
    @

  _renderOption: (option) ->
    $ '<option>',
      text: option.name
      value: option.value
      data: option.data

  getValue: ->
    @el.val()

  setValue: (value) ->
    @el.val value
    @

  getBlankOption: ->
    $blankOption = @el.find('option:not([value]), option[value=""]')
    if $blankOption.length > 0 then $blankOption else null

module.exports = HtmlSelect
