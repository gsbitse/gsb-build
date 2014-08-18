// ==UserScript==
// @name       Parse Build Issues
// @namespace  http://stanfordgsb.jira.com/
// @version    0.1
// @description  enter something useful
// @match      https://stanfordgsb.jira.com/*
// @copyright  2012+, You
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
    if (!$('#notes-container').length) {
      $notesContainer = $('<div id="notes-container"></div>');
      $('body').prepend($notesContainer);
    }
    
    if ($('h1.search-title').text() == 'Ready For Release') {
      if(!$('p#notes-area').length) {
        $startLink = $('<a id="notes-start-link" href="#">Get Notes</a>');
        $('#notes-container').prepend($startLink);
        $notesArea = $('<p id="notes-area"></p>');
        $startLink.after($notesArea);
        
        $startLink.click(function() {
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
        });
      }
    }
    else {
      $('div#notes-container').empty();
    }
  }
})(jQuery);
