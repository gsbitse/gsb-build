// ==UserScript==
// @name       Parse Build Issues
// @namespace  http://stanfordgsb.jira.com/
// @version    0.1
// @description  Shows notes for release builds
// @match      https://stanfordgsb.jira.com/*
// @copyright  2014+, GSB
// ==/UserScript==

(function($) {
  $(document).ready(function() {
    $('body').bind('DOMSubtreeModified.event1', modified);
  });
  
  function modified() {
    $(this).unbind('DOMSubtreeModified.event1');
    setTimeout(function(){
      addNotes();
      $('body').bind('DOMSubtreeModified.event1',modified);
    },1000);
  }
  
  function addNotes() {    
    if ($('h1.search-title').text() == 'Ready For Release') {
      if(!$('div#notes-area').length) {
      	$notesContainer = $('<div id="notes-container"></div>');
        $startLink = $('<button id="notes-start-link">Show Notes</button>');
        $notesContainer.prepend($startLink);
        $notesArea = $('<div id="notes-area"></div>');
        $notesContainer.append($notesArea);
        $('div.navigator-group').prepend($notesContainer);
        $notesArea.hide();
        
        var status = 'hidden';
        $startLink.click(function(e) {
          e.preventDefault();
          if (status == 'hidden') {
            issues = {};
            $('#issuetable tbody tr').each(function(index, item) {
              $issueLink = $(item).find('td.summary a.issue-link:not(.parentIssue)');
              var issue = {};
              issue.number = $issueLink.data('issue-key');
              issue.link = 'https://stanfordgsb.jira.com' + $issueLink.attr('href');
              issue.text = $issueLink.text();
              issue.owner = $(this).find('td.assignee a').text();
              issues[issue.owner] = issues[issue.owner] || {};
              issues[issue.owner][index] = issue;
            });
            var html = '<ul>';
            for (assignee in issues) {
              html += '<li>' + assignee + '<ul>';
              for (index in issues[assignee]) {
                issue = issues[assignee][index];
                html += '<li><a href="' + issue.link + '">' + issue.number + ': ' + issue.text + '</a></li>'
              }
              
              html += '</ul></li>';
            }
            html += '</ul><br />';
            
            $notesArea.html(html);
            $notesArea.show('slow');
            $startLink.text('Hide Notes');
            status = 'shown';
          }
          else {
            $notesArea.hide('slow');
            $startLink.text('Show Notes');
            status = 'hidden';
          }
        });
      }
    }
    else {
      $('div#notes-container').empty();
    }
  }
})(jQuery);
