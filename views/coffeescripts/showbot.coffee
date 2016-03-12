
jQuery(document).ready(->
  init_cluster_arrow_handler($('tr.cluster-top').children('td.title'))

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

connect_to_socket = ->
  SOCKET_PATH = '/socket'
  document.ws = new WebSocket('ws://' + window.location.host + SOCKET_PATH)
  ws = document.ws
  ws.onopen = -> $('span.live-indicator').show()
  ws.onclose = -> $('span.live-indicator').hide()
  ws.onmessage = (raw_msg) ->
    $seg_ctrl = $('ul.segmented_controls > li.selected')
    if $seg_ctrl.length == 0
      # No titles for *any* show are available, reload the page
      # so we get a first entry.
      location.reload()
    else
      view_mode = $seg_ctrl.attr('id')

    msg = JSON.parse(raw_msg.data)
    if !msg.action?
      console.log('Got bad message, missing action')
      return

    # TODO: Need to address the case where a new title is added and it's
    # associated with a show that isn't already live.
    dispatcher =
      table:
        upvote: (msg)->
          link_sel =
            "tr[data-suggestion-id='" + msg.suggestion_id + "'] a.vote_up"
          $link = $(link_sel)
          $vote_count = $link.siblings('.vote_count').first()
          update_votes(msg, $link, $vote_count)
          force_resort($link.parents('table'))
        new_title: add_title_to_table
      bubble:
        upvote: (msg) ->
          link_sel =
            "ol a[data-id='" + msg.suggestion_id + "'].vote_up"
          $link = $(link_sel)
          $vote_count = $link.siblings('.vote_count').first()
          update_votes(msg, $link, $vote_count)
        new_title: add_title_to_bubble
      clusters:
        upvote: (msg) ->
          $tr = $('tr[data-sg-id="' + msg.suggestion_id + '"]')
          $tr.find('td.votes span.vote_count').text(msg.votes)

          if !msg.cluster_id # suggestion does not belong to a cluster
            $tr.find('td.cluster-votes').text(msg.cluster_votes)
          else
            # Update total cluster count
            $toptr = $('#cluster-' + msg.cluster_id)
            $toptr.find('td.cluster-votes').text(msg.cluster_votes)

            # If the suggestion isn't already at the top of the cluster, and another
            # title has overtaken its count as the top suggestion, we need to rebuild
            # the cluster
            is_sugg_already_top = msg.suggestion_id == $toptr.data('sg-id')
            top_vote_count = $toptr.find('span.vote_count').text()
            should_rebuild_cluster = msg.votes > top_vote_count

            if !is_sugg_already_top && should_rebuild_cluster
              rebuild_cluster(msg, $toptr)
        new_title: add_title_to_cluster

    # Dispatch message to handlers
    try
      dispatcher[view_mode][msg.action](msg)
    catch err
      # Deliberately avoiding a rethrow here since a bad msg is not a critical failure
      console.log('ERROR: Something went wrong during socket msg dispatch.')
      console.log(err)
      console.log(raw_msg)
      console.log('Check view mode and make sure action is registered with dispatcher.')

############################################################
# Message Handlers
############################################################

update_votes = (response) ->
  if arguments.length == 3
    # Upvote originated locally
    $link = arguments[1]
    $vote_count = arguments[2]
  else
    # Live update branch

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

add_title_to_table = (msg) ->
  tbody_sel =
    ".suggestions_table[data-show-slug='" + msg.show_slug + "'] tbody"
  $tbody = $(tbody_sel)
  if $tbody.length == 0
    # Even if the seg controls are found, it's still possible this is
    # the first suggestion for a new show, in which case force reload.
    location.reload()
  else
    $tbody.append(msg.trl)
    refresh_timeago()
    increment_title_counts()
    force_resort($tbody.closest('table'))

add_title_to_bubble = (msg) ->
  $ol = $("#titles ol[data-show-slug='"+ msg.show_slug + "']")
  if $ol.length == 0
    location.reload()

  # Reclear list given newly prepended bubble
  $ol.prepend(msg.bubble_live)
  $ol.children('li').detach().each((idx, li) ->
    if idx != 0 and idx % 3 == 0
      $ol.append('<div class="clear"></div>')
    $ol.append(li)
  )
  refresh_timeago()

add_title_to_cluster = (msg) ->
  if msg.cluster.id # New title belongs to an existing cluster
    if msg.cluster.new_cluster
      # Suggestions added to the list that aren't already part of a cluster will be
      # missing any cluster data (naturally, since they aren't already part of a cluster)
      # Server provides that suggestions ID so we can identify this scenario and hot swap
      # that suggestion with the new cluster render
      osg_sel = 'tr[data-sg-id="' + msg.cluster.new_cluster.orig_sg_id + '"]'
      $(osg_sel).replaceWith(msg.cluster.render)
      init_cluster_arrow_handler(
        $('tr.cluster-top#cluster-' + msg.cluster.id).children('td.title'))
    else
      # If this is not a new cluster, we should be able to find the existing one based on meta
      # TODO: Respect sort order?
      old_tr_sel = "tr#cluster-" + msg.cluster.id + ",tr.child-cluster-" + msg.cluster.id
      $old_tr = $(old_tr_sel)

      # Examine current expansion state and prep render so we don't close it if already open
      expansion_state = $old_tr.attr('data-expansion-state')
      $render = $($.parseHTML(msg.cluster.render))
      if expansion_state == 'open'
        $render.filter('.cluster-top').attr('data-expansion-state', 'open')
        $render.find('.cluster-arrow').toggleClass('expanded-arrow')
        $render.filter('.child-cluster-' + msg.cluster.id).css('display', 'table-row')

      $parent = $old_tr.parent()
      $(old_tr_sel).remove()

      $parent.prepend($render)
      init_cluster_arrow_handler(
        $('tr.cluster-top#cluster-' + msg.cluster.id).children('td.title'))
  else
    $('.suggestions_table tbody').append(msg.cluster.render)

  increment_title_counts()

############################################################
# Helpers
############################################################

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

increment_title_counts = ->
  is_cluster_mode = $('.view_mode #clusters').hasClass('selected')

  increment_title = ($el) ->
    title_count_rgx = /(\d+)( Title.*)$/

    $el.each((idx, el) ->
      match = title_count_rgx.exec($(el).text())
      match[1] = parseInt(match[1]) + 1
      $el.text(match[1] + match[2])
    )

  increment_title($('#content h2.subtitle'))
  if is_cluster_mode
    update_cluster_title_count()
  else
    increment_title($('#titles .suggestions_table .total'))

refresh_timeago = ->
  $("abbr.timeago").timeago().show().timeago().tipsy(
    gravity: 'w'
    fade: true
  )

init_cluster_arrow_handler = ($titles)->
  $titles
    .attr('title', 'Click to expand/collapse')
    .click(->
      $tr = $(this).parent()
      $tr.siblings('.child-'+this.parentElement.id).toggle()
      $(this).find('.cluster-arrow').toggleClass('expanded-arrow')
      if $tr.attr('data-expansion-state') == 'closed'
        new_state = 'open'
      else
        new_state = 'closed'
      $tr.attr('data-expansion-state', new_state)
    )

update_cluster_title_count = ->
  group_count = $('tr.cluster-top, tr[data-sg-id]').length
  title_count = $('tbody tr').length

  count_str = if title_count == 1
  then title_count + ' Title'
  else title_count + ' Titles'

  count_str += ' in ' + group_count + ' Group'

  $('.suggestions_table .total').text(count_str)

rebuild_cluster = (msg, $toptr) ->
  child_sel = '.child-cluster-' + msg.cluster_id + '[data-sg-id="' + msg.suggestion_id + '"]'
  $childtr = $(child_sel)

  ############################################################
  # SWAP OUT ROWS
  # In practice, we're just swapping the relevant data.
  # No need to reconstruct the table itself
  ############################################################
  # Suggestion ids
  top_tr_id = $toptr.data('sg-id')
  $toptr.data('sg-id', $childtr.data('sg-id'))
  $childtr.data('sg-id', top_tr_id)

  # Votes
  $childtr.find('td span.vote_count').text($toptr.find('td span.vote_count').text())
  $toptr.find('td span.vote_count').text(msg.votes)

  # Titles
  tmp_title = $toptr.find('td.title').text().trim()
  $toptr.find('td.title').text($childtr.find('td.title').text().trim())
  $childtr.find('td.title').text(tmp_title)

  # User
  tmp_user = $toptr.find('td.user').text().trim()
  $toptr.find('td.user').text($childtr.find('td.user').text().trim())
  $childtr.find('td.user').text(tmp_user)

  # Time contents
  top_time_contents = $toptr.find('td.time abbr.timeago').detach()
  child_time_contents = $childtr.find('td.time abbr.timeago').detach()
  $toptr.find('td.time').append(child_time_contents)
  $childtr.find('td.time').append(top_time_contents)
  ############################################################
