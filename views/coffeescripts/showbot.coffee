
jQuery(document).ready(->
  # Timeago and Tipsy
  refresh_timeago()

  # Modernizr
  if (Modernizr.touch)
    # Remove hover events for Touch devices since they screw up rendering
    $(".hover").removeClass("hover")

  # Show the heart since it starts off hidden
  $('.heart').show()

  # Table Sorting
  $("table.sortable").tablesorter(
    textExtraction: table_text_extraction
    sortList: [[0,1]]
  )

  setup_voting()
  connect_to_socket()
)

refresh_timeago = ->
  $("abbr.timeago").timeago().show().timeago().tipsy(
    gravity: 'w'
    fade: true
  )

force_resort = ($table)->
  ############################################################
  # HACK: We need to explicitly trigger a sort based on its current
  # state, but doing so immediately after calling an update results
  # in a race condition that can corrupt the sort of the table.
  # Sitting it behind a 10ms delay allows update to finish before
  # executing the sort, but this is obviously not ideal.
  #
  # Proper way to handle this:
  # update.then(sortFn) via `onUpdate` event, which afaik, does not
  # exist and needs to be hacked in to tablesorter.
  ############################################################
  $table.trigger('update')
  sortFn = -> $table.trigger('sorton', [$table[0].config.sortList])
  setTimeout(sortFn, 10) # Queue sort

# Extract text from cells that aren't normal
#
# Returns a String of text that represents the cell for sorting purposes.
table_text_extraction = (element) ->
  $element = $(element)
  text = $element.html()

  # If this is a date column, extract the text for sorting
  if $element.find('abbr').length
    text = $element.find('abbr').data('epoch-time')
  # Extract vote count value if this is a vote column
  # Note: This is also required for sorting to continue working via the
  #   trigger('update') after a vote is cast
  else if $element.find('.vote_count').length
    text = $element.find('.vote_count').html()

  text

setup_voting = ->
  $('a.vote_up').live('click', (e) ->
    e.preventDefault()
    $link = $(@)
    $vote_count = $link.siblings('.vote_count').first()

    # Do nothing if already marked as voted
    if $vote_count.hasClass('voted')
      return
    else
      $vote_count.addClass('voted')

    id = $link.data('id')

    $.get("/titles/#{id}/vote_up", (response) ->
      if response?
        $vote_arrow = $link.find('.vote_arrow')
        $vote_arrow.addClass('launch')
        # Wait for the launch animation to finish
        setTimeout(
          -> $vote_arrow.remove()
          800 # 0.2 seconds less than animation due to hide
        )

        update_votes(response, $link, $vote_count)

    , "json").error(->
      $vote_count.removeClass('voted')
      $vote_count.addClass('error')
    )
  )

add_title_to_table = (msg) ->
  tbody_sel =
    ".suggestions_table[data-show-slug='" + msg.show_slug + "'] tbody"
  $tbody = $(tbody_sel)
  if $tbody.length == 0
    # Expect to fail to find the table if this is the first tile.
    # Page reload should render out the table and the title that
    # triggered this update. Table should be found on subsequent
    # updates
    location.reload()
  else
    $tbody.append(msg.trl)
    refresh_timeago()
    increment_title_counts()
    force_resort($tbody.closest('table'))

update_votes = (response) ->
  if arguments.length == 3
    # Upvote originated locally
    $link = arguments[1]
    $vote_count = arguments[2]
  else
    # Live update branch
    link_sel =
      "tr[data-suggestion-id='" + response.suggestion_id + "'] a.vote_up"
    $link = $(link_sel)
    $vote_count = $link.siblings('.vote_count').first()

  vote_amount = parseInt(response.votes)
  if isNaN(vote_amount)
    $vote_count.addClass('error')
  else
    $vote_count.text(vote_amount)

  if response.cluster_top
    $link.closest('tr').children('.cluster-votes').text(response.cluster_votes)
  else
    $link.closest('tr')
      .siblings('#cluster-' + response.cluster_id)
      .children('.cluster-votes')
      .text(response.cluster_votes)

  force_resort($link.parents('table'))

increment_title_counts = ->
  increment_title = ($el) ->
    title_count_rgx = /(\d+)( Title.*)$/

    $el.each((idx, el) ->
      match = title_count_rgx.exec($(el).text())
      match[1] = parseInt(match[1]) + 1
      $el.text(match[1] + match[2])
    )

  increment_title($('#content h2.subtitle'))
  increment_title($('#titles .suggestions_table .total'))

connect_to_socket = ->
  SOCKET_PATH = '/socket'
  document.ws = new WebSocket('ws://' + window.location.host + SOCKET_PATH)
  ws = document.ws
  ws.onopen = -> console.log('Frontside ws cx open!')
  ws.onclose = -> console.log('Frontside ws cx closed!')
  ws.onmessage = (raw_msg) ->
    msg = JSON.parse(raw_msg.data)
    if !msg.action?
      console.log('Got bad message, missing action')
      return

    # Dispatch action
    if msg.action == 'upvote'
      update_votes(msg)
    else if msg.action == 'new_title'
      add_title_to_table(msg)
    else # Unknown action
      # Swallow? Not much the user can do here, we're in a bad state.
      # Could attempt to renegotiate cx, or reload page (nuclear option!)
      # Not expecting to hit this branch.
      console.log('Got bad message, unknown action')
